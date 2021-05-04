# frozen_string_literal: true

require_relative 'code'
require_relative 'output'

# manages the Game state for a single game
class Game
  include Output

  def initialize(codemaker, codebreaker)
    @code = Code.new(codemaker.pick_code)
    @player = codebreaker
  end

  def play
    guessed = false

    guessed = handle_guess while @player.guesses_left? && !guessed

    @player.print_end_message(guessed, @code.code)
    guessed ? @player.num_guesses : @player.num_guesses + 1
  end

  private

  def guess_correct?(hint)
    hint[:direct] == 4
  end

  def handle_guess
    guess = @player.guess_code

    hint = @code.check(guess)
    display_hint(hint)

    guessed = guess_correct?(hint)

    if @player.is_a?(CPUPlayer)
      @player.give_hint(hint, guess)
      sleep(1.5) unless @player.is_a?(KnuthsCPUPlayer) || guessed
    end

    guessed
  end
end
