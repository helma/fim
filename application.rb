require 'rubygems'
require 'sinatra'
require 'tag'

set :sessions, true

helpers do
  def thumb(img)
    File.join("/thumbs",img.sub(/jpg/i,'png'))
  end
end

before do
  #@rows = 7
  #@columns = 9
  @rows = 6
  @columns = 7
end

# index
get '/index/next' do
  total_size = Tag.find(session["tags"]).size
  session["first_id"] = session["first_id"].to_i + @rows*@columns
  #session["first_id"] = total_size - @rows*@columns if session["first_id"] > total_size
  session["current"] = session["first_id"]
  redirect "/index"
end

get '/index/prev' do
  session["first_id"] = session["first_id"].to_i - @rows*@columns
  session["first_id"] = 0 if session["first_id"] < 0
  #session["current"] = session["first_id"]
  redirect "/index"
end

get '/index/:id' do
  session["first_id"] = params[:id].to_i
  redirect "/index"
end

get '/index' do
  session["first_id"] = 0 unless session["first_id"]
  session["tags"] = [] unless session["tags"]
  session["current"] = session["first_id"]
  @images = Tag.find(session["tags"])
  haml :index
end

# show
get '/show/:id' do
  @image = Tag.find(session["tags"])[params[:id].to_i]
  session["current"] = params[:id].to_i
  haml :show
end

# tags
get '/tag' do
  session["tags"] = []
  session["first_id"] = 0
  redirect "/index"
end

get '/tag/:tags' do
  tags = params[:tags].split(/,\s*/).to_a
  session["tags"] = tags
  session["first_id"] = 0
  redirect "/index"
end

get "/tag/image/:id" do
  image = Tag.find(session["tags"])[params[:id].to_i]
  session["current"] = params[:id].to_i
  image + ": " + Tag.tags(image)
end

post "/tag" do
  image = Tag.find(session["tags"])[params[:id].to_i]
  Tag.toggle(params[:tag],image)
end

# tools
post "/rotate" do
  i= Tag.find(session["tags"])[params[:id].to_i]
  image = File.join 'public',i
  `cp #{image} #{image}.original`
  `jpegtran -copy all -rotate #{params[:degrees]} #{image}.original > #{image}`
  thumbnail = File.join 'public', thumb(i)
  `convert #{image} -thumbnail x100 -strip  #{thumbnail}`
  thumb Tag.find(session["tags"])[params[:id].to_i]
end

get '/stylesheet.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :stylesheet
end
