#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), "..", "bin")

require 'test/unit'
require 'hand'

# Because Hand.new takes an instance of Player
require 'player'

class TestHand < Test::Unit::TestCase

  def setup
    @hand = Hand.new(Player.new(nil))
  end

  def test_blackjack?
    Card::VALUES.reject {|c| Card.new(nil,c).largest_value == 10 }.each do |c|
      @hand.reset!
      @hand << Card.new(nil, :ace)
      @hand << Card.new(nil, c)

      # Asserts that any hand with an ace and card that doesn't have a value
      # of 10, cannot be a blackjack.
      assert !@hand.blackjack?
    end

    Card::VALUES.select {|c| Card.new(nil,c).largest_value == 10 }.each do |c|
      @hand.reset!
      @hand << Card.new(nil, :ace)
      @hand << Card.new(nil, c)

      # Asserts that every hand with an ace and a card that has a value of 10
      # is a blackjack.
      assert @hand.blackjack?
    end

    Card::VALUES.each do |c|
      @hand.reset!
      @hand << Card.new(nil, c)
      @hand << Card.new(nil, c)

      # Asserts that no hand with two of the same cards can be a blackjack.
      assert !@hand.blackjack?
    end

    Card::VALUES.each do |c|
      @hand.reset!
      @hand.from_split = true

      @hand << Card.new(nil, :ace)
      @hand << Card.new(nil, c)

      # Asserts that any hand that was created from splitting another hand
      # fails, even if it would otherwise be considered blackjack.
      assert !@hand.blackjack?
    end

  end

  def test_soft?
    Card::VALUES.reject {|c| c == :ace }.each do |c|
      @hand.reset!
      @hand << Card.new(nil, :ace)
      @hand << Card.new(nil, c )

      # Asserts that any hand with an ace and any other single card is soft,
      # because the ace will always be worth 11.
      assert @hand.soft?
    end

    Card::VALUES.select {|c| Card.new(nil,c).largest_value == 10 }.each do |c|
      @hand.reset!
      @hand << Card.new(nil, :ace)
      @hand << Card.new(nil, c)
      @hand << Card.new(nil, c)

      # Asserts that two 10 value cards and an ace are not considered soft hands
      # because the ace should be worth 1.
      assert !@hand.soft?
    end
  end

  def test_size
    Card::VALUES.each_with_index do |c,i|
      @hand << Card.new(nil, c)

      # Asserts that there are in fact i+1 cards in the hand.
      assert_equal @hand.size, (i+1)
    end
  end

  def test_busted?
    Card::VALUES.each do |c|
      @hand.reset!
      @hand << Card.new(nil, c)

      # Asserts that any one card in a hand cannot be considered a bust,
      # because the max value for a card is 11.
      assert !@hand.busted?
    end

    Card::VALUES.each do |c1|
      Card::VALUES.each do |c2|
        @hand.reset!
        @hand << Card.new(nil, c1)
        @hand << Card.new(nil, c2)

        # Asserts that no two cards in a hand can be considered a bust,
        # because the max value for any two cards is 21.
        assert !@hand.busted?
      end
    end
  end

  def test_active?
    @hand.stand

    # Asserts that if a hand has had stand called on it, it is no longer active.
    assert !@hand.active?
  end

  def test_splittable?
    Card::VALUES.each do |c1|
      Card::VALUES.each do |c2|
        @hand.reset!
        @hand << Card.new(nil, c1)
        @hand << Card.new(nil, c2)

        if @hand[0].largest_value == @hand[1].largest_value
          # Asserts that if there are only two cards and they have the same
          # value, then they are splittable.
          assert @hand.splittable?
        else
          # Asserts that if the two cards don't have the same value, they are
          # not splittable.
          assert !@hand.splittable?
        end
      end
    end

    Card::VALUES.each do |c1|
      Card::VALUES.each do |c2|
        Card::VALUES.each do |c3|
          @hand.reset!
          @hand << Card.new(nil, c1)
          @hand << Card.new(nil, c2)
          @hand << Card.new(nil, c3)

          # Asserts that no matter what the cards are, if the hand does not have
          # two cards, it is not splittable.
          assert !@hand.splittable?
        end
      end
    end
  end

end

