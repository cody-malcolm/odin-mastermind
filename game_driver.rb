# frozen_string_literal: true

require_relative 'output'
require_relative 'player'
require_relative 'game'

# manages the flow of the application
class GameDriver
  include Output

  def run
    print_welcome_banner

    offer_explanation

    quit = false

    quit = prompt_for_game_type? until quit

    say_goodbye
  end

  private

  def offer_explanation
    selection = prompt_for_selection(%i[y n], 'Would you like an explanation of the rules? (y/n): ')
    puts selection == :y ? "\n#{explanation}" : "\n"
  end

  def prompt_for_game_type?
    print "For now, press 'y' to quit: "
    selection = gets.chomp
    puts ''
    setup_single_game unless selection == 'y'
    selection == 'y'
  end

  def say_goodbye
    puts 'Thank you for playing!'
  end

  def setup_single_game
    computer = CPUPlayer.new
    player = HumanPlayer.new

    game = Game.new(computer, player)

    game.play
  end

  def prompt_for_selection(options, prompt)
    print prompt
    selection = gets.chomp.to_sym
    until options.include? selection
      puts "\nSorry, that wasn't a valid selection."
      print prompt
      selection = gets.chomp.to_sym
    end
    selection
  end

  def explanation
    "#{game_overview}\n#{game_rules}\n#{examples}\n#{game_modes}\n"
  end
end
