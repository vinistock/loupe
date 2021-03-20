# typed: true

module Ant
  class Reporter
    sig { params(io: T.any(IO, StringIO)).void }
    def initialize(io = $stdout); end

    sig { void }
    def increment_test_count; end

    sig { void }
    def increment_assertion_count; end

    sig { void }
    def increment_success_count; end

    sig { params(file_name: String, test_name: String, line_number: Integer, message: String).void }
    def increment_failure_count(file_name, test_name, line_number, message); end

    sig { params(other: Reporter).returns(T.self_type) }
    def +(other); end

    sig { void }
    def print_summary; end

    sig { returns(Integer) }
    def exit_status; end
  end
end
