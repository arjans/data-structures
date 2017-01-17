class LeftistHeap
	attr_accessor :rank, :value, :left, :right

	def initialize(value = nil, left = nil, right = nil)
		@value = value
		if right.nil?
			@rank = 0
			@left = left
			@right = right
		elsif left.nil?
			@rank = 0
			@left = right
			@right = left
		elsif	left.rank >= right.rank
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
		if h.nil?
			true
		elsif @right.nil?
			@right = h
		elsif @value < h.value
			@right.merge(h)
		else
			@right = LeftistHeap.new(@value, @left, @right).merge(h.right)
			@value = h.value
			@left = h.left
		end
		self
	end

	def insert(v)
		if @value == nil
			@value = v
			@right = nil
			@left = nil
		else
			temp = LeftistHeap.new(@value, @left, @right)
			@value = v
			@right = nil
			@left = nil
			self.merge(temp)
		end
		self
	end

	def min
		@value
	end

	def delete_min
		temp = @right
		@value = @left.value
		@right = @left.right
		@left = @left.left
		self.merge(temp)
	end

	def exists?(v)
		if v == @value
			true
		else
			(@left && @left.exists?(v)) || (@right && @right.exists?(v))
		end
	end

	def print
		left = @left.nil? ? nil : @left.print
		right = @right.nil? ? nil : @right.print
		[left, @value, right]
	end
end
