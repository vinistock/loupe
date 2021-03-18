# typed: true

module Ant
  class TestCase
    sig { returns(T::Hash[T.untyped, T::Array[String]]) }
    def self.classes; end

    sig { params(test_class: T.untyped).void }
    def self.inherited(test_class); end

    sig { params(number: String).void }
    def self.add_line_number(number); end

    sig { params(line_numbers: T::Array[String], reporter: Reporter).returns(Reporter) }
    def self.run(line_numbers = [], reporter = Reporter.new); end

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

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def refute(actual, failure_message = nil); end

    sig { params(expected: T.untyped, actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert_equal(expected, actual, failure_message = nil); end

    sig { params(expected: T.untyped, actual: T.untyped, failure_message: T.nilable(String)).void }
    def refute_equal(expected, actual, failure_message = nil); end

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert_empty(actual, failure_message = nil); end

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def refute_empty(actual, failure_message = nil); end

    sig { params(object: T.untyped, method: T.any(String, Symbol), failure_message: T.nilable(String)).void }
    def assert_respond_to(object, method, failure_message = nil); end

    sig { params(object: T.untyped, method: T.any(String, Symbol), failure_message: T.nilable(String)).void }
    def refute_respond_to(object, method, failure_message = nil); end

    sig { params(collection: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def assert_includes(collection, object, failure_message = nil); end

    sig { params(collection: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def refute_includes(collection, object, failure_message = nil); end

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert_nil(actual, failure_message = nil); end

    sig { params(actual: T.untyped, failure_message: T.nilable(String)).void }
    def refute_nil(actual, failure_message = nil); end

    sig { params(klass: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def assert_instance_of(klass, object, failure_message = nil); end

    sig { params(klass: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def refute_instance_of(klass, object, failure_message = nil); end

    sig { params(klass: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def assert_kind_of(klass, object, failure_message = nil); end

    sig { params(klass: T.untyped, object: T.untyped, failure_message: T.nilable(String)).void }
    def refute_kind_of(klass, object, failure_message = nil); end

    sig { params(object: T.untyped, method: T.untyped, failure_message: T.nilable(String)).void }
    def assert_predicate(object, method, failure_message = nil); end

    sig { params(object: T.untyped, method: T.untyped, failure_message: T.nilable(String)).void }
    def refute_predicate(object, method, failure_message = nil); end

    sig { params(matcher: T.any(Regexp, String), object: T.untyped, failure_message: T.nilable(String)).void }
    def assert_match(matcher, object, failure_message = nil); end

    sig { params(matcher: T.any(Regexp, String), object: T.untyped, failure_message: T.nilable(String)).void }
    def refute_match(matcher, object, failure_message = nil); end

    sig { params(expected: T.untyped, actual: T.untyped, failure_message: T.nilable(String)).void }
    def assert_same(expected, actual, failure_message = nil); end

    sig { params(expected: T.untyped, actual: T.untyped, failure_message: T.nilable(String)).void }
    def refute_same(expected, actual, failure_message = nil); end

    sig { params(path: String, failure_message: T.nilable(String)).void }
    def assert_path_exists(path, failure_message = nil); end

    sig { params(path: String, failure_message: T.nilable(String)).void }
    def refute_path_exists(path, failure_message = nil); end

    sig do
      params(
        expected: T.untyped,
        actual: T.untyped,
        delta: T.any(Float, Integer),
        failure_message: T.nilable(String)
      ).void
    end
    def assert_in_delta(expected, actual, delta = 0.001, failure_message = nil); end

    sig do
      params(
        expected: T.untyped,
        actual: T.untyped,
        delta: T.any(Float, Integer),
        failure_message: T.nilable(String)
      ).void
    end
    def refute_in_delta(expected, actual, delta = 0.001, failure_message = nil); end

    sig do
      params(
        expected: T.untyped,
        actual: T.untyped,
        epsilon: T.any(Float, Integer),
        failure_message: T.nilable(String)
      ).void
    end
    def assert_in_epsilon(expected, actual, epsilon = 0.001, failure_message = nil); end

    sig do
      params(
        expected: T.untyped,
        actual: T.untyped,
        epsilon: T.any(Float, Integer),
        failure_message: T.nilable(String)
      ).void
    end
    def refute_in_epsilon(expected, actual, epsilon = 0.001, failure_message = nil); end

    sig do
      params(
        stdout: T.nilable(T.any(Regexp, String)),
        stderr: T.nilable(T.any(Regexp, String)),
        block: T.nilable(T.proc.bind(T.untyped).returns(T.untyped))
      ).void
    end
    def assert_output(stdout = nil, stderr = nil, &block); end

    sig do
      params(
        stdout: T.nilable(T.any(Regexp, String)),
        stderr: T.nilable(T.any(Regexp, String)),
        block: T.nilable(T.proc.bind(T.untyped).returns(T.untyped))
      ).void
    end
    def refute_output(stdout = nil, stderr = nil, &block); end

    sig { params(block: T.nilable(T.proc.bind(T.untyped).returns(T.untyped))).void }
    def assert_silent(&block); end

    sig { params(block: T.nilable(T.proc.bind(T.untyped).returns(T.untyped))).void }
    def refute_silent(&block); end
  end
end
