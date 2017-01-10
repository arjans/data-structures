class EmptyError < StandardError
end

class EmptyNode
	attr_accessor :rank, :value, :left, :right

	def initialize
		@rank = -1
		@value = nil
		@left = nil
		@right = nil
	end

	def merge(h)
		h
	end

	def insert(v)
		LeftistHeap.new(v, EmptyNode.new, EmptyNode.new)
	end

	def min
		raise EmptyError
	end

	def delete_min
		raise EmptyError
	end

	def exists?(v)
		false
	end

	def print
		nil
	end
end

class LeftistHeap
	attr_accessor :rank, :value, :left, :right

	def initialize(value, left, right)
		@value = value
		if left.rank >= right.rank
			@rank = right.rank + 1
			@left = left
			@right = right
		else
			@rank = left.rank + 1
			@left = right
			@right = left
		end
	end

	def merge(h)
		if h.class == EmptyNode
			self
		elsif @value < h.value
			LeftistHeap.new(@value, @left, @right.merge(h))
		else
			LeftistHeap.new(h.value, h.left, self.merge(h.right))
		end
	end

	def insert(v)
		LeftistHeap.new(v, EmptyNode.new, EmptyNode.new).merge(self)
	end

	def min
		@value
	end

	def delete_min
		@left.merge(@right)
	end

	def exists?(v)
		if v == @value
			true
		else
			@left.exists?(v) || @right.exists?(v)
		end
	end

	def print
		[@left.print, @value, @right.print]
	end
end
