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
    @num_guesses += 1

    guess = prompt_for_guess

    until valid_guess?(guess)
      puts "That wasn't a valid guess! Guesses should be 4 digits and contain only the numbers 1-6."
      guess = prompt_for_guess
    end
    print "Your guess:#{' ' * 10}"
    print_full_code(guess)
    guess
  end

  def guesses_left?
    @num_guesses < @max_guesses
  end

  def print_end_message(successful, code)
    if successful
      print_message(%i[green blinking], "#{' ' * 12}***")
      print_message(%i[green], 'CONGRATULATIONS!')
      put_message(%i[green blinking], '***')
      puts "#{' ' * 10}You broke the secret code!"
    else
      print "Sorry, you were unsuccessful breaking the code. Better luck next time!\nThe secret code was: "
      print_full_code(code)
      puts ''
    end
  end

  private

  def valid_guess?(guess)
    guess.match?(/^[1-6]{4}$/)
  end

  def prompt_for_guess
    if last_guess?
      print_message(%i[orange blinking underline], 'Warning')
      print ": Last guess! \u21D2  "
    else
      print_message(%i[underline], "Guess ##{@num_guesses}")
      print ": Please enter a guess (eg. 1346) \u21D2  "
    end

    gets.chomp
  end

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
