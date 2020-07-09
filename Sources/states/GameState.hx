package states;

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

class GameState extends State {
	// var screenWidth:Int;
	// var screenHeight:Int;
	var world:Tilemap;
	var hero:Hero;
	var touchJoystick:VirtualGamepad;
	var scoreDisplay:Text;
	var score:Int = 0;
	var hudLayer:StaticLayer;
	var transportZone:CollisionGroup;
	var waterZone:CollisionGroup;
	var objects:CollisionGroup;
	var enemyCollisions:CollisionGroup;
	var devilsCollisions:CollisionGroup;
	var wand:Wand;
	var isWand:Bool;

	override function load(resources:Resources) {
		resources.add(new DataLoader("world" + GGD.levelNumber + "_tmx"));
		var atlas = new JoinAtlas(3072, 3072);
		atlas.add(new TilesheetLoader("RPGpack", 32, 32, 0));
		atlas.add(new TilesheetLoader("inside", 16, 16, 0));
		atlas.add(new FontLoader("KenneyThick", 30));
		atlas.add(new SpriteSheetLoader("characters", 32, 32, 0, [
			new Sequence("idleHero", [51]),
			new Sequence("walkDownHero", [48, 49, 50, 51]),
			new Sequence("walkUpHero", [52, 53, 54, 55]),
			new Sequence("walkToRightHero", [56, 57, 58]),
			new Sequence("idleEnemy", [99]),
			new Sequence("walkDownEnemy", [96, 97, 98, 99]),
			new Sequence("walkUpEnemy", [100, 101, 102, 103]),
			new Sequence("walkToRightEnemy", [104, 105, 106]),
			new Sequence("wand", [131])
		]));
		atlas.add(new SpriteSheetLoader("devil", 64, 64, 0, [
			new Sequence("idleDevil", [11]),
			new Sequence("walkDownDevil", [8, 9, 10, 11]),
			new Sequence("walkUpDevil", [0, 1, 2, 3]),
			new Sequence("walkToRightDevil", [12, 13, 14, 15]),
			new Sequence("walkToLeftDevil", [4, 5, 6, 7]),
		]));
		resources.add(atlas);
	}

	override function init() {
		GGD.simulationLayer = new Layer();
		transportZone = new CollisionGroup();
		waterZone = new CollisionGroup();
		objects = new CollisionGroup();
		enemyCollisions = new CollisionGroup();
		devilsCollisions = new CollisionGroup();
		world = new Tilemap("world" + GGD.levelNumber + "_tmx", 1);
		isWand = false;
		if (GGD.levelNumber == 3) {
			isWand = false;
			world.init(function(layerTilemap, tileLayer) {
				if (!tileLayer.properties.exists("noCollision")) {
					layerTilemap.createCollisions(tileLayer);
				}
				GGD.simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("inside")));
			}, parseMapObjects);
			stage.addChild(GGD.simulationLayer);
			stage.defaultCamera().limits(0, 0, 512, 768);
			hero = new Hero(225, 440, GGD.simulationLayer);
			GGD.player = hero;
			for (i in 0...4) {
				var enemy:Devil = new Devil(GGD.simulationLayer, devilsCollisions);
				addChild(enemy);
			}
		} else {
			world.init(function(layerTilemap, tileLayer) {
				if (!tileLayer.properties.exists("noCollision")) {
					layerTilemap.createCollisions(tileLayer);
				}
				GGD.simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("RPGpack")));
			}, parseMapObjects);
			stage.addChild(GGD.simulationLayer);
			stage.defaultCamera().limits(0, 0, world.widthIntTiles * 32, world.heightInTiles * 32);
			if (GGD.levelNumber == 1) {
				hero = new Hero(150, 900, GGD.simulationLayer);
			} else {
				hero = new Hero(50, 150, GGD.simulationLayer);
				wand = new Wand(800, 150, GGD.simulationLayer);
				isWand = true;
			}
			GGD.player = hero;
			for (i in 0...60) {
				var enemy:Enemy = new Enemy(GGD.simulationLayer, enemyCollisions);
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
		CollisionEngine.overlap(hero.collision, enemyCollisions);
		CollisionEngine.overlap(hero.collision, devilsCollisions);
		CollisionEngine.collide(hero.collision, waterZone);
		CollisionEngine.collide(enemyCollisions, waterZone);
		CollisionEngine.collide(enemyCollisions, objects);
		CollisionEngine.collide(hero.collision, objects);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, enemyCollisions, bulletVsEnemy);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, devilsCollisions, bulletVsDevil);
		CollisionEngine.overlap(hero.gun.bulletsCollisions, objects, bulletVsObjects);
		if (isWand) {
			CollisionEngine.overlap(hero.collision, wand.collider, heroVsWand);
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
				GGD.levelNumber = GGD.levelNumber + 1;
				changeState(new GameState());
			case 2:
				if (GGD.hasWand) {
					GGD.levelNumber = GGD.levelNumber + 1;
					changeState(new GameState());
				}
			default:
		}
	}

	function heroVsWand(heroCollision:ICollider, wandCollision:ICollider) {
		GGD.hasWand = true;
		isWand = false;
		this.wand.damage();
		this.wand.die();
	}

	function bulletVsEnemy(bulletCollision:ICollider, enemyCollision:ICollider) {
		var enemy:Enemy = cast enemyCollision.userData;
		enemy.damage();
		var bullet:Bullet = cast bulletCollision.userData;
		bullet.die();
	}

	function bulletVsDevil(bulletCollision:ICollider, devilCollision:ICollider) {
		var devil:Devil = cast devilCollision.userData;
		devil.damage();
		var bullet:Bullet = cast bulletCollision.userData;
		bullet.die();
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
