# typed: true

module Ant
  class Cli < Thor
    sig { params(files: T::Array[String]).void }
    def test(*files); end

    private

    sig { params(files: T::Array[T::Array[String]]).returns(T.any(T.nilable(T::Hash[String, T::Array[Integer]]), T::Array[String])) }
    def require_tests(files); end
  end
end
