# A sample Guardfile
# More info at https://github.com/guard/guard#readme

# Run JS and CoffeeScript files in a typical Rails 3.1 fashion, placing Underscore templates in app/views/*.jst
# Your spec files end with _spec.{js,coffee}.

spec_location = "spec/javascripts/%s_spec"
lib_spec_location ="lib/assets/javascripts/frundis/spec/%s_spec"

# uncomment if you use NerdCapsSpec.js
# spec_location = "spec/javascripts/%sSpec"

guard 'jasmine-headless-webkit' do
  watch(%r{^lib/(.*)\.coffee$}) { |m| newest_js_file(spec_location % m[1]) }
  #watch(%r{^spec/javascripts/(.*)_spec\.coffee}) { |m| newest_js_file(lib_spec_location % m[1]) }
  #watch(%r{^public/javascripts/(.*)\.js$}) { |m| newest_js_file(spec_location % m[1]) }
  #watch(%r{^app/assets/javascript/app/(.*)\.(js|coffee)$})
  watch(%r{^spec/javascripts/(.*)_spec\..*}) { |m| newest_js_file(spec_location % m[1]) }
end

