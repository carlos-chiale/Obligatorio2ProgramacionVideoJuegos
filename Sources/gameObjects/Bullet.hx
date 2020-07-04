package gameObjects;

import com.collision.platformer.CollisionGroup;
import com.gEngine.helper.RectangleDisplay;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;
import GlobalGameData.GGD;

class Bullet extends Entity
{
	public var collision:CollisionBox;
	var display:RectangleDisplay;
	var lifeTime:Float=0;
	var totaLifetime:Float=3;

	public function new() 
	{
		super(); 
		collision=new CollisionBox();
		collision.width=5;
		collision.height=5;
		collision.userData=this;

		display = new RectangleDisplay();
		display.setColor(255,0,0);
		display.scaleX=5;
		display.scaleY=5;
	}
	override function limboStart() {
		display.removeFromParent();
		collision.removeFromParent();
	}
	override function update(dt:Float) {
		lifeTime+=dt;
		if(lifeTime>totaLifetime){
			die();
		}
		collision.update(dt);
		display.x=collision.x;
		display.y=collision.y;
		
		super.update(dt);
	}
	public function shoot(x:Float, y:Float,dirX:Float,dirY:Float,bulletsCollision:CollisionGroup):Void
	{
		lifeTime=0;
		collision.x=x;
		collision.y=y;
		collision.velocityX = 1000 * dirX;
		collision.velocityY = 1000 * dirY;
		bulletsCollision.add(collision);
		GGD.simulationLayer.addChild(display);
		
	}
}