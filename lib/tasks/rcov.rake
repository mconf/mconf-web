namespace :test do

  task :prepare_rcov do
    rm_f "coverage"
    rm_f "coverage.data"
    Rcov = "rcov --rails --aggregate coverage.data --text-summary -Ilib"
  end

  desc 'Measures unit test coverage'
  task :unit_coverage => :prepare_rcov do    
    system("#{Rcov} --html test/unit/*_test.rb")
  end
  
  desc 'Measures functional test coverage'
  task :functional_coverage => :prepare_rcov do    
    system("#{Rcov} --html test/functional/*_test.rb")
  end
  
  desc 'Measures integration test coverage'
  task :integration_coverage => :prepare_rcov do    
    system("#{Rcov} --html test/integration/*_test.rb")
  end
  
  desc 'whole units and functionals'
  task :rcov => :prepare_rcov do
    system("#{Rcov} --html test/unit/*_test.rb test/functional/*_test.rb")
  end
end
