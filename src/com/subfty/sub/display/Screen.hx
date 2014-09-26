package com.subfty.sub.display;
import com.subfty.minimalism.Main;
import com.subfty.sub.svg.SVGParser;
import nme.display.Sprite;
import nme.events.Event;
import nme.Lib;

/**
 * ...
 * @author Filip Loster
 */

interface Updatable {
	function update():Void;
}

class Screen extends Sprite{
	
	var _update : Array<Updatable>;
	
	public function new(parent:Sprite, name:String) {
		super();
		
		_update = new Array<Updatable>();
			
		parent.addChild(this);
		
		this.visible = false;

		this.name = name;
		Main.screens.set(this.name, this);
		
		SVGParser.parse("layouts/" + name + ".svg", this);
		
	  //REGISTERING UPDATABLES
	    findAndRegisterUpdatables(this);
		//for (f in Reflect.fields(this))
			//if (Std.is(Reflect.field(this, f), Updatable))
				//registerUpdatable(Reflect.field(this, f));
	}
	
  //CALLBACKS
	/**
	 * called when this screen is set as an active
	 */
	public function load() {}
	/**
	 * called when screen is set as inactive
	 */
	public function unload() {}
	/**
	 * called when application is paused/minimised
	 */
	public function pause() { }
	/** 
	 * called when application is resumed 
	 **/
	public function resume() { }
	
  //REGISTERING UPDATABLE CLASSES
	function findAndRegisterUpdatables(spr:Sprite) {
		for (i in 0...spr.numChildren) {
			var s = spr.getChildAt(i);
			
			if (Std.is(s, Updatable))
				registerUpdatable(cast(s));
			
			if(Std.is(s, Sprite))
				findAndRegisterUpdatables(cast(s));
		}
	}
	public function registerUpdatable(c : Updatable) {
		for ( u in _update)
			if (u == c)
				return;
		_update.push(c);
	}
	public function unregisterUpdatable(c : Updatable) {
		_update.remove(c);
	}
	
	/**
	 * Called each frame
	 */
	public function step() {
	  //UPDATING 
		for (u in _update)
			if(u != null)
				u.update();
	}
}