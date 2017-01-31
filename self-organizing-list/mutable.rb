#
# Self-organizing, mutable list
#

class List
	attr_accessor :first, :rest

	def initialize(x, y = EmptyList.new)
		@first = x
		@rest = y
	end

	def remove(x)
		if @first == x
			return @rest
		end

		iter = -> l {
			n = l.rest
			return false if n.nil?
			if n.first == x
				l.rest = n.rest
			else
				iter.(l.rest)
			end
		}
		iter.(self)
	end
end

class MtfList
	attr_accessor :list

	def initialize
		@list = nil
	end

	def insert(x)
		@list = List.new(x, @list)
	end

	def member(x)
		return false if @list.nil?
		if @list.remove(x)
			@list = List.new(x, @list)
		else
			false
		end
	end
end
