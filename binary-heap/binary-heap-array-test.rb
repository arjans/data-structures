require 'memory_profiler'
require_relative 'binary-heap-array'

report = MemoryProfiler.report do

	ordered_vals = (1..25000).to_a
	shuffled_vals = ordered_vals.shuffle
	h = BinaryHeap.new(25000, :<, shuffled_vals)

	puts "ORDERED ACCESS:"
	puts ordered_vals.all? do |v|
		v == h.pop
	end
end

report.pretty_print
