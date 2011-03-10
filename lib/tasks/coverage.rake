namespace :coverage do
 
  task :clean do
    rm_f "test/coverage"
    rm_f "test/coverage.data"
    Rcov = "cd test && rcov --rails --aggregate coverage.data -Ilib \
                   --text-summary -x 'bundler/*,gems/*'"
  end
 
  def display_coverage
    system("sensible-browser test/coverage/index.html")
  end
 
  desc 'Measures unit test coverage'
  task :unit => :clean do
    system("#{Rcov} --html unit/*_test.rb")
    display_coverage
  end
 
  desc 'Measures functional test coverage'
  task :func => :clean do
    system("#{Rcov} --html functional/*_test.rb")
    display_coverage
  end
 
  desc 'All unit test coverage'
  task :all => :clean do
    system("#{Rcov} --html */*_test.rb")
    display_coverage
  end
 
end
 
task :coverage do
  Rake::Task["coverage:all"].invoke
end