require 'set'
require 'pry'

class Node
  attr_accessor :v, :ns

  def initialize(v, ns = [])
    @v = v
    @ns = ns
  end
end

#
# Breadth-first search
#
def bfs(s, t, v = Set[])
  queue = [[s, []]]
  result = []
  queue.each do |arr|
    node, path = arr
    v << node
    if node.equal?(t)
      path << node
      result << path
    else
      (node.ns.to_set - v).each do |c|
        queue << [c, path + [node]]
      end
    end
  end
  result.min_by { |arr| arr.length }
end

#
# Depth-first search
#
def dfs(s, t, v = Set[])
  return nil if v.include?(s)

  puts "visiting: #{s.v}"

  if s.equal?(t)
    return [s]
  else
    v << s
    r = s.ns.map { |n| dfs(n, t, v) }.
             reject(&:nil?).
             min_by { |x| x.length }
    r.nil? ? nil : [s] + r
  end
end

#
# Generates a graph from a matrix, where each node is connected to
# the nodes above, below, left, and right of it.
#
# Returns a matrix containing the nodes.
#
def graph_from_matrix(m)
  res = m.map do |row|
    row.map do |el|
      Node.new(el)
    end
  end

  res.each.with_index do |row, i|
    row.each.with_index do |el, j|
      el.ns << res[i - 1][j] if (i - 1 >= 0) # up
      el.ns << res[i + 1][j] if (i + 1 <= res.length - 1) # down
      el.ns << res[i][j - 1] if (j - 1 >= 0) # left
      el.ns << res[i][j + 1] if (j + 1 <= res[0].length - 1) # right
    end
  end
end
