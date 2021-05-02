# frozen_string_literal: true

# stores the selected code and provides related functionality
class Code
  attr_reader :code

  def initialize(secret_code)
    @code = secret_code
  end

  # returns a hash with the number of direct hits and indirect hits
  def check(guess)
    results = {}
    temp_code = @code.split('')
    temp_guess = guess.split('')

    results[:direct] = calc_direct!(temp_code, temp_guess)
    results[:indirect] = calc_indirect!(temp_code, temp_guess)

    results
  end

  def calc_direct!(code, guess)
    direct = 0
    code.each_with_index do |c, i|
      next unless guess[i] == c

      code[i] = 'd'
      guess[i] = 'd'
      direct += 1
    end
    direct
  end

  def calc_indirect!(code, guess)
    indirect = 0

    code.each_with_index do |c, i|
      next if c == 'd' || !guess.include?(c)

      indirect += 1
      code[i] = 'i'
      guess[guess.index(c)] = 'i'
    end
    indirect
  end
end
