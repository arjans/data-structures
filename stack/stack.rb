# Implementing a stack for algorithm study group.

class Stack
	def initialize
		@bottom = 3 # zero-indexed
		@top = 3 # zero-indexed
		@items = [nil,nil,nil,nil]
	end

	def empty?
		@top == @bottom
	end

	def pop
		if empty?
			"Underflow"
		else
			@top += 1
			item = @items[@top]
			@items[@top] = nil
			puts @items.inspect
			item
		end
	end

	def push(x)
		if @top == -1
			"Overflow"
		else
			@items[@top] = x
			@top -= 1
			@items
		end
	end
end
