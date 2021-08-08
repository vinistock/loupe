# Loupe

[Loupe](https://en.wikipedia.org/wiki/Loupe) is a test framework with built in parallel execution supporting Ractor or forked process modes.

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

Tests can run in parallel using Ractor or process mode. When using Ractors, the application's code must be Ractor compatible.

```shell
bin/loupe --ractor            # [default] run tests using Ractor workers
bin/loupe --process           # run tests using forked processes
bin/loupe --interactive       # [default] use an interactive reporter to display test results
bin/loupe --plain             # use a plain reporter to display test results
bin/loupe --color, --no-color # enable/disable output colors
bin/loupe --editor=EDITOR     # which editor to use for opening files when using interactive mode. The default is the environment variable $EDITOR
```

## Credits

This project draws a lot of inspiration from other Ruby test frameworks, namely

- [Minitest](https://github.com/seattlerb/minitest)
- [rspec](https://github.com/rspec/rspec)

## Contributing

Please refer to the guidelines in [contributing](https://github.com/vinistock/loupe/blob/master/CONTRIBUTING.md).
