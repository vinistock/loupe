# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Run the type checker"
task :type_check do
  system("bundle exec srb tc")
  abort unless $?.success? # rubocop:disable Style/SpecialGlobalVars
end

task default: %i[test rubocop type_check]
