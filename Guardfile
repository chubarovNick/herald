# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec' , cmd: 'bundle exec rspec'do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }

end


# guard :jasmine do
#   watch(%r{spec/javascripts/spec\.(js\.coffee|js|coffee)$}) { 'spec/javascripts' }
#   watch(%r{spec/javascripts/.+_spec\.(js\.coffee|js|coffee)$})
#   watch(%r{spec/javascripts/fixtures/.+$})
#   watch(%r{app/assets/javascripts/(.+?)\.(js\.coffee|js|coffee)(?:\.\w+)*$}) { |m| "spec/javascripts/#{ m[1] }_spec.#{ m[2] }" }
# end
