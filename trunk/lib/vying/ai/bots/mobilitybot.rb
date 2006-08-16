require 'game'

class MobilityBot < Bot
  include Minimax

  attr_reader :leaf, :nodes

  def initialize( user_id, username )
    super
    @leaf, @nodes = 0, 0
  end

  def select( position, player )
    @leaf, @nodes = 0, 0
    score, op = best( analyze( position ) )
    puts "**** Searched #{nodes}:#{leaf} positions, best: #{score}"
    op
  end

  def evaluate( position, player )
    @leaf += 1
    player_score = position.ops ? position.ops.length : 0
    position.turn( :rotate )
    opp_score = position.ops ? position.ops.length : 0
    player_score - opp_score
  end

  def cutoff( position, depth )
    position.final? || depth >= 2
  end
end
