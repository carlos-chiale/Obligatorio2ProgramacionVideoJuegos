package gameObjects;

import js.html.audio.DistanceModelType;
import com.framework.utils.Entity;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.XboxJoystick;
import com.gEngine.GEngine;
import kha.math.FastVector2;
import GlobalGameData.GGD;

class Hero extends Entity {
	static private inline var SPEED:Float = 250;

	public var display:Sprite;
	public var collision:CollisionBox;

	var direction:FastVector2;

	public var x(get, null):Float;
	public var y(get, null):Float;

	// var maxSpeed = 700;
	public var gun:Gun;
	public var xForBullet(get,null):Float;
	public var yForBullet(get,null):Float;
	var screenWidth = GEngine.i.width;
	var screenHeight = GEngine.i.height;
	public var width(get,null):Float;
	public var height(get,null):Float;

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		direction = new FastVector2(0, 1);
		display = new Sprite("characters");
		display.timeline.frameRate=1/20;
		display.pivotX=16;
		display.smooth = false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.x = x;
		collision.y = y;
		collision.userData = this;
		
		// collision.maxVelocityX = maxSpeed;
		// collision.dragX = 0.9;
		gun = new Gun();
		addChild(gun);
	}

	override function update(dt:Float) {
		super.update(dt);
		// collision.velocityX=0;
		// collision.velocityY=0;
		// if (collision.x + collision.width > screenWidth || collision.x < 0) {
		// 	collision.velocityX *= -50;
		// }
		if(collision.velocityX !=0 || collision.velocityY !=0){
			direction.setFrom(new FastVector2(collision.velocityX,collision.velocityY));
			direction.setFrom(direction.normalized());
		}else{
			if(Math.abs(direction.x)>Math.abs(direction.y)){
				direction.y=0;
			}else{
				direction.x=0;
			}
		}
		collision.update(dt);
	}

	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
		// display.timeline.playAnimation("walkDown");
		if (notWalking()) {
			if (direction.x == 0) {
				if (direction.y > 0) {
					display.timeline.playAnimation("idleHero"); // down
				} else {
					display.timeline.playAnimation("idleHero"); // up
				}
			} else {
				display.timeline.playAnimation("idleHero");
				if (direction.x > 0) {
					display.scaleX = 1;
				} else {
					display.scaleX = -1;
				}
			}
		}else{
			if(direction.x==0){
				if(direction.y>0){
					display.timeline.playAnimation("walkDownHero");
				}else{
					display.timeline.playAnimation("walkUpHero");
				}
			}else{
				display.timeline.playAnimation("walkToRightHero");
				if(direction.x>0){
					display.scaleX = Math.abs(display.scaleX);
				}else{
					display.scaleX = -Math.abs(display.scaleX);
				}
			}
		}
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.velocityX = -SPEED;
			} else {
				collision.velocityX = 0;
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.velocityX = SPEED;
			} else {
				collision.velocityX = 0;
			}
		}
		if (id == XboxJoystick.UP_DPAD) {
			if (value == 1) {
				collision.velocityY = -SPEED;
			} else {
				collision.velocityY = 0;
			}
		}
		if (id == XboxJoystick.DOWN_DPAD) {
			if (value == 1) {
				collision.velocityY = SPEED;
			} else {
				collision.velocityY = 0;
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1 && GGD.hasWand) {
				gun.shoot(x,y-height*0.75,direction.x,direction.y);
			}
		}
	}

	public function get_xForBullet():Float{
		return collision.x+collision.width/2;
	}
	public function get_yForBullet():Float{
		return collision.y;
	}

	public function get_x():Float {
		return collision.x + collision.width * 0.5;
	}

	public function get_y():Float {
		return collision.y + collision.height;
	}

	public function get_width():Float{
		return collision.width;
	}
	public function get_height():Float{
		return collision.height;
	}

	public function onAxisChange(id:Int, value:Float) {}

	inline function walking45() {
		return direction.x != 0 && direction.y != 0;
	}

	inline function notWalking() {
		return collision.velocityX == 0 && collision.velocityY == 0;
	}
}
