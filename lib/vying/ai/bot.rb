# Copyright 2007, Eric Idema except where otherwise noted.
# You may redistribute / modify this file under the same terms as Ruby.

require 'vying/rules'

class Bot < User
  attr_accessor :cache, :delegates

  def initialize( username=nil, id=nil )
    username ||= name

    super( username, id )

    @cache = Search::Cache::FallThrough.new
    @delegates = {}
  end

  def bot?
    true
  end

  def ready?
    true
  end

  def self.plays?( rules )
    self.w_const_defined?( rules.class_name.intern )
  end

  def plays?( rules )
    self.class.w_const_defined?( rules.class_name.intern )
  end

  def delegate_for( position )
    k = position.rules.class_name.intern

    return @delegates[k] if @delegates.key?( k )

    if self.class.w_const_defined?( k )
      @delegates[k] = self.class.w_const_get( k ).new
      @delegates[k].cache = cache
      @delegates[k]
    end
  end

  def select( sequence, position, player )
    return position.moves.first if position.moves.length == 1

    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :select )
      return delegate.select( sequence, position, player )
    end

    score, move = best( analyze( position, player ) )

    move 
  end

  def resign?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :resign? )
      return delegate.resign?( sequence, position, player )
    end

    false
  end

  def offer_draw?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :offer_draw? )
      return delegate.offer_draw?( sequence, position, player )
    end

    false
  end

  def accept_draw?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :accept_draw? )
      return delegate.accept_draw?( sequence, position, player )
    end

    false
  end

  def request_undo?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :request_undo? )
      return delegate.request_undo?( sequence, position, player )
    end

    false
  end

  def accept_undo?( sequence, position, player )
    delegate = delegate_for( position )
    if delegate && delegate.respond_to?( :accept_undo? )
      return delegate.accept_undo?( sequence, position, player )
    end

    false
  end

  def analyze( position, player )
    h = {}
    position.moves.each do |move|
      delegate = delegate_for( position )
      if delegate && delegate.respond_to?( :evaluate )
        h[move] = delegate.evaluate( position.apply( move ), player )
      else
        h[move] = evaluate( position.apply( move ), player )
      end
    end
    h
  end

  def best( scores )
    scores = scores.invert
    m = scores.max
    #puts "scores: #{scores.inspect} (taking #{m.inspect})"
    m
  end

  def fuzzy_best( scores, delta )
    s = []
    scores.each { |move,score| s << [score,move] }
    m = s.max
    ties = s.select { |score,move| (score - m.first).abs <= delta }
    m = ties[rand(ties.length)]
    #puts "scores: #{s.inspect}, t: #{ties.inspect} (taking #{m.inspect})"
    m
  end

  def to_s
    username || self.class.to_s
  end

  def name
    to_s
  end

  def inspect
    "#<Bot #{name}>"
  end

  def Bot.require_all( path=$: )
    required = []
    path.each do |d|
      Dir.glob( "#{d}/**/bots/**/*.rb" ) do |f|
        f =~ /(.*)\/bots\/(.*\.rb)$/
        if ! required.include?( $2 ) && !f["_test"]
          required << $2
          require "#{f}"
        end
      end
    end
  end

  @@bots_list = []
  @@bots_play = {}

  def self.inherited( child )
    a = child.to_s.split( /::/ )
    if a.length > 1
      bc = a[0,a.length-1].join( "::" )
      if @@bots_list.any? { |b| b.to_s == bc }
        b = Bot.find( bc )
        r = Rules.find( a.last )
        (@@bots_play[r] ||= []) << b if b && r
      else
        @@bots_list << child
      end
    else
      @@bots_list << child
    end
  end

  def Bot.list( rules=nil )
    return @@bots_list.select { |b| b.plays?( rules ) } if rules
    @@bots_list
  end

  def Bot.play( rules )
    @@bots_play[Rules.find( rules )]
  end

  def Bot.find( name )
    Bot.list.each do |b|
      return b if name.to_s.downcase == b.to_s.downcase ||
                  name.to_s.downcase == b.name.downcase

      a = name.to_s.split( "::" )
      if a.length > 1
        bc = a[0,a.length-1].join( "::" )
        b = Bot.find( bc )
        r = Rules.find( a.last )
        return b if b && r && b.plays?( r )
      end
    end

    nil
  end

  DIFFICULTY_LEVELS = { :easy   => 0,
                        :medium => 1,
                        :hard   => 2 }

  def self.difficulty( d=nil )
    @difficulty = DIFFICULTY_LEVELS[d]
    class << self 
      def difficulty_name; DIFFICULTY_LEVELS[@difficulty]; end
      def difficulty; @difficulty; end
    end
    d
  end

  def self.difficulty_for( rules )
    if self.w_const_defined?( "#{rules.class_name}".intern )
      d = self.w_const_get( "#{rules.class_name}".intern ).difficulty
      return DIFFICULTY_LEVELS.invert[d] if d && DIFFICULTY_LEVELS.invert[d]
    end
    return :unknown
  end

  def difficulty_for( rules )
    self.class.difficulty_for( rules )
  end

end

