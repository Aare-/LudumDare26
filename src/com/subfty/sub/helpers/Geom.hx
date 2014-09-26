package com.subfty.sub.helpers;
import nme.geom.Matrix;
import nme.geom.Point;

/**
 * ...
 * @author Filip Loster
 */

class Geom implements Singleton{

	public static function multiplyPointByMatrix(m:Matrix, p:Point):Point {
		p.x = (m.a * p.x + m.c * p.y + m.tx);
		p.y = (m.b * p.x + m.d * p.y + m.ty);
		return p;
	}
	
}