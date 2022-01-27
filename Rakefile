require 'bundler/gem_tasks'



desc 'Run specs'
task :spec do
  files = FileList['spec/**/*_spec.rb'].shuffle.join(' ')
  sh "bundle exec bacon #{files}"
end

task :default => :spec

