# Implementing a queue for algorithm study group.

class Queue
	def initialize
		@front = 0
		@back = 0
		@items = [nil, nil, nil, nil]
		@num_items = 0
	end

	def empty?
		@num_items == 0
	end

	def dequeue
		if empty?
			"Underflow"
		else
			@num_items -= 1
			item = @items[@front]
			@items[@front] = nil
			@front = (@front + 1) % @items.length
			puts @items.inspect
			item
		end
	end

	def enqueue(x)
		if @num_items == @items.length
			"Overflow"
		else
			@num_items += 1
			@items[@back] = x
			@back = (@back + 1) % @items.length
			@items
		end
	end
end
