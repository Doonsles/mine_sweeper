module MineSweeper
  class Board
    def initialize(size = 9)
      @size = size

      bombs = bomb_placement
      @grid = []
      (0..8).each do |x|
        row = []
        (0..8).each do |y|
          row << Tile.new(bomb: bombs.include?([x, y]))
        end

        @grid << row
      end
    end

    def display
      puts "1 2 3 4 5 6 7 8 9"
      (0..8).each do |x|
        (0..8).each do |y|
          if @grid[x][y].visible?
            # what is the state
          else
            print "*"
          end
          print " "
        end

        puts "#{x+1}"
      end
    end


    private
    def bomb_placement
      bombs = []
      while bombs.length < 10
        x = rand(8)
        y = rand(8)

        bombs << [x, y] unless bombs.include?([x, y])
      end

      bombs
    end
  end

  class Tile
    def initialize(options = {})
      @bomb = options[:bomb]
      @visible = false
    end

    def bomb?
      @bomb
    end

    def visible?
      @visible
    end
  end

  class Game
  end
end

MineSweeper::Board.new.display
