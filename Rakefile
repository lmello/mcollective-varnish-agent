specdir = File.join([File.dirname(__FILE__), "spec"])

require 'rake'
begin
  require 'rspec/core/rake_task'
rescue LoadError
end

def safe_system *args
  raise RuntimeError, "Failed: #{args.join(' ')}" unless system *args
end

if defined?(RSpec::Core::RakeTask)
  desc "Run agent and application tests"
  RSpec::Core::RakeTask.new(:test) do |t|
    require "#{specdir}/spec_helper.rb"
    t.pattern = 'spec/**/*_spec.rb'
    t.rspec_opts = File.read("#{specdir}/spec.opts").chomp
  end
end

task :default => :test
