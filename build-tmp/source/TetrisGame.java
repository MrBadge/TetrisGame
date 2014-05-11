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
import org.jbox2d.common.MathUtils; 

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
PBox2D box2d;
ArrayList<Box> boxes;

public void setup() {
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

public void draw() {
	kinect.update();
	background(main_background);
	box2d.step();

	if (boxes.size() < 4 && random(1) < 0.05f){
		if (random(1) <= 0.5f) {
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
class Box {

  Body body;
  float w;
  float h;

  Box(float x, float y) {
    w = 250;
    h = width / 4;
    makeBody(new Vec2(x, y), w, h);
  }

  public void killBody() {
    box2d.destroyBody(body);
  }

  public boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.y > height+200) {
      killBody();
      return true;
    }
    return false;
  }

  public void display() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();

    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(175);
    stroke(0);
    rect(0, 0, w, h);
    popMatrix();
  }

  public void makeBody(Vec2 center, float w_, float h_) {

    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 1;
    fd.friction = 0.3f;
    fd.restitution = 0.5f;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setLinearVelocity(new Vec2(0, random(2, 15)));
    //body.setAngularVelocity(random(-5, 5));
  }
}


//import org.jbox2d.collision.*;// bounding box of our world

//import org.jbox2d.collision.shapes.PolygonDef;
//import org.jbox2d.collision.shapes.*;// define our shapes
//import org.jbox2d.collision.PolygonDef;

//import flash.display.*;// sprite class

public class Car {

	static final double MAX_STEER_ANGLE = Math.PI/3;
	static final float STEER_SPEED = 1.5f;
	static final float SIDEWAYS_FRICTION_FORCE = 10;
	static final int HORSEPOWERS = 40;
	//static final Vec2 CAR_STARTING_POS = new Vec2(10,10);

	Vec2 leftRearWheelPosition = new Vec2(-1.5f,1.9f);
	Vec2 rightRearWheelPosition = new Vec2(1.5f,1.9f);
	Vec2 leftFrontWheelPosition = new Vec2(-1.5f,-1.9f);
	Vec2 rightFrontWheelPosition = new Vec2(1.5f,-1.9f);

	Body body;
	Body leftWheel;
	Body rightWheel;
	Body rightRearWheel;
	Body leftRearWheel;
	RevoluteJoint leftJoint;
	RevoluteJoint rightJoint;

	int engineSpeed = 0;
	float steeringAngle = 0;

	public Car (Vec2 pos) {
		//Vec2 CAR_STARTING_POS = new Vec2(10,10);
		/*BodyDef staticDef = new BodyDef();
		staticDef.position.set(5,20);
		PolygonDef staticBox = new PolygonDef();
		staticBox.SetAsBox(5,5);
		box2d.createBody(staticDef).CreateShape(staticBox);
		staticDef.position.x = 25;
		box2d.createBody(staticDef).CreateShape(staticBox);
		staticDef.position.set(15, 24);
		box2d.createBody(staticDef).CreateShape(staticBox);*/
		// define our body
		BodyDef bodyDef = new BodyDef();
		bodyDef.linearDamping = 1;
		bodyDef.angularDamping = 1;
		bodyDef.position = pos.clone();

		body = box2d.createBody(bodyDef);
		body.resetMassData();//resetMassData(); //setMassFromShapes

		BodyDef leftWheelDef = new BodyDef();
		leftWheelDef.position = pos.clone();
		leftWheelDef.position.add(leftFrontWheelPosition);
		leftWheel = box2d.createBody(leftWheelDef);

		BodyDef rightWheelDef = new BodyDef();
		rightWheelDef.position = pos.clone();
		rightWheelDef.position.add(rightFrontWheelPosition);
		rightWheel = box2d.createBody(rightWheelDef);

		BodyDef leftRearWheelDef = new BodyDef();
		leftRearWheelDef.position = pos.clone();
		leftRearWheelDef.position.add(leftRearWheelPosition);
		leftRearWheel = box2d.createBody(leftRearWheelDef);

		BodyDef rightRearWheelDef = new BodyDef();
		rightRearWheelDef.position = pos.clone();
		rightRearWheelDef.position.add(rightRearWheelPosition);
		rightRearWheel = box2d.createBody(rightRearWheelDef);

		// define our shapes
		PolygonShape boxDef = new PolygonShape();
		boxDef.setAsBox(1.5f,2.5f);
		//boxDef.density = 1;
		body.createFixture(boxDef, 1);

		//Left Wheel shape
		PolygonShape leftWheelShapeDef = new PolygonShape();
		leftWheelShapeDef.setAsBox(0.2f,0.5f);
		//leftWheelShapeDef.density = 1;
		leftWheel.createFixture(leftWheelShapeDef, 1);

		//Right Wheel shape
		PolygonShape rightWheelShapeDef = new PolygonShape();
		rightWheelShapeDef.setAsBox(0.2f,0.5f);
		//rightWheelShapeDef.density = 1;
		rightWheel.createFixture(rightWheelShapeDef, 1);

		//Left Wheel shape
		PolygonShape leftRearWheelShapeDef = new PolygonShape();
		leftRearWheelShapeDef.setAsBox(0.2f,0.5f);
		//leftRearWheelShapeDef.density = 1;
		leftRearWheel.createFixture(leftRearWheelShapeDef, 1);

		//Right Wheel shape
		PolygonShape rightRearWheelShapeDef = new PolygonShape();
		rightRearWheelShapeDef.setAsBox(0.2f,0.5f);
		//rightRearWheelShapeDef.density = 1;
		rightRearWheel.createFixture(rightRearWheelShapeDef, 1);

		body.resetMassData();
		leftWheel.resetMassData();
		rightWheel.resetMassData();
		leftRearWheel.resetMassData();
		rightRearWheel.resetMassData();

		RevoluteJointDef leftJointDef = new RevoluteJointDef();
		leftJointDef.initialize(body, leftWheel, leftWheel.getWorldCenter());
		leftJointDef.enableMotor = true;
		leftJointDef.maxMotorTorque = 100;

		RevoluteJointDef rightJointDef = new RevoluteJointDef();
		rightJointDef.initialize(body, rightWheel, rightWheel.getWorldCenter());
		rightJointDef.enableMotor = true;
		rightJointDef.maxMotorTorque = 100;

		leftJoint = (RevoluteJoint)(box2d.createJoint(leftJointDef)); //wtf
		rightJoint = (RevoluteJoint)(box2d.createJoint(rightJointDef));

		PrismaticJointDef leftRearJointDef = new PrismaticJointDef();
		leftRearJointDef.initialize(body, leftRearWheel, leftRearWheel.getWorldCenter(), new Vec2(1,0));
		leftRearJointDef.enableLimit = true;
		leftRearJointDef.lowerTranslation = leftRearJointDef.upperTranslation = 0;

		PrismaticJointDef rightRearJointDef = new PrismaticJointDef();
		rightRearJointDef.initialize(body, rightRearWheel, rightRearWheel.getWorldCenter(), new Vec2(1,0));
		rightRearJointDef.enableLimit = true;
		rightRearJointDef.lowerTranslation = rightRearJointDef.upperTranslation = 0;

		box2d.createJoint(leftRearJointDef);
		box2d.createJoint(rightRearJointDef);
	}

	public void killOrthogonalVelocity(Body targetBody){
		Vec2 localPoint = new Vec2(0,0);
		Vec2 velocity = targetBody.getLinearVelocityFromLocalPoint(localPoint);
		
		//Vec2 sidewaysAxis = targetBody.getXForm().R.col2.clone();
		//sidewaysAxis.mul(Math.dot(velocity,sidewaysAxis)); !!!!!!!!

		//targetBody.setLinearVelocity(sidewaysAxis);//targetBody.GetWorldPoint(localPoint));
	}

	public void update(){
		
	    // We look at each body and get its screen position
	    Vec2 pos = box2d.getBodyPixelCoord(body);
	    // Get its angle of rotation
	    float a = body.getAngle();

	    rectMode(CENTER);
	    pushMatrix();
	    translate(pos.x, pos.y);
	    rotate(-a);
	    fill(175);
	    stroke(0);

	    //rect(0,0,w,h);
	    //ellipse(0, h/2, r*2, r*2);
	    popMatrix();
  
		//box2d.step(0, 1/30, 8);
		killOrthogonalVelocity(leftWheel);
		killOrthogonalVelocity(rightWheel);
		killOrthogonalVelocity(leftRearWheel);
		killOrthogonalVelocity(rightRearWheel);

		//Driving
		//Vec2 ldirection = leftWheel.getTransform().R.col2.clone();
		//ldirection.mul(engineSpeed);
		//Vec2 rdirection = rightWheel.getTransform().R.col2.clone();
		//rdirection.mul(engineSpeed);
		//leftWheel.applyForce(ldirection, leftWheel.getPosition());
		//rightWheel.applyForce(rdirection, rightWheel.getPosition());
		
		//Steering
		float mspeed;
		mspeed = steeringAngle - leftJoint.getJointAngle();
		leftJoint.setMotorSpeed(mspeed * STEER_SPEED);
		mspeed = steeringAngle - rightJoint.getJointAngle();
		rightJoint.setMotorSpeed(mspeed * STEER_SPEED);
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
