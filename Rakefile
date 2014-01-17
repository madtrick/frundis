begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

namespace :assets do
  desc "Transpile the Coffescript code into javascript one"
  task :transpile do
    require 'guard'
    Guard.setup
    Guard.guards('coffeescript').run_all
  end
end
