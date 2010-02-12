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
	property :history, Text
	property :last, Boolean, :default => false

	is :tree, :order => :id

	def info
		"#{id}/#{Image.last.id}: #{file}"
		#self.attributes.collect{|k,v| "#{k}: #{v}" if v and k != :last}.compact.join(", ") + ", last id: #{Image.last.id}"
	end

	def history_add(filename)
		if self.history.nil?
			self.history = filename
		else
			self.history = self.history + ', ' + filename
		end
	end
end

DataMapper.auto_upgrade!
