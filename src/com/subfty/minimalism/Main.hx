package com.subfty.minimalism;

import com.subfty.minimalism.screens.Death;
import com.subfty.minimalism.screens.Game;
import com.subfty.minimalism.screens.Intro;
import com.subfty.sub.display.helpers.FPS;
import com.subfty.sub.display.Screen;
import com.subfty.sub.helpers.FixedAspectRatio;
import com.subfty.sub.helpers.GamepadProxy;
import nme.display.Sprite;
import nme.display.Stage;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.Lib;
import com.subfty.sub.data.Config;
import nape.space.Space;
import nape.util.BitmapDebug;
import nape.util.Debug;
import nape.geom.Vec2;
import nme.ui.Keyboard;
import nape.util.BitmapDebug;

/**
 * ...
 * @author Filip Loster
 */

class Main extends Sprite {
	public static var pausePsychic:Float;
	
  //ASPECT RATIO
  //SCREEN SIZE CLIPPED TO THE FIXED SCREEN PROPORTIONS
	public static var STAGE_W:Int;
	public static var STAGE_H:Int;
	
  //ACTUAL SCREEN SIZE
	public static var SCREEN_W(get_screen_w, null):Float;
	public static var SCREEN_H(get_screen_h, null):Float;
	
	public static var aspect:FixedAspectRatio;
	public static var stage:Stage;
	
  //CALCULATING DELTA
	private static var prevFrame:Int = -1;
	public static var delta:Int = 0;
	public static var movAlpha:Float = 0;
	static var napeDelta:Int;
	static var desiredStepTime:Int;
	
  //NAPE
	var VELOC_ITER:Int;
	var DEATH_LOOP_MARGIN:Int;
	var POS_ITER:Int;
	var FIXED_TIMESTAMP:Int;
	public static var space:Space;
	var debug:Debug;
	
  //INPUT
	#if flash
	public static var gamepad : Gamepad = null;
	public static var gamepads : Array<Gamepad> = [];
	#end
	public static var keyboard : Array<Bool> = [];
	
  //SCREENS
    //current screen
	public static var screen(default, set_screen):Screen;
	
	public static var screens:Hash <Screen> = new Hash <Screen> ();
	//list of screens
	public static var game:Game;
	public static var death:Death;
	public static var intro:Intro;
	
  //DEBUG
	//#if debug
	var fps:FPS;
	//#end
	
	public function new(){
		super();
		#if iphone
		Lib.current.stage.addEventListener(Event.RESIZE, init);
		#else
		addEventListener(Event.ADDED_TO_STAGE, init);
		#end
	}

	private function init(e) {
		Config.loadXmlData();
			
	  //LOADING DATA
		STAGE_W = Std.parseInt(Config.f.node.nape.node.space.att.width);
		STAGE_H = Std.parseInt(Config.f.node.nape.node.space.att.height);
		
		VELOC_ITER = Std.parseInt(Config.f.node.nape.node.accuracy.att.veloc_i);
		POS_ITER = Std.parseInt(Config.f.node.nape.node.accuracy.att.pos_i);
		
		FIXED_TIMESTAMP = Std.parseInt(Config.f.node.nape.att.fixed_timestamp);
		DEATH_LOOP_MARGIN = Std.parseInt(Config.f.node.nape.att.death_loop_margin);
		
		aspect = new FixedAspectRatio(this, STAGE_W, STAGE_H);
		aspect.fix(null);
	
	  //NAPE INITIATION
		space = new Space(Vec2.weak(Std.parseFloat(Config.f.node.nape.node.gravity.att.x), 
						            Std.parseFloat(Config.f.node.nape.node.gravity.att.y)));
		napeDelta = 0;
		desiredStepTime = Math.floor(1 / stage.frameRate * 1000);
		
		//addChild(debug.display);
	  //SETTING UP SCREENS
		game = new Game(this, "game");
		death = new Death(this, "death");
		intro = new Intro(this, "intro");
		
	  //REGISTERING EVENTS
		for (i in 0...666)
			keyboard.push(false);
		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		screen = intro;
		//screen = game;
		
		fps = new FPS(10, STAGE_H - 30, 0xff0000);
		fps.mouseEnabled = false;
		//this.addChild(fps);
		
		pausePsychic = 0;
	}
	
	static public function main() {
		#if flash
		try{
			GamepadProxy.start();
		}catch (e:Dynamic) {}
		#end
		
		stage = Lib.current.stage;
		stage.scaleMode = nme.display.StageScaleMode.NO_SCALE;
		stage.align = nme.display.StageAlign.TOP_LEFT;
		
		Lib.current.addChild(new Main());
	}

  //EVENTS
	//MAIN LOOP
	function onEnterFrame(e:Event) {
		#if flash
	  //GAMEPADS
		try{
		gamepads = GamepadProxy.getGamepads();
        for (g in gamepads)
            if (g != null) {
				gamepad = g;
                break;
            }
		}catch (e:Dynamic) {}
		#end
		
	  //CALCULATING DELTA
		if (prevFrame < 0) prevFrame = Lib.getTimer();
		delta = (Lib.getTimer() - prevFrame);
		prevFrame = Lib.getTimer();
		
	  //NAPE STEP
	  
		napeDelta += Math.floor(Math.min(delta, DEATH_LOOP_MARGIN));
		if(FIXED_TIMESTAMP >= 1){
			while(napeDelta >= desiredStepTime){
				space.step(1 / stage.frameRate, VELOC_ITER, POS_ITER);
				napeDelta -= desiredStepTime;
			}
			movAlpha = napeDelta / desiredStepTime;
		}else {		
			delta = Math.floor(Math.min(delta, DEATH_LOOP_MARGIN));
			if(pausePsychic > 0){
				space.step(Math.max(0.01,delta / 1000) * pausePsychic, VELOC_ITER, POS_ITER);
				movAlpha = 1;
			}
		}
		
		if (screen != null)
			screen.step();
	}
	//INPUT
	function onKeyDown(e:KeyboardEvent) {
		keyboard[e.keyCode] = true;
	}
	function onKeyUp(e:KeyboardEvent) {
		keyboard[e.keyCode] = false;
	}
	
  //GETTERS/SETTERS
  	static function get_screen_w():Float {
		return Lib.current.stage.stageWidth / aspect.scaleFactor;
	}
	static function get_screen_h():Float {
		return Lib.current.stage.stageHeight / aspect.scaleFactor;
	}
	
	private static function set_screen(s:Screen):Screen {
		if (screen != null) {			
			screen.visible = false;
			screen.unload();
		}
		screen = s;
		if(screen != null){
			screen.visible = true;
			screen.load();
		}
		
		return screen;
	}
}
