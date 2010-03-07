gems = ['dm-core', 'dm-serializer', 'do_sqlite3', 'dm-is-tree']

Shoes.setup do
	gems.each { |g| gem g }
end

require 'display'
require 'keyboard'

@@display = Display.new
@@keyboard = Keyboard.new

Shoes.app  do
	background black
	@stack = stack do
		image @@display.image.file, :width => @@display.img_width, :height => @@display.img_height
		para @@display.image.info, :size => 10, :stroke => white
	end
	
	keypress do |k|
		@@keyboard.handle k
		if @@display.reload
			@stack.clear do
				image @@display.image.file, :width => @@display.img_width, :height => @@display.img_height 
				case @@keyboard.mode
				when 'Crop'
					fill_color = '#555'
					rect :top => @@display.crop_bottom, :left => 0, :width => @@display.img_width, :height => @@display.img_height-@@display.crop_bottom, :fill => fill_color, :stroke => fill_color
					rect :top => 0, :left => @@display.crop_right, :width => @@display.img_width-@@display.crop_right, :height => @@display.img_height, :fill => fill_color, :stroke => fill_color
					rect :top => 0, :left => 0, :width => @@display.img_width, :height => @@display.crop_top, :fill => fill_color, :stroke => fill_color
					rect :top => 0, :left => 0, :width => @@display.crop_left, :height => @@display.img_height, :fill => fill_color, :stroke => fill_color
					para @@keyboard.mode, :size => 10, :stroke => white
				when 'Command'
					para "> " + @@keyboard.input, :size => 10, :stroke => white
				else
					@@display.reset_crop
					para @@display.image.info, :size => 10, :stroke => white if @@display.info == true
				end
			end
		end
	end
end
