class Enemies {
  ArrayList<Car> enemyList;
  int w, h;
  boolean last_enemy_side;
  int last_enemy_time;
  int time, update_step;
  double p_gen; //probabilities of enemy generation and

  public Enemies(int w, int h, int update_step) {
    enemyList = new ArrayList<Car>();
    this.w = w;
    this.h = h;
    this.update_step = update_step;
    last_enemy_side = false;
    last_enemy_time = 0;
    p_gen = 0.3;
    time = millis();
  }

  void generate_enemy(boolean side) {
    int x = 2;
    last_enemy_side = side;

    if(side) {
      x = 7;
    }
    enemyList.add(new Car(new Vec2(x, -2), w, h));
  }

  void generate_enemy() {
    //System.out.println(last_enemy_time);
    if (last_enemy_time > 3) {
      double rand = Math.random();
      if (rand <= p_gen) {
        if (last_enemy_time > 7) {
          generate_enemy(!last_enemy_side);
        } else {
          generate_enemy(last_enemy_side);
        }
        last_enemy_time = 0;
      } else {
        last_enemy_time++;
      }
    } else {
      last_enemy_time++;
    }
  }

  void update() {
    for(Car c : enemyList) {
      c.move_down();
    }
    generate_enemy();
  }

  public void display() {
    for(Car c : enemyList) {
      c.display();
    }
    if (millis() - time >= update_step) {
      update();
      time = millis();
    }
  }

}
