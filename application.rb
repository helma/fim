require 'rubygems'
require 'sinatra'
require 'tag'
require 'thumb'

enable :sessions

@@tag = Tag.new

before do
  @rows = 7
  @columns = 7
end

# index
get '/index/first' do
  session["page"] = 0
  redirect "/index"
end

get '/index/last' do
  @images = @@tag.find(session["show_tag"])
  session["page"] = @images.size/(@rows*@columns)
  redirect "/index"
end

get '/index/next' do
  @images = @@tag.find(session["show_tag"])
  session["page"] = session["page"] + 1 unless session["page"] >= @images.size/(@rows*@columns)
  redirect "/index"
end

get '/index/prev' do
  session["page"] = session["page"] - 1 
  session["page"] = 0 if session["page"] < 0
  redirect "/index"
end

get '/index' do
  session["page"] = 0 unless session["page"]
  session["show_tag"] = "" unless session["show_tag"]
  first = session["page"]*@rows*@columns
  last = first + @rows*@columns -1
  @images = @@tag.find(session["show_tag"])
  @size = @images.size
  @images = @images[first..last]
  unless @current = @images.index(session["current"]) 
    @current = 0
    session["current"] = @images[0]
  end
  @selected = @@tag.find("selected")
  haml :index
end

# show
get %r{/show(.*)} do |img|
  session["current"] = img
  @image = img
  exif = MiniExiftool.new(File.join "public",img)
  @width = exif.imagewidth
  @height = exif.imageheight
  haml :show
end

# tags
get '/tag' do
  session["show_tag"] = ""
  session["page"] = 0
  redirect "/index"
end

get '/tag/select' do
  `echo '#{(@@tag.all - ["delete","keep","portfolio","selected"]).sort.join("\n")}' | dmenu -b `
end

get '/tag/:tag' do
  session["show_tag"] = params[:tag]
  session["page"] = 0
  redirect "/index"
end

post %r{/tag(.*)} do |image|
  session["current"] = image
  @@tag.toggle(params[:tag],image)
  @@tag.find(session["show_tag"]).include?(image).to_s
end

# rotate
get %r{/rotate(.*)} do |img|
  session["current"] = img
  image = File.join 'public', img
  puts `cp -v #{image} #{image}.original`
  `jpegtran -copy all -rotate #{params[:degrees]} #{image}.original > #{image}`
  Thumb.new(img)
end

# crop
get %r{/crop(.*)} do |img|
  session["current"] = img
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
  session["current"] = cropped
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
post %r{/current(.*)} do |img|
  session["current"] = img
end

get %r{/info(.*)} do |image|
  session["current"] = image
  @images = @@tag.find(session["show_tag"])
  image + ": " + @@tag.tags(image) #+ session.inspect
end

get '/stylesheet.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :stylesheet
end
