require 'test/unit'

require 'vying'
require 'vying/rules/rules_test'

class TestThreeMusketeers < Test::Unit::TestCase
  include RulesTests

  def rules
    ThreeMusketeers
  end

  def test_info
    assert_equal( "Three Musketeers", ThreeMusketeers.info[:name] )
  end

  def test_players
    assert_equal( [:red,:blue], ThreeMusketeers.players )
    assert_equal( [:red,:blue], ThreeMusketeers.new.players )
  end

  def test_initialize       # Need to be more thorough here
    g = Game.new( ThreeMusketeers )
    assert_equal( :red, g.turn )
    assert_equal( [:red,:red,:red], g.board[:a5,:c3,:e1] )
    assert_equal( 5, g.board.width )
    assert_equal( 5, g.board.height )
    assert_equal( 22, g.board.occupied[:blue].length )
  end

  def test_has_moves
    g = Game.new( ThreeMusketeers )
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
    g << g.moves.first
    assert_equal( [:blue], g.has_moves )
    g << g.moves.first
    assert_equal( [:red], g.has_moves )
  end

  def test_moves
    g = Game.new( ThreeMusketeers )
    assert_equal( ["a5a4", "a5b5", 
                   "c3c2", "c3d3", "c3b3", "c3c4",
                   "e1d1", "e1e2"].sort, g.moves.sort )
    g << "c3c2"
    assert_equal( :red, g.board[:c2] )
    assert_equal( nil, g.board[:c3] )
    assert_equal( ["b3c3", "d3c3", "c4c3"].sort, g.moves.sort )
  end
end

