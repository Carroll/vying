# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying'

# This is an implementation of American Checkers, or Straight Checkers, or
# British Draughts, or, etc, etc, depending on what part of the world you're
# from.
#
# For more detailed rules, etc:  http://vying.org/games/american_checkers

Rules.create( "AmericanCheckers" ) do
  name    "American Checkers"
  version "1.0.0"
  notation :checkers_notation

  players :red, :white

  king :red   => :RED_KING,
       :white => :WHITE_KING

  allow_draws_by_agreement

  cache :init, :moves

  position do
    attr_reader :board, :jumping

    def init
      @board = Board.new( 8, 8 )
      @board[:b1,:d1,:f1,:h1,:a2,:c2,:e2,:g2,:b3,:d3,:f3,:h3] = :red
      @board[:a8,:c8,:e8,:g8,:b7,:d7,:f7,:h7,:a6,:c6,:e6,:g6] = :white

      @jumping = false
    end

    def moves
      p    = turn
      opp  = (p    == :red) ? :white : :red
      k    = rules.king[p]
      oppk = rules.king[opp]

      jd  = (turn == :red) ? [:se, :sw] : [:ne, :nw]
      kjd = [:se, :sw, :ne, :nw]

      found = []

      if jumping
        c = jumping

        (board[c] == k ? kjd : jd).each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          p2 = board[c2 = board.coords.next( c1, d )] if c1
          if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
            found << "#{c}#{c2}"
          end
        end

        return found
      end

      board.occupied[p].each do |c|
        jd.each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          p2 = board[c2 = board.coords.next( c1, d )] if c1
          if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
            found << "#{c}#{c2}"
          end
        end
      end if board.occupied[p]

      board.occupied[k].each do |c|
        kjd.each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          p2 = board[c2 = board.coords.next( c1, d )] if c1
          if (p1 == opp || p1 == oppk) && p2.nil? && !c2.nil?
            found << "#{c}#{c2}"
          end
        end
      end if board.occupied[k]

      return found unless found.empty?

      board.occupied[p].each do |c|
        jd.each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
        end
      end if board.occupied[p]

      board.occupied[k].each do |c|
        kjd.each do |d|
          p1 = board[c1 = board.coords.next( c, d )]
          found << "#{c}#{c1}" if p1.nil? && ! c1.nil?
        end
      end if board.occupied[k]

      found
    end

    def apply!( move )
      coords, p = Coord.expand( move.to_coords ), turn

      board.move( coords.first, coords.last )

      if coords.length == 3
        board[coords[1]] = nil
        @jumping = coords.last

        if moves.empty?
          rotate_turn
          @jumping = false

          clear_cache
        end
      else
        rotate_turn
      end

      if p == :red && coords.last.y == 7
        board[coords.last] = rules.king[:red]
      elsif p == :white && coords.last.y == 0
        board[coords.last] = rules.king[:white]
      end

      self
    end

    def final?
      moves.empty?
    end

    def winner?( player )
      player != turn
    end

    def loser?( player )
      player == turn
    end

    def score( player )
      opp = opponent( player )
      oppk = rules.king[opp]
      12 - board.count( opp ) - board.count( oppk )
    end

    def hash
      [board,turn].hash
    end
  end

end

