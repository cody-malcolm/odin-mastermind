# frozen_string_literal: true

# manages the Game state for a single game
class Game
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
    end

    @player.print_end_message(guessed, @code.code)
  end

  private

  def guess_correct?(hint)
    hint[:direct] == 4
  end

  def display_hint(hint)
    hint[:direct].times { print_direct_match }
    hint[:indirect].times { print_indirect_match }
    puts ''
  end
end
