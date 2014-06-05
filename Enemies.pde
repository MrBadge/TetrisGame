class Enemies {
  ArrayList<Car> enemyList;
  int w, h;
  boolean last_enemy_side;
  int last_enemy_time;
  int time, update_step, step_inc;
  double p_gen; //probabilities of enemy generation and
  int Car_length = 7;
  boolean pause;
  int steps, steps_left;

  public Enemies(int w, int h, int initial_update_step, int steps_to_speedup, int update_step_inc) {
    enemyList = new ArrayList<Car>();
    this.w = w;
    this.h = h;
    this.update_step = initial_update_step;
    last_enemy_side = false;
    last_enemy_time = 3;
    p_gen = 0.5;
    time = millis();
    pause = true;
    steps_left = 0;
    steps = steps_to_speedup;
    step_inc = update_step_inc;
  }

  void generate_enemy(boolean side) {
    int x = 2;
    last_enemy_side = side;

    if(side) {
      x = 7;
    }
    enemyList.add(new Car(new Vec2(x, -2), w, h));
  }

  void generate_enemy(){
    if (last_enemy_time > 7){
      last_enemy_time = 0;
        generate_enemy(!last_enemy_side);
      //}
    }else if (last_enemy_time > 3 && Math.random() < (1 - p_gen)/3) {
      generate_enemy(last_enemy_side);
      last_enemy_time = 0;
    } else {
      last_enemy_time++;
    }
  }
  
  void setPause(boolean pause) {
    this.pause = pause;
  }
  
  boolean getPause() {
    return pause;
  }

  boolean collisionExists(Car plr){
    for (Car c : enemyList) {
      if (plr.intersectsWith(c)){
        return true;
      }
    }
    return false;
  }

  //For debug
  String size(){
    return String.valueOf(enemyList.size());
  }

  void update() {
    for(Car c : enemyList) {
      c.move_down();
    }
    generate_enemy();
    if(steps_left == steps) {
      update_step -= step_inc;
      steps_left = 0;
      println(update_step);
    } else
      steps_left++;
  }

  public void display(Car plr) {
    for(Car c : enemyList) {
      if (c.finished()){
        enemyList.remove(c);
        break;
      }else {
        c.display();
      }
    }
    if (millis() - time >= update_step && !pause) {
      update();
      if (collisionExists(plr)){
        //println("Collision!" + Math.random());
        gameState = GameStates.FinishAnimationPlaying;
      }
      time = millis();
    }
  }
}
