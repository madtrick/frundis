spec_location = "spec/javascripts/%s_spec"
lib_spec_location ="lib/assets/javascripts/frundis/spec/%s_spec"


guard 'jasmine-headless-webkit' do
  watch(%r{^lib/(.*)\.coffee$}) { |m| newest_js_file(spec_location % m[1]) }
  #watch(%r{^spec/javascripts/(.*)_spec\.coffee}) { |m| newest_js_file(lib_spec_location % m[1]) }
  #watch(%r{^public/javascripts/(.*)\.js$}) { |m| newest_js_file(spec_location % m[1]) }
  #watch(%r{^app/assets/javascript/app/(.*)\.(js|coffee)$})
  watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
end

group :assets do
  guard 'coffeescript', input: 'lib', output: 'lib'
end
