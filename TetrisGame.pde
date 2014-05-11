import SimpleOpenNI.*;
import pbox2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.joints.*;

PImage main_background;
SimpleOpenNI kinect;
boolean isTracking = false;
PBox2D box2d;
ArrayList<Box> boxes;

void setup() {
	main_background = loadImage("RoadTexture.jpg");
	size(main_background.width, main_background.height);
	noStroke();

	box2d = new PBox2D(this);
    box2d.createWorld();
    box2d.setGravity(0, -10);

    boxes = new ArrayList<Box>();
	kinect = new SimpleOpenNI(this);
	kinect.setMirror(true);
	kinect.enableDepth();
	kinect.enableUser();
	//c = new Car(new Vec2(100,100));
}

void draw() {
	kinect.update();
	background(main_background);
	box2d.step();

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
    }	

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
	      	fill(0,255,0);
	      	ellipse(projRHand.x,projRHand.y + main_background.height / 2,10,10);
	 	}
  	}
 	
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