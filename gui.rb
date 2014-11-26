require 'gtk2'
require_relative 'fim.rb'

GREEN = Gdk::Color.parse("green")
RED = Gdk::Color.parse("red")
BLACK = Gdk::Color.parse("black")
WHITE = Gdk::Color.parse("white")
GREY = Gdk::Color.parse("grey")

@clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
@win = Gtk::Window.new
@win.modify_bg(Gtk::STATE_NORMAL,BLACK)

def move offset
  if @current+offset >= 0 and @current+offset < @index[@tag].size
    @index[@tag].insert(@current+offset,@index[@tag].delete_at(@current))
    save_index
    select offset
  end
end

def select offset
  @current = @current + offset
  @current = 0 if @current < 0
  @current = @index[@tag].size-1 if @current > @index[@tag].size - 1
  save_current
  draw
end

def select_tag tag
  image = @index[tag][@current]
  @last_tag = @tag
  @tag = tag.chomp unless tag.empty?
  save_tag
  @current = @index[@tag].index image
  @current ||= 0
  save_current
  draw
end

def tag_input
  tags = @index.keys 
  img_tags = exif_keywords
  if img_tags
    current_tags = img_tags.collect{|t| t.to_s}
    tags.collect!{|t| current_tags.include?(t.to_s) ? "+#{t}" : t.to_s}
  end
  `echo '#{(tags.sort).join("\n")}' | dmenu -b `.chomp.sub(/\+/, '')
end

def quit
  save_current
  save_tag
  save_index
  Gtk.main_quit
end

@win.signal_connect("key-press-event") do |w,e|
  case Gdk::Keyval.to_name(e.keyval)
  #when "q"
    #quit
  when /^h$|Left/
    select -1
  when /^l$|Right/
    select 1
  when "r"
    puts `cp -v #{current_image} #{current_image}.original`
    puts `jpegtran -copy all -rotate 90 #{current_image}.original > #{current_image}`
    `fim-thumb #{current_image}`
    curframe = @current.modulo(@size)
    @frames[curframe].child.pixbuf = Gdk::Pixbuf.new(thumb @current).adjust(@tw,@th)
  when 'c'
    `fim-crop`
    @index = YAML.load_file(@indexfile)
    @current = File.read(@currentfile).chomp.to_i
    draw
  when "t"
    add_tag tag_input
    draw
  when "T"
    tag = tag_input
    @index[@tag].each{|i| add_tag tag, i }
    draw
  when "minus"
    delete_tag tag_input
    draw
  when "Delete"
    delete_tag @tag
    draw
  when "BackSpace"
    add_tag "DELETE"
    draw
  when "backslash"
    add_tag "KEEP"
    draw
  when 'slash'
    select_tag tag_input
  when "grave"
    select 1 if @group
    @group ||= group_tags(current_image).first
    @group ||= "_"+SecureRandom.uuid
    add_tag @group
    draw
  when "equal"
    exif = MiniExiftool.new current_image
    `echo "#{current_image}: #{exif.keywords}" | dzen2 -p 2`
  when "y"
    @clipboard.text = current_image
    @clipboard.store
  else
    puts '"'+Gdk::Keyval.to_name(e.keyval)+'"'
  end
end

@win.signal_connect("destroy") { quit }
