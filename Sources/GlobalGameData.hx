import com.gEngine.display.Camera;
import com.gEngine.display.Layer;
import gameObjects.Hero;

typedef GGD = GlobalGameData; 
class GlobalGameData {

    public static var player:Hero;
    public static var simulationLayer:Layer;
    public static var camera:Camera;
    public static var levelNumber:Int=1;
    public static var hasWand:Bool=false;

    public static function destroy() {
        player=null;
        simulationLayer=null;
        camera=null;
    }
}