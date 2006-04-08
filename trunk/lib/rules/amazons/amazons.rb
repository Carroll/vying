# NAME
#   Amazons
#
# RESOURCES
#   Wikipedia <http://en.wikipedia.org/wiki/Amazons_(game)>
#

require 'board/standard'
require 'game'

class Amazons < Rules

  INFO = info( __FILE__ )

  class Position < Struct.new( :board, :turn, :lastc, :wqs, :bqs, :ops_cache )
    def to_s
      "Board:\n#{board}\nTurn: #{turn}\n Last: #{lastc}"
    end
  end

  def Amazons.init
    b = Board.new( 10, 10 )

    wqs = [Coord[0,3], Coord[3,0], Coord[6,0], Coord[9,3]]
    bqs = [Coord[0,6], Coord[3,9], Coord[6,9], Coord[9,6]]
    
    wqs.each { |c| b[c] = Piece.white }
    bqs.each { |c| b[c] = Piece.black }

    ps = PlayerSet.new( Piece.white, Piece.black )

    Position.new( b, ps, nil, wqs, bqs, :ns )
  end

  def Amazons.players
    [Piece.white, Piece.black]
  end

  def Amazons.op?( position, op )
    return false unless op.to_s =~ /(\w\d+)(\w\d+)/
    sc = Coord[$1]
    ec = Coord[$2]

    queens = position.turn == Piece.white ? position.wqs : position.bqs

    return false unless queens.include?( sc )
    return false unless d = sc.direction_to( ec )

    ic = sc
    while (ic = position.board.coords.next( ic, d ))
      return false if !position.board[ic].nil?
      break        if ic == ec
    end

    return true
  end

  def Amazons.ops( position )
    return position.ops_cache if position.ops_cache != :ns

    a = []
    b = position.board

    queens = position.turn == Piece.white ? position.wqs : position.bqs

    if position.lastc.nil? || b[position.lastc] == Piece.arrow
      queens.each do |c| 
        [:n,:e,:s,:w,:ne,:nw,:se,:sw].each do |d|
          ic = c
          while (ic = b.coords.next( ic, d ))
            b[ic].nil? ? a << "#{c}#{ic}" : break;
          end
        end
      end
    else
      [:n,:e,:s,:w,:ne,:nw,:se,:sw].each do |d|
        ic = position.lastc
        while (ic = b.coords.next( ic, d ))
          b[ic].nil? ? a << "#{position.lastc}#{ic}" : break;
        end
      end
    end

    position.ops_cache = a == [] ? nil : a
  end

  def Amazons.apply( position, op )
    op.to_s =~ /(\w\d+)(\w\d+)/
    sc = Coord[$1]
    ec = Coord[$2]

    pos = position.dup

    if pos.lastc.nil? || pos.board[pos.lastc] == Piece.arrow
      pos.board.move( sc, ec )
      queens = pos.turn == Piece.white ? pos.wqs : pos.bqs
      queens.delete( sc )
      queens << ec
    else
      pos.board[ec] = Piece.arrow
      pos.turn.next!
    end

    pos.lastc = ec
    pos.ops_cache = :ns
    pos
  end

  def Amazons.final?( position )
    !ops( position )
  end

  def Amazons.winner?( position, player )
    position.turn != player
  end

  def Amazons.loser?( position, player )
    position.turn == player
  end

  def Amazons.draw?( position )
    false
  end


end
