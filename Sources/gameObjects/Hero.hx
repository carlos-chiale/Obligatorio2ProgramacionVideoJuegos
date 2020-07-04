package gameObjects;

import com.framework.utils.Entity;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.XboxJoystick;
import com.gEngine.GEngine;
import kha.math.FastVector2;

class Hero extends Entity {

	static private inline var SPEED:Float = 250;

	public var display:Sprite;
	public var collision:CollisionBox;
	var direction:FastVector2;
	public var x(get,null):Float;
	public var y(get,null):Float;

	// var maxSpeed = 700;

	// public var gun:Gun;
	// public var xForBullet(get,null):Float;
	// public var yForBullet(get,null):Float;

	var screenWidth = GEngine.i.width;
	var screenHeight = GEngine.i.height;

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		direction=new FastVector2(0,1);
		display = new Sprite("characters");
		// display.timeline.frameRate=1/10;
		display.smooth = false;
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x = x;
		collision.y = y;
		collision.userData = this;
		layer.addChild(display);
		// collision.maxVelocityX = maxSpeed;
		// collision.dragX = 0.9;
		// gun = new Gun();
		// addChild(gun);
	}

	override function update(dt:Float) {
		super.update(dt);
		// collision.velocityX=0;
		// collision.velocityY=0;
		// if (collision.x + collision.width > screenWidth || collision.x < 0) {
		// 	collision.velocityX *= -50;
		// }
		collision.update(dt);
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		display.timeline.playAnimation("idle");
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if(value ==1 ) collision.velocityX=-SPEED;
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if(value ==1 ) collision.velocityX=SPEED;
		}
		// if (id == XboxJoystick.A) {
		// 	if (value == 1) {
		// 		gun.shoot(xForBullet,yForBullet,0,-1);
		// 	}
		// }
	}

	// public function get_xForBullet():Float{
	// 	return collision.x+collision.width/2;
	// }
	// public function get_yForBullet():Float{
	// 	return collision.y;
	// }

	public function get_x():Float{
		return collision.x+collision.width*0.5;
	}
	public function get_y():Float{
		return collision.y+collision.height;
	}

	public function onAxisChange(id:Int, value:Float) {}
}
