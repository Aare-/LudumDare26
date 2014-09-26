package com.subfty.sub.svg.actors;
import com.subfty.minimalism.Main;
import com.subfty.sub.display.Screen;
import com.subfty.sub.svg.SVGParser;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.events.TouchEvent;

/**
 * ...
 * @author Filip Loster
 */

class Trigger extends Sprite{
  //STATIC PART
	static var actions:Hash < Xml->Void > = new Hash < Xml->Void > ();
	public static function registarAction(id:String, func:Xml->Void) {
		if (!actions.exists(id))
			actions.set(id, func);
	}
	public static function clearActionHash() {
		actions = new Hash < Xml->Void > ();
	}
	
  //VALUES
	var w:Float;
	var h:Float;
	
	var act:Xml->Void = null;
	var goToScreen:String = null;
	var xml:Xml;
	
	public function new(xml:Xml) {
		super();
		this.xml = xml;
		SVGParser.applyTransformToRect(xml, cast(this));
		var a:String = xml.get("action");
		if (a != null && actions.exists(a)) 
			act = actions.get(a);
		goToScreen = xml.get("goToScreen");
		
		#if mobile
			this.addEventListener(TouchEvent.TOUCH_BEGIN, onTap);
		#else
			this.addEventListener(MouseEvent.MOUSE_DOWN, onTap);
		#end
	}
	
	//TOUCH EVENTS
	function onTap(e: { localX:Float, localY:Float, 
				   target:Dynamic}) {
		if (e.target != this) return;
		
		if (act != null)
			act(xml);
		if (goToScreen != null)
			Main.screen = Main.screens.get(goToScreen);
	}
}