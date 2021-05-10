# Using the fake test suite

The fake test suite is used to compare results between different configurations.

To generate the suite:
```bash
# framework can be minitest/parallel/guava

bin/generate_suite [framework]
```

To run the suite:
```bash
# Guava
../exe/guava test/fake/guava/**/*rb

# Minitest
ruby -Ilib -e 'ARGV.each { |f| require f }' ./test/fake/minitest/*.rb

# Minitest + parallel Rails plugin
ruby -Ilib -e 'ARGV.each { |f| require f }' ./test/fake/parallel/*.rb
```
