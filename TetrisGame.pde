import SimpleOpenNI.*;
import gifAnimation.*;
import ddf.minim.*;

Minim minim;
AudioPlayer mainSound;
AudioPlayer explosion;
AudioPlayer lineChange;
AudioPlayer over;
AudioPlayer start;
MusicManager musMan;

PFont f;

PImage main_background;
PImage road_part;
PImage newGame;
SimpleOpenNI kinect;
boolean isTracking = false;

Car plr;
int plrPoints;
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

GameStates gameState = GameStates.Inviting;
GameStates prevState = GameStates.Inviting;


void setup() {
  STanim = new Gif(this, "images/123.gif");
  stMan = new StartupManager(STanim);
  road_part = loadImage("images/RoadPart.jpg");
  newGame = loadImage("images/start-new-game.png");
  newGame.resize(200, 180);
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

  minim = new Minim(this);
  musMan = new MusicManager();
  musMan.playMain();

  f = createFont("Arial Bold", 30, true); 
}

void draw() {
  onGameStateChange();
  kinect.update();
  for (int i = 0; i < lines_count; i++){
    image(road_part, road_part.width*i, 0);
  }
  //background(main_background);
  //fill(0, 255, 0, 0);
  //green cells on road
  /*stroke(0, 255, 0, 255);
  for (int i = 1; i < col_count; i++){
    line(cell_height*i, 0, cell_height*i, main_background.height);
  }
  for (int i = 1; i <  row_count; i++){
    line(0, cell_width*i, main_background.width, cell_width*i);
  }*/

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
        if (plr.getCurLine() == 1){
          musMan.playLineChange();
          plr.move(new Vec2(2, row_count - 3));
        }
      }else{
        if (plr.getCurLine() == 0){
          musMan.playLineChange();
          plr.move(new Vec2(7, row_count - 3));
        }
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

  if (gameState == GameStates.Inviting){
    image(newGame, main_background.width / 2 - newGame.width / 2, main_background.height / 2 - newGame.height / 2);
  }

  textFont(f);       
  fill(255, 0, 0);
  textAlign(CENTER);
  text(plrPoints, main_background.width / 2, 60);
}

void onGameStateChange() {
    if (gameState == GameStates.StartAnimationPlaying && prevState == GameStates.Inviting){
      musMan.playStart();
    }
    if (gameState == GameStates.Running && prevState == GameStates.StartAnimationPlaying){
      enemies = new Enemies(cell_width, cell_height, 150, 50, 7);
      enemies.setPause(false);
    }
    if (gameState == GameStates.FinishAnimationPlaying && prevState == GameStates.Running){
      enemies.setPause(true);
      gameover.startGameOverAnimation(50);
    }
    if (isTracking && gameState == GameStates.Inviting && prevState == GameStates.FinishAnimationPlaying){
      stMan.StartAnim();
      gameState = GameStates.StartAnimationPlaying;
      musMan.playMain();
      musMan.playStart();
    }
    if (!isTracking && gameState == GameStates.Inviting && prevState == GameStates.FinishAnimationPlaying){
      musMan.playMain();
    }
    if (gameState == GameStates.Running && prevState == GameStates.StartAnimationPlaying){
      plrPoints = 0;
    }
    if (prevState != gameState){
      println("GameState: "+ gameState);
    }
    prevState = gameState;
}

void onNewUser(SimpleOpenNI kin, int userId) {
  if (!isTracking){
    isTracking = true;
    stMan.StartAnim();
    plTracker.show();
    gameState = GameStates.StartAnimationPlaying;
    println("onNewUser - userId: " + userId);
    kin.startTrackingSkeleton(userId);
  }
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
  isTracking = false;
  plTracker.hide();
  gameState = GameStates.FinishAnimationPlaying;
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
      if (enemies != null)
        enemies.setPause(false);
      break;
    case ' ':
      if(gameState == GameStates.Inviting) {
        stMan.StartAnim();
        //musMan.playMain();
        gameState = GameStates.StartAnimationPlaying;
      }
      break;
  }
}

void stop() {
  musMan.stopAll();

  super.stop();
}
