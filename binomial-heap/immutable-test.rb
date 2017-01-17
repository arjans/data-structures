require 'pry'
require_relative 'immutable'

vals = (1..15000).to_a + (10000..25000).to_a
ordered_vals = vals.sort
shuffled_vals = ordered_vals.shuffle
h = BinomialHeap.new
h = shuffled_vals.inject(h) { |h,n| h.insert(n) }

puts "ORDERED ACCESS:"
result = ordered_vals.all? do |v|
	puts "v: #{v}"
	min = h.find_min
	puts "min: #{min}"
	h = h.delete_min
	v == min ? true : (raise "Unexpected min value.")
end
puts result
