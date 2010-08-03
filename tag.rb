require 'mini_exiftool'
require 'yaml'

class Tag

  attr_accessor :tags

  def self.find(tags)
    @tags = YAML.load_file("tags.yaml")
    if tags.empty?
      @tags.collect{|t,i| i}.flatten.compact.uniq.collect{|i| i.sub(/public/,'')}.sort
    else
      images = []
      tags.each { |t| images << @tags[t] }
      images.flatten.compact.uniq.collect{|i| i.sub(/public/,'')}.sort
    end
  end

  def self.tags(img)
    MiniExiftool.new(File.join('public',img)).keywords.to_a.join(', ') #+ " orientation: "+ MiniExiftool.new(File.join('public',img))['Orientation']
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
    tags[tag].delete(img)
    File.open('tags.yaml', 'w+') { |out| YAML::dump(@tags, out) }

  end

  def self.add(tag,img)

    exif = MiniExiftool.new(File.join('public',img))
    exif.keywords = [exif.keywords , tag].flatten.uniq
    exif.save

    tags = YAML.load_file("tags.yaml")
    tags[tag] = [] unless tags[tag]
    tags[tag] << img
    tags[tag].uniq!
    File.open('tags.yaml', 'w+') { |out| YAML::dump(@tags, out) }
  end

end
