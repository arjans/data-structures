#
# Immutable binomial heap based on Okasaki's implementation in "Purely Functional Data Structures"
#

#
# Linked lists are useful in immutable binomial heaps.
# The heap is basically a list of binomial trees.
# If it were an array, each change in the heap would copy the entire array.
# With lists, if the `rest` of the list is unchanged, it'll be shared.
#
class LinkedList
	attr_accessor :first, :rest

	def initialize(first, rest = nil)
		@first = first
		@rest = rest
	end

	def inspect
		"[#{@first.inspect}, #{@rest.inspect}]"
	end
end

#
# Only binomial trees of equal rank can be merged together.
#
class BinomialTree
	attr_accessor :rank, :value, :children

	def initialize(rank, value, children)
		@rank = rank
		@value = value
		@children = children
	end

	def merge(t)
		raise "Trees are of unequal rank." if @rank != t.rank

		if @value < t.value
			BinomialTree.new(@rank + 1, @value, [t] + @children)
		else
			BinomialTree.new(@rank + 1, t.value, [self] + t.children)
		end
	end

	def inspect
		if @children.empty?
			@value
		else
			"Tree[#{@value.inspect}, #{@children.map(&:inspect)}]"
		end
	end
end

class BinomialHeap
	attr_accessor :list

	def initialize(list = nil)
		@list = list
	end

	def insert(v)
		BinomialHeap.new(insert_tree(BinomialTree.new(0, v, []), @list))
	end

	#
	# Returns minimum element in heap without removing it.
	#
	def peek
		raise "Empty heap" if @list.nil?

		helper = -> l, result {
			if l.nil?
				result
			elsif l.first.nil?
				helper.call(l.rest, result)
			elsif result.nil? || l.first.value < result
				helper.call(l.rest, l.first.value)
			else
				helper.call(l.rest, result)
			end
		}
		helper.call(@list, nil)
	end

	#
	# Returns the heap resulting from removing the minimum element.
	#
	def pop
		raise "Empty heap" if @list.nil?

		t, ts = remove_min_tree
		BinomialHeap.new(t.children.
											 reverse.
											 inject(ts) { |ts, c| insert_tree(c, ts) })
	end

	# private

		#
		# Returns a tuple containing the min tree
		# and the list of trees that no longer contains it.
		#
		def remove_min_tree
			raise "Empty heap" if @list.nil?

			min_elem = peek
			helper = -> l {
				if l.nil?
					[nil, l]
				else
					t, ts = helper.(l.rest)
					if t.nil? && l.first && l.first.value == min_elem
						[l.first, LinkedList.new(nil, l.rest)]
					else
						[t, LinkedList.new(l.first, ts)]
					end
				end
			}
			helper.(@list)
		end

		# def remove_min_tree
		# 	raise "Empty heap" if @list.nil?

		# 	helper = -> l {
		# 		if l.rest.nil?
		# 			[l.first, l.rest]
		# 		else
		# 			t, ts = helper.(l.rest)
		# 			if l.first && l.first.value < t.value
		# 				[l.first, LinkedList.new(t, l.rest)]
		# 			else
		# 				[t, l]
		# 			end
		# 		end
		# 	}
		# 	helper.call(@list)
		# end

		#
		# Returns a new linked list containing the inserted tree.
		#
		# CHANGE TO MERGING TWO HEAPS (Reversed list of a tree's children looks like a heap.)
		#
		def insert_tree(tree, list)
			helper = -> t, l, count {
				if l.nil?
					LinkedList.new(t, l)
				elsif count != t.rank
					LinkedList.new(l.first, helper.(t, l.rest, count + 1))
				elsif l.first
					LinkedList.new(nil, helper.(l.first.merge(t), l.rest, count + 1))
				else
					LinkedList.new(t, l.rest)
				end
			}
			helper.(tree, list, 0)
		end

		def compare(x,y)
			if @f.class == Proc
				@f.call(x,y)
			else
				x.method(@f).call(y)
			end
		end
end
