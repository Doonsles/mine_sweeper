module MineSweeper
  class Board

    def initialize(size = 9)
      @game_over = false
      @size = size

      bombs = bomb_placement
      @grid = []
      (0..8).each do |x|
        row = []
        (0..8).each do |y|
          row << Tile.new(x, y, bomb: bombs.include?([x, y]))
        end

        @grid << row
      end
    end

    def display
      puts "1 2 3 4 5 6 7 8 9"
      (0..8).each do |x|
        (0..8).each do |y|
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
      @game_over
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

    def explore(curr_tile)
      puts "exploring!"
      queue = [curr_tile]

      until queue.empty?
        next_tile = queue.shift
        puts "exploring tile #{next_tile}"
        next_tile.visible = true
        # legal_tiles = get_legal_tiles(next_tile)
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

      bomb_offsets = [ [-1, -1],
                       [-1, 1],
                       [1, -1],
                       [1, 1] ]

      bomb_count = 0
      offsets.each do |x, y|
        new_x = tile.x - x
        new_y = tile.y - y

        if (new_x >= 0 && new_x < 9) && (new_y >= 0 && new_y < 9)
          tile = @grid[new_x][new_y]

          legal_tiles << tile
          bomb_count += 1 if tile.bomb?
        end
      end
      tile_info[:tiles] = legal_tiles

      bomb_offsets.each { |x, y| bomb_count += 1 if @grid[x][y].bomb? }
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

      #check if won or lost
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
