require 'rubygems'
require 'sinatra'
require 'tag'

#set :sessions, true
enable :sessions

helpers do
  def thumb(img)
    File.join("/thumbs",img.sub(/jpg/i,'png'))
  end
end

before do
  @rows = 6
  @columns = 7
  @images = Tag.find(session["show_tag"])
end

# index
get '/index/next' do
  session["page"] = session["page"] + 1 unless session["page"] >= @images.size/(@rows*@columns)
  session["current"] = session["page"]*@rows*@columns
  redirect "/index"
end

get '/index/prev' do
  session["page"] = session["page"] - 1 
  session["page"] = 0 if session["page"] < 0
  session["current"] = session["page"]*@rows*@columns
  redirect "/index"
end

get '/index' do
  session["page"] = 0 unless session["page"]
  session["show_tag"] = "" unless session["show_tag"]
  session["current"] = session["page"]*@rows*@columns unless session["current"]
  haml :index
end

# show
get '/show/:id' do
  @image = @images[session["current"]]
  haml :show
end

# tags
get '/tag' do
  session["show_tag"] = ""
  session["page"] = 0
  session["current"] = 0
  redirect "/index"
end

get '/tag/:tag' do
  session["show_tag"] = params[:tag]
  session["page"] = 0
  session["current"] = 0
  redirect "/index"
end

post "/tag" do
  image = @images[params[:id].to_i]
  Tag.toggle(params[:tag],image)
  "removed" if Tag.find(session["show_tag"]).index(image).nil?
=begin
    session["current"] = params[:id].to_i
  else
    session["current"] += 1
  end
  redirect "/index"
=end
end

# tools
get "/info/:id" do 
  session["current"] = params[:id].to_i
  image = @images[session["current"]]
  image + ": " + Tag.tags(image) + session.inspect
end

post "/rotate" do
  i = @images[params[:id].to_i]
  image = File.join 'public', i
  puts `cp -v #{image} #{image}.original`
  `jpegtran -copy all -rotate #{params[:degrees]} #{image}.original > #{image}`
  thumbnail = File.join 'public', thumb(i)
  `convert #{image} -thumbnail x100 -strip  #{thumbnail}`
  thumb i
end

get '/stylesheet.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :stylesheet
end
