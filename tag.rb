require 'rubygems'
require 'mini_exiftool'
require 'yaml'

class Tag

  attr_accessor :tags

  def initialize
    if File.exist?("tags.yaml")
      @tags = YAML.load_file("tags.yaml")
    else
      @tags = {}
      @tags["all"] = []
    end
    @quality = ["delete","keep","work","portfolio"]
  end

  def find(tag)
    if tag.nil? or tag == ""
      @tags["all"].sort
    elsif tag == "empty"
      images = @tags["all"]
      @quality.each { |t| images = images - @tags[t] }
      images.sort
    else
      @tags[tag].sort
    end
  end

  def all
    @tags.keys
  end

  def tags(img)
    MiniExiftool.new(File.join('public',img)).keywords.to_a.join(', ')
  end

  def set?(tag,img)
    MiniExiftool.new(File.join('public',img)).keywords.to_a.include?(tag)
  end

  def toggle(tag,img)
    if set?(tag,img)
      delete(tag,img)
    else
      # remove all quality tags
      if @quality.include?(tag)
        @quality.each {|t| delete(t,img) if set?(t,img) }
      end
      add(tag,img)
    end
  end

  def delete(tag,img)

    exif = MiniExiftool.new(File.join('public',img))
    keywords = exif.keywords
    keywords.delete(tag)
    exif.keywords = keywords
    exif.save

    @tags[tag].delete img
    save
  end

  def add(tag,img)

    exif = MiniExiftool.new(File.join('public',img))
    exif.keywords = [exif.keywords , tag].flatten.uniq
    exif.save

    @tags[tag] = [] unless @tags[tag]
    @tags[tag] << img
    @tags[tag].uniq!
    save
  end

  def update(img,write=true)
    exif = MiniExiftool.new(File.join('public',img))
    keywords = exif['keywords'].to_a
    @tags["all"] << img
    keywords.each do |tag|
      @tags[tag] = [] if @tags[tag].nil?
      @tags[tag] << img
    end
    save if write
  end

  def save
    File.open('tags.yaml', 'w+') { |out| YAML::dump(@tags, out) }
  end

end
