require 'mini_exiftool'
require 'yaml'

class Tag

  attr_accessor :tags

  def self.find(tag)
    @tags = YAML.load_file("tags.yaml")
    if tag.nil? or tag == ""
      @tags["all"].collect{|i| i.sub(/public/,'')}.sort
    elsif tag == "empty"
      images = @tags["all"]
      ["delete","keep","portfolio"].each { |t| images = images - @tags[t] }
      images.collect{|i| i.sub(/public/,'')}.sort
    else
      @tags[tag].collect{|i| i.sub(/public/,'')}.sort
    end
  end

  def self.tags(img)
    MiniExiftool.new(File.join('public',img)).keywords.to_a.join(', ')
  end

  def self.set?(tag,img)
    MiniExiftool.new(File.join('public',img)).keywords.to_a.include?(tag)
  end

  def self.toggle(tag,img)
    if Tag.set?(tag,img)
      Tag.delete(tag,img)
    else
      Tag.add(tag,img)
    end
  end

  def self.delete(tag,img)

    exif = MiniExiftool.new(File.join('public',img))
    keywords = exif.keywords
    keywords.delete(tag)
    exif.keywords = keywords
    exif.save

    tags = YAML.load_file("tags.yaml")
    tags[tag].delete File.join('public',img)
    File.open('tags.yaml', 'w+') { |out| YAML::dump(tags, out) }

  end

  def self.add(tag,img)

    exif = MiniExiftool.new(File.join('public',img))
    exif.keywords = [exif.keywords , tag].flatten.uniq
    exif.save

    tags = YAML.load_file("tags.yaml")
    tags[tag] = [] unless tags[tag]
    tags[tag] << File.join('public',img)
    tags[tag].uniq!
    tags[tag].sort!
    File.open('tags.yaml', 'w+') { |out| YAML::dump(tags, out) }
  end

end
