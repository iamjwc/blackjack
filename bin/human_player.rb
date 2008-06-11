require 'player'
require 'interface'

include Interface

class HumanPlayer < Player
  def initialize( name = "HumanPlayer" )
    super(name)
  end

  # This provides an interface for Player#take_turn. All subclasses of Player
  # should implement this method so that BlackJack will know how the player 
  # wants to act.
  def take_turn( hand, dealer_card )
    msg = "Hit/Stand"
    msg << "/Double-Down" if hand.double_down_allowed?
    msg << "/Split"       if hand.split_allowed?

    msg << " {h/s"
    msg << "/d"  if hand.double_down_allowed?
    msg << "/sp" if hand.split_allowed?
    msg << "}: "

    case Interface::input(msg) {|c| ["h","s","d","sp"].include?(c) }
      when "h": :hit
      when "s": :stand
      when "d": :double_down
      when "sp": :split
    end
  end

  # This is the interface for Player#place_bet.
  def place_bet
    msg = "Place your bet {1-#{available_cash}}: "
    Interface::input(msg) {|b| hand.is_valid_bet?(b.to_i) }.to_i
  end
end

