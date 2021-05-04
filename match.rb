# frozen_string_literal: true

require_relative 'code'
require_relative 'output'

# manages a Match between the computer and the player
class Match
  include Output

  def initialize(computer, player)
    @num_rounds = prompt_for_rounds
    @computer = computer
    @player = player
    @scores = { @computer => 0, @player => 0 }
  end

  def play
    @num_rounds.times do |round|
      print_new_round_info(round + 1)

      play_single_game(@computer, @player)
      play_single_game(@player, @computer)
    end

    puts "The match is over! The final score is: #{scores}"
    puts ''
  end

  private

  def print_new_round_info(round)
    puts "Round ##{round} is about to begin!"
    puts "The current score is: #{scores}"
    puts ''
  end

  def prompt_for_rounds
    2
  end

  def play_single_game(codemaker, codebreaker)
    game = Game.new(codemaker, codebreaker)
    @scores[codemaker] += game.play
    codebreaker.reset
  end

  def scores
    "Computer #{@scores[@computer]}, You #{@scores[@player]}"
  end
end
