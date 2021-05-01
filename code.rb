# frozen_string_literal: true

# stores the selected code and provides related functionality
class Code
  attr_reader :code

  def initialize(secret_code)
    @code = secret_code
  end

  # returns a hash with the number of direct hits and indirect hits
  def check(guess)
    results = { direct: 0, indirect: 0 }
    temp_code = String.new(@code)
    temp_guess = String.new(guess)

    # check_direct! completely removes the direct matches from both temp_code and temp_guess
    # check_indirect's logic is predicated on this removal
    results[:direct] = check_direct!(temp_code, temp_guess)
    results[:indirect] = check_indirect(temp_code, temp_guess)
    results
  end

  private

  # returns the number of direct matches, and strips all direct matches from both the code and the guess
  def check_direct!(code, guess)
    direct_matches = []
    code.chars.each_with_index { |c, i| direct_matches.unshift(i) if guess.slice(i) == c }

    direct_matches.each do |i|
      code.slice!(i)
      guess.slice!(i)
    end

    direct_matches.length
  end

  # adds the earliest index in guess that matches the given char and isn't already in the used_guess_indices ary
  def find_unused_index!(char, guess, used_guess_indices)
    guess_index = guess.index(char)
    guess_index = guess.index(char, guess_index + 1) while used_guess_indices.include?(guess_index)

    used_guess_indices.push(guess_index) unless guess_index.nil?
  end

  # returns the number of indirect matches per Mastermind rules
  def check_indirect(code, guess)
    used_guess_indices = []
    code.chars.each { |c| find_unused_index!(c, guess, used_guess_indices) }

    used_guess_indices.length
  end
end
