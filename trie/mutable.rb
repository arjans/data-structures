class TrieNode
  attr_accessor :terminal, :character

  def initialize(character: "", terminal: false)
    @character = character
    @terminal = terminal
    @children = []
  end

  def add_node(node)
    i = node.character.ord % 97
    @children[i] = node
  end

  def next_node(character)
    i = character.ord % 97
    @children[i]
  end
end

class Trie
  def initialize
    @root = TrieNode.new
  end

  def word_present?(word)
    current_node = @root
    word.chars.each do |c|
      unless current_node = current_node.next_node(c)
        return nil
      end
    end
    current_node.terminal
  end

  def add_word(word)
    current_node = @root
    word.chars.each do |c|
      if current_node.next_node(c)
        current_node = current_node.next_node(c)
      else
        new_node = TrieNode.new(character: c)
        current_node.add_node(new_node)
        current_node = new_node
      end
    end
    current_node.terminal = true
  end
end
