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

  # prints the code with a colored background, and a space following it
  def print_code(number)
    print "\e[#{code_key[number]}m #{number} \e[0m"
    print ' '
  end
end
