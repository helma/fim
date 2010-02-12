gems = ['dm-core', 'dm-serializer', 'do_sqlite3', 'dm-is-tree']

Shoes.setup do
	gems.each { |g| gem g }
end

require 'database'

Shoes.app  do

	@screen_size = `xrandr | grep '*+'`.split(/\n/).first.sub(/^\s+/,'').split(/\s+/).first.split(/x/).collect{|i| i.to_i}
	@command = false
	@mode = :command
	@filter = ''
	@image = Image.first unless @image = Image.first(:last => true)
	display

	keypress do |k|
		if k == :escape # togle input mode
			@command = !@command
			@input = '' 
			display
		end
		if @command
			case k
			when "\n"
				case @input
				when /^filter/
					items = @input.split(/\s+/)
					@input = items.first + "'" + items[1] + "'" # paranthesis for string argument
				end
				begin
					eval @input
				rescue => e
					alert "Cannot evaluate #{@input} #{e.message} #{e.backtrace}"
				end
				@command = !@command
				@input = '' 
			when :backspace
				@input.slice!(-1)
			else
				@input += k
			end
		else
			@image.last = false
			@image.save
			case k
			when 'j'
				id = @image.id + 1
				id = Image.last.id if id > Image.last.id
				case @filter
				when 'deleted'
					@image = Image.first(:id.gte => id, :deleted => true)
				when 'selected'
					@image = Image.first(:id.gte => id, :selected => true)
				else
					@image = Image.first(:id.gte => id, :deleted => false)
				end
			when 'k'
				id = @image.id - 1
				id = Image.first.id if id < Image.first.id
				case @filter
				when 'deleted'
					@image = Image.last(:id.lte => id, :deleted => true)
				when 'selected'
					@image = Image.last(:id.lte => id, :selected => true)
				else
					@image = Image.last(:id.lte => id, :deleted => false)
				end
			when 'r'
				rotated_file = @image.file.sub(/.jpg/,'rot90.jpg')
				`jpegtran -rotate 90 #{@image.file} > #{rotated_file}`
				@image.history_add @image.file
				@image.file = rotated_file
				@image.save
			when 's'
				@image.selected = !@image.selected
				@image.save
			when 'a'
				@image.art = !@image.art
				@image.save
			when 'p'
				@image.private = !@image.private
				@image.save
			when 'd'
				@image.deleted = !@image.selected
				@image.save
			when 'g'
				@command = true
				@input = 'goto '
			when 'f'
				@command = true
				@input = 'filter '
			when 'q'
				exit
			end
		end
		display
	end

	def display
		ratio = 0.9*[@screen_size[0].to_f/@image.width,@screen_size[1].to_f/@image.height].min
		@image.last = true
		@image.save
		clear
		background black
		stack do
			img = image @image.file, :width => (@image.width*ratio).to_i, :height => (@image.height*ratio).to_i
			para @image.info, :size => 10, :stroke => white
			para "> " + @input, :size => 10, :stroke => white if @command
		end
	end

	def crop
		background	@image.file, :height => 680
		mask do
			fill black
			rect :top => 20, :left => 20, :width => 260, :height => 300
		end
	end

	def goto(id)
		case @filter
		when 'deleted'
			@image = Image.first(:id.gte => id, :deleted => true)
		when 'selected'
			@image = Image.first(:id.gte => id, :selected => true)
		else
			@image = Image.first(:id.gte => id, :deleted => false)
		end
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
	end

	def crop
		mask do
			title "Shoes", :weight => "bold", :size => 82
		end

	end

end
