require 'player'

class Dealer < Player

  def initialize
    super("Dealer")
    @cash = 0
  end

  # The dealer must hit while their total is less than 17.
  def take_turn( hand, dealer_hand )
    if hand.total < 17
      :hit
    else
      :stand
    end
  end

  # Dealer has two cards originally, one face up, and one face down. This
  # returns the card that was dealt face up.
  def up_card
    hand[1].dup
  end

  # Returns the name for Dealer.
  def to_s
    @name
  end
end
