require 'image'
require 'thumbnails'

class Display

	attr_accessor :width, :height, :image, :reload, :info, :crop_top, :crop_bottom, :crop_left, :crop_right, :stack, :thumbnails

	def initialize(stack) 
		screen_size = `xrandr`.split(/\n/).last.sub(/^\s+/,'').split(/\s+/).first.split(/x/).collect{|i| i.to_i}
		@width = screen_size[0]
		@height = screen_size[1]
		@image = Image.last_visited.leaves.last
		@info = true
		@stack = stack
		reset_crop
	end

	def reset_crop
		@crop_top = 0
	 	@crop_bottom = img_height
	 	@crop_left = 0
	 	@crop_right = img_width 
	end

	def ratio
		[@width.to_f/@image.width,@height.to_f/@image.height].min*0.93
	end

	def img_width
		(@image.width*ratio).round
	end

	def img_height
		(@image.height*ratio).round
	end

	def filter(condition)
		case condition
		when /^d/
			@filter = :deleted
		when /^s/
			@filter = :selected
		when /^a/
			@filter = :art
		when /^p/
			@filter = :private
		else
			@filter = false
		end
		goto @image.id
		@@keyboard.show
	end

	def goto(id)
		@image.root.last_visited = false
		@image.root.save
		if @filter
			@image = Image.first(:id.gte => id, :parent => nil,  @filter => true)
		else
			@image = Image.first(:id.gte => id, :parent => nil,  :deleted => false)
		end
		@image = image.leaves.last
		@image.last_visited = true
		@image.save
#		@@keyboard.show
	end

	def next
		@image.root.last_visited = false
		@image.root.save
		id = @image.root.id + 1
		id = Image.last.id if id > Image.last.id
		if @filter
			@image = Image.first(:id.gte => id, :parent => nil,  @filter => true)
		else
			@image = Image.first(:id.gte => id, :parent => nil,  :deleted => false)
		end
=begin
		case @filter
		when 'deleted'
			image = Image.first(:id.gte => id, :parent => nil,  :deleted => true)
		when 'selected'
			image = Image.first(:id.gte => id, :parent => nil,  :selected => true)
		else
			image = Image.first(:id.gte => id,  :parent => nil, :deleted => false)
		end
=end
		@image = image.leaves.last
		@image.last_visited = true
		@image.save
	end

	def previous
		@image.root.last_visited = false
		@image.root.save
		id = @image.root.id - 1
		id = Image.first.id if id < Image.first.id
		if @filter
			@image = Image.last(:id.lte => id, :parent => nil,  @filter => true)
		else
			@image = Image.last(:id.lte => id, :parent => nil,  :deleted => false)
		end
=begin
		case @filter
		when 'deleted'
			image = Image.last(:id.lte => id, :parent => nil,  :deleted => true)
		when 'selected'
			image = Image.last(:id.lte => id, :parent => nil,  :selected => true)
		else
			image = Image.last(:id.lte => id, :parent => nil,  :deleted => false)
		end
=end
		@image = image.leaves.last
		@image.last_visited = true
		@image.save
	end

	def rotate
			rotated_file = @image.file.sub(/.jpg/,'rot90.jpg')
			`jpegtran -rotate 90 #{@image.file} > #{rotated_file}`
			@image = @image.children.create :file => rotated_file, :width => @image.height, :height => @image.width
			@reload = true
	end

	def crop
			cropped_file = @image.file.sub(/.jpg/,'crop.jpg')
			width = ((@crop_right-@crop_left)/self.ratio).round
			height = ((@crop_bottom-@crop_top)/self.ratio).round
			x = (@crop_left/self.ratio).round
			y = (@crop_top/self.ratio).round
			`jpegtran -crop #{width}x#{height}+#{x}+#{y} #{@image.file} > #{cropped_file}`
			@image = @image.children.create :file => cropped_file, :width => width, :height => height
			@reload = true
	end

	def index
		@thumbnails = Thumbnails.new if @thumbnails.nil?
		@stack.app do
			@stack.clear do
				@@display.thumbnails.images.each do |row|
					stack do
						flow do
							row.each do |img|
								stack :width => @@display.width/5-1 do
									image img.file, :width => @@display.thumbnails.width(img), :height => @@display.thumbnails.height(img)
									border black
									border white if @@display.image == img
								end
							end
						 end
					end
				end
			end
		end
	end

	def show
		@stack.app do
			@stack.clear do
				image @@display.image.file, :width => @@display.img_width, :height => @@display.img_height 
				@@display.reset_crop
				para @@display.image.info, :size => 10, :stroke => white if @@display.info == true
			end
		end
	end

	def command
		@stack.app do
			@stack.clear do
				image @@display.image.file, :width => @@display.img_width, :height => @@display.img_height 
				para "> " + @@keyboard.input, :size => 10, :stroke => white
			end
		end
	end
	
	def show_crop
		@stack.app do
			@stack.clear do 
				image @@display.image.file, :width => @@display.img_width, :height => @@display.img_height 
				fill_color = '#555'
				rect :top => @@display.crop_bottom, :left => 0, :width => @@display.img_width, :height => @@display.img_height-@@display.crop_bottom, :fill => fill_color, :stroke => fill_color
				rect :top => 0, :left => @@display.crop_right, :width => @@display.img_width-@@display.crop_right, :height => @@display.img_height, :fill => fill_color, :stroke => fill_color
				rect :top => 0, :left => 0, :width => @@display.img_width, :height => @@display.crop_top, :fill => fill_color, :stroke => fill_color
				rect :top => 0, :left => 0, :width => @@display.crop_left, :height => @@display.img_height, :fill => fill_color, :stroke => fill_color
				para @@keyboard.mode, :size => 10, :stroke => white
			end
		end
	end

end
