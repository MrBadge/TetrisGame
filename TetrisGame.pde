import SimpleOpenNI.*;
//import pbox2d.*;
//import org.jbox2d.collision.shapes.*;
//import org.jbox2d.common.*;
//import org.jbox2d.dynamics.*;
//import org.jbox2d.dynamics.joints.*;
//import java.util.Random;

PImage main_background;
PImage road_part;
SimpleOpenNI kinect;
boolean isTracking = false;
//PBox2D box2d;
//ArrayList<Box> boxes;
Car plr;
Enemies enemies;
int cell_width;
int cell_height;
int row_count = 20;
int col_count = 10;
int lines_count = 2;


void setup() {
  road_part = loadImage("RoadPart.jpg");
  main_background = createImage(road_part.width * lines_count, road_part.height, ARGB);
  size(main_background.width, main_background.height);
  noStroke();

  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser();

  cell_width = main_background.width / col_count;
  cell_height = main_background.height / row_count;
  plr = new Car(new Vec2(main_background.width / 2, cell_height * 2), cell_width, cell_height);
  enemies = new Enemies(cell_width, cell_height, 150);
  //c = new Car(new Vec2(100,100));
}

void draw() {
  kinect.update();
  for (int i = 0; i < lines_count; i++){
    image(road_part, road_part.width*i, 0);
  }
  //background(main_background);
  //fill(0, 255, 0, 0);
  stroke(0, 255, 0, 255);
  for (int i = 1; i < col_count; i++){
    line(cell_height*i, 0, cell_height*i, main_background.height);
  }
  for (int i = 1; i <  row_count; i++){
    line(0, cell_width*i, main_background.width, cell_width*i);
  }

  if (enemies.collisionExists(plr)){
    println("Collision!");
  }

  enemies.display();
  
  int[] users=kinect.getUsers();
  if (isTracking){
    int uid = users[0];
    ellipseMode(CENTER);
    if (kinect.isTrackingSkeleton(uid)){
      /*PVector realHead=new PVector();
        kinect.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_HEAD,realHead);
        PVector projHead=new PVector();
        kinect.convertRealWorldToProjective(realHead, projHead);
        fill(0,255,0);
        ellipse(projHead.x,projHead.y,10,10);
        print(projHead.x,projHead.y);*/
      PVector realRHand=new PVector();
      kinect.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_RIGHT_HAND,realRHand);
      PVector projRHand=new PVector();
      kinect.convertRealWorldToProjective(realRHand, projRHand);
      //fill(0,255,0);
      //ellipse(projRHand.x,projRHand.y + main_background.height / 2,10,10);
      if (projRHand.x < main_background.width / 2){
        plr.move(new Vec2(2, row_count - 2));
      }else{
        plr.move(new Vec2(7, row_count - 2));
      }
      plr.display();
    }
  }
  plr.display();
}

void onNewUser(SimpleOpenNI kin, int userId)
{
  if (!isTracking){
    isTracking = true;
    println("onNewUser - userId: " + userId);
    kin.startTrackingSkeleton(userId);
  }
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  isTracking = false;
}

void keyPressed() {
  switch(keyCode)
  {
    case LEFT:
      plr.move(new Vec2(2, row_count - 2));
      break;
    case RIGHT:
      plr.move(new Vec2(7, row_count - 2));
      break;
    case UP:
      break;
    case DOWN:
      break;
  }
}
