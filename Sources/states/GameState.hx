package states;

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
import gameObjects.Bullet;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.StaticLayer;
import com.gEngine.display.Text;
import com.loading.basicResources.FontLoader;
import com.gEngine.display.Sprite;
import gameObjects.TransportZone;
class GameState extends State {
	// var screenWidth:Int;
	// var screenHeight:Int;
	var world:Tilemap;
	var hero:Hero;
	var touchJoystick:VirtualGamepad;
	var scoreDisplay:Text;
	var score:Int = 0;
	var hudLayer:StaticLayer;
	// var transportZone:TransportZone;
	override function load(resources:Resources) {
		resources.add(new DataLoader("world_tmx"));
		var atlas = new JoinAtlas(2048, 2048);
		atlas.add(new TilesheetLoader("RPGpack", 32, 32, 0));
		atlas.add(new FontLoader("KenneyThick", 30));
		atlas.add(new SpriteSheetLoader("characters", 32, 32, 0, [
			new Sequence("idle", [51]),
			new Sequence("walkDown", [48, 49, 50, 51]),
			new Sequence("walkUp", [52, 53, 54, 55]),
			new Sequence("walkToRight", [56, 57, 58])
		]));
		resources.add(atlas);
	}

	override function init() {
		GGD.simulationLayer = new Layer();
		// transportZone = new CollisionBox();
		// transportZone=new TransportZone(0,0,0,0, null);
		world = new Tilemap("world_tmx", 1);
		world.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			GGD.simulationLayer.addChild(layerTilemap.createDisplay(tileLayer, new Sprite("RPGpack")));
		}, parseMapObjects);
		stage.addChild(GGD.simulationLayer);
		hero = new Hero(200, 750, GGD.simulationLayer);
		createTouchJoystick();
		GGD.camera = stage.defaultCamera();
		stage.defaultCamera().limits(0, 0, world.widthIntTiles * 32, world.heightInTiles * 32);
		addChild(hero);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		switch (object.objectType) {
			case OTRectangle:
				// if (object.type == "transport") {			
				// 	var transportZone = new TransportZone(object.x, object.y, object.width, object.height, GGD.simulationLayer);
				// 	GGD.simulationLayer.addChild(transportZone);
				// }
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

		// CollisionEngine.overlap(hero.collision, transportZone.collider, heroVsTransportZone);

	}

	override function render() {
		super.render();
	}

	override function destroy() {
		super.destroy();
		touchJoystick.destroy();
		GGD.destroy();
	}

	function heroVsTransportZone(heroCollision: ICollider, transportZoneCollision: ICollider){

	}

	#if DEBUGDRAW
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		var camera = stage.defaultCamera();
		CollisionEngine.renderDebug(framebuffer, camera);
	}
	#end
}
