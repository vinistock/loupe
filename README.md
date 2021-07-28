# Loupe

[Loupe](https://en.wikipedia.org/wiki/Loupe) is a test framework built with Ractors for parallel execution.

## Installation

Add the gem to the `Gemfile`.

```ruby
gem "loupe"
```

And then execute:

```shell
bundle install
```

Optionally, install bundler binstubs in your application.

```shell
bundle binstub loupe
```

## Usage

Because of current Ractor limitations, Loupe implements only one syntax for writing tests: using methods prefixed with `test_`. The other common syntax of using the `test` method with a block is not supported.

Tests need to inherit from `Loupe::Test`, but do not need to explicitly require test_helper, like the example below.

```ruby
# frozen_string_literal: true

class MyTest < Loupe::Test
  def before
    @author = Author.create(name: "John")
    @post = Post.create(author: @author)
  end

  def after
    @author.destroy
    @post.destroy
  end

  def test_post_is_linked_to_author
    expect(@post.author.name).to_be_equal_to("John")
  end
end
```

To run the test suite, invoke the executable. If a binstub was generated, prefer the binstub over `bundle exec`.

```shell
bundle exec loupe
bin/loupe test/post_test.rb test/author_test.rb
```

## Credits

This project draws a lot of inspiration from other Ruby test frameworks, namely

- [Minitest](https://github.com/seattlerb/minitest)
- [rspec](https://github.com/rspec/rspec)

## Contributing

Please refer to the guidelines in [contributing](https://github.com/vinistock/loupe/blob/master/CONTRIBUTING.md).
