package com.subfty.sub.display.sprites;

import aze.display.TileGroup;
import aze.display.TileLayer;
import aze.display.TileSprite;
import haxe.Stack;
import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Loader;
import nme.display.Sprite;
import nme.feedback.Haptic;
import nme.Lib;
import nme.events.Event;
import nme.Memory;

/**
 * Just in case some additional custom functions needed
 * @author Filip Loster
 */

class ImgSprite extends TileSprite{
	
	public var width (default, _setWidth):Float;
	public var height(default, _setHeight):Float;
	
	public var scaleX(default, _setScaleX):Float;
	public var scaleY(default, _setScaleY):Float;
	
	public function new(tile:String, group:TileGroup) {
		super(tile);	
		
		oScaleX = 0;
		oScaleY = 0;
		
		group.addChild(this);
		
		scaleX = 1;
		scaleY = 1;
		
		width = 0;
		height = 0;
	}
	
  //SETTING SIZE/SCALE
	function _setWidth(val:Float):Float {
		width = val;
		_reloadSize();
		
		return val;
	}
	
	function _setHeight(val:Float):Float {
		height = val;
		_reloadSize();
		
		return val;
	}
	
	function _setScaleX(val:Float):Float {
		scaleX = val;
		_reloadSize();
		
		return val;
	}
	
	function _setScaleY(val:Float):Float {
		scaleY = val;
		_reloadSize();
		
		return val;
	}
	
	function _reloadSize() {
		if (size != null) {
			oScaleX = width / size.width * scaleX;
			oScaleY = height / size.height * scaleY;
		}
	}
	
	function setSize(w:Float, h:Float) {
		width = w;
		height = h;
	}
	
	function setScale(scale:Float) {
		scaleX = scale;
		scaleY = scale;
	}
	
	function setPosition(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}