#
# Immutable binomial heap based on Okasaki's implementation in "Purely Functional Data Structures"
#

#
# Basic list implementation.
#
# Usage:
#   List.new(1)
#   # => List[1, nil]
#   List.new(2, List.new(1))
#   # => List[2, List[1, nil]]
#
class List
  attr_accessor :first, :rest

  def initialize(first, rest = nil)
    @first = first
    @rest = rest
  end

  def reverse
    helper = -> l, result {
      l.nil? ? result :  helper.(l.rest, List.new(l.first, result))
    }
    helper.(self, nil)
  end

  def inspect
    "List[#{@first.inspect}, #{@rest.inspect}]"
  end
end

#
# Binomial tree
#
# Usage:
#   Create binomial tree of rank 0 (just one element)
#
#   t = BinomialTree.new(0, 1, nil)
#   # => Tree[1, nil]
#
#   Link two binomial trees together
#
#   t.link(BinomialTree.new(0, 2, nil))
#   # => Tree[1, List[Tree[2, nil], nil]]
#
class BinomialTree
  attr_accessor :rank, :value, :children

  alias root value

  def initialize(rank, value, children)
    @rank = rank
    @value = value
    @children = children
  end

  #
  # Only binomial trees of equal rank can be linked together.
  #
  def link(t)
    raise "Trees are of unequal rank." if @rank != t.rank

    if @value < t.value
      BinomialTree.new(@rank + 1, @value, List.new(t, @children))
    else
      BinomialTree.new(@rank + 1, t.value, List.new(self, t.children))
    end
  end

  def inspect
    "Tree[#{@value.inspect}, #{@children.inspect}]"
  end
end

#
# Binomial heap
#
# Same api as most heaps: is_empty?, insert, find_min, delete_min, merge
#
# Usage:
#   Create an empty heap:
#
#   BinomialHeap.new
#   # => Heap[nil]
#
#   Initialize from array:
#
#   h = [1,5,2,3,7,9].inject(BinomialHeap.new) { |h,n| h.insert(n) }
#   # => Heap[List[Tree[2, nil], List[Tree[1, List[Tree[5, nil], nil]], nil]]]
#
class BinomialHeap
  attr_accessor :list

  def initialize(list = nil)
    @list = list
  end

  def is_empty?
    @list.nil?
  end

  def insert(v)
    BinomialHeap.new(insert_tree(BinomialTree.new(0, v, nil), @list))
  end

  #
  # Returns minimum element in heap without removing it.
  #
  def find_min
    raise "Empty heap" if @list.nil?
    remove_min_tree.first.root
  end

  #
  # Merge two binomial heaps.
  #
  def merge(h)
    BinomialHeap.new(merge_lists(@list, h.list))
  end

  #
  # Returns a new heap with the minimum element removed.
  #
  def delete_min
    raise "Empty heap" if @list.nil?

    t, ts = remove_min_tree
    if t.children.nil?
      BinomialHeap.new(ts)
    else
      BinomialHeap.new(merge_lists(ts, t.children.reverse))
    end
  end

  def inspect
    "Heap[#{@list.inspect}]"
  end

  private

    #
    # Returns a new list with the tree inserted in its proper order.
    # If there was already a tree of the same rank, the two are linked together
    # and inserted into the rest of the list.
    #
    def insert_tree(t, l)
      if l.nil?
        List.new(t, l)
      elsif t.rank < l.first.rank
        List.new(t, l)
      else
        insert_tree(l.first.link(t), l.rest)
      end
    end

    #
    # Merge two lists of binomial trees.
    # Returns a new list.
    #
    def merge_lists(ts1, ts2)
      if ts1.nil?
        ts2
      elsif ts2.nil?
        ts1
      elsif ts1.first.rank < ts2.first.rank
        List.new(ts1.first, merge_lists(ts1.rest, ts2))
      elsif ts2.first.rank < ts1.first.rank
        List.new(ts2.first, merge_lists(ts1, ts2.rest))
      else
        insert_tree(ts1.first.link(ts2.first), merge_lists(ts1.rest, ts2.rest))
      end
    end

    #
    # Returns a tuple containing the min tree
    # and the list of trees that no longer contains it.
    #
    def remove_min_tree
      raise "Empty heap" if @list.nil?

      helper = -> l {
        if l.rest.nil?
          [l.first, l.rest]
        else
          t, ts = helper.(l.rest)
          if l.first.root < t.root
            [l.first, l.rest]
          else
            [t, List.new(l.first, ts)]
          end
        end
      }
      helper.(@list)
    end
end
