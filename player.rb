# frozen_string_literal: true

# "Abstract" superclass for HumanPlayer and CPUPlayer
class Player
  def pick_code; end

  def guess_code; end
end

# Implements Human-specific functionalities
class HumanPlayer < Player
  def pick_code
    put_message([], 'Please pick a code for the computer to guess')
    gets.chomp
  end

  def guess_code(number)
    print_message([], "Guess ##{number}: Please guess a code -> ")
    gets.chomp
  end
end

# Implements CPU-specific functionalities
class CPUPlayer < Player
  def pick_code
    '1234'
  end

  def guess_code
    '2222'
  end
end
