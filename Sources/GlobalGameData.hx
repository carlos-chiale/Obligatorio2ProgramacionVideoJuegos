import com.gEngine.display.Layer;
import gameObjects.Hero;

typedef GGD = GlobalGameData; 
class GlobalGameData {

    public static var player:Hero;
    public static var simulationLayer:Layer;

    public static function destroy() {
        player=null;
        simulationLayer=null;
    }
}