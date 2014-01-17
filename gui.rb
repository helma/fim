require_relative 'fim.rb'

@clipboard = Gtk::Clipboard.get(Gdk::Selection::CLIPBOARD)
@win = Gtk::Window.new
@win.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.parse("black"))

def move(offset)
  if @current+offset >= 0 and @current+offset < @index[@tag].size
    @index[@tag].insert(@current+offset,@index[@tag].delete_at(@current))
    save_index
    select offset
  end
end

def select(offset)
  @current = @current + offset
  @current = 0 if @current < 0
  @current = @index[@tag].size-1 if @current > @index[@tag].size - 1
  save_current
  puts current_image
  draw
end

def select_tag tag
  image = @index[tag][@current]
  @tag = tag.chomp unless tag.empty?
  save_tag
  @current = @index[@tag].index image
  @current ||= 0
  save_current
  draw
end

def tag_input
  tags = @index.keys #- @q_tags
  img_tags = [MiniExiftool.new(current_image).keywords].flatten.uniq
  if img_tags
    current_tags = img_tags.collect{|t| t.to_s}
    tags.collect!{|t| current_tags.include?(t.to_s) ? "+#{t}" : t.to_s}
  end
  `echo '#{(tags.sort).join("\n")}' | dmenu -b `.chomp.sub(/\+/, '')
end

def update_index keywords, image=current_image
  @tag_index[image] = keywords
  keywords.each do |t|
    @index[t] ||= [] 
    @index[t] << image unless @index[t].include? image
  end
  @index['_'] << image if (keywords & @action_tags).empty?
  save_index
  draw
end

def add_tag tag, image=current_image
  tag = tag.chomp.to_s
  keywords = exif_keywords
  keywords -= @action_tags if @action_tags.include? tag #or tag.match(/^[A-Z]/) # remove @action_tags
  keywords << tag
  save_keywords keywords
  update_index keywords, image
end

def delete_tag tag, image=current_image
  tag = tag.chomp.to_s
  keywords = exif_keywords
  keywords.delete tag
  save_keywords keywords
  keywords << '_' if (keywords & @action_tags).empty?
  update_index keywords, image
end

def quit
  save_current
  save_tag
  save_index
  Gtk.main_quit
end

@win.signal_connect("key-press-event") do |w,e|
  case Gdk::Keyval.to_name(e.keyval)
  when "q"
    quit
  when /^h$|Left/
    puts "-1"
    select -1
  when /^l$|Right/
    puts "+1"
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
  when "backslash"
    add_tag "KEEP"
  when "y"
    @clipboard.text = current_image
    @clipboard.store
  else
    puts '"'+Gdk::Keyval.to_name(e.keyval)+'"'
  end
end

@win.signal_connect("destroy") { quit }


