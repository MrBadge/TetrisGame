import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import pbox2d.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 
import org.jbox2d.dynamics.joints.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TetrisGame extends PApplet {








PImage main_background;
SimpleOpenNI kinect;
boolean isTracking = false;
//PBox2D box2d;
//ArrayList<Box> boxes;
Car plr;
int cell_width;
int cell_height;
int row_count = 20;
int col_count = 10;

public void setup() {
	main_background = loadImage("RoadTexture.jpg");
	size(main_background.width, main_background.height);
	noStroke();

	//box2d = new PBox2D(this);
    //box2d.createWorld();
    //box2d.setGravity(0, -10);

    //boxes = new ArrayList<Box>();
	kinect = new SimpleOpenNI(this);
	kinect.setMirror(true);
	kinect.enableDepth();
	kinect.enableUser();

	cell_width = main_background.width / col_count;
	cell_height = main_background.height / row_count;
	plr = new Car(new Vec2(main_background.width / 2, cell_height * 2), cell_width, cell_height);
	//c = new Car(new Vec2(100,100));
}

public void draw() {
	kinect.update();
	background(main_background);
	//fill(0, 255, 0, 0);
	stroke(0, 255, 0, 255);
	for (int i = 1; i < col_count; i++){
		line(cell_height*i, 0, cell_height*i, main_background.height);
	}
	for (int i = 1; i <  row_count; i++){
		line(0, cell_width*i, main_background.width, cell_width*i);
	}
	/*box2d.step();

	if (boxes.size() < 4 && random(1) < 0.05){
		if (random(1) <= 0.5) {
	    	Box p = new Box(width/4, -30);
	    	boxes.add(p);
	    }else {
	    	Box p = new Box(width*3/4, -30);
	    	boxes.add(p);
	    }
	}

	for (Box b: boxes) {
	    b.display();
	}

	for (int i = boxes.size()-1; i >= 0; i--) {
    	Box b = boxes.get(i);
    	if (b.done()) {
      		boxes.remove(i);
    	}
    }	*/
    //plr.move(new Vec2(150, 150));
    //plr.display();

	//PImage depthImage=kinect.depthImage();

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
 	
}

public void onNewUser(SimpleOpenNI kin, int userId)
{
  if (!isTracking){
  	isTracking = true;
  	println("onNewUser - userId: " + userId);
  	kin.startTrackingSkeleton(userId);
  }
}
 
public void onLostUser(SimpleOpenNI curContext, int userId)
{
  println("onLostUser - userId: " + userId);
  isTracking = false;
}
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
		mc = cntr.clone();
	}

	public void display() {
		stroke(0);
		//rectMode(CENTER);
		for (Vec2 shift: shifts) {
			fill(255);
		    rect(mc.x*def_width + shift.x*def_width, mc.y*def_height + shift.y*def_height, def_width, def_height);
		    fill(0);
		    rect((mc.x + 0.2f)*def_width + shift.x*def_width, (mc.y + 0.2f)*def_height + shift.y*def_height, (int)def_width*0.6f, (int)def_height*0.6f);
		}
	}

	public boolean finished() {
		return (false); //NOT IMPLEMENTED EXCEPTION
	}

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "TetrisGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
