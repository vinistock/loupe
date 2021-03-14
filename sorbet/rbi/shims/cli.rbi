# typed: true

module Ant
  class Cli < Thor
    sig { returns(T::Array[String]) }
    attr_reader :files

    sig { void }
    def test; end

    sig { params(_name: String).void }
    def self.handle_no_command_error(_name); end

    private

    sig { params(files: T::Array[String]).returns(T.any(T.nilable(T::Hash[String, T::Array[Integer]]), T::Array[String])) }
    def require_tests(files); end
  end
end
