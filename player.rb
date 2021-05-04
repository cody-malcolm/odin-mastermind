# frozen_string_literal: true

require_relative 'output'
require_relative 'code'

# "Abstract" superclass for HumanPlayer and CPUPlayer
class Player
  include Output

  attr_reader :num_guesses

  def initialize(max_guesses)
    @max_guesses = max_guesses
    setup
  end

  def guesses_left?
    @num_guesses < @max_guesses
  end

  # resets the number of guesses
  def reset
    setup
  end

  private

  def setup
    @num_guesses = 0
  end
end

# Implements Human-specific functionalities
class HumanPlayer < Player
  def initialize
    super(12)
  end

  # prompts user for a secret code, validates and displays it, and returns the code selected
  def pick_code
    print 'Please pick a code for the computer to guess (eg. 1346): '
    selection = gets.chomp
    until valid_guess?(selection)
      print "That isn't a valid code. Please pick a code for the computer to guess: "
      selection = gets.chomp
    end

    print "\nThe secret code is:#{' ' * 13}"
    print_full_code(selection)
    puts "\n\n"
    selection
  end

  # promps user for a guess, validates and displays it, and returns the guess
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

  # prints the human player specific game end message
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

  # returns true if the guess is valid
  def valid_guess?(guess)
    guess.match?(/^[1-6]{4}$/)
  end

  # displays a message prompting the player for a guess
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

  # returns true if this is the player's last guess
  def last_guess?
    @num_guesses == @max_guesses
  end
end

# Implements CPU-specific functionalities
class CPUPlayer < Player
  def initialize(max_guesses)
    super(max_guesses)
    setup
  end

  # resets @s
  def reset
    super
    setup
  end

  # class method that returns an appropriate child class instance based on the parameter
  def self.new_cpu(strength)
    case strength
    when :n then NormalCPUPlayer.new
    when :s then StrongCPUPlayer.new
    when :e then ExpertCPUPlayer.new
    when :k then KnuthsCPUPlayer.new
    else NormalCPUPlayer.new # parameter is pre-validated, so this should never happen, but...
    end
  end

  # print the computer-specific game end message
  def print_end_message(successful, _)
    if successful
      put_message(%i[red], 'The computer broke your code!')
    else
      print_congratulations
      puts 'The computer was unable to break your code!'
    end
    puts ''
  end

  # processes a hint by removing all elements of @s which would not give the same hint
  def give_hint(hint, guess)
    @s.select! { |candidate| Code.new(candidate).check(guess) == hint }
  end

  protected

  # picks a code and either returns it (if sufficient number of unique digits) or recursively calls itself
  def pick_code(min_unique)
    code = "#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}#{rand(1..6)}"
    code.chars.uniq.length >= min_unique ? code : pick_code
  end

  # handles common portion of CPUPlayer guess_code function
  def guess_code(code)
    @num_guesses += 1

    print_message(%i[underline], "Guess ##{@num_guesses}")
    print ': The computer guessed: '
    print_full_code(code)
    code
  end

  # create and return set of all 1296 possible codes
  def create_set
    s = []
    1.upto(6) { |w| 1.upto(6) { |x| 1.upto(6) { |y| 1.upto(6) { |z| s.push("#{w}#{x}#{y}#{z}") } } } }
    s
  end

  private

  def setup
    super
    @s = create_set # s is the set of remaining possible combinations
  end
end

# An artifically slowed down AI
class NormalCPUPlayer < CPUPlayer
  def initialize
    super(8) # this AI can fail, it occasionally requires 9 guesses with bad luck
    setup
  end

  # resets initial_guesses
  def reset
    super
    setup
  end

  # normal AIs can pick any possible code except '1111', '2222', ..., '6666'
  def pick_code
    super(2)
  end

  # the AI for a normal CPU, usually but not always identifies the code in 8 moves
  def guess_code
    # prune any initial guesses that are guaranteed to give 'xxxx' response

    # for example, if the code is '1123' and the AI has already guessed '1111', '2222', and '3333', then the AI
    # already knows that the code does not include any '4', '5', or '6', and will not waste turns making those guesses

    # reverse is needed to ensure every index is checked when entries are being deleted
    @initial_guesses.reverse.each { |g| @initial_guesses.delete(g) if @s.none? { |c| c.include?(g.slice(0)) } }

    # choose initial guesses at random until all are guessed or eliminated, then choose randomly from @s
    super(@initial_guesses.empty? ? @s.sample : @initial_guesses.slice!(rand(@initial_guesses.length)))
  end

  private

  # set the initial guesses
  def setup
    super
    @initial_guesses = %w[1111 2222 3333 4444 5555 6666]
  end
