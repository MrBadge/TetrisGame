public class StartupManager {

	Gif anim;

	StartupManager(Gif anim) {
		this.anim = anim;
		anim.play();
		//anim = new Gif(this, "123.gif");
		//anim.noLoop();
	}

	public void StartAnim() {
		anim.play();
	}

	public void displayAnimation() {
		image(anim, 0, 0);
	}

} 