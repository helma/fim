class Thumbnails

	attr_accessor :images, :rows, :columns

	def initialize
		@rows = 4
		@columns = 5
		index
	end

	def ratio(img)
		[@@display.width.to_f/(@columns*img.width),@@display.height.to_f/(@rows*img.height)].min
	end

	def width(img)
		(img.width*ratio(img)).round
	end

	def height(img)
		(img.height*ratio(img)).round#-1
	end

	def index
		@images = []
		current = @@display.image
		@rows.times do
			row = []
			@columns.times do
				row << @@display.image
				@@display.next
			end
			@images << row
		end
		@@display.image = current
	end

	def next
		current = @@display.image
		@@display.image = @images[0][0]
		(@columns*@rows).times { @@display.next }
		index
		@@display.image = current
	end

	def previous
		current = @@display.image
		@@display.image = @images[0][0]
		(@columns*@rows).times { @@display.previous }
		index
		@@display.image = current
	end

end
