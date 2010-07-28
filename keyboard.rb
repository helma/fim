require 'index'
require 'show'
require 'command'
require 'crop'

class Keyboard

	attr_accessor :display, :reload

	def initialize
		@mode = Index.new
		@reload = true
	end

	def mode
		@mode.class.to_s
	end

	def input
		@mode.input
	end

	def navigate
		@mode = Show.new
	end

	def index
		@mode = Index.new
	end

	def handle(k)
		case k
		when :escape # togle input mode
			@mode = Index.new
		when "s"
			@mode = Show.new
		when 'i'
			@@display.info = !@@display.info
			@@display.reload = true
		when ':' 
			@mode = Command.new
		when 'g'
			@mode = Command.new 'goto '
		when 'f'
			@mode = Command.new 'filter '
		when 'c'
			@mode = Crop.new
		when 'q'
			exit
		else
			@mode.handle k
		end
	end

end
