public class MusicManager {

	public MusicManager () {
		mainSound = minim.loadFile("sounds/main.mp3");
		start = minim.loadFile("sounds/start_sound.wav");
		over = minim.loadFile("sounds/game_over.wav");
		lineChange = minim.loadFile("sounds/line_change.wav");
		explosion = minim.loadFile("sounds/car_explosion.wav");
	}

	void playMain() {
		mainSound.loop();
	}

	void stopMain() {
		mainSound.pause();
	}

}