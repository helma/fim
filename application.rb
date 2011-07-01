require 'rubygems'
require 'sinatra'
require 'haml'
require 'sass'
require File.join(File.dirname(__FILE__),"tag.rb")
require File.join(File.dirname(__FILE__),"thumb.rb")

@@tag = Tag.new

before do
  @rows = 7
  @columns = 6
  @show_tag = "" unless @show_tag = File.read("show-tag").chomp
  @current = 0 unless @current = File.read("current").to_i
end

after do
  File.open("show-tag", "w+"){|f| f.puts @show_tag}
  File.open("current", "w+"){|f| f.puts @current}
end

# index
get '/index/first' do
  @current = 0
  redirect "/index"
end

get '/index/last' do
  @current = @@tag.find(@show_tag).size - 1
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

get '/index' do
  first = @current - @current.modulo(@rows*@columns)
  last = first + @rows*@columns 
  @images = @@tag.find(@show_tag)[first..last]
  puts @images.inspect
  @selected = @@tag.find("selected")
  haml :index
end

# show
get %r{/show/(.*)} do |cur|
  @current = cur.to_i
  @image = @@tag.find(@show_tag)[@current]
  exif = MiniExiftool.new(File.join "public",@image)
  @width = exif.imagewidth
  @height = exif.imageheight
  haml :show
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

# rotate
get %r{/rotate(.*)} do |img|
  #@current = img
  image = File.join 'public', img
  puts `cp -v #{image} #{image}.original`
  `jpegtran -copy all -rotate #{params[:degrees]} #{image}.original > #{image}`
  Thumb.new(img)
end

# crop
get %r{/crop(.*)} do |img|
  #@current = img
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
  @@tag.update(cropped)
  #@current = cropped
  redirect "/index"
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
post %r{/current/(.*)} do |cur|
  @current = cur
end

get %r{/info/(.*)} do |current|
  images = @@tag.find(@show_tag)
  "#{images[current.to_i]}: #{@@tag.tags(images[current.to_i])} (#{@show_tag} #{current}/#{images.size})"
end

get '/stylesheet.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :stylesheet
end
