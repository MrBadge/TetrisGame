class GameOverManager {
  int speed;
  int time;
  int w, h;
  int rows, cols;
  boolean animation;
  boolean direction;
  boolean[][] tiles;
  
  public GameOverManager(int rows, int cols, int w, int h) {
    animation = false;
    tiles = new boolean[rows][cols];
    this.w = w;
    this.h = h;
    this.rows = rows;
    this.cols = cols;
  }
  
  public void startGameOverAnimation(int speed) {
    this.speed = speed;
    direction = false;
    animation = true;
    time = millis();
    for(int i = 0; i < rows; i++)
      for(int j = 0; j < cols; j++)
        tiles[i][j] = false;
  }
  
  public boolean isShowingAnimation() {
    return animation;
  }
  
  void update() {
    if(direction) {
      int i;
      for(i = 0; i < rows && !tiles[i][0]; i++){}
      if(i < rows)
        for(int j = 0; j < cols; j++)
          tiles[i][j] = false;
      else
        animation = false;
    } else {
      int i;
      for(i = rows-1; i >= 0 && tiles[i][0]; i--){}
      if(i >= 0)
        for(int j = 0; j < cols; j++)
          tiles[i][j] = true;
      else
        direction = true;
    }
  }
  
  public void display() {
    if((millis() - time > speed) && animation)
    {
      update();
      time = millis();
    }
    
    stroke(0);
    for(int i = 0; i < rows; i++)
      for(int j = 0; j < cols; j++)
        if(tiles[i][j])
        {
          fill(255);
          rect(j*w, i*h, w, h);
          fill(0);
          rect((j + 0.2)*w, (i + 0.2)*h, (int)w*0.6, (int)h*0.6);
        }
    
  }
  
}
