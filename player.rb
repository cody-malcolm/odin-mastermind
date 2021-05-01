# frozen_string_literal: true

# "Abstract" superclass for HumanPlayer and CPUPlayer
class Player
  def initialize(max_guesses)
    @max_guesses = max_guesses
    @num_guesses = 0
  end

  def pick_code; end

  def guess_code; end
end

# Implements Human-specific functionalities
class HumanPlayer < Player
  def initialize
    super(8)
  end

  def pick_code
    put_message([], 'Please pick a code for the computer to guess')
    gets.chomp
  end

  def guess_code
    @num_guesses += 1 if guesses_left?

    if last_guess?
      print_message(%i[orange blinking underline], 'Warning')
      puts ': Last guess!'
    else
      print_message(%i[underline], "Guess ##{@num_guesses}")
      puts ': Please enter a guess (eg. 2345)'
    end

    gets.chomp
  end

  def guesses_left?
    @num_guesses < @max_guesses
  end

  def print_end_message(successful, code)
    if successful
      print_message(%i[green blinking], '**')
      print_message(%i[green], 'CONGRATULATIONS!')
      print_message(%i[green blinking], '**')
      puts 'You broke the secret code!'
    else
      print "Sorry, you were unsuccessful breaking the code. Better luck next time!\nThe secret code was: "
      print_full_code(code)
      puts ''
    end
  end

  private

  def last_guess?
    @num_guesses == @max_guesses
  end
end

# Implements CPU-specific functionalities
class CPUPlayer < Player
  def initialize
    super(num_guesses: 4)
  end

  def pick_code
    "#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}"
  end

  def guess_code
    '2222'
  end
end
