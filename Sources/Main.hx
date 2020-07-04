package;


import kha.WindowMode;
import com.framework.Simulation;
import kha.System;
import kha.System.SystemOptions;
import kha.FramebufferOptions;
import kha.WindowOptions;
import states.GameState;

class Main {
    public static function main() {
		#if hotml new hotml.Client(); #end
		
			var windowsOptions=new WindowOptions("Obligatorio2",0,0,768,768,null,true,WindowFeatures.FeatureResizable,WindowMode.Windowed);
		var frameBufferOptions=new FramebufferOptions();
		System.start(new SystemOptions("Obligatorio2",768,768,windowsOptions,frameBufferOptions), function (w) {
			new Simulation(GameState,512,768);
        });
    }
}
