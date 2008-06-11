require 'black_jack'
require 'human_player'
require 'interface'

include Interface

class BlackJackConsole
  def initialize
    @b = BlackJack.new

    setup_handlers!
  end

  def setup_handlers!
    @b.events.add :pre_player_bet do |player,bet|
      Interface::pause_and_clear_screen

      Interface::seperator
      puts "Player #{player.number}: #{player}"
    end

    @b.events.add :post_player_bet do |player,bet|
      Interface::newline
      puts "You bet $#{bet}. Thank you."
      Interface::newline
    end

    @b.events.add :pre_player_play do |player|
      Interface::pause_and_clear_screen
      Interface::seperator
      puts "Player #{player.number}: #{player}"
    end

    @b.events.add :pre_player_play_hand_turn do |player,hand|
      puts  "  Hand: #{hand}"
      puts  "  Total: #{hand.total}"
      Interface::newline
    end

    @b.events.add :post_player_play_hand_turn do |player,hand|
      Interface::newline
    end

    @b.events.add :post_player_play_hand do |player,hand|
      puts  "  Hand: #{hand}"
      puts  "  Total: #{hand.total}"
      Interface::newline

      if hand.busted?
        puts "  BUST!"
      else
        puts "  Standing..."
      end
      Interface::newline
    end
    
    @b.events.add :pre_determine_player_win do |player,dealer|
      Interface::pause_and_clear_screen

      Interface::seperator
      puts "Player #{player.number}: #{player}"
      puts "  Previous Cash: $#{player.cash}"
      Interface::newline
      puts "  Dealer Hand: #{dealer.hand}"
      puts "  Dealer Total: #{dealer.hand.total}"
      Interface::newline
    end

    @b.events.add :post_determine_players_hand_win do |winnings,p_hand,d_hand|
      puts "  Hand: #{p_hand}"
      puts "  Total: #{p_hand.total}"
      if p_hand.win_by_blackjack?(d_hand)
        puts "    Won $#{winnings} by BlackJack!"
      elsif p_hand.win?(d_hand)
        puts "    Won $#{winnings}!"
      elsif p_hand.lose?(d_hand)
        puts "    Lost $#{winnings.abs}."
      else
        puts "    Push."
      end
      Interface::newline
    end

    @b.events.add :post_determine_player_win do |player,dealer|
      puts "  Post Cash: $#{player.cash}"
      Interface::newline

      if player.cash <= 0
        puts "Player #{player.number} loses..."
        Interface::newline
      end
    end
  end

  def get_number_of_players
    Interface::seperator

    count = Interface::input("How many players? {1-4}: ") do |o|
      (1..4) === o.to_i
    end

    Interface::newline

    count.to_i
  end

  def get_player_names( count )
    Interface::seperator

    count.times do |i|
      name = Interface::input("Player #{i+1}'s name: ") do |o|
        !o.empty?
      end

      @b.join( HumanPlayer.new(name) )
    end

    Interface::newline
  end

  # Calling this will run the new instance of the BlackJack game.
  def run
    Interface::header
    Interface::newline

    count = get_number_of_players
    get_player_names( count )

    @b.play_game
  end

  private :setup_handlers!, :get_number_of_players, :get_player_names
end

