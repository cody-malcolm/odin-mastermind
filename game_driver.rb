# frozen_string_literal: true

require_relative 'output'
require_relative 'player'
require_relative 'game'
require_relative 'match'

# manages the flow of the application
class GameDriver
  include Output
  def initialize
    @quit = false
  end

  def run
    print_welcome_banner

    offer_explanation

    prompt_for_game_type until @quit

    say_goodbye
  end

  private

  def offer_explanation
    selection = prompt_for_selection(%i[y n], 'Would you like an explanation of the rules? (y/n): ')
    puts selection == :y ? "\n#{explanation}" : "\n"
  end

  def prompt_for_game_type
    selection = prompt_for_selection(%i[s m q], 'Would you like a (s)ingle game, a (m)atch, or to (q)uit? (s/m/q): ')
    puts ''
    case selection
    when :s then setup_single_game
    when :m then setup_match
    when :q then @quit = true
    end
  end

  def say_goodbye
    puts 'Thank you for playing!'
  end

  def pick_computer_level
    prompt = 'Would you like to play against a (n)ormal, (s)trong, or (e)xpert computer? (n/s/e): '
    strength = prompt_for_selection(%i[n s e k], prompt)
    puts ''
    CPUPlayer.new_cpu(strength)
  end

  def setup_single_game
    computer = pick_computer_level
    selection = prompt_for_selection(%i[c b], 'Would you like to (c)reate the secret code, or (b)reak it? (c/b): ')
    puts ''

    player = HumanPlayer.new

    game = selection == :b ? Game.new(computer, player) : Game.new(player, computer)

    game.play
  end

  def setup_match
    computer = pick_computer_level
    player = HumanPlayer.new

    match = Match.new(computer, player)

    match.play
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
