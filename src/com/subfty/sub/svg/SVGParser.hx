package com.subfty.sub.svg;

import com.subfty.minimalism.Main;
import com.subfty.minimalism.screens.actors.Level;
import com.subfty.sub.helpers.Geom;
import com.subfty.sub.helpers.Statics;
import com.subfty.sub.svg.actors.Trigger;
import nme.Assets;
import nme.display.Shape;
import nme.display.Sprite;
import nme.geom.Matrix;

//TODO: import all not mentioned anywhere classes here to make them compile!
import com.subfty.sub.svg.actors.GraphicTrigger;
import com.subfty.sub.svg.actors.Box;

/**
 * @author Filip Loster
 */

#if haxe3
import haxe.ds.StringMap;
#else
typedef StringMap<T> = Hash<T>;
#end

class SVGParser implements Singleton{

	static var aliases:Hash<String>;
	
	private static var mTranslateMatch = ~/translate\((.*)[, ](.*)\)/;
	private static var mScaleMatch = ~/scale\((.*)\)/;
	private static var mMatrixMatch = ~/matrix\((.*)[, ](.*)[, ](.*)[, ](.*)[, ](.*)[, ](.*)\)/;
	private static var mURLMatch = ~/url\(#(.*)\)/;
	
	public static function parse(file:String, root:Sprite) {
		if (aliases == null)
			loadAliases();
		
		var inXML:Xml = Xml.parse(Assets.getText(file));
		
		var svg = inXML.firstElement();
		
		if (svg == null || (svg.nodeName != "svg" && svg.nodeName != "svg:svg"))
			throw "Not an SVG file (" + (svg == null ? "null" : svg.nodeName) + ")";
			
		loadGroup(root, svg);
		
	  //CLEARING STUFF
		Trigger.clearActionHash();
	}
	
	public static function loadGroup (g:Sprite, inG:Xml):Sprite {
		
		for (el in inG.elements ()) {
			var name = el.nodeName;
			var classPatch:String = el.get("class");
			
			if (name.substr (0, 4) == "svg:") 
				name = name.substr(4);
				
			if (name == "g") {
				if (el.get("level") != null) {
				  //LOADING LEVEL
					Level.parseLevel(el);
				}else {
				  //LOADING GROUP
					var s:Sprite = new Sprite();
					s.name = el.get("id");
					g.addChild(s);
					
					applyTransformToPoint(el, cast(s));
					
					loadGroup(s, el);
				}
			} else if (classPatch != null) {
			  //CREATING NEW OBJECT IF ASSOCIATED WITH THIS RECTANGLE
				if (aliases.exists(classPatch))
					classPatch = aliases.get(classPatch);
				var obj:Dynamic = Type.createInstance(Type.resolveClass(classPatch), [el]);
				obj.name = el.get("id");
				g.addChild(obj);				
			} else if (name == "flowRoot") {
				/*trace("parsing text: ");
				var textValue:String = "";
				var t_x:Float = 0;
				var t_y:Float = 0;
				var t_w:Float = 0;
				var t_h:Float = 0;
				var translateM:Matrix = getTransformMatrix(el);
				
				for (child in el){
					trace("    nodeName: " + child.nodeName);
					if (child.nodeName == "svg:flowPara") {
						trace("    flowPara: " + child.firstChild().toString());
					}else if (child.nodeName == "svg:flowRegion") {
						var rect:Xml = child.firstChild();
						
						
						trace("    rect x: " + rect.get("x") + " y: " + rect.get("y") +
							  " width: "+rect.get("width")+" height: " +rect.get("height"));
					}
				}*/
				
			}else {
				
			}
		}
		
		return g;
	}
	
  //WORKERS
	private static function getFloat (inXML:Xml, inName:String, inDef:Float = 0.0):Float {
		if (inXML.exists (inName))
			return Std.parseFloat (inXML.get (inName));
			
		return inDef;
	}

	public static function getTransformMatrix(xml:Xml):Matrix {
		if(xml.exists("transform")){
			var m:Matrix = new Matrix(0, 0, 0, 0, 0, 0);
			m.identity();
			applyTransform(m, xml.get("transform"));
			return m;
		}
		return null;
	}
	public static function applyTransform (ioMatrix:Matrix, inTrans:String):Float {
		var scale = 1.0;
		
		if (mTranslateMatch.match(inTrans)){
			// TODO: Pre-translate
			
			ioMatrix.translate (Std.parseFloat (mTranslateMatch.matched (1)), Std.parseFloat (mTranslateMatch.matched (2)));
			
		} else if (mScaleMatch.match (inTrans)) {
			
			// TODO: Pre-scale
			var str:Array<String> = mScaleMatch.matched(1).split(",");
			ioMatrix.scale (Std.parseFloat (str[0]), 
							Std.parseFloat (str[1]));
			scale = Std.parseFloat (str[0]);
			
		} else if (mMatrixMatch.match (inTrans)) {
			
			var m = new Matrix (
				Std.parseFloat (mMatrixMatch.matched (1)),
				Std.parseFloat (mMatrixMatch.matched (2)),
				Std.parseFloat (mMatrixMatch.matched (3)),
				Std.parseFloat (mMatrixMatch.matched (4)),
				Std.parseFloat (mMatrixMatch.matched (5)),
				Std.parseFloat (mMatrixMatch.matched (6))
			);
			
			m.concat (ioMatrix);
			
			ioMatrix.a = m.a;
			ioMatrix.b = m.b;
			ioMatrix.c = m.c;
			ioMatrix.d = m.d;
			ioMatrix.tx = m.tx;
			ioMatrix.ty = m.ty;
			
			scale = Math.sqrt (ioMatrix.a * ioMatrix.a + ioMatrix.c * ioMatrix.c);
			
		} else
			trace("Warning, unknown transform:" + inTrans);
			
		return scale;
	}

  //UTILS
	/**
	 * List of additional parameters:
		 * fillScreen: true, width, height
		 * stickToBorderY: top, bottom
		 * stickToBorderX: left, right
	 */
	public static function applyTransformToRect(xml:Xml, rect: { x:Float, y:Float, w:Float, h:Float }):Matrix {
		var m:Matrix = applyTransformToPoint(xml, cast(rect));
		
		rect.w = Std.parseFloat(xml.get("width"));
		rect.h = Std.parseFloat(xml.get("height"));
		
		if (m != null) {
			/*Statics.p1.x = Std.parseFloat(xml.get("width")) + Std.parseFloat(xml.get("x"));
			Statics.p1.y = Std.parseFloat(xml.get("height")) + Std.parseFloat(xml.get("y"));
			
			Geom.multiplyPointByMatrix(m, Statics.p1);*/
			
			rect.w = (rect.w ) * m.a + (rect.w ) * m.b;
			rect.h = (rect.h ) * m.d + (rect.h ) * m.c;
		}
		
	  //PARSING TAG FILL SCREEN
		if (xml.exists("fillScreen")) {
			var fs:String = xml.get("fillScreen");
			if(fs == "true") {
				rect.x = -(Main.SCREEN_W - Main.STAGE_W) / 2;
				rect.y = -(Main.SCREEN_H - Main.STAGE_H) / 2;
				rect.w = Main.SCREEN_W;
				rect.h = Main.SCREEN_H;
			}else if (fs == "width") {
				rect.x = -(Main.SCREEN_W - Main.STAGE_W) / 2;
				rect.w = Main.SCREEN_W;
			}else if (fs == "height") {
				rect.y = -(Main.SCREEN_H - Main.STAGE_H) / 2;
				rect.h = Main.SCREEN_H;
			}else
				trace("corrupted fillScreen value");
		}
		
	  //PARSING TAG STICK TO BORDER Y
		if (xml.exists("stickToBorderY")) {
			var fs:String = xml.get("stickToBorderY");
			if (fs == "top") {
				rect.y = Main.STAGE_H + (Main.SCREEN_H - Main.STAGE_H) / 2 - rect.h;
			}else if (fs == "bottom") {
				rect.y = -(Main.SCREEN_H - Main.STAGE_H) / 2;
			}else
				trace("corrupted stickToBorderY value");
		}
		
	  //PARSING TAG STICK TO BORDER X
		if (xml.exists("stickToBorderX")) {
			var fs:String = xml.get("stickToBorderX");
			if (fs == "left") {
				rect.x = -(Main.SCREEN_W - Main.STAGE_W) / 2;
			}else if (fs == "right") {
				rect.x = Main.STAGE_W + (Main.SCREEN_W - Main.STAGE_W) / 2 - rect.w;
			}else
				trace("corrupted stickToBorderX value");
		}
		
		return m;
	}
	public static function applyTransformToPoint(xml:Xml, point: { x:Float, y:Float } ):Matrix {
		if(!xml.exists("x") || !xml.exists("y")) return null;
		
		var m:Matrix = SVGParser.getTransformMatrix(xml);
		
		point.x =  Std.parseFloat(xml.get("x"));
		point.y = Std.parseFloat(xml.get("y"));
		
		if (m != null) {
			Statics.p1.x = point.x;
			Statics.p1.y = point.y;
			Geom.multiplyPointByMatrix(m, Statics.p1);
			
			point.x = Statics.p1.x;
			point.y = Statics.p1.y;
		}
		return m;
	}
	public static function getColor(xml:Xml):Int {
		return Std.parseInt("0x"+getParam(xml, "style", "fill:#"));
	}
	public static function getAlpha(xml:Xml):Float {
		return Std.parseFloat(getParam(xml, "style", "fill-opacity:"));
	}
	
	private static function getParam(xml:Xml, att:String, tag:String):String {
		if (xml.exists(att)) {
			var attval:String = xml.get(att);
			var from:Int = attval.indexOf(tag) + tag.length;
			var to:Int = attval.indexOf(";", from);
			return attval.substr(from, to - from);
		}
		return "";
	}
	
	static function loadAliases() {
		aliases = new Hash<String>();
		
		var xml:Xml = Xml.parse(Assets.getText("data/aliases.xml")).firstChild();
		for (el in xml.elements ()) 
			aliases.set(el.get("id"), el.get("value"));
	}
}