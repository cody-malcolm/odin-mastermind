# frozen_string_literal: true

require_relative 'output'
require_relative 'code'

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
    print 'Please pick a code for the computer to guess: '
    selection = gets.chomp
    until valid_guess?(selection)
      print "That isn't a valid code. Please pick a code for the computer to guess: "
      selection = gets.chomp
    end

    print "\nThe secret code is:        "
    print_full_code(selection)
    puts "\n\n"
    selection
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
  def initialize(max_guesses)
    super(max_guesses)
    @s = create_set
  end

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

  def give_hint(hint, guess)
    @s.select! { |candidate| Code.new(candidate).check(guess) == hint }
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

  def create_set
    s = []
    1.upto(6) do |w|
      1.upto(6) do |x|
        1.upto(6) do |y|
          1.upto(6) do |z|
            s.push("#{w}#{x}#{y}#{z}")
          end
        end
      end
    end
    s
  end
end

# An artifically slowed down AI
class NormalCPUPlayer < CPUPlayer
  def initialize
    super(12)
  end

  def pick_code
    super(2)
  end

  def guess_code
    case @num_guesses
    when 0 then super('1111')
    when 1 then super('2222')
    when 2 then super('3333')
    when 3 then super('4444')
    when 4 then super('5555')
    when 5 then super('6666')
    else super(@s[0])
    end
  end
end

# A strong AI, with some fake initial guesses to slow it down a bit
class StrongCPUPlayer < CPUPlayer
  def initialize
    super(8)
  end

  def pick_code
    super(3)
  end

  def guess_code
    case @num_guesses
    when 0 then super('1122')
    when 1 then super('3344')
    when 2 then super('5566')
    else super(@s[0])
    end
  end
end

# An AI that always solves the code in 5 or fewer turns (Knuth's algorithm)
class ExpertCPUPlayer < CPUPlayer
  def initialize
    super(5)
    @full_set = create_set
    @possible_hints = generate_possible_hints
  end

  def pick_code
    super(4)
  end

  def guess_code
    selection = @num_guesses.zero? ? '1122' : apply_knuths

    @full_set.delete(selection)

    super(selection)
  end

  private

  def generate_possible_hints
    [
      { direct: 0, indirect: 0 }, { direct: 1, indirect: 0 },
      { direct: 0, indirect: 1 }, { direct: 1, indirect: 1 },
      { direct: 0, indirect: 2 }, { direct: 1, indirect: 2 },
      { direct: 0, indirect: 3 }, { direct: 1, indirect: 3 },
      { direct: 0, indirect: 4 }, { direct: 2, indirect: 0 },
      { direct: 3, indirect: 0 }, { direct: 2, indirect: 1 },
      { direct: 4, indirect: 0 }, { direct: 2, indirect: 2 }
    ]
  end

  def apply_knuths
    options = {}
    @full_set.each { |combo| options[combo] = max_possibilities(combo) }
    minimizing_value = options.values.min
    minimizing_combos = options.select { |_, v| v == minimizing_value }.keys
    minimizing_combos.each { |combo| return combo if @s.include?(combo) }
    minimizing_combos[0]
  end

  def max_possibilities(combo)
    @possible_hints.reduce(0) do |a, h|
      num = @s.count { |c| Code.new(c).check(combo) == h }
      a > num ? a : num
    end
  end
end
