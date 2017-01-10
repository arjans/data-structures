require 'memory_profiler'
require_relative 'leftist-heap-immutable'

report = MemoryProfiler.report do
	ordered_vals = (1..25).to_a
	shuffled_vals = ordered_vals.shuffle
	h = shuffled_vals.inject(EmptyNode.new) { |h,v| h.insert(v) }

	puts "ALL INSERTED:"
	puts shuffled_vals.all? { |v| h.exists?(v) }
	puts "ORDERED ACCESS:"
	puts ordered_vals.all? do |v|
		min = h.min
		h = h.delete_min
		min == v
	end
end

report.pretty_print
