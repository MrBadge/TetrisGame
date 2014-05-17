public class Vec2 {

	int x;
	int y;

	public Vec2 (int x, int y) {
		this.x = x;
		this.y = y;
	}

	Vec2 clone(){
		return new Vec2(x, y);
	}

}