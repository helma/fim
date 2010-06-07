gems = ['dm-core', 'dm-serializer', 'do_sqlite3', 'dm-is-tree']

Shoes.setup do
	gems.each { |g| gem g }
end

require 'display'
require 'keyboard'

Shoes.app  do
	@@keyboard = Keyboard.new
	background black
	@stack = stack
	@@display = Display.new(stack)
	@@display.index
	
	keypress do |k|
		@@keyboard.handle k
		if @@display.reload
			case @@keyboard.mode
			when "Index"
				@@display.index
			when "Show"
				@@display.show
			when 'Crop'
				@@display.show_crop
			when 'Command'
				@@display.command
			end
		end
	end
end
