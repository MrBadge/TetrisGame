class PlayerTracker {
  boolean show;
  int h;
  
  public PlayerTracker(int cell_height) {
    show = false;
    h = cell_height;
  }
  
  public void show() {
    show = true;
  }
  
  public void hide() {
    show = false;
  }
  
  public void display() {
    if(show) {
      stroke(0);
      fill(150);
      rect(0, height, width, -h);
      fill(255,0,0);
      ellipse(projCoM.x, height - h/2, h/2, h/2);
    }
  }
  
}
