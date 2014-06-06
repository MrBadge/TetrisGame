public class Car {

  Vec2 mc;
  int def_width;
  int def_height;
  ArrayList<Vec2> shifts = new ArrayList<Vec2>() {{
    add(new Vec2(0, 0));
    add(new Vec2(0, -2));
    add(new Vec2(0, -1));
    add(new Vec2(1, -1));
    add(new Vec2(1, 1));
    add(new Vec2(-1, 1));
    add(new Vec2(-1, -1));
  }};

  public Car (Vec2 center, int w, int h) {
    mc = center.clone();
    def_width = w;
    def_height = h;
  }

  public void move(Vec2 cntr) {
    if (mc.x != cntr.x && musMan != null)
      musMan.playLineChange();
    mc = cntr.clone();
  }

  public void move_down() {
    mc.y++;
  }

  public int get_y()
  {
    return (int)mc.y;
  }

  public int getCurLine() {
    if (mc.x < 5)
      return 0;
    else 
      return 1;
  }

  void display() {
    stroke(0);
    //rectMode(CENTER);
    for (Vec2 shift: shifts) {
      fill(255);
      rect(mc.x*def_width + shift.x*def_width, mc.y*def_height + shift.y*def_height, def_width, def_height);
      fill(0);
      rect((mc.x + 0.2)*def_width + shift.x*def_width, (mc.y + 0.2)*def_height + shift.y*def_height, (int)def_width*0.6, (int)def_height*0.6);
    }
  }

  public boolean intersectsWith(Car c) { //Should be optimized
    for (Vec2 shift : shifts) {
      if (mc.x == c.mc.x && Math.abs(mc.y - c.mc.y) <= 3) {
        return true;
      }
    }
    return false;
  }

  public boolean finished() {
    if (mc.y + 3 > def_height)
      return (true);
    return (false);
  }

}
