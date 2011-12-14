require 'flickraw'

@flickrdir = File.join @dir, "flickr"
@flickr_ids = YAML.load_file File.join(@flickrdir,"index.yaml")

begin
  FlickRaw.api_key = File.read(File.join(@flickrdir, "key")).chomp
  FlickRaw.shared_secret = File.read(File.join(@flickrdir, "secret")).chomp
  flickr.access_token = File.read(File.join(@flickrdir, "access-token")).chomp
  flickr.access_secret = File.read(File.join(@flickrdir, "access-secret")).chomp
rescue
  puts "Cannot connect to flickr."
end
