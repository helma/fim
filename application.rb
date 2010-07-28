gems = ['dm-core', 'dm-serializer', 'dm-sqlite-adapter', 'dm-migrations','dm-is-tree'] 

Shoes.setup do
  gem 'dm-core < 1.0'
  gem 'dm-serializer < 1.0'
  gem 'do_sqlite3 < 1.0'
  gem 'dm-is-tree < 1.0'

	#gems.each { |g| gem g }
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
