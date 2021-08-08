# frozen_string_literal: true

require "io/console"

module Loupe
  # Pager
  #
  # This class is responsible for paginating the test failures,
  # and implementing an interface for interacting with them.
  class PagedReporter < Reporter
    # @return [void]
    def print_summary
      @current_page = 0
      @console = IO.console
      @summary = <<~SUMMARY
        Tests: #{@test_count} Expectations: #{@expectation_count}
        Passed: #{@success_count} Failures: #{@failure_count}

        Finished in #{Time.now - @start_time} seconds
      SUMMARY

      page
    end

    private

    # Main loop of the pager
    # Allow users to navigate through pages of test failures
    # and interact with them.
    # @return [void]
    def page # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
      loop do
        header

        if @failures.empty?
          puts "All tests passed"
          break
        end

        file_preview
        footer

        case @console.raw { |c| c.read(1) }
        when "j"
          @current_page += 1 unless @current_page == @failures.length - 1
        when "k"
          @current_page -= 1 unless @current_page.zero?
        when "o"
          open_editor
        when "f"
          @failures.delete_at(@current_page)
          @current_page -= 1 unless @current_page.zero?
        when "r"
          rerun_failure
        when "q"
          break
        end
      end
    end

    # Prints a bar at the top with the summary of the test run
    # including totals failures and expectations
    # @return [void]
    def header
      @console.erase_screen(1)
      @console.cursor = [0, 0]
      bar = "=" * @console.winsize[1]
      puts "#{bar}\n#{@summary}\n#{bar}\n"
    end

    # Print the preview of the file where a failure occurred
    # add a line indicating where exactly it broke
    # @return [void]
    def file_preview
      failure = @failures[@current_page]
      lines = File.readlines(failure.file_name)

      lines.insert(failure.line_number + 1,
                   "#{indentation_on_failure_line(lines)}^^^ #{failure.message.gsub(/(\[\d;\d{2}m|\[0m)/, '')}")
      content = lines[failure.line_number - 5..failure.line_number + 5].join('\n')
      system("echo '#{content}' | bat --force-colorization --language=rb --paging=never")
    end

    # The indentation on the line where the failure happened
    # so that the error message can be inserted at the right level
    # @param lines [Array<String>]
    # return [String]
    def indentation_on_failure_line(lines)
      " " * (lines[@failures[@current_page].line_number].chars.index { |c| c != " " })
    end

    # Print the failure message and usage instructions at the bottom
    # @return [void]
    def footer
      @console.cursor_down(5)
      puts @status
      puts @failures[@current_page]
      @console.cursor_down(2)
      puts "j (next) / k (previous) / o (open in editor) / f (mark as fixed) / r (rerun test) / q (quit)"
      @status = nil
    end

    # Open the editor selected by options (or defined by $EDITOR) with the current
    # failure being viewed.
    # @return [void]
    def open_editor
      editor = @options[:editor] || ENV["EDITOR"]
      executable = editor_executable(editor)

      case editor
      when "vim", "nvim"
        spawn "#{executable} +#{@failures[@current_page].line_number} #{@failures[@current_page].file_name}"
      when "code"
        spawn "#{executable} -g #{@failures[@current_page].file_name}:#{@failures[@current_page].line_number}"
      else
        spawn "#{executable} #{@failures[@current_page].file_name}"
      end
    end

    # Attempt to find the editor's executable within
    # the given PATHs
    # @param editor [String]
    # @return [String]
    def editor_executable(editor)
      ENV["PATH"].split(":").each do |p|
        path = File.join(p.delete("}").delete("{"), editor)
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
      failure = @failures[@current_page]
      $LOADED_FEATURES.delete(failure.file_name)
      require failure.file_name

      reporter = failure.klass.run(failure.test_name, @options)

      if reporter.failures.empty?
        @status = "#{@color.p('Fixed', :green)}. Click f to remove from list"
      else
        @failures[@current_page] = reporter.failures.first
        @status = @color.p("Still failing", :red)
      end
    end
  end
end
