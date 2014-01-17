require_relative 'gui.rb'

@rows = 6
@cols = 6
@size = @rows*@cols

class Gdk::Pixbuf
  def adjust(tw,th)
    ratio = [tw/self.width, th/self.height].min
    self.scale(self.width*ratio, self.height*ratio)
  end
end

def draw
  if @index[@tag].nil?
    @tag = "*" 
    save_tag
  end
  @index[@tag].sort unless @tag.match(/^[A-Z]/) 
  if @current >= @index[@tag].size
    @current = @index[@tag].size - 1
    save_current
  end
  n = @current - @current.modulo(@size)
  n = 0 if n < 0
  @frames.each do |frame|
    frame.set_state(Gtk::STATE_NORMAL) 
    if @index[@tag][n]
      frame.child.pixbuf = Gdk::Pixbuf.new(thumb n).adjust(@tw,@th)
      frame.set_state(Gtk::STATE_SELECTED) if group? @index[@tag][n]
      frame.set_state(Gtk::STATE_ACTIVE) if n == @current
    else
      frame.child.pixbuf = nil
    end
    n += 1
  end
end

@win.modify_bg(Gtk::STATE_ACTIVE,Gdk::Color.parse("grey"))

@table = Gtk::Table.new(@rows,@cols,true)
@frames = []
@tw = 0.98*@win.screen.width/@cols.to_f
@th = 0.98*@win.screen.height/@rows.to_f

@rows.times do |r|
  @cols.times do |c|
    frame = Gtk::Frame.new
    frame.modify_bg(Gtk::STATE_ACTIVE,Gdk::Color.parse("red"))
    frame.modify_bg(Gtk::STATE_SELECTED,Gdk::Color.parse("grey"))
    frame.modify_bg(Gtk::STATE_NORMAL,Gdk::Color.parse("black"))
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
  when 'slash'
    select_tag tag_input
  when "T"
    tag = tag_input
    @index[@tag].each{|i| add_tag tag, i }
  when "minus"
    delete_tag tag_input
  when "BackSpace"
    add_tag "DELETE"
  when "grave"
    @group ||= group_tags(current_image).first
    @group ||= "_"+SecureRandom.uuid
    add_tag @group
    select 1
  #when 'p'
    #`fim-print #{current_image}`
  #when 'e'
    #`fim-pd`
  end
end


