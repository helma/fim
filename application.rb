require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require 'yaml'
require 'mini_exiftool'
#require File.join(File.dirname(__FILE__),"tag.rb")
require File.join(File.dirname(__FILE__),"thumb.rb")

before '/index*' do
  @rows = 7
  @columns = 6
  @index = YAML.load_file("index.yaml")
  @tag = File.read("tag").chomp
  case @tag
  when "*"
    @images = @index.keys.sort
  when "!"
    @images = @index.collect{|k,v| k if v.empty?}.compact.sort
  else
    @images = @index.collect{|k,v| k if v.to_s.include?(@tag)}.compact.sort
  end
  @current = File.read("current").chomp
  @current = @images.first unless @images.include? @current
  @selected = @index.collect{|k,v| k if v.include?("selected")}.compact
end

get '/index' do
  haml :index
end

# index
get %r{/info(.*)} do |img|
  exif = MiniExiftool.new(File.join('public',img))
  "#{img}: #{exif.keywords}" 
end

# show
get %r{/show(.*)} do |img|
  @image = img
  exif = MiniExiftool.new(File.join "public",img)
  @width = exif.imagewidth
  @height = exif.imageheight
  haml :show
end

# change current
post %r{/current(.*)} do |img|
  File.open("current", "w+"){|f| f.puts img}
end

# change index tag
post '/tag' do 
  parse_tags
  File.open("tag", "w+"){|f| f.puts @tag}
end

# toggle image tag
post %r{/tag(.*)} do |img|
  parse_tags
  exif = MiniExiftool.new(File.join('public',img))
  index = YAML.load_file("index.yaml")
  if exif.keywords.to_a.include?(@tag)
    exif.keywords.to_a.delete @tag
    index[img].delete @tag
  else
    q_tags = ["0","1","2","3"]
    exif.keywords = exif.keywords.to_a - q_tags if q_tags.include?(@tag) # unique quality tags
    exif.keywords.to_a << @tag
    index[img] << @tag
  end
  exif.keywords.to_a.uniq!
  exif.save
  index[img].to_a.uniq!
  File.open("index.yaml","w+"){|f| f.puts index.to_yaml}
end

# rotate
post %r{/rotate(.*)} do |img|
  image = File.join 'public', img
  puts `cp -v #{image} #{image}.original`
  `jpegtran -copy all -rotate #{params[:degrees]} #{image}.original > #{image}`
  Thumb.new(img)
end

# crop
get %r{/crop(.*)} do |img|
  @image = img
  exif = MiniExiftool.new(File.join "public",img)
  @width = exif.imagewidth
  @height = exif.imageheight
  haml :crop
end

post "/crop" do 
  original = File.join("public",params[:image])
  cropped = original.sub(/.jpg/i,'crop.jpg')
  puts "jpegtran -copy all -crop #{params[:width]}x#{params[:height]}+#{params[:x]}+#{params[:y]} #{original} > #{cropped}"
  `jpegtran -copy all -crop #{params[:width]}x#{params[:height]}+#{params[:x]}+#{params[:y]} #{original} > #{cropped}` unless original == cropped
  cropped.sub!(/public/,'')
  Thumb.new(cropped)
  File.open("current", "w+"){|f| f.puts cropped}
  index = YAML.load_file("index.yaml")
  index[cropped] = index[params[:image]] 
  File.open("index.yaml","w+"){|f| f.puts index.to_yaml}
  redirect "/index"
end

def parse_tags
  if params[:tag]
    @tag = params[:tag]
  else
    tags = YAML.load_file("index.yaml").collect{|k,v| v}.flatten.compact.uniq.collect{|v| v.to_s}.sort
    @tag = `echo '#{(tags).join("\n")}' | dmenu -b `
  end
end

=begin
@@tag = Tag.new

before do
  @tag = "" unless @tag = File.read("show-tag").chomp
  #@current = 0 unless @current = File.read("current").to_i
end

after do
  File.open("show-tag", "w+"){|f| f.puts @show_tag}
  File.open("current", "w+"){|f| f.puts @current}
end

get '/test' do
  haml :test
end
get '/page/first' do
  File.open("current", "w+"){|f| f.puts @images.first}
  redirect "/index"
end

get '/page/last' do
  File.open("current", "w+"){|f| f.puts @images.last}
  redirect "/index"
end


get '/index/next' do
  @current += @rows*@columns
  @current = @@tag.find(@show_tag).size - 1 if @current > @@tag.find(@show_tag).size
  redirect "/index"
end

get '/index/prev' do
  @current -= @rows*@columns
  @current = 0 if @current < 0
  redirect "/index"
end

# tags
get '/tag' do
  @show_tag = ""
  redirect "/index"
end

get '/tag/select' do
  `echo '#{(@@tag.all - ["delete","keep","portfolio","selected"]).sort.join("\n")}' | dmenu -b `
end

get '/tag/:tag' do
  image = @@tag.find(@show_tag)[@current]
  @show_tag = params[:tag]
  @current = 0 unless @current = @@tag.find(@show_tag).index(image)
  redirect "/index"
end

post %r{/tag/(.*)} do |cur|
  @current = cur.to_i
  image = @@tag.find(@show_tag)[@current]
  @@tag.toggle(params[:tag],image)
  @@tag.find(@show_tag).include?(image).to_s
end


# edit
post "/edit" do
  original = File.join("public",params[:image])
  exif = MiniExiftool.new original
  edit = original.sub(/.jpg/i,'_edit.png')
  `convert #{original} -resize '3648x2048' -quality 95 #{edit}` 
  `exiftool -tagsFromFile  #{original} #{edit}`
  @@tag.update(edit.sub(/public/,''))
  `./edit #{edit} &`
end

# print
get %r{/print(.*)} do |img|
  `./print #{File.join "public",img}`
end

# tools
=end

get '/stylesheet.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :stylesheet
end
