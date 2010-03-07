require 'navigate'
require 'command'
require 'crop'

class Keyboard

	attr_accessor :display, :reload

	def initialize#(display)
		@mode = Navigate.new
		@reload = true
	end

	def mode
		@mode.class.to_s
	end

	def input
		@mode.input
	end

	def navigate
		@mode = Navigate.new
	end

	def handle(k)
		case k
		when :escape # togle input mode
			@mode = Navigate.new
		when 'i'
			@@display.info = !@@display.info
			@@display.reload = true
		when ':' 
			@mode = Command.new
		when 'g'
			@mode = Command.new 'goto '
		when 'f'
			@mode = Command.new	'filter '
		when 'c'
			@mode = Crop.new
		when 'q'
			exit
		else
			@mode.handle k
		end
	end

end
