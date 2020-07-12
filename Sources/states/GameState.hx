package states;

import js.lib.intl.DateTimeFormat.DateTimeFormatPartType;
import gameObjects.Potion;
import gameObjects.Bullet;
import js.html.audio.WaveShaperNode;
import com.collision.platformer.CollisionBox;
import com.helpers.Rectangle;
import com.loading.basicResources.SpriteSheetLoader;
import com.gEngine.display.Blend;
import com.framework.utils.Random;
import com.collision.platformer.ICollider;
import com.framework.utils.Input;
import kha.input.KeyCode;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import com.collision.platformer.CollisionEngine;
import com.collision.platformer.Tilemap;
import com.gEngine.display.extra.TileMapDisplay;
import com.loading.basicResources.TilesheetLoader;
import com.loading.basicResources.JoinAtlas;
import com.gEngine.GEngine;
import com.loading.basicResources.ImageLoader;
import com.loading.Resources;
import com.framework.utils.State;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import format.tmx.Data.TmxObject;
import kha.Assets;
import gameObjects.Hero;
import GlobalGameData.GGD;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.StaticLayer;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Sprite;
import gameObjects.Zone;
import gameObjects.Enemy;
import gameObjects.Devil;
import gameObjects.Wand;
import kha.Color;
import com.gEngine.display.StaticLayer;
import com.loading.basicResources.SoundLoader;
import kha.audio1.AudioChannel;
import com.soundLib.SoundManager.SM;

class GameState extends State {
	// var screenWidth:Int;
	// var screenHeight:Int;
	var world:Tilemap;
	var hero:Hero;
	var devil1:Devil;
	var devil2:Devil;
	var devil3:Devil;
	var touchJoystick:VirtualGamepad;
	var scoreDisplay:Text;
	var score:Int = 0;
	var hudLayer:StaticLayer;
	var transportZone:CollisionGroup;
	var waterZone:CollisionGroup;
	var borderZone:CollisionGroup;
	var objects:CollisionGroup;
	var enemyCollisions:CollisionGroup;
	var devilsCollisions:CollisionGroup;
	var wand:Wand;
	var potion:Potion;
	var isWand:Bool;
	var isPotion:Bool;
	var thereAreDevils:Bool;
	var heart:Sprite;
	var lifeText:Text;
	var helpText:Text;
	var isShowingHelpText:Bool;
	var appearHelpingTest:Int;

	override function load(resources:Resources) {
		resources.add(new DataLoader("world" + GGD.levelNumber + "_tmx"));
		var atlas = new JoinAtlas(3072, 3072);
		atlas.add(new TilesheetLoader("RPGpack", 32, 32, 0));
		atlas.add(new TilesheetLoader("inside", 16, 16, 0));
		atlas.add(new FontLoader("KenneyThick", 30));
		atlas.add(new SpriteSheetLoader("characters", 32, 32, 0, [
			new Sequence("idleHero", [51]), new Sequence("walkDownHero", [48, 49, 50, 51]), new Sequence("walkUpHero", [52, 53, 54, 55]),
			new Sequence("walkToRightHero", [56, 57, 58]), new Sequence("idleEnemy", [99]), new Sequence("walkDownEnemy", [96, 97, 98, 99]),
			new Sequence("walkUpEnemy", [100, 101, 102, 103]), new Sequence("walkToRightEnemy", [104, 105, 106]), new Sequence("wand", [131]),
			new Sequence("potion", [143])]));
		atlas.add(new SpriteSheetLoader("devil", 64, 64, 0, [
			new Sequence("idleDevil", [11]),
			new Sequence("walkDownDevil", [8, 9, 10, 11]),
			new Sequence("walkUpDevil", [0, 1, 2, 3]),
			new Sequence("walkToRightDevil", [12, 13, 14, 15]),
			new Sequence("walkToLeftDevil", [4, 5, 6, 7]),
		]));
		atlas.add(new SpriteSheetLoader("PixelArtGameAssets01", 32, 32, 0, [new Sequence("heart", [2])]));
		atlas.add(new FontLoader("Kenney_Pixel", 24));
		resources.add(atlas);
		resources.add(new SoundLoader("achievement"));
		resources.add(new SoundLoader("bubble2"));
		resources.add(new SoundLoader("FinalBattle"));
		resources.add(new SoundLoader("gameOver"));
		resources.add(new SoundLoader("swing"));
		resources.add(new SoundLoader("woodSmall"));
		resources.add(new SoundLoader("ogre1"));
		resources.add(new SoundLoader("mnstr7"));
		resources.add(new SoundLoader("mnstr2"));
		resources.add(new SoundLoader("giant2"));
		resources.add(new SoundLoader("Battle", false));
	}

