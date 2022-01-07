# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.name = "test"  # this is the default
  t.libs << "spec"  # load the test dir
  t.test_files = Dir['spec/**/*_spec.rb']
  t.verbose = false
  t.warning = false
end

Rails.application.load_tasks
