module MineSweeper
  class Tile
    attr_accessor :visible, :adjacent_bomb_count
    attr_reader :x, :y
    attr_writer :flag

    def initialize(x, y, options = {})
      @x = x
      @y = y
      @bomb = options[:bomb]
      @visible = false
      @adjacent_bomb_count = nil
      @flag = false
    end

    def bomb?
      @bomb
    end

    def visible?
      @visible
    end

    def flagged?
      @flag
    end

    def to_s
      "Tile: (#{x}, #{y}): bomb: #{bomb}"
    end
  end
end