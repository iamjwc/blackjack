#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), "..", "bin")

require 'test/unit'
require 'card'

class TestCard < Test::Unit::TestCase

  def test_ace?
    Card::SUITS.each do |suit|
      # Asserts that these cards are aces
      assert Card.new(suit, :ace).ace?

      # Removes all of the values that are aces
      Card::VALUES.reject {|value| value == :ace }.each do |value|
        # Asserts that these cards are NOT aces
        assert !Card.new( suit, value ).ace?
      end
    end
  end

  def test_face_card?
    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        if [:king,:queen,:jack].include? value
          # Asserts that these cards are face cards
          assert Card.new(suit, value).face_card?
        else
          # Asserts that these cards are NOT face cards
          assert !Card.new(suit, value).face_card?
        end
      end
    end
  end

  def test_values
    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        c = Card.new(suit, value)

        if c.ace?
          # Asserts that aces return these two exact values
          assert_equal [1,11], c.values
        elsif c.face_card?
          # Asserts that face cards return an array with just 10
          assert_equal [10], c.values
        else
          # Asserts that other cards return an array with just their value
          assert_equal [value], c.values
        end
      end
    end
  end

  def test_largest_value
    Card::SUITS.each do |suit|
      Card::VALUES.each do |value|
        c = Card.new(suit, value)

        if c.ace?
          # Asserts that aces return these two exact values
          assert_equal 11, c.largest_value
        elsif c.face_card?
          # Asserts that face cards return an array with just 10
          assert_equal 10, c.largest_value
        else
          # Asserts that other cards return an array with just their value
          assert_equal value, c.largest_value
        end
      end
    end
  end

end
