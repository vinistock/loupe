# Guava

Guava is an experimental test framework built with Ractors using [Minitest](https://github.com/seattlerb/minitest) inspired assertions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "guava"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install guava

## Usage

Because of current Ractor limitations, Guava implements only one syntax for writing tests: using methods prefixed with `test_`. The other common syntax of using the `test` method with a block is not supported.

Tests need to inherit from `Guava::Test`, like the example below.

```ruby
# frozen_string_literal: true

require "test_helper"

class MyTest < Guava::Test
  def setup
    @author = Author.create(name: "John")
    @post = Post.create(author: @author)
  end

  def teardown
    @author.destroy
    @post.destroy
  end

  def test_post_is_linked_to_author
    assert_equal "John", @post.author.name
  end
end
```

To run the test suite, invoke the executable (optionally passing a list of test files).

```shell
$ bundle exec guava
$ bundle exec guava test/post_test.rb
$ bundle exec guava test/post_test.rb test/author_test.rb
```

## Contributing

Please refer to the guidelines in [contributing](https://github.com/vinistock/guava/blob/master/CONTRIBUTING.md).
