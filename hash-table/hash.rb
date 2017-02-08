class MyHash
  def initialize(size: 100)
    @size = size
    @hash = Array.new(size)
  end

  attr_accessor :hash

  def insert(key, value)
    i = hashing_function(key)
    @hash[i] ||= []
    if @hash[i].find { |arr| arr.first == key }
      return "Key exists."
    else
      @hash[i] << [key, value]
    end
  end

  def delete(key)
    i = hashing_function(key)
    arr = lookup(key)
    @hash[i].delete(arr)
  end

  def lookup(key)
    i = hashing_function(key)
    if @hash[i]
      result = @hash[i].find { |arr| arr.first == key }
    else
      nil
    end
    result
  end

  def hashing_function(key)
    key.chars.map(&:ord).reduce(&:*) % @size
  end
end
