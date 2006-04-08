
require "test/unit"
require "game"

class TestConnectFour < Test::Unit::TestCase
  def test_init
    g = Game.new( ConnectFour )
    assert_equal( Board.new( 7, 6 ), g.board )
    assert_equal( Player.red, g.turn )
  end

  def test_ops
    g = Game.new( ConnectFour )
    ops = g.ops

    assert_equal( 'a6', ops[0] )
    assert_equal( 'b6', ops[1] )
    assert_equal( 'c6', ops[2] )
    assert_equal( 'd6', ops[3] )
    assert_equal( 'e6', ops[4] )
    assert_equal( 'f6', ops[5] )
    assert_equal( 'g6', ops[6] )

    while ops = g.ops do
      g << ops[0]
    end

    assert_not_equal( g.history[0], g.history.last )

    assert_equal( 42-19, g.board.count( nil ) )
    assert_equal( 10, g.board.count( Piece.red ) )
    assert_equal( 9, g.board.count( Piece.blue ) )
  end

  def test_players
    g = Game.new( ConnectFour )
    assert_equal( [Player.red,Player.blue], g.players )
    assert_equal( [Piece.red,Piece.blue], g.players )
  end

  def test_game01
    # This game is going to be a win for Red (vertical)
    g = Game.new( ConnectFour )
    g << "g6" << "a6" << "g5" << "b6" << "g4" << "c6"
    assert( !g.final? )
    g << "g3"
    assert( g.final? )

    assert( !g.draw? )
    assert( g.winner?( Player.red ) )
    assert( !g.loser?( Player.red ) )
    assert( !g.winner?( Player.blue ) )
    assert( g.loser?( Player.blue ) )

    assert_equal( 1, g.score( Player.red ) )
    assert_equal( -1, g.score( Player.blue ) )
  end

  def test_game02
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << "b6" << "a6" << "c6" << "b5" << "c5" << "c4" << "d6" << "d5" << "d4"
    assert( !g.final? )
    g << "d3"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( g.loser?( Player.red ) )
    assert( g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( -1, g.score( Player.red ) )
    assert_equal( 1, g.score( Player.blue ) )
  end

  def test_game03
    # This game is going to be a win for Blue (diagonal)
    g = Game.new( ConnectFour )
    g << "d6" << "e6" << "c6" << "d5" << "c5" << "c4" << "b6" << "b5" << "b4"
    assert( !g.final? )
    g << "b3"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( g.loser?( Player.red ) )
    assert( g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( -1, g.score( Player.red ) )
    assert_equal( 1, g.score( Player.blue ) )
  end

  def test_game04
    # This game is going to be a draw
    g = Game.new( ConnectFour )
    g << "a6" << "a5" << "a4" << "a3" << "a2" << "a1"
    g << "b6" << "b5" << "b4" << "b3" << "b2" << "b1"
    g << "d6" << "c6" << "c5" << "c4" << "c3" << "c2"
    g << "c1" << "d5" << "d4" << "d3" << "d2" << "d1"
    g << "e6" << "e5" << "e4" << "e3" << "e2" << "e1"
    g << "g6" << "f6" << "f5" << "f4" << "f3" << "f2"
    g << "f1" << "g5" << "g4" << "g3" << "g2"
    assert( !g.final? )
    g << "g1"
    assert( g.final? )

    assert( g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( !g.loser?( Player.red ) )
    assert( !g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( 0, g.score( Player.red ) )
    assert_equal( 0, g.score( Player.blue ) )
  end

  def test_game05
    # This game is going to be a win for Blue (horizontal 5-in-a-row)
    g = Game.new( ConnectFour )
    g << "g6" << "a6" << "a5" << "c6" << "c5" << "d6" << "d5" << "e6" << "e5"
    assert( !g.final? )
    g << "b6"
    assert( g.final? )

    assert( !g.draw? )
    assert( !g.winner?( Player.red ) )
    assert( g.loser?( Player.red ) )
    assert( g.winner?( Player.blue ) )
    assert( !g.loser?( Player.blue ) )

    assert_equal( -1, g.score( Player.red ) )
    assert_equal( 1, g.score( Player.blue ) )
  end

end

