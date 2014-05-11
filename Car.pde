//import org.jbox2d.collision.*;// bounding box of our world

//import org.jbox2d.collision.shapes.PolygonDef;
//import org.jbox2d.collision.shapes.*;// define our shapes
//import org.jbox2d.collision.PolygonDef;
import org.jbox2d.common.MathUtils;
//import flash.display.*;// sprite class

public class Car {

	static final double MAX_STEER_ANGLE = Math.PI/3;
	static final float STEER_SPEED = 1.5;
	static final float SIDEWAYS_FRICTION_FORCE = 10;
	static final int HORSEPOWERS = 40;
	//static final Vec2 CAR_STARTING_POS = new Vec2(10,10);

	Vec2 leftRearWheelPosition = new Vec2(-1.5,1.9);
	Vec2 rightRearWheelPosition = new Vec2(1.5,1.9);
	Vec2 leftFrontWheelPosition = new Vec2(-1.5,-1.9);
	Vec2 rightFrontWheelPosition = new Vec2(1.5,-1.9);

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
		boxDef.setAsBox(1.5,2.5);
		//boxDef.density = 1;
		body.createFixture(boxDef, 1);

		//Left Wheel shape
		PolygonShape leftWheelShapeDef = new PolygonShape();
		leftWheelShapeDef.setAsBox(0.2,0.5);
		//leftWheelShapeDef.density = 1;
		leftWheel.createFixture(leftWheelShapeDef, 1);

		//Right Wheel shape
		PolygonShape rightWheelShapeDef = new PolygonShape();
		rightWheelShapeDef.setAsBox(0.2,0.5);
		//rightWheelShapeDef.density = 1;
		rightWheel.createFixture(rightWheelShapeDef, 1);

		//Left Wheel shape
		PolygonShape leftRearWheelShapeDef = new PolygonShape();
		leftRearWheelShapeDef.setAsBox(0.2,0.5);
		//leftRearWheelShapeDef.density = 1;
		leftRearWheel.createFixture(leftRearWheelShapeDef, 1);

		//Right Wheel shape
		PolygonShape rightRearWheelShapeDef = new PolygonShape();
		rightRearWheelShapeDef.setAsBox(0.2,0.5);
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

	void killOrthogonalVelocity(Body targetBody){
		Vec2 localPoint = new Vec2(0,0);
		Vec2 velocity = targetBody.getLinearVelocityFromLocalPoint(localPoint);
		
		//Vec2 sidewaysAxis = targetBody.getXForm().R.col2.clone();
		//sidewaysAxis.mul(Math.dot(velocity,sidewaysAxis)); !!!!!!!!

		//targetBody.setLinearVelocity(sidewaysAxis);//targetBody.GetWorldPoint(localPoint));
	}

	void update(){
		
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