package com.subfty.sub.helpers;
import nape.geom.Vec2;
import nme.display.Sprite;
import nme.geom.Point;

/**
 * ...
 * @author Filip Loster
 */

class Statics implements Singleton{

	public static var p1:Point = new Point(0, 0);
	public static var p2:Point = new Point(0, 0);

	public static var v1:Vec2 = new Vec2(0, 0);
	public static var v2:Vec2 = new Vec2(0, 0);
	public static var v3:Vec2 = new Vec2(0, 0);
	
	public static function getPositionOnScreen(sprite:Sprite):Point {
		p1.x = sprite.x;
		p1.y = sprite.y;
		var parent = sprite.parent;
		while (parent != null) {
			p1.x += parent.x;
			p1.y += parent.y;
			parent = parent.parent;
		}
		
		return p1;
	}
}