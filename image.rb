gems = ['dm-core', 'dm-serializer', 'do_sqlite3', 'dm-is-tree'] unless gems

gems.each { |g| require g }

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/images.sqlite3")

class Image 
	include DataMapper::Resource
	property :id, Serial
	property :parent_id, Integer
	property :file, String
	property :width, Integer
	property :height, Integer
	property :selected, Boolean, :default => false
	property :private, Boolean, :default => false
	property :art, Boolean, :default => false
	property :deleted, Boolean, :default => false
	#property :history, Text
	property :last, Boolean, :default => false

	is :tree, :order => :id

	def info
		tags = ''
		tags += ', selected' if @selected
		tags += ', private' if @private
		tags += ', art' if @art
		tags += ', history' if @history
		tags += ", parent: #{parent.file}" if parent
		unless leaf?
			tags += ', children: '
			children.each do |child|
				tags += child.file
			end
		end
		"#{id}/#{Image.last.id}: #{file}" + tags + @width.to_s + 'x' + @height.to_s
	end

	def leaf?
		children == []
	end

	def leafs
		if children == []
			self
		else
			children.first 
		end
	end

	def root
		image = self
		while image.parent
			image = image.parent
		end
		image
	end

	def self.last_visited
		i = Image.first unless i = Image.first(:last => true)
		i
	end
end

DataMapper.auto_upgrade!
