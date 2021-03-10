# typed: true

module Ant
  class TestCase
    sig { returns(T::Array[T.untyped]) }
    def self.classes; end

    sig { params(test_class: T.untyped).void }
    def self.inherited(test_class); end

    sig { returns(Reporter) }
    def self.run; end

    sig { params(reporter: Reporter, method_name: Symbol).returns(T.self_type) }
    def initialize(reporter, method_name); end

    sig { void }
    def setup; end

    sig { void }
    def teardown; end

    sig { void }
    def run; end

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert(actual, failure_message = nil); end

    sig { params(expected: T.untyped, actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert_equal(expected, actual, failure_message = nil); end
  end
end
