# frozen_string_literal: true

require "io/console"

module Loupe
  # Pager
  #
  # This class is responsible for paginating the test failures,
  # and implementing an interface for interacting with them.
  class PagedReporter < Reporter # rubocop:disable Metrics/ClassLength
    # @return [void]
    def print_summary
      @current_page = 0
      @console = IO.console
      @runtime = Time.now - @start_time
      @running = true
      page
    end

    private

    # Main loop of the pager
    # Allow users to navigate through pages of test failures
    # and interact with them.
    # @return [void]
    def page
      while @running
        @current_failure = @failures[@current_page]
        @mid_width = @console.winsize[1] / 2
        header

        if @failures.empty?
          puts "All tests fixed"
          @running = false
        else
          file_preview
          menu
          handle_raw_command
        end
      end
    end

    # Read a raw command from the console and match it
    #
    # @return [void]
    def handle_raw_command # rubocop:disable Metrics/CyclomaticComplexity
      case @console.raw { |c| c.read(1) }
      when "j"
        @current_page += 1 unless @current_page == @failures.length - 1
      when "k"
        @current_page -= 1 unless @current_page.zero?
      when "o"
        open_editor
      when "f"
        @failures.delete_at(@current_page)
        @failure_count -= 1
        @success_count += 1
        @current_page -= 1 unless @current_page.zero?
      when "r"
        rerun_failure
      when "q"
        @running = false
      end
    end

    # Print the summary at the top of the screen.
    # This string has to be updated every time, since the statistics
    # might change if the user has marked tests as fixed
    # return [String]
    def summary
      <<~SUMMARY
        Tests: #{@test_count} Expectations: #{@expectation_count}
        Passed: #{@success_count} Failures: #{@failure_count}

        Finished in #{@runtime} seconds
      SUMMARY
    end

    # Prints a bar at the top with the summary of the test run
    # including totals failures and expectations
    # @return [void]
    def header
      @console.erase_screen(2)
      @console.cursor = [0, 0]
      bar = "=" * @console.winsize[1]
      puts "#{bar}\n#{summary}\n#{bar}\n"
    end

    # Print the preview of the file where a failure occurred
    # add a line indicating where exactly it broke
    # @return [void]
    def file_preview
      lines = File.readlines(@current_failure.file_name)

      lines.insert(
        @current_failure.line_number + 1,
        "#{indentation_on_failure_line(lines)}^^^ #{@current_failure.message.gsub(/(\[\d;\d{2}m|\[0m)/, '')}"
      )
      content = lines[@current_failure.line_number - 5..@current_failure.line_number + 5].join('\n')

      system("echo '#{content}' | " \
             " bat --force-colorization --language=rb" \
             " --paging=never --terminal-width=#{@mid_width - 1} --wrap character")
    end

    # The indentation on the line where the failure happened
    # so that the error message can be inserted at the right level
    # @param lines [Array<String>]
    # return [String]
    def indentation_on_failure_line(lines)
      " " * (lines[@current_failure.line_number].chars.index { |c| c != " " })
    end

    # @return [void]
    def menu
      location, message = @current_failure.location_and_message

      print_on_right_side(7, @status)
      print_on_right_side(9, location)
      print_on_right_side(10, message)

      print_on_right_side(12, "Commands")
      print_on_right_side(14, "j (next)")
      print_on_right_side(15, "k (previous)")
      print_on_right_side(16, "o (open in editor)")
      print_on_right_side(17, "f (mark as fixed)")
      print_on_right_side(18, "r (rerun selected test)")
      print_on_right_side(19, "q (quit)")

      @status = nil
    end

    # The first half of the screen is the file preview.
    # This helper method assists in printing things on the
    # other side of the screen.
    #
    # Always clear coloring afterwards
    #
    # return [void]
    def print_on_right_side(row, message)
      @console.cursor = [row, @mid_width + 1]
      available_length = @console.winsize[1] - @mid_width + 1
      print message.to_s[0, available_length]
      print "\033[0m"
    end

    # Open the editor selected by options (or defined by $EDITOR) with the current
    # failure being viewed.
    # @return [void]
    def open_editor
      editor = @options[:editor] || ENV["EDITOR"]
      executable = editor_executable(editor)

      case editor
      when "vim", "nvim"
        spawn "#{executable} +#{@current_failure.line_number} #{@current_failure.file_name}"
      when "code"
        spawn "#{executable} -g #{@current_failure.file_name}:#{@current_failure.line_number}"
      else
        spawn "#{executable} #{@current_failure.file_name}"
      end
    end

    # Attempt to find the editor's executable within
    # the given PATHs
    # @param editor [String]
    # @return [String]
    def editor_executable(editor)
      ENV["PATH"].split(":").each do |p|
        path = File.join(p, editor)
        return path if File.exist?(path)
      end
    end

    # Rerun the current failure
    #
    # Since the developer is changing the test file to fix it,
    # we need to unload it from LOADED_FEATURES and require it again.
    # Otherwise, we would just be re-running the same test loaded in memory
    # and it would never pass.
    #
    # @return void
    def rerun_failure
      $LOADED_FEATURES.delete(@current_failure.file_name)
      require @current_failure.file_name

      reporter = @current_failure.klass.run(@current_failure.test_name, @options)

      if reporter.failures.empty?
        @status = "#{@color.p('Fixed', :green)}. Click f to remove from list"
      else
        @failures[@current_page] = reporter.failures.first
        @status = @color.p("Still failing", :red)
      end
    end
  end
end
