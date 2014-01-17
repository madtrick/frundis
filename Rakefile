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

  desc "Minimize the JavaScript files"
  task minimize: :transpile do
    require 'uglifier'
    uglified, source_map = Uglifier.new.compile_with_map(File.read(js_lib_file))
    write_file('lib', 'frundis.min.js', uglified)
    write_file('lib', 'frundis.min.js.map', source_map)
  end
end

def js_lib_file
  File.join(%w{lib frundis.js})
end

def write_file(path, filename, contents)
  File.open(File.join([path, filename]), "w") {|f| f.write contents}
end
