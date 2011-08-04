desc "Task for the Travis CI"
task :travis => ["db:create", "db:migrate", "db:test:prepare", "db:seed", :spec]
