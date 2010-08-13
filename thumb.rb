class Thumb

  def initialize(img)
    thumbnail = File.join 'public', Thumb.path(img)
    image = File.join('public', img)
    exif = MiniExiftool.new image
    height = 100
    width = 16*height/9
    ratio = [width/exif.imagewidth.to_f, height/exif.imageheight.to_f].min
    width = (exif.imagewidth*ratio).round
    height = (exif.imageheight*ratio).round
    `mkdir -p #{File.dirname(thumbnail)}`
    `convert #{image} -thumbnail #{width}x#{height} -strip  #{thumbnail}`
    Thumb.path(img)
  end

  def self.path(img)
    img.sub(/images/,'thumbs').sub(/jpg/i,'png')
  end

end
