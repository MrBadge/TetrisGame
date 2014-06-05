public class MusicManager {

	SamplePlayer player;
	Gain g;
	AudioContext ac;

	public MusicManager (AudioContext ac) {
		this.ac = new AudioContext();
		player = new SamplePlayer(ac, SampleManager.sample("sounds/main.mp3"));
		g = new Gain(ac, 2, 0.2);
		g.addInput(player);
		ac.out.addInput(g);
		ac.start();
	}

	void PlayMain() {

	}

}