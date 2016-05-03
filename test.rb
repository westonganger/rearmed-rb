lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rearmed.rb'

require 'method_source'

puts "sort_by: #{["1.1","1.11","1.2","1.22"].sort_by{|x| x}}"
puts "natural_sort_by: #{["1.1","1.11","1.2","1.22"].natural_sort_by{|x| Rearmed.naturalize_str(x)}}"
