package com.subfty.sub.svg.actors;
import nme.display.Sprite;

/**
 * ...
 * @author Filip Loster
 */

class Box extends Sprite{

  //VALUES
	var w:Float;
	var h:Float;
	var color:Int;
	
	public function new(xml:Xml) {
		super();
		
		SVGParser.applyTransformToRect(xml, cast(this));
		color = SVGParser.getColor(xml);
		
		graphics.beginFill(color, 1);
		graphics.drawRect(0, 0, w, h);
		graphics.endFill();
	}
	
}