# Least Recently Used Cache
class LRUCache
  def initialize(size)
    @size = size
    @list = List.new
    @hash = {}
  end

  def get(k)
    n = @hash[k]
    if n
      @list.remove(n)
      @list.push(n)
      n.v
    end
  end

  def set(k, v)
    if @list.length == @size
      n1 = @list.tail
      @list.remove(n1)
      @hash.delete(n1.k)
    end
    n2 = Node.new(k, v)
    @list.push(n2)
    @hash[k] = n2
  end
end

# Doubly-linked list
class List
  attr_accessor :head, :tail, :length

  def initialize
    @head = nil
    @tail = nil 
    @length = 0
  end

  def push(n)
    n.r = @head
    @head.l = n if @head
    @length += 1
    @head = n
    @tail = n if @length == 1
  end

  def remove(n)
    @tail = n.l if @tail.equal?(n)
    @head = n.r if @head.equal?(n)
    n.l.r = n.r if n.l
    n.r.l = n.l if n.r
    @length -= 1
  end
end

class Node
  attr_accessor :l, :r, :k, :v
  def initialize(k, v)
    @v = v
    @k = k
    @l = nil
    @r = nil
  end
end

lru = LRUCache.new(3)
lru.set("a", 1)
lru.set("b", 2)
lru.set("c", 3)
puts lru.get("c") #=> 3
lru.set("d", 4)
puts lru.get("d") #=> 4
puts lru.get("a") #=> nil
