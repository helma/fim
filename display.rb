require 'image'

class Display

	attr_accessor :width, :height, :image, :ratio, :img_width, :img_height, :reload, :info, :crop_top, :crop_bottom, :crop_left, :crop_right, :m

	def initialize 
		screen_size = `xrandr | grep '*+'`.split(/\n/).first.sub(/^\s+/,'').split(/\s+/).first.split(/x/).collect{|i| i.to_i}
		@width = screen_size[0]
		@height = screen_size[1]
		@image = Image.last_visited.leafs
		@info = true
		resize
		reset_crop
	end

	def reset_crop
		@crop_top = 0
	 	@crop_bottom = @img_height
	 	@crop_left = 0
	 	@crop_right = @img_width 
	end

	def resize
		@ratio = [@width.to_f/@image.width,@height.to_f/@image.height].min*0.93
		@img_width = (@image.width*@ratio).round
		@img_height = (@image.height*@ratio).round
		@reload = true
	end

	def goto(id)
		@image.root.last = false
		@image.root.save
		case @filter
		when 'deleted'
			@image = Image.first(:id.gte => id, :parent => nil,  :deleted => true)
		when 'selected'
			@image = Image.first(:id.gte => id, :parent => nil,  :selected => true)
		else
			@image = Image.first(:id.gte => id, :parent => nil,  :deleted => false)
		end
		@image = image.leafs
		@image.last = true
		@image.save
		@@keyboard.navigate
		resize
	end

	def filter(condition)
		case condition
		when /^d/
			@filter = 'deleted'
		when /^s/
			@filter = 'selected'
		else
			@filter = ''
		end
		@@keyboard.navigate
	end

	def next
		@image.root.last = false
		@image.root.save
		id = @image.root.id + 1
		id = Image.last.id if id > Image.last.id
		case @filter
		when 'deleted'
			image = Image.first(:id.gte => id, :parent => nil,  :deleted => true)
		when 'selected'
			image = Image.first(:id.gte => id, :parent => nil,  :selected => true)
		else
			image = Image.first(:id.gte => id,  :parent => nil, :deleted => false)
		end
		@image = image.leafs
		@image.last = true
		@image.save
		resize
	end

	def previous
		@image.root.last = false
		@image.root.save
		id = @image.root.id - 1
		id = Image.first.id if id < Image.first.id
		case @filter
		when 'deleted'
			image = Image.last(:id.lte => id, :parent => nil,  :deleted => true)
		when 'selected'
			image = Image.last(:id.lte => id, :parent => nil,  :selected => true)
		else
			image = Image.last(:id.lte => id, :parent => nil,  :deleted => false)
		end
		@image = image.leafs
		@image.last = true
		@image.save
		resize
	end

	def rotate_image
			rotated_file = @image.file.sub(/.jpg/,'rot90.jpg')
			`jpegtran -rotate 90 #{@image.file} > #{rotated_file}`
			@image = @image.children.create :file => rotated_file, :width => @image.height, :height => @image.width
			resize
			@reload = true
	end

	def crop_image
			cropped_file = @image.file.sub(/.jpg/,'crop.jpg')
			width = ((@crop_right-@crop_left)/@ratio).round
			height = ((@crop_bottom-@crop_top)/@ratio).round
			x = (@crop_left/@ratio).round
			y = (@crop_top/@ratio).round
			`jpegtran -crop #{width}x#{height}+#{x}+#{y} #{@image.file} > #{cropped_file}`
			@image = @image.children.create :file => cropped_file, :width => width, :height => height
			resize
			@reload = true
	end

end
