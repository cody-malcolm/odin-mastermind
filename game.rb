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
    while @player.guesses_left? && !guessed
      guess = @player.guess_code
      hint = @code.check(guess)
      display_hint(hint)
      guessed = guess_correct?(hint)
      if @player.is_a?(CPUPlayer)
        @player.give_hint(hint, guess)
        sleep(1.5) unless guessed
      end
    end

    @player.print_end_message(guessed, @code.code)
  end

  private

  def guess_correct?(hint)
    hint[:direct] == 4
  end
end
