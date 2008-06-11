require 'hand'

class Player
  attr_accessor :cash, :number, :hands
  attr_reader   :name

  def initialize( name )
    @hands = [Hand.new(self)]
    @cash  = 1000

    @name   = name
    @number = 0
  end

  # Returns the first (and often times the only) hand for Player.
  def hand
    @hands[0]
  end

  # Returns how much cash Player currently has left that can be bet.
  def available_cash
    sum = @hands.inject(0) {|sum, hand| sum += hand.bet }

    @cash-sum
  end
  
  # Returns a formatted string with Player information.
  def to_s
    "#{@name} ($#{available_cash})"
  end
end