	override function init() {
		GGD.simulationLayer = new Layer();
		transportZone = new CollisionGroup();
		waterZone = new CollisionGroup();
		borderZone = new CollisionGroup();
		objects = new CollisionGroup();
		enemyCollisions = new CollisionGroup();
		devilsCollisions = new CollisionGroup();
		world = new Tilemap("world" + GGD.levelNumber + "_tmx", 1);
		isWand = false;
		isPotion = false;
		thereAreDevils = false;
		stage.addChild(GGD.simulationLayer);
		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);
		heart = new Sprite("PixelArtGameAssets01");
		heart.timeline.playAnimation("heart");
		heart.y = 20;
		heart.x = 33;
		heart.scaleX = heart.scaleY = 2;
		heart.smooth = false;
		hudLayer.addChild(heart);
		lifeText = new Text("Kenney_Pixel");
		lifeText.text = GGD.heroLife + "";
		lifeText.x = 20;
		lifeText.y = 20;
		lifeText.scaleX = 2.5;
		lifeText.scaleY = 2.5;
		lifeText.color = Color.Red;
		hudLayer.addChild(lifeText);

		isShowingHelpText = false;
		helpText = new Text("Kenney_Pixel");
		helpText.x = 150;
		helpText.y = 100;
		helpText.color = Color.Red;
		appearHelpingTest = 0;

