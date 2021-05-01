# frozen_string_literal: true

require_relative 'output'

# "Abstract" superclass for HumanPlayer and CPUPlayer
class Player
  include Output

  def initialize(max_guesses)
    @max_guesses = max_guesses
    @num_guesses = 0
  end

  def guesses_left?
    @num_guesses < @max_guesses
  end
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

  def print_end_message(successful, code)
    if successful
      print_congratulations
      puts "#{' ' * 10}You broke the secret code!\n\n"
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
  def self.new_cpu(strength)
    case strength
    when :n then NormalCPUPlayer.new
    when :s then StrongCPUPlayer.new
    when :e then ExpertCPUPlayer.new
    end
  end

  def print_end_message(successful, _)
    if successful
      put_message(%i[red], 'The computer broke your code!')
    else
      print_congratulations
      puts 'The computer was unable to break your code!'
    end
    puts ''
  end

  protected

  def pick_code(min_unique)
    code = "#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}"
    code.chars.uniq.length >= min_unique ? code : pick_code
  end

  def guess_code(code)
    @num_guesses += 1

    print "The computer guessed:#{' ' * 6}"
    print_full_code(code)
    code
  end
end

# A fairly naive AI
class NormalCPUPlayer < CPUPlayer
  def initialize
    super(12)
  end

  def pick_code
    super(2)
  end

  def guess_code
    super('2222')
  end
end

# A moderately strong AI
class StrongCPUPlayer < CPUPlayer
  def initialize
    super(8)
  end

  def pick_code
    super(3)
  end

  def guess_code
    super('2222')
  end
end

# An AI that always solves the code in 5 or fewer turns
class ExpertCPUPlayer < CPUPlayer
  def initialize
    super(5)
  end

  def pick_code
    super(4)
  end

  def guess_code
    super('2222')
  end
end
