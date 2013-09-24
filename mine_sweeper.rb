require "yaml"


module MineSweeper
  class Board
    SMALL = 9
    LARGE = 16

    def initialize(size = SMALL)
      @game_over = false
      if size != SMALL && size != LARGE
        size = SMALL
      end
      @size = size
      @bomb_count = (size == SMALL ? 10 : 40)

      @grid = init_grid
    end

    def display
      puts "1 2 3 4 5 6 7 8 9"
      (0...@size).each do |x|
        (0...@size).each do |y|
          tile = @grid[x][y]

          if tile.visible?
            if tile.bomb?
              print "B"
            elsif tile.adjacent_bomb_count == 0
              print "_"
            else
              print tile.adjacent_bomb_count
            end
          else
            if tile.flagged?
              print "F"
            elsif tile.bomb? && game_over?
              print "B"
            else
              print "*"
            end
          end
          print " "
        end

        # vertical axis line number
        puts "#{x+1}"
      end
    end

    def reveal(pos)
      tile = @grid[pos[0]][pos[1]]
      return if tile.flagged?

      if tile.bomb?
        tile.visible = true
        @game_over = true
        return
      end

      explore(tile)
    end

    def flag(pos)
      tile = @grid[pos[0]][pos[1]]
      tile.flag = !tile.flagged?
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
    def init_grid
      bombs = bomb_placement
      p bombs
      grid = []
      (0...@size).each do |x|
        row = []
        (0...@size).each do |y|
          row << Tile.new(x, y, :bomb => bombs.include?([x, y]))
        end

        grid << row
      end

      grid
    end

    def bomb_placement
      bombs = []
      while bombs.length < @bomb_count
        x = rand(@size)
        y = rand(@size)

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
            if !queue.include?(tile) && !tile.visible? && !tile.flagged?
              queue << tile
            end
          end
        end
      end
    end

    def adjacent_tile_info(tile)
      tile_info = {}

      offsets      = [ [0, 1],
                       [0, -1],
                       [1, 0],
                       [-1, 0] ]

      diag_offsets = [ [-1, -1],
                       [-1, 1],
                       [1, -1],
                       [1, 1] ]

      tile_info[:tiles] = adjacent_tiles(tile, offsets)

      tile_info[:bomb_count] = bomb_count(tile, offsets + diag_offsets)

      tile_info
    end

    def adjacent_tiles(tile, offsets)
      legal_tiles = []
      offsets.each do |x, y|
        new_x = tile.x - x
        new_y = tile.y - y

        if (new_x >= 0 && new_x < @size) && (new_y >= 0 && new_y < @size)
          legal_tiles << @grid[new_x][new_y]
        end
      end

      legal_tiles
    end

    def bomb_count(tile, offsets)
      count = 0
      offsets.each do |x, y|
        new_x = tile.x - x
        new_y = tile.y - y

        if (new_x >= 0 && new_x < @size) && (new_y >= 0 && new_y < @size)
          count += 1 if @grid[new_x][new_y].bomb?
        end
      end

      count
    end
  end



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



  class Game
    def initialize(size = nil)
      if size
        @board = Board.new(size)
      else
        action = get_game_info
        if action == :load
          @board = load_game
        else
          @board = Board.new(action == :large ? Board::LARGE : Board::SMALL)
        end
      end
    end

    def play
      @board.display

      until @board.game_over?
        action, position = get_user_input
        if action == "s"
          save_game
        elsif action == "r"
          @board.reveal(position)
        else
          @board.flag(position)
        end
        @board.display
      end

      if @board.won?
        puts "You win!"
      else
        puts "Sorry, you lost!"
      end
    end


    private

    def get_game_info
      puts "Would you like to:"
      puts " a: start game with #{Board::SMALL} grid"
      puts " b: start game with #{Board::LARGE} grid"
      puts " c: load saved game"

      action = gets.chomp
      if action == "a"
        :small
      elsif action == "b"
        :large
      elsif action == "c"
        :load
      else
        puts "that doesn't sound right"
      end
    end

    def get_user_input
      puts "Reveal (r) or Flag (f) a square? Or Save (s) a game?"
      print "Enter the click you would like to make (format: [rfs] x y): "
      user_input = gets.chomp.split(' ')

      action = user_input[0]
      if action == "s"
        return [action, nil]
      end

      position = user_input[1..-1].map { |i| i.to_i - 1 }.reverse

      [action, position]
    end

    def save_game
      board_yaml = @board.to_yaml
      time = Time.now.strftime("%Y-%m-%d:%H:%M")
      filename = "games/my_game-#{time}.yaml"

      File.open(filename, "w") do |file|
        file.puts(board_yaml)
      end

      puts "Game saved to #{filename}."
    end

    def load_game
      puts "Enter filename: "
      filename = gets.chomp

      YAML::load(File.read(filename))
    end
  end
end

MineSweeper::Game.new.play
