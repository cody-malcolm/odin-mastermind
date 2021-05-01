# frozen_string_literal: true

# 31 = red
# 32 = green
# 33 = orange
# 41-47, 100-106 = white on color
# 5 flashing
# 7 black on white background
# 4 single underline

# 41.upto(47) { |i| puts "\e[#{i}m#{i}\e[0m" }
# 100.upto(106) { |i| puts "\e[#{i}m#{i}\e[0m" }

# puts "\e[4m\e[5m\e[31mWarning!\e[0m\e[0m\e[0m"
#
# text = "Warning!"
#
# text = style(4, text)
# text = style(5, text)
# text = style(31, text)
#
# puts text

# Handles the output of command line messages
module Output
  # convert given code into corresponding color code
  def code_key
    {
      '1' => 41,
      '2' => 43,
      '3' => 102,
      '4' => 42,
      '5' => 44,
      '6' => 45
    }
  end

  # convert memorable keys to corresponding color codes
  def style_key
    {
      red: 31,
      green: 32,
      orange: 33,
      blue: 94,
      background: 40,
      blinking: 5,
      underline: 4,
      invert: 7
    }
  end

  # recursively apply all styles to the given text
  def style(styles, text)
    return text if styles.empty?

    current_style = styles.pop
    style(styles, "\e[#{style_key[current_style]}m#{text}\e[0m")
  end

  # wrappers for puts, print, and p, with styling
  def put_message(styles, message)
    puts style(styles, message)
  end

  def print_message(styles, message)
    print style(styles, message)
  end

  def p_message(styles, message)
    p style(styles, message)
  end

  def print_full_code(code)
    code.chars.each { |c| print_code(c) } # TODO: look into why (&:print_code) doesn't pass argument
    puts ''
  end

  # prints the code with a colored background, and a space following it
  def print_code(number)
    print "\e[#{code_key[number]}m #{number} \e[0m"
    print ' '
  end

  def code_as_string(code)
    code.chars.map { |c| "\e[#{code_key[c]}m #{c} \e[0m" }.join(' ')
  end

  def display_hint(hint)
    print 'The hint for that guess is: '
    hint[:direct].times { print "\u25C6 " }
    hint[:indirect].times { print "\u25C7 " }
    (4 - hint[:direct] - hint[:indirect]).times { print "\u00D7 " }
    puts "\n\n"
  end

  def print_welcome_banner
    print ' ' * 10
    put_message(%i[invert blue background], ' ****************************** ')
    print ' ' * 10
    put_message(%i[invert blue background], ' *   Welcome to Mastermind!   * ')
    print ' ' * 10
    put_message(%i[invert blue background], ' ****************************** ')
    puts ''
  end

  def game_overview
    <<~OVERVIEW
      In Mastermind, you play against the computer to see who is better at breaking a secret code.
    OVERVIEW
  end

  def game_rules
    <<~RULES
      The secret code is four numbers long and built from the following: #{code_as_string('123456')}

      Duplicates are allowed, and there are 1296 total possible combinations.

      In order to help break the code, after every attempt a hint will be given, as follows:
      - A \u25C6  will be shown for every guessed number that is in the correct spot
      - A \u25C7  will be shown for every guessed number that is in the secret code, but is in the wrong spot
      - A \u00D7  will be shown for every number that is not present in the secret code

      Note that the order these hints are displayed does #{style(%i[underline], 'not')} correspond to the order of \
      the numbers in the guess. They are always displayed in the order: \u25C6 \u25C7 \u00D7

      The human player always gets 12 attempts to break the code. The computer gets a varying number based on \
      AI intelligence level selected.
    RULES
  end

  def examples
    <<~EXAMPLE
      For example, given the secret code #{code_as_string('4456')} and the guess #{code_as_string('4154')}, the \
      corresponding hint would be \u25C6 \u25C6 \u25C7 \u00D7, because positions 1 and 3 are correct, and the number \
      in position 4 of the guess is present at position 2 of the secret code. There is no '1' in the code, so there \
      is one \u00D7 displayed.

      As another example, given the secret code #{code_as_string('1234')} and the guess #{code_as_string('4423')}, \
      the corresponding hint would be \u25C7 \u25C7 \u25C7 \u00D7, because there are 3 numbers from the guess \
      present in the code, but none of them are in the correct position.
    EXAMPLE
  end

  def game_modes
    <<~MODES
      There are two game modes. Select a "single" game if you only want to play a game as the code maker or code \
      breaker. Select a "match" game if you would like to play a match against the computer.

      In a match, you will specify the number of rounds you wish to play, and for each round, you and the computer \
      will each get a chance to 'make' and 'break' the code. Each round, you will each earn points as the code maker \
      based on how many turns it takes for your code to be broken and AI difficulty chosen. The winner of the match \
      is the one with the most points after all the rounds are completed.
    MODES
  end
end
