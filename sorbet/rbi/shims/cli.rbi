# typed: true

module Ant
  class Cli < Thor
    sig { params(files: T::Array[String]).void }
    def test(*files); end

    private

    sig { params(files: T::Array[T::Array[String]]).void }
    def require_tests(files); end
  end
end
