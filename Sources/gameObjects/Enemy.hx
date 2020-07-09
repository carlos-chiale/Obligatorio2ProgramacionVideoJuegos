package gameObjects;

import com.framework.utils.Entity;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Layer;
import gameObjects.Hero;
import GlobalGameData.GGD;
import kha.math.FastVector2;
import com.framework.utils.Random;

class Enemy extends Entity {
	var display:Sprite;
	var collision:CollisionBox;
	var collisionGroup:CollisionGroup;

	static inline var MAX_SPEED:Float = 100;

	public function new(layer:Layer, collisions:CollisionGroup, minX:Float, maxX:Float, minY:Float, maxY:Float) {
		super();
		collisionGroup = collisions;
		display = new Sprite("characters");
		layer.addChild(display);
		// display.offsetY = 7;
		collision = new CollisionBox();
		collision.userData = this;
		collision.width = display.width();
		collision.height = display.height();
        display.timeline.frameRate = 1 / 20;
        display.pivotX=16;
		display.smooth = false;
		randomPos(minX, maxX, minY, maxY);
	}

	private function randomPos(minX:Float, maxX:Float, minY:Float, maxY:Float) {
		// display.offsetX=-22;
		// display.offsetY=-14;
		display.timeline.playAnimation("idleEnemy");
		collisionGroup.add(collision);
		// var target:Hero = GGD.player;
		// var dirX = 1 - Math.random() * 2;
		// var dirY = 1 - Math.random() * 2;
		// if (dirX == 0 && dirY == 0) {
		// 	dirX += 1;
		// }
		// var length = Math.sqrt(dirX * dirX + dirY * dirY);
		// collision.x = target.x + 1000 * dirX / length;
		// collision.y = target.y + 600 * dirY / length;

		collision.x = Random.getRandomIn(minX, maxX);
		collision.y = Random.getRandomIn(minY, maxY);
	}

	override public function update(dt:Float):Void {
		// if(display.timeline.currentAnimation=="die_"){
		//     if(display.timeline.playing){
		//         randomPos();
		//     }
		//     return;
		// }
		var target:Hero = GGD.player;
		var dir:FastVector2 = new FastVector2(target.x - (collision.x + collision.width * 0.5), target.y - (collision.y + collision.height));
		if (Math.abs(dir.x) > 5 && Math.abs(dir.y) > 5) {
			if (Math.abs(dir.x) > Math.abs(dir.y)) {
				dir.x = 0;
			} else {
				dir.y = 0;
			}
		}
		dir.setFrom(dir.normalized());
		dir.setFrom(dir.mult(MAX_SPEED));
		collision.velocityX = dir.x;
		collision.velocityY = dir.y;
		collision.update(dt);
		super.update(dt);
	}

	public function damage():Void {
		// display.offsetY = -35;
		// display.timeline.playAnimation("die_", false);
		display.removeFromParent();
		collision.removeFromParent();
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
		// if (display.timeline.currentAnimation == "die_")
		// 	return;
		if (Math.abs(collision.velocityX) > Math.abs(collision.velocityY)) {
			display.timeline.playAnimation("walkToRightEnemy");
			if (collision.velocityX > 0) {
				display.scaleX = 1;
			} else {
				display.scaleX = -1;
			}
		} else {
			if (collision.velocityY > 0) {
				display.timeline.playAnimation("walkDownEnemy");
			} else {
				display.timeline.playAnimation("walkUpEnemy");
			}
		}
		super.render();
	}
}
