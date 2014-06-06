public class Bonus extends Car{

	BonusTypes bType;
	PImage bImage;
	float perc;

	public Bonus (BonusTypes bonusType, float p, Vec2 center, int w, int h) {
		super(center, w, h);
		bType = bonusType;
		perc = p;
		switch (bType) {
			case SpeedDec:
				bImage = loadImage("images/speedDec.png");
				break;		
		}
	}

	void display() {
    	image(bImage, mc.x*def_width - bImage.width / 2, mc.y*def_height - bImage.height / 2);
  	}

  	void getBonus() {
  		//?
  	}

}