package com.subfty.sub.helpers;

/**
 * http://code.google.com/p/hapi/source/browse/trunk/hapi/math/Vector2D.hx?r=8
 * @author Krzysztof Rozalski
 */

class Vector2D {

	public inline static var ZERO:Vector2D = new Vector2D(0,0);
	
	public var x:Float;
	public var y:Float;
	
	public function new( px, py) {
		x = px;
		y = py;
	}
	
	public static function angleBetween(v:Vector2D ,w:Vector2D){
		return Math.acos(v.dot(w)/(v.getLength()*w.getLength()));
	}
	
	public inline function clone():Vector2D {
		return new Vector2D( this.x, this.y );
	}
	
	public inline function equals( v:Vector2D ):Bool {
		return ( this.x == v.x && this.y == v.y );
	}
	
	public inline function zero():Vector2D {
		this.x = this.y = 0;
		return this;
	}
	
	public inline function plus( v:Vector2D ):Vector2D {
		this.x += v.x;
		this.y += v.y;
		return this;
	}
	
	public inline function plusNew( v:Vector2D):Vector2D {
		return new Vector2D( this.x + v.x, this.y + v.y );
	}
	
	public inline function minus( v:Vector2D ):Vector2D {
		this.x -= v.x;
		this.y -= v.y;
		return this;
	}
	
	public inline function minusNew( v:Vector2D ):Vector2D {
		return new Vector2D( this.x - v.x, this.y - v.y );
	}
	
	public inline function mult( n:Float ):Vector2D {
		this.x *= n;
		this.y *= n;
		return this;
	}
	
	public inline function multNew( n:Float ):Vector2D {
		return new Vector2D( this.x * n, this.y * n );
	}
	
	public inline function div( n:Float ):Vector2D {
		this.x /= n;
		this.y /= n;
		return this;
	}
	
	public inline function divNew( n:Float ):Vector2D {
		return new Vector2D( this.x / n, this.y / n );
	}
	
	public inline function dot( v:Vector2D ):Float {
		return this.x*v.x + this.y*v.y;
	}
	
	public inline function cross( v:Vector2D ):Float {
		return this.x*v.y - this.y*v.x;
	}
	
	public inline function normalize():Vector2D {
		var l:Float = this.getLength();
		if ( l != 0 )
			return this.div( l );
		else
			return ZERO;
	}
	
	public inline function getNormal():Vector2D {
		var l:Float = this.getLength();
		if ( l != 0 )
			return this.divNew( l );
		else
			return ZERO;
	}
	
	public inline function getAngle():Float {
		var a:Float = radToDeg(Math.atan2(y, x));
		if ( a < 0 )
			a += 360;
			return a;
	}
	
	public inline function getNegative():Vector2D {
		return new Vector2D( -this.x, -this.y );
	}
	
	public inline function negative():Void {
		this.x = - this.x;
		this.y = - this.y;
	}
	
	public inline function distance( v:Vector2D ):Float {
		var dx:Float = this.x - v.x;
		var dy:Float = this.y - v.y;
		return Math.sqrt( dx*dx + dy*dy );
	}
	
	public inline function getLength():Float {
		return Math.sqrt( this.x*this.x + this.y*this.y );
	}
	
	public function rotate(angle:Float) {
		var sin = Math.sin(angle);
		var cos = Math.cos(angle);
		var newX = x * cos - y * sin;
		var newY = x * sin + y * cos;
		this.x = newX;
		this.y = newY;
	}
	
	public function toString():String {
		return "("+x+", "+y+")";
	}
	
	/**
	* Converts specified angle in radians to degrees.
	* @return angle in degrees (not normalized to 0...360)
	*/
	public inline static function radToDeg(rad:Float):Float
	{
		return 180 / Math.PI * rad;
	}
	/**
	* Converts specified angle in degrees to radians.
	* @return angle in radians (not normalized to 0...Math.PI*2)
	*/
	public inline static function degToRad(deg:Float):Float
	{
		return Math.PI / 180 * deg;
	}
}