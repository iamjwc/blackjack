#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), "..", "bin")

require 'test/unit'
require 'deck'

ITERATIONS = 100

class TestDeck < Test::Unit::TestCase

  def setup
    @deck = Deck.new
  end

  def test_add_deck!
    ITERATIONS.times do |i|
      # Asserts that there are 52*(i+1) cards in the deck
      assert_equal @deck.cards.size, 52*(i+1)
      @deck.add_deck!
    end
  end

  def test_shuffle!
    ITERATIONS.times do |i|
      # Gets a deep copy of the array.
      cards_copy = @deck.cards.collect {|card| card }

      # Asserts that the old copy of the cards array, and the newly shuffled
      # cards are not the same.
      assert_not_equal @deck.shuffle!.cards, cards_copy
    end
  end

  def test_take_card
    ITERATIONS.times do |i|
      # Gets the top card off of the deck.
      top_card  = @deck.cards.last
      deck_size = @deck.cards.size

      # Asserts that the top card is the same as the card that was returned by
      # take card
      assert_equal @deck.take_card, top_card

      # Asserts that the deck now has one card less than it did before the card
      # was taken, if the top card wasn't nil.
      assert_equal @deck.cards.size, deck_size-1 unless top_card.nil?
    end
  end

end
