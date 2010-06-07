# TODO: Add square selection
class Crop

	attr_accessor :input

	def initialize
		@step = 10
	end

	def handle(k)
		case k
		when 'h'
			@@display.crop_left += @step 
		when 'H'
			@@display.crop_left -= @step unless @@display.crop_left - @step < 0
		when 'l'
			@@display.crop_right -= @step unless @@display.crop_right - @step < 0
		when 'L'
			@@display.crop_right += @step
		when 'j'
			@@display.crop_top += @step
		when 'J'
			@@display.crop_top -= @step unless @@display.crop_top - @step < 0
		when 'k'
			@@display.crop_bottom -= @step unless @@display.crop_bottom - @step < 0
		when 'K'
			@@display.crop_bottom += @step
		when '1'
			@step = 1
		when '2'
			@step = 10
		when '3'
			@step = 100
		when "\n"
			@@keyboard.navigate
			@@display.crop
		end
		@@display.reload = true
	end

end
