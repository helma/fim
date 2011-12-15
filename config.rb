require 'yajl'
require 'yaml'
require 'mini_exiftool'

@dir = File.join ENV['HOME'], "images"
@imagedir = File.join @dir, "images"
@thumbdir = File.join @dir, "thumbs"

@indexfile = File.join @dir, "index.yaml"
@tagfile = File.join @dir, "tag"
@currentfile = File.join @dir, "current"
@q_tags = ["0","1","2","3","4"]

@index = YAML.load_file(@indexfile)
@index.keys.each{|t| @index.delete t if @index[t].empty?}
@tag = File.read(@tagfile).chomp.to_s
@current = File.read(@currentfile).chomp.to_i
