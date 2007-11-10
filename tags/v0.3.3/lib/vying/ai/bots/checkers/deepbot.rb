require 'vying/ai/bot'
require 'vying/ai/bots/checkers/checkers'

class AI::Checkers::DeepBot < AI::Bot
  include AI::Checkers::Bot

  def eval( position, player )
    eval_captures( position, player )
  end

  def cutoff( position, depth )
    position.final? || depth >= 3
  end

end

