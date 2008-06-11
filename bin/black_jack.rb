require 'dealer'
require 'deck'
require 'event_handler'

class BlackJack
  attr_reader :events

  def initialize
    @dealer = Dealer.new
    @deck   = Deck.new
    @events = EventHandler.new

    @players = []
  end

  # Allows players to join the game.
  def join( player )
    player.number = @players.size+1
    @players << player
  end

  # Plays round after round until all the players have no cash and have been
  # kicked out.
  def play_game
    @events.handle(:game) do
      until @players.empty?
        play_round

        # Remove the players that have no cash left.
        @players.reject! {|p| p.cash <= 0 }
      end
    end
  end

  # Resets the players hands so they can be reused next time.
  def reset_players
    # Replaces the hands array with a new array, with only one hand in it.
    @players.each {|p| p.hands = [p.hand.reset!] }

    # Resets the dealers only hand.
    @dealer.hand.reset!
  end

  # Clears the hands of all of the players, takes the bets, deals the cards,
  # plays the game, figures out the winners, and then reshuffles the deck.
  def play_round 
    @events.handle(:round) do
      reset_players

      take_bets
      deal
      play
      determine_winners
      
      @deck.reset!
    end
  end

  # Returns an array of all of the players at the table, including the dealer.
  def all_at_table
    @players+[@dealer]
  end

  # Calls the Player#place_bet method on each player at the table and sets the
  # bet ammount accordingly.
  def take_bets
    @players.each do |p|
      @events.handle(:pre_player_bet, p)

      p.hand.bet = p.place_bet

      @events.handle(:post_player_bet, p, p.hand.bet)
    end
  end

  # Deals all players two cards by dealing each player one card, then dealing
  # each player a second card.
  def deal
    @events.handle(:deal) do
      2.times do
        all_at_table.each {|p| p.hand << @deck.take_card }
      end
    end
  end

  # Each player plays each of their hands, then the dealer plays his hand.
  def play
    @players.each do |p|
      @events.handle(:player_play, p) do
        p.hands.each {|hand| play_hand(p, hand) }

        p.hands.reject! {|hand| hand.invalid }
      end
    end

    # Dealer plays his hand last.
    @events.handle(:dealer_play, @dealer) do
      dealer_play_hand
    end
  end

  # Plays out a players hand.
  def play_hand( player, hand )
    @events.handle(:player_play_hand, player, hand) do

      while hand.active?
        @events.handle(:player_play_hand_turn, player, hand) do
          if :split == take_turn(player, hand)
            # Automatically return if Player decided to split their hand
            return
          end
        end
      end

    end
  end

  # Plays out the dealers hand.
  def dealer_play_hand
    while @dealer.hand.active?
      take_turn(@dealer, @dealer.hand)
    end
  end

  # Figures out what the player wants to do for each turn.
  def take_turn( player, hand )
    turn = nil
    case turn = player.take_turn(hand, @dealer.up_card)
      when :hit:
        hand.hit(@deck.take_card)

      when :double_down:
        if hand.double_down_allowed?
          hand.double_down(@deck.take_card)
        else
          raise 'Cannot double down!'
        end

      when :split:
        if hand.split_allowed?
          hands = hand.split

          2.times do |i|
            hands[i] << @deck.take_card
            player.hands << hands[i]
          end
        else
          raise 'Cannot split!'
        end

      when :stand:
        hand.stand # Ha... Kinda funny how that worked out.
    end

    turn
  end

  # Tests each players hand to see if win against the dealers.
  def determine_winners
    @events.handle(:determine_winners, @players, @dealer) do
      @players.each do |p|
        determine_winner(p)
      end
    end
  end

  # Figures out which player's hands win against the dealers hands.
  def determine_winner( player )
    @events.handle(:determine_player_win, player, @dealer) do
      player.hands.each do |hand|
        @events.handle(:pre_determine_players_hand_win, hand, @dealer.hand)

        w = hand.winnings(@dealer.hand)
        player.cash += w
        hand.clear_bet!

        @events.handle(:post_determine_players_hand_win, w, hand, @dealer.hand)
      end
    end
  end

end
