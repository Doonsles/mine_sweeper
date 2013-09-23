module MineSweeper
  class Board

    def initialize(size = 9)
      @game_over = false
      @size = size
      @bomb_count = (size == 9 ? 10 : 40)

      bombs = bomb_placement
      @grid = []
      (0...@size).each do |x|
        row = []
        (0...@size).each do |y|
          row << Tile.new(x, y, bomb: bombs.include?([x, y]))
        end

        @grid << row
      end
    end

    def display
      puts "1 2 3 4 5 6 7 8 @size"
      (0...@size).each do |x|
        (0...@size).each do |y|
          if @grid[x][y].visible?
            if @grid[x][y].adjacent_bomb_count == 0
              print "_"
            else
              print @grid[x][y].adjacent_bomb_count
            end
          else
            #for debugging
            if @grid[x][y].bomb?
              print "b"
            else
              print "*"
            end
          end
          print " "
        end

        puts "#{x+1}"
      end
    end

    def reveal(pos)
      tile = @grid[pos[0]][pos[1]]
      if tile.bomb?
        tile.visible = true
        @game_over = true
        return
      end

      explore(tile)
    end

    def game_over?
      @game_over  || won?
    end

    def won?
      (0...@size).each do |x|
        (0...@size).each do |y|
          if @grid[x][y].bomb? && @grid[x][y].visible?
            return false
          elsif !@grid[x][y].bomb? && !@grid[x][y].visible?
            return false
          end
        end
      end
      true
    end


    private
    def bomb_placement
      bombs = []
      while bombs.length < @bomb_count
        x = rand(@size-1)
        y = rand(@size-1)

        bombs << [x, y] unless bombs.include?([x, y])
      end

      bombs
    end

    def explore(curr_tile)
      queue = [curr_tile]

      until queue.empty?
        next_tile = queue.shift
        next_tile.visible = true

        tile_info = adjacent_tile_info(next_tile)

        next_tile.adjacent_bomb_count = tile_info[:bomb_count]

        if tile_info[:bomb_count] == 0
          tile_info[:tiles].each do |tile|
            if !queue.include?(tile) && !tile.visible?
              queue << tile
            end
          end
        end
      end
    end

    def adjacent_tile_info(tile)
      tile_info = {}

      legal_tiles = []

      offsets      = [ [0, 1],
                       [0, -1],
                       [1, 0],
                       [-1, 0] ]

      diag_offsets = [ [-1, -1],
                       [-1, 1],
                       [1, -1],
                       [1, 1] ]

      bomb_count = 0
      offsets.each do |x, y|
        new_x = tile.x - x
        new_y = tile.y - y

        if (new_x >= 0 && new_x < @size) && (new_y >= 0 && new_y < @size)
          ad_tile = @grid[new_x][new_y]

          legal_tiles << ad_tile
          bomb_count += 1 if ad_tile.bomb?
        end
      end
      tile_info[:tiles] = legal_tiles

      count_tiles = []
      diag_offsets.each do |x, y|
        new_x = tile.x - x
        new_y = tile.y - y
        if (new_x >= 0 && new_x < @size) && (new_y >= 0 && new_y < @size)
          bomb_count += 1 if @grid[new_x][new_y].bomb?
          count_tiles << @grid[new_x][new_y]
        end
      end

      tile_info[:bomb_count] = bomb_count

      tile_info
    end

    def count_bombs(legal_tiles)
      count = 0
      legal_tiles.each do |tile|
        count += 1 if tile.bomb?
      end

      count
    end
  end

  class Tile
    attr_accessor :visible, :adjacent_bomb_count
    attr_reader :x, :y

    def initialize(x, y, options = {})
      @x = x
      @y = y
      @bomb = options[:bomb]
      @visible = false
      @adjacent_bomb_count = nil
    end

    def bomb?
      @bomb
    end

    def visible?
      @visible
    end

    def to_s
      "Tile: (#{x}, #{y}): bomb: #{bomb}"
    end
  end



  class Game
    def initialize
      @board = Board.new
    end

    def play
      @board.display

      until @board.game_over?
        position = get_user_input
        @board.reveal(position)
        @board.display
      end

      if @board.won?
        puts "You win!"
      else
        puts "Sorry, you lost!"
      end
    end


    private

    def get_user_input
      puts "Enter the click you would like to make (format x y)"
      user_input = gets.chomp.split(' ').map { |i| (i.to_i - 1) }
      user_input.reverse
    end
  end
end

MineSweeper::Game.new.play
