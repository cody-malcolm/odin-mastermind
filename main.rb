# frozen_string_literal: true

require_relative 'output'
require_relative 'player'
require_relative 'code'
require_relative 'game'

include Output

# put_message(%i[underline red], 'This is a big fat test')
# 1.upto(6) { |i| print_code(i.to_s) }
# puts ''

computer = CPUPlayer.new
#
# puts computer.pick_code
# puts computer.guess_code
#
player = HumanPlayer.new
#
# puts player.pick_code
# puts player.guess_code(3)

# code1 = Code.new('1234')
# puts code1.check('1234')
# puts code1.check('2234')
# puts code1.check('2341')
# puts code1.check('2123')
#
# code2 = Code.new('5555')
# puts code2.check('2123')
# puts code2.check('5555')
# puts code2.check('5565')
# puts code2.check('1254')
# puts code2.check('5050')
#
# code3 = Code.new('4456')
# puts code3.check('2123')
# puts code3.check('4154')
# puts code3.check('4445')
# puts code3.check('4645')
# puts code3.check('4465')
#
# code4 = Code.new('1244')
# puts code4.check('1111')
# puts code4.check('4444')

game = Game.new(computer, player)

game.play
