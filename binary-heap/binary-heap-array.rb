class BinaryHeap
	def initialize(size, f, vals = nil)
		@heap = Array.new(size)
		@f = f
		@end = 0
		heapify(vals) if vals
	end

	def insert(x)
		return "Overflow" if @end > (@heap.size - 1)
		@heap[@end] = x
		swap_up(@end)
		@end += 1
		self
	end

	def peek
		return "Underflow" if @heap[0].nil?
		@heap[0]
	end

	def pop
		return "Underflow" if @heap[0].nil?
		temp = @heap[0]		
		@heap[0] = @heap[@end - 1]
		@heap[@end - 1] = nil
		@end -= 1
		swap_down(0)
		temp
	end

	def merge(x)
		heapify(x.instance_variable_get(:@heap))
	end

	#
	# My idiosycratic pop: O(2*log(n))
	#

	# def pop
	# 	delete(0)
	# end

	# def delete(i)
	# 	left = @heap[left_child(i)]
	# 	right = @heap[right_child(i)]
	# 	if left.nil?
	# 		@heap[i] = @heap[@end - 1]
	# 		@heap[@end - 1] = nil
	# 		@end -= 1
	# 		swap_up(i) if @heap[i]
	# 	elsif right.nil?
	# 		@heap[i] = left
	# 		delete(left_child(i))
	# 	elsif left < right
	# 		@heap[i] = left
	# 		delete(left_child(i))
	# 	else
	# 		@heap[i] = right
	# 		delete(right_child(i))
	# 	end
	# end

	private
		
		def heapify(x)
			x.each do |v|
				break if v.nil?
				return "Overflow" if @end > (@heap.size - 1)
				@heap[@end] = v
				@end += 1
			end

			(0..(2**Math::log(@end,2).floor - 2)).to_a.reverse.each do |i|
				swap_down(i)
			end

			self
		end

		def swap_up(i)
			if i > 0
				parent = parent(i)
				if compare(@heap[i], @heap[parent])
					temp = @heap[parent]
					@heap[parent] = @heap[i]
					@heap[i] = temp
					if parent > 0
						swap_up(parent)
					end
				end
			end
		end

		def swap_down(i)
			min_index = nil
			if @heap[left_child(i)] && 
				compare(@heap[left_child(i)], @heap[i])
				min_index = left_child(i) 
			end
			if @heap[right_child(i)] && 
				compare(@heap[right_child(i)], @heap[i]) && 
				compare(@heap[right_child(i)], @heap[left_child(i)])
				min_index = right_child(i) 
			end

			if min_index
				@heap[i], @heap[min_index] = @heap[min_index], @heap[i]
				swap_down(min_index)
			end
		end

		def compare(x,y)
			if @f.class == Proc
				@f.call(x,y)
			else
				x.method(@f).call(y)
			end
		end

		def parent(i)
			(i - 1) / 2 # integer division automatically returns floor
		end

		def left_child(i)
			2*i + 1
		end

		def right_child(i)
			2*i + 2
		end
end
