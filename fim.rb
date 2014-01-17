require 'json'
require 'yaml'
require 'mini_exiftool'
require 'micro-optparse'

@dir = File.read(File.join ENV['HOME'], "images","collection").chomp
@tagfile = File.join @dir, "tag"
@tag = File.read(@tagfile).chomp.to_s

@imagedir = File.join @dir, "images"
@thumbdir = File.join @dir, "thumbs"

@indexfile = File.join @dir, "index.yaml"
@currentfile = File.join @dir, "current"
@action_tags = ["DELETE","KEEP","PRIVATE"]

`fim-update-index` unless File.exist? @indexfile
@index = YAML.load_file(@indexfile) 
@index.keys.each{|t| @index.delete t if @index[t].empty?}

@tag_index = {}

@index.each do |t,imgs|
  imgs.each do |i|
    @tag_index[i] ||= []
    @tag_index[i] << t
  end
end

@current = File.read(@currentfile).chomp.to_i

def save_current
  File.open(@currentfile,"w+"){|f| f.print @current}
end

def save_tag
  File.open(@tagfile,"w+"){|f| f.print @tag}
end

def save_index
  pid = fork{ File.open(@indexfile,"w+"){|f| f.puts @index.to_yaml}}
  Process.detach pid
end

def save_keywords keywords, image=current_image
  pid = fork do
    exif = MiniExiftool.new(image)
    keywords = keywords.uniq - ["_","*"]
    if keywords.empty?
      exif.keywords = nil
    elsif keywords.size == 1
      exif.keywords = keywords.first
    else
      exif.keywords = keywords
    end
    exif.save
  end
  Process.detach pid
end

def exif_keywords image=current_image
  exif = MiniExiftool.new(image)
  [exif.keywords].flatten.uniq.collect{|t| t.to_s}
end

def current_image
  @index[@tag][@current] if @index[@tag] 
end

def group_tags img
  @tag_index[img].grep(/^_\w+/)
end

def group? img
  !(group_tags(img) & group_tags(current_image)).empty?
end

def thumb(idx)
  @index[@tag][idx].sub(/#{@imagedir}/,@thumbdir).sub(/jpg/i,'png')
end
