begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort "Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine"
  end
end

VERSION = "1.1.0"

namespace :assets do
  desc "Transpile the Coffescript code into javascript one"
  task :transpile do
    require 'guard'
    require 'fileutils'

    Guard.setup
    Guard.guards('coffeescript').run_all
    FileUtils.mv js_lib_file, versioned_js_lib_file
  end

  desc "Minimize the JavaScript files"
  task minimize: :transpile do
    require 'uglifier'
    uglified, source_map = Uglifier.new.compile_with_map(File.read(versioned_js_lib_file))
    write_file(versioned_min_js_lib_file, uglified)
    write_file(versioned_map_lib_file, source_map)
  end
end

def js_lib_file
  File.join(%w{lib frundis.js})
end

def versioned_min_js_lib_file
  versioned_js_lib_file.gsub(".js", "-min.js")
end

def versioned_map_lib_file
  "#{versioned_min_js_lib_file}.map"
end

def versioned_js_lib_file
  js_lib_file.gsub(".js", "-#{VERSION}.js")
end

def write_file(filepath, contents)
  File.open(filepath, "w") {|f| f.write contents}
end
