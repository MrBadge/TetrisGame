import SimpleOpenNI.*;
import gifAnimation.*;
import ddf.minim.*;

Minim minim;
AudioPlayer player;
//import pbox2d.*;
//import org.jbox2d.collision.shapes.*;
//import org.jbox2d.common.*;
//import org.jbox2d.dynamics.*;
//import org.jbox2d.dynamics.joints.*;
//import java.util.Random;

PImage main_background;
PImage road_part;
PImage stNewGame;
SimpleOpenNI kinect;
boolean isTracking = false;
//boolean isGameRunning = false;
//boolean isAnimPlaying = false;
//PBox2D box2d;
//ArrayList<Box> boxes;
Car plr;
Enemies enemies;
GameOverManager gameover;
StartupManager stMan;
PlayerTracker plTracker;
int cell_width;
int cell_height;
int row_count = 20;
int col_count = 10;
int lines_count = 2;
PVector projCoM;
Gif STanim;

//GameStates GameStates { isRunning, isStarting, isFinishing, isTracking, isInviting }

GameStates gameState = GameStates.Inviting;
GameStates prevState = GameStates.Inviting;


void setup() {
  STanim = new Gif(this, "images/123.gif");
  stMan = new StartupManager(STanim);
  road_part = loadImage("images/RoadPart.jpg");
  stNewGame = loadImage("images/start-new-game.png");
  stNewGame.resize(200, 200);
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
  plr.move(new Vec2(2, row_count - 3));
  gameover = new GameOverManager(row_count, col_count, cell_width, cell_height);
  plTracker = new PlayerTracker(cell_height);
  projCoM = new PVector();
  //c = new Car(new Vec2(100,100));

  minim = new Minim(this);
  player = minim.loadFile("sounds/main.mp3");
  player.play();
}

void draw() {
  onGameStateChange();
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

  if (gameState == GameStates.Inviting){
    image(stNewGame, main_background.width / 2 - stNewGame.width / 2, main_background.height / 2 - stNewGame.height / 2);
  }

  gameover.display();
  stMan.displayAnimation();
  plTracker.display();
  if(enemies != null) enemies.display(plr);
  
  if (gameState == GameStates.Running){
    if (isTracking){
      int[] users=kinect.getUsers();
      int uid = users[0];
      ellipseMode(CENTER);

      PVector realCoM=new PVector();
      kinect.getCoM(uid,realCoM);
      kinect.convertRealWorldToProjective(realCoM, projCoM);
      if (projCoM.x < main_background.width / 2){
        plr.move(new Vec2(2, row_count - 2));
      }else{
        plr.move(new Vec2(7, row_count - 2));
      }
      //if (kinect.isTrackingSkeleton(uid)){
        /*PVector realHead=new PVector();
          kinect.getJointPositionSkeleton(uid,SimpleOpenNI.SKEL_HEAD,realHead);
          PVector projHead=new PVector();
          kinect.convertRealWorldToProjective(realHead, projHead);
          fill(0,255,0);
          ellipse(projHead.x,projHead.y,10,10);
          print(projHead.x,projHead.y);*/
        /*PVector realRHand=new PVector();
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
      }*/
    }
    plr.display();
  }

  /*if (isTracking && !isGameRunning){
    if (!isAnimPlaying){
      STanim.play();
      isAnimPlaying = true;
    }
    image(STanim, main_background.width / 2 - STanim.width / 2, main_background.height / 2 - STanim.height / 2);
    if (!STanim.isPlaying()){
      STanim.stop();
      isGameRunning = true;
      isAnimPlaying = false;
      println("isGameRunning");
    }
  }*/
}

void onGameStateChange(){
    /*if (isTracking && gameState == GameStates.Inviting){
      stMan.StartAnim();
      gameState = GameStates.StartAnimantionPlaying;
    }*/
    if (gameState == GameStates.Running && prevState == GameStates.StartAnimationPlaying){
      enemies = new Enemies(cell_width, cell_height, 150, 40, 10);
      enemies.setPause(false);
    }
    if (gameState == GameStates.FinishAnimationPlaying && prevState == GameStates.Running){
      enemies.setPause(true);
      gameover.startGameOverAnimation(50);
    }
    if (isTracking && gameState == GameStates.Inviting && prevState == GameStates.FinishAnimationPlaying){
      stMan.StartAnim();
      gameState = GameStates.StartAnimationPlaying;
    }
    if (prevState != gameState){
      println("GameState: "+ gameState);
    }
    prevState = gameState;
}

void onNewUser(SimpleOpenNI kin, int userId)
{
  if (!isTracking){
    isTracking = true;
    stMan.StartAnim();
    plTracker.show();
    gameState = GameStates.StartAnimationPlaying;
    println("onNewUser - userId: " + userId);
    kin.startTrackingSkeleton(userId);
  }
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  isTracking = false;
  plTracker.hide();
  gameState = GameStates.FinishAnimationPlaying;
  //isGameRunning = false;
}

void keyPressed() {
  switch(keyCode)
  {
    case LEFT:
      if(gameState == GameStates.Running) plr.move(new Vec2(2, row_count - 3));
      break;
    case RIGHT:
      if(gameState == GameStates.Running) plr.move(new Vec2(7, row_count - 3));
      break;
    case UP:
      //isGameRunning = false;
      //gameover.startGameOverAnimation(50);
      break;
    case DOWN:
      //isGameRunning = true;
      enemies.setPause(false);
      break;
    case ' ':
      stMan.StartAnim();
      gameState = GameStates.StartAnimationPlaying;
      break;
  }
}
