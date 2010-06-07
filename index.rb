class Index 

	def initialize
		@mult = 1
	end

	def handle(k)
		case k
		when /\d/
			@mult = k.to_i
		when 'h'
			@mult.times { @@display.previous }
			while !@@display.thumbnails.images.flatten.include? @@display.image
				@@display.thumbnails.previous 
			end
			@mult = 1
		when 'l'
			@mult.times { @@display.next }
			while !@@display.thumbnails.images.flatten.include? @@display.image
				@@display.thumbnails.next 
			end
			@mult = 1
		when 'j'
			(@mult*@@display.thumbnails.columns).times{ @@display.next }
			while !@@display.thumbnails.images.flatten.include? @@display.image
				@@display.thumbnails.next 
			end
			@mult = 1
		when 'k'
			(@mult*@@display.thumbnails.columns).times{ @@display.previous }
			while !@@display.thumbnails.images.flatten.include? @@display.image
				@@display.thumbnails.previous 
			end
			@mult = 1
		when ' '
			(@mult*@@display.thumbnails.rows*@@display.thumbnails.columns).times{ @@display.next }
			@mult.times { @@display.thumbnails.next }
			@mult = 1
		when 'b'
			(@mult*@@display.thumbnails.rows*@@display.thumbnails.columns).times{ @@display.previous }
			@mult.times { @@display.thumbnails.previous }
			@mult = 1
		when 'r'
			@@display.rotate
		when 's'
			@@display.image.selected = !@@display.image.selected
			@@display.image.save
		when 'd'
			@@display.image.deleted = !@@display.image.selected
			@@display.image.save
			@@display.next
		when 'a'
			@@display.image.art = !@@display.image.art
			@@display.image.save
		when 'p'
			@@display.image.private = !@@display.image.private
			@@display.image.save
		end
		@@display.reload = true
	end

end

