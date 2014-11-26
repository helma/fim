require_relative 'gui.rb'

@rows = 6
@cols = 6
@size = @rows*@cols

class Gdk::Pixbuf
  def adjust(tw,th)
    ratio = 0.98 * [tw/self.width, th/self.height].min
    self.scale(self.width*ratio, self.height*ratio)
  end
end

def draw
  @index[@tag].sort! #unless @tag.match(/^[A-Z]/) and !@action_tags.include?(@tag)
  if @current >= @index[@tag].size
    @current = @index[@tag].size - 1
    save_current
  end
  n = @current - @current.modulo(@size)
  n = 0 if n < 0
  @frames.each do |frame|
    frame.modify_bg(Gtk::STATE_NORMAL,BLACK)
    if @index[@tag][n]
      frame.child.pixbuf = Gdk::Pixbuf.new(thumb n).adjust(@tw,@th)
      if @tag.match /^_\w+/ # groups
        img_tags = @tag_index[@index[@tag][n]]
        frame.modify_bg(Gtk::STATE_NORMAL,RED) if img_tags.include? "DELETE"
        frame.modify_bg(Gtk::STATE_NORMAL,GREEN) if img_tags.include? "KEEP"
        frame.modify_bg(Gtk::STATE_NORMAL,WHITE) if n == @current
      else
        frame.modify_bg(Gtk::STATE_NORMAL,GREY) if group? @index[@tag][n]
        frame.modify_bg(Gtk::STATE_NORMAL,RED) if n == @current
      end
    else
      frame.child.pixbuf = nil
    end
    n += 1
  end
end

@table = Gtk::Table.new(@rows,@cols,true)
@frames = []
@tw = 0.98*@win.screen.width/@cols.to_f
@th = 0.98*@win.screen.height/@rows.to_f

@rows.times do |r|
  @cols.times do |c|
    frame = Gtk::Frame.new
    frame.modify_bg(Gtk::STATE_NORMAL,BLACK)
    image = Gtk::Image.new 
    frame.add image
    @table.attach frame, c, c+1, r, r+1
    @frames << frame
  end
end

@win.add(@table)
draw

@win.signal_connect("key-press-event") do |w,e|
  case Gdk::Keyval.to_name(e.keyval)
  when "Escape"
    @group = nil
    @index = YAML.load_file(@indexfile)
    draw
  when "q"
    @tag.match(/^_\w+/) ? select_tag(@last_tag) : quit
  when /^j$|Down/
    select @cols
  when /^k$|Up/
    select -@cols
  when "b"
    select -@size
  when "space"
    select @size
  when /^g$|Home/
    select -@current
  when /^G$|End/
    select @index[@tag].size-@current
  when "K"
    move -@cols
  when "J"
    move @cols
  when "H"
    move -1
  when "L"
    move 1
  when "Return"
    tags = group_tags(current_image)
    if (tags.empty? or tags.first == @tag) 
      `fim-view`
      @index = YAML.load_file(@indexfile)
      draw
    else
      select_tag(tags.first)
    end
  end
end


