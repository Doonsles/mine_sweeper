require "./tile"

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
end