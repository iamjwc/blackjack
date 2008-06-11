require 'card'

class Hand
  attr_reader   :bet, :invalid
  attr_accessor :from_split

  def initialize( player )
    @player = player

    reset!
  end

  # Resets the hand to its original state.
  def reset!
    @hand = []
    @bet  = 0

    @active     = true
    @invalid    = false
    @from_split = false
    
    @total_out_of_date = true

    self
  end

  # Adds a card to the hand and invalidates the total.
  def <<( card )
    @hand << card
    @total_out_of_date = true
  end

  # Gets a card at any index in the hand.
  def []( index )
    @hand[index].dup
  end

  # Gets the total value of the cards in the player's hand.
  def total
    # Avoids computing total if the total is up to date.
    return @total if !@total_out_of_date

    totals = [0]

    # Loops through each card, adding each of the cards possible values to an
    # array, and then replacing the totals array with the new array
    @hand.each do |card|
      new_totals = []

      # Aces can be worth different values, depending on the rest of the hand,
      # so we add all of its possible values up, and we will decide which is
      # correct at the end.
      card.values.each do |value|
        new_totals += totals.collect {|t| t + value }
      end
      
      totals = new_totals
    end

    @total_out_of_date = false

    # Removes all of the totals bigger than 21, and then returns the largest
    # one left. If no totals are 21 or under, then it returns :bust.
    @total = totals.reject {|t| t > 21 }.max || :bust
  end

  # Indicates if the total is a soft total or not.
  def soft?
    # Creates a new hand with the same cards of this hand, minus the aces.
    copy = Hand.new(nil)
    @hand.each {|c| copy << c unless c.ace? }

    # The hand is considered soft if there are no aces, or if the aces were
    # all valued at 1 in the total.
    copy.total != (total-(size-copy.size))
  end

  # Returns how many cards are in the hand.
  def size
    @hand.size
  end

  # Returns a comma delimited string of all of the cards in the hand.
  def to_s
    @hand.join(", ")
  end

  # Determines if hand busted.
  def busted?
    total == :bust
  end

  # Determines if current hand is considered blackjack.
  def blackjack?
    total == 21 && size == 2 && !@from_split
  end

  # Sets the current bet to 0
  def clear_bet!
    @bet = 0
  end

  # Places bet if the bet is valid.
  def bet=( wager )
    if is_valid_bet?(wager)
      @bet = wager
    else
      raise 'Invalid bet amount'
    end
  end

  # Returns if the player is still able to play in the round or not.
  def active?
    @active = (total != :bust && @active)
  end

  # Computes how much money a hand wins, depending on how it was won/lost.
  def winnings( dealers_hand )
    winnings = 0
    if win_by_blackjack?(dealers_hand)
      winnings = (@bet * 1.5).floor
    elsif win?(dealers_hand)
      winnings = @bet
    elsif lose?(dealers_hand)
      winnings = -@bet
    end

    winnings
  end

  # Hits the player by adding a card to their hand and updating their total.
  # Returns the total.
  def hit( card )
    @hand << card
    @total_out_of_date = true
    total
  end

  # Makes the player inactive, and returns the total.
  def stand
    @active = false
    total
  end

  # If the double down is allowed, the bet is doubled, a card is added to
  # Hand, and then stand is called. Otherwise, error is raised.
  def double_down( card )
    if double_down_allowed?
      @bet *= 2
      hit(card)
      stand
    else
      raise 'Double down not allowed.'
    end
  end

  # If splitting is allowed 2 new hands are created and returned to be placed
  # in Player's hands, and the current hand is invalidated. Otherwise, error
  # is raised.
  def split
    if split_allowed?
      hands = [Hand.new(@player),Hand.new(@player)]

      b = @bet
      clear_bet!
      
      2.times do |i|
        hands[i] << @hand[i]
        hands[i].bet = b
        hands[i].from_split = true
      end

      @invalid = true

      hands
    else
      raise 'Split not allowed.'
    end
  end

  # A double down is allowed whenever a player has enough money to double
  # their bet.
  def double_down_allowed?
    is_valid_bet?(@bet)
  end

  # A split is allowed whenever a player has enough money to double their bet
  # and the hand is Hand#splittable?
  def split_allowed?
    is_valid_bet?(@bet) && splittable?
  end

  # A hand is splittable if the player has only two cards, and the two cards
  # have the same face value
  def splittable?
    size == 2 && @hand.first.largest_value == @hand.last.largest_value
  end

  # If the hand is considered a win and considered blackjack.
  def win_by_blackjack?( hand )
    blackjack? && win?(hand)
  end

  # Determines is the hand wins up against another hand.
  def win?( hand )
    # Dealer busts and Player did not bust
    (hand.busted? && !busted?) ||

    # Dealer does not have blackjack and Player does
    (!hand.blackjack? && blackjack?) ||

    # Dealer does not have blackjack, neither Player nor Dealer busted, and
    # Player total is greater than Dealer total
    (!hand.blackjack? && !hand.busted? && !busted? && total > hand.total)
  end

  # Determines if this hand and the hand it is up against ties.
  def push?( hand )
    # Dealer and Player have blackjack
    (hand.blackjack? && blackjack?) ||

    # Neither Dealer or Player have blackjack and their totals are equal
    (!hand.blackjack? && !blackjack? && total == hand.total)
  end

  # Determines is the hand loses up against another hand.
  def lose?( hand )
    # Player neither wins nor ties
    !win?(hand) && !push?(hand)
  end

  # Returns whether the bet being placed is valid or not. Valid bets must be
  # an integer value and must be between $1 and the amount of cash that that
  # player has.
  def is_valid_bet?( wager )
    wager.integer? && (1..@player.available_cash) === wager
  end

end

