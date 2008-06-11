require 'card'

class Deck
  attr_reader :cards

  # Fills the deck with cards in a random order.
  def initialize
    @cards = []
    add_deck!.shuffle!
  end

  # Shuffles 52 more cards into the current deck of cards.
  def add_deck!
    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        # Inserts each card into a random position between 0 and the current
        # number of cards already in @cards.
        @cards.insert( rand(@cards.size), Card.new(suit, value) )
      end
    end

    self
  end

  # Shuffles the deck of cards.
  def shuffle!
    @cards = @cards.sort_by { rand }

    self
  end

  # Takes the top card off of the deck and returns the Card object.
  def take_card
    @cards.pop
  end

  # Reinitializes the deck.
  def reset!
    initialize

    self
  end
end

