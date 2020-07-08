package gameObjects;

import com.gEngine.display.Layer;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class Wand extends Entity {
	public var display:Sprite;
	public var collider:CollisionBox;

	public function new(x:Float, y:Float, layer:Layer) {
		super();
		collider = new CollisionBox();
		display = new Sprite("characters");		
		collider.width = display.width();
		collider.height = display.height();
		collider.x = x;
		collider.y = y;
        collider.userData = this;
        display.timeline.playAnimation("wand");  
		layer.addChild(display);
		display.x = collider.x;
		display.y = collider.y;
    }

    public function damage():Void{
        collider.removeFromParent();
        display.removeFromParent();
    }
}
