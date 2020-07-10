package states;

import GlobalGameData.GGD;
import com.gEngine.display.Sprite;
import kha.Color;
import com.loading.basicResources.JoinAtlas;
import com.gEngine.display.StaticLayer;
import com.gEngine.GEngine;
import com.gEngine.display.Text;
// import kha.Assets;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Layer;
import kha.input.KeyCode;
import com.framework.utils.Input;
import kha.math.FastVector2;
import com.loading.basicResources.ImageLoader;
import com.loading.Resources;
import com.framework.utils.State;

class GameOver extends State {
	var score:String;

	public function new(score:String = "") {
		super();
		this.score = score;
	}

	override function load(resources:Resources) {
		var atlas:JoinAtlas = new JoinAtlas(1024, 1024);
		atlas.add(new ImageLoader("gameOver"));
		atlas.add(new FontLoader("KenneyThick", 30));
		resources.add(atlas);
	}

	override function init() {
		var image = new Sprite("gameOver");
		image.x = GEngine.virtualWidth * 0.5 - image.width() * 0.5;
		image.y = 100;
		stage.addChild(image);
		var text = new Text("KenneyThick");
		text.text = "Enter to play again";
		text.x = GEngine.virtualWidth / 2 - text.width() * 0.5;
		text.y = GEngine.virtualHeight / 2;
		text.color = Color.Red;
		stage.addChild(text);
	}

	var time:Float = 0;
	var targetPosition:FastVector2;

	override function update(dt:Float) {
		super.update(dt);
		if (Input.i.isKeyCodePressed(KeyCode.Return)) {
			GGD.levelNumber=1;
			GGD.heroLife=9;
			GGD.hasWand=false;
			GGD.hasPotion=false;
			changeState(new GameState());
		}
	}
}
