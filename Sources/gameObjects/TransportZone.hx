package gameObjects;

import com.framework.utils.Entity;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Layer;

class TransportZone extends Entity {
	public var collider:CollisionBox;

	public function new(x:Float, y:Float, width:Float, height:Float, layer:Layer) {
        super();
        collider = new CollisionBox();
        collider.x = x;
		collider.y = y;
		collider.userData = this;
		collider.width = width;
        collider.height = height;
        // layer.addChild()
    }
    
    override function update(dt:Float) {
        super.update(dt);
    }
}
