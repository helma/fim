@dir = File.join ENV['HOME'], "images"
@imagedir = File.join @dir, "images"
@thumbdir = File.join @dir, "thumbs"
@flickrdir = File.join @dir, "flickr"

@indexfile = File.join @dir, "index.yaml"
@tagfile = File.join @dir, "tag"
@currentfile = File.join @dir, "current"