		if (GGD.levelNumber == 3) {
			isWand = false;
			SM.stopMusic();
			SM.playMusic("FinalBattle");
			world.init(function(layerTilemap, tileLayer) {
				if (!tileLayer.properties.exists("noCollision")) {
					layerTilemap.createCollisions(tileLayer);
				}
				GGD.simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("inside")));
			}, parseMapObjects);
			stage.addChild(GGD.simulationLayer);
			stage.defaultCamera().limits(0, 0, 512, 768);
			hero = new Hero(225, 440, GGD.simulationLayer, 1.3);
			GGD.player = hero;
			devil1 = new Devil(GGD.simulationLayer, devilsCollisions, 50, 200, 50, 380);
			devil2 = new Devil(GGD.simulationLayer, devilsCollisions, 50, 200, 50, 380);
			devil3 = new Devil(GGD.simulationLayer, devilsCollisions, 50, 200, 50, 380);
			addChild(devil1);
			addChild(devil2);
			addChild(devil3);
			thereAreDevils = true;
		} else {
		
			world.init(function(layerTilemap, tileLayer) {
				if (!tileLayer.properties.exists("noCollision")) {
					layerTilemap.createCollisions(tileLayer);
				}
				GGD.simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("RPGpack")));
			}, parseMapObjects);
			stage.addChild(GGD.simulationLayer);
			stage.defaultCamera().limits(0, 0, world.widthIntTiles * 32, world.heightInTiles * 32);
			SM.playMusic("Battle", true);
			if (GGD.levelNumber == 1) {
				hero = new Hero(150, 900, GGD.simulationLayer);
				potion = new Potion(150, 150, GGD.simulationLayer);
				isPotion = true;				
			} else {
				hero = new Hero(50, 150, GGD.simulationLayer, 2);
				wand = new Wand(800, 150, GGD.simulationLayer);
				isWand = true;
			}
			GGD.player = hero;
			for (i in 0...10 * GGD.levelNumber) {
				var enemy:Enemy = new Enemy(GGD.simulationLayer, enemyCollisions, 50, 800, 50, 700);
				addChild(enemy);
			}
		}
		createTouchJoystick();
		GGD.camera = stage.defaultCamera();
		addChild(hero);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		switch (object.objectType) {
			case OTRectangle:
				if (object.type == "transport") {
					var transport = new Zone(object.x, object.y, object.width, object.height);
					transportZone.add(transport.collider);
				}
				if (object.type == "water") {
					var water = new Zone(object.x, object.y, object.width, object.height);
					waterZone.add(water.collider);
				}
				if (object.type == "house") {
					var house = new Zone(object.x, object.y, object.width, object.height);
					objects.add(house.collider);
				}
				if (object.type == "border") {
					var border = new Zone(object.x, object.y, object.width, object.height);
					borderZone.add(border.collider);
				}
			default:
		}
	}

	function createTouchJoystick() {
		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.DOWN_DPAD, KeyCode.Down);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.A);
		touchJoystick.notify(hero.onAxisChange, hero.onButtonChange);
		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(hero.onAxisChange, hero.onButtonChange);
	}

	private var mTime:Float = 0;

	override function update(dt:Float) {
		super.update(dt);
		stage.defaultCamera().setTarget(hero.x, hero.y);
		CollisionEngine.overlap(hero.collision, transportZone, heroVsTransportZone);
		CollisionEngine.overlap(hero.collision, enemyCollisions, heroVsEnemy);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, enemyCollisions, bulletVsEnemy);
		CollisionEngine.overlap(hero.collision, devilsCollisions, heroVsDevil);
		CollisionEngine.collide(hero.collision, waterZone);
		CollisionEngine.collide(hero.collision, borderZone);
		CollisionEngine.collide(enemyCollisions, waterZone);
		CollisionEngine.collide(enemyCollisions, objects);
		CollisionEngine.collide(hero.collision, objects);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, devilsCollisions, bulletVsDevil);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, objects, bulletVsObjects);
		if (thereAreDevils) {
			CollisionEngine.overlap(devil1.gun.bulletsCollisions, hero.collision);
			CollisionEngine.overlap(devil2.gun.bulletsCollisions, hero.collision);
			CollisionEngine.overlap(devil3.gun.bulletsCollisions, hero.collision);
		}
		if (isPotion) {
			CollisionEngine.overlap(hero.collision, potion.collider, heroVsPotion);
		}
		if (isWand) {
			CollisionEngine.overlap(hero.collision, wand.collider, heroVsWand);
		}
		if (isShowingHelpText) {
			appearHelpingTest--;
			if (appearHelpingTest == 0) {
				isShowingHelpText = false;
				helpText.removeFromParent();
			}
		}
	}

	override function render() {
		super.render();
	}

	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
		GGD.destroy();
	}

	function heroVsTransportZone(heroCollision:ICollider, transportZoneCollision:ICollider) {
		switch (GGD.levelNumber) {
			case 1:
				if (GGD.hasPotion) {
					GGD.levelNumber = GGD.levelNumber + 1;
					changeState(new GameState());
				} else {
					helpText.text = "You need the potion first.";
					hudLayer.addChild(helpText);
					isShowingHelpText = true;
					appearHelpingTest = 50;
				}
			case 2:
				if (GGD.hasWand) {
					GGD.levelNumber = GGD.levelNumber + 1;
					changeState(new GameState());
				} else {
					helpText.text = "You need the wand first.";
					hudLayer.addChild(helpText);
					isShowingHelpText = true;
					appearHelpingTest = 50;
				}
			default:
		}
	}

	function heroVsWand(heroCollision:ICollider, wandCollision:ICollider) {
		GGD.hasWand = true;
		isWand = false;
		this.wand.damage();
		this.wand.die();
		SM.playFx("woodSmall");
	}

	function heroVsPotion(heroCollision:ICollider, potionCollision:ICollider) {
		GGD.hasPotion = true;
		isPotion = false;
		hero.speed = 350;
		this.potion.damage();
		this.potion.die();
		SM.playFx("bubble2");
	}

	function heroVsEnemy(enemyCollision:ICollider, heroCollision:ICollider) {
		var enemy:Enemy = cast enemyCollision.userData;
		enemy.damage();
		enemy.die();
		GGD.heroLife--;
		lifeText.text = GGD.heroLife + "";
		SM.playFx("ogre1");
		// if (GGD.heroLife == 0) {
		// 	changeState(new GameOver());
		// 	SM.playFx("gameOver");
		// SM.stopMusic(); 
		// }
	}

	function heroVsDevil(devilCollision:ICollider, heroCollision:ICollider) {
		SM.stopMusic();
		changeState(new GameOver());
		SM.playFx("gameOver");
	}

	function bulletVsEnemy(bulletCollision:ICollider, enemyCollision:ICollider) {
		var enemy:Enemy = cast enemyCollision.userData;
		enemy.damage();
		enemy.die();
		var bullet:Bullet = cast bulletCollision.userData;
		bullet.die();
		SM.playFx("mnstr7");
	}

	function bulletVsDevil(bulletCollision:ICollider, devilCollision:ICollider) {
		var devil:Devil = cast devilCollision.userData;
		devil.damage();
		var bullet:Bullet = cast bulletCollision.userData;
		bullet.die();
		SM.playFx("mnstr2");
	}

	function bulletVsObjects(bulletCollision:ICollider, objectCollision:ICollider) {
		var bullet:Bullet = cast bulletCollision.userData;
		bullet.die();
	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
