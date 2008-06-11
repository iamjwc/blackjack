#!/usr/bin/env ruby
$:.unshift File.join(File.dirname(__FILE__), "..", "bin")

require 'test/unit'
require 'player'

class TestPlayer < Test::Unit::TestCase

  def setup
    @player = Player.new(nil)
  end

  def test_available_cash
    cash = @player.cash

    100.upto(200) do |i|
      @player.hand.bet = i

      # Asserts that the available_cash is equal to original cash minus the bet.
      assert_equal @player.available_cash, (cash-i)
    end
  end

end

