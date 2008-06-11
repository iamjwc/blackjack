# The Card class represents a playing card.
class Card
  SUITS  = [:spades, :hearts, :diamonds, :clubs]
  VALUES = [:ace, 2, 3, 4, 5, 6, 7, 8, 9, 10, :jack, :queen, :king]

  attr_reader :suit, :identifier

  # Initializes card to the appropriate suit and identifier passed in.
  def initialize( suit, identifier )
    @suit, @identifier = suit, identifier
  end

  # Returns if Card is an ace.
  def ace?
    :ace == @identifier
  end

  # Returns if Card is a face card.
  def face_card?
    [:jack,:queen,:king].include? @identifier
  end

  # Returns an array of all possible values for Card.
  def values
    return [1,11] if ace?
    return [10]   if face_card?
    [@identifier]
  end

  # Returns Card's largest possible values.
  def largest_value
    values.max
  end

  # Returns Card's identifier in all caps.
  def to_s
    @identifier.to_s.upcase
  end
end

