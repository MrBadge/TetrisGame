public class MusicManager {

	public MusicManager () {
		mainSound = minim.loadFile("sounds/main.mp3");
		start = minim.loadFile("sounds/start_sound.mp3");
		over = minim.loadFile("sounds/game_over.mp3");
		lineChange = minim.loadFile("sounds/line_change.wav");
		explosion = minim.loadFile("sounds/car_explosion.mp3");
	}

	void playMain() {
		if (!mainSound.isPlaying()){
			mainSound.loop();
			mainSound.rewind();
		}
	}

	void pauseMain() {
		mainSound.pause();
	}

	void playStart() {
		start.play();
		start.rewind();
	}

	void playLineChange() {
		lineChange.play();
		lineChange.rewind();
	}

	void playOver() {
		over.play();
		over.rewind();
	}

	void playExplosion() {
		explosion.play();
		explosion.rewind();
	}

	void stopAll() {
		mainSound.close();
		start.close();
		over.close();
		lineChange.close();
		explosion.close();
		minim.stop();
	}

}