end

# A strong AI, with some fake initial guesses to slow it down a bit
class StrongCPUPlayer < CPUPlayer
  def initialize
    super(7)
    setup
  end

  def reset
    super
    setup
  end

  def pick_code
    super(3) # strong AIs require at least three unique digits, so '1223' is allowed but '1414' would not be
  end

  # the AI for a strong CPU, structure is essentially identical to normal CPU (see normal CPU for detailed comments)
  def guess_code
    @initial_guesses.reverse.each do |g|
      @initial_guesses.delete(g) if @s.none? { |c| c.include?(g.slice(0)) || c.include?(g.slice(2)) }
    end

    super(@initial_guesses.empty? ? @s.sample : @initial_guesses.slice!(rand(@initial_guesses.length)))
  end

  private

  def setup
    super
    @initial_guesses = %w[1122 3344 5566]
  end
end

# An expert AI, but without Knuth's minimax
class ExpertCPUPlayer < CPUPlayer
  def initialize
    super(6)
    setup
  end

  def reset
    super
    setup
  end

  def pick_code
    super(4) # expert AIs always choose a code with 4 unique digits
  end

  # the AI for the expert CPU. Starts with a randomly selected initial guess then randomly chooses from @s
  def guess_code
    super(@num_guesses.zero? ? @initial_guess.sample : @s.sample)
  end

  private

  def setup
    super
    @initial_guess = %w[1122 1133 1144 1155 1166 2233 2244 2255 2266 3344 3355 3366 4455 4466 5566]
  end
end

# An AI that always solves the code in 5 or fewer turns (Knuth's algorithm). Is an Easter Egg, since it's still
# relatively slow on repl.it
# This fully implements Knuth's algorithm including the minimax component, as described in his 1976 paper:
# http://www.cs.uni.edu/~wallingf/teaching/cs3530/resources/knuth-mastermind.pdf
class KnuthsCPUPlayer < CPUPlayer
  def initialize
    super(5)
    setup
    print_easter_egg
  end

  def reset
    super
    setup
  end

  def pick_code
    super(4) # same as expert CPU, Knuth's AI will only select codes with 4 unique digits
  end

  # always start with '1122' (per Knuth's algo), then apply the full algorithm based on previous hints
  def guess_code
    selection = @num_guesses.zero? ? '1122' : apply_knuths

    @full_set.delete(selection) # remove the current selection from the full set (per Knuth's algo)

    super(selection)
  end

  private

  # Knuth's AI
  def apply_knuths
    options = {}
    # for every unchecked code, store it with its worst-case number of remaining possibilities in @s
    @full_set.each { |combo| options[combo] = max_possibilities(combo) }
    # find out whice of the worst-case possibilities is the best in terms of minimizing the next size of @s
    minimizing_value = options.values.min
    # identify all codes we could pick with this best worst-case performance
    minimizing_combos = options.select { |_, v| v == minimizing_value }.keys
    # iterate through the identified codes and return it if is possibly the secret code
    minimizing_combos.each { |combo| return combo if @s.include?(combo) }
    minimizing_combos[0] # if none of the 'best' guesses are in @s, return the first. Recommend read pg3 of the paper
  end

  # given one code, checks every element of @s with that code to get the hint response (if the @s code was the secret
  # code). Then returns the highest of the possible hint responses (worst case scenario)
  def max_possibilities(combo)
    hint_counts = Hash.new(0)
    @s.each do |code|
      hint_counts[Code.new(code).check(combo)] += 1
    end
    hint_counts.values.max
  end

  def print_easter_egg
    put_message([:orange], "Easter Egg found! Playing against super-tough Knuth's AI!")
    puts 'Please be aware that the second guess may take up to 20 seconds, please be patient.'
    puts ''
  end

  def setup
    super
    @full_set = create_set # separate from @s (which gets pruned), the minimax algo uses an (almost) full list of codes
  end
end
