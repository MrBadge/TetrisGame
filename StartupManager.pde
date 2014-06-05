public class StartupManager {

	Gif anim;
	//boolean isAnimPlaying = false;

	StartupManager(Gif anim) {
		this.anim = anim;
		//anim.play();
		//anim = new Gif(this, "123.gif");
		anim.noLoop();
	}

	public void StartAnim() {
		anim.play();
		//isAnimPlaying = true;
	}

	public void displayAnimation() {
		if (gameState == GameStates.StartAnimationPlaying)
			if (anim.isPlaying()){
				image(anim, main_background.width / 2 - STanim.width / 2, main_background.height / 2 - STanim.height / 2);
			}else {
				gameState = GameStates.Running;
			}
	}

} 
