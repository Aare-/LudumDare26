package com.subfty.sub.helpers;

import nme.display.DisplayObject;
import nme.display.Sprite; 
import nme.events.Event;
import nme.Lib;
 
/**
 * @author Camden Reslink
 */
 
class FixedAspectRatio {
	private var intendedWidth:Float;
	private var intendedHeight:Float;
	private var intendedAspectRatio:Float;
	private var screenAspectRatio:Float;
	private var sprite:Sprite;
	
	public var scaleFactor:Float;
	public var offsetX:Float;
	public var offsetY:Float;
	
	private var boundingBars:Sprite;
	
	public function new ( stage:Sprite, intendedWidth:Float, intendedHeight:Float ) {
		this.sprite = stage;
		this.intendedWidth = intendedWidth;
		this.intendedHeight = intendedHeight;
		
		Lib.current.stage.addEventListener(Event.RESIZE, this.fix);
	}
	
	public function fix( e:Event ):Void {
		screenAspectRatio = (sprite.stage.stageWidth / sprite.stage.stageHeight);
		intendedAspectRatio = intendedWidth/intendedHeight;
		if ( screenAspectRatio > intendedAspectRatio ) {
			var scaleInfoArray:Array<Float> = screenIsWider();
			scaleFactor = scaleInfoArray[0];
			offsetX = scaleInfoArray[1];
			offsetY = scaleInfoArray[2];
		} else {
			var scaleInfoArray:Array<Float> = screenIsNarrower();
			scaleFactor = scaleInfoArray[0];
			offsetX = scaleInfoArray[1];
			offsetY = scaleInfoArray[2];
		}
		
		sprite.scaleX = sprite.scaleY = scaleFactor;
	}
	
	private function screenIsWider():Array<Float> {
		var maskHeight:Float = sprite.stage.stageHeight;
		var maskWidth:Float = maskHeight * intendedAspectRatio;
		var maskX:Float = (sprite.stage.stageWidth - maskWidth) * 0.5;
		var maskY:Float = 0;
		
		//if(boundingBars == null){
			//boundingBars = new Sprite();
			//Lib.stage.addChild(boundingBars);
		//}
		//boundingBars.graphics.clear();
		//boundingBars.graphics.beginFill(0x000000);
		//boundingBars.graphics.drawRect(0, 0, maskX, maskHeight);
		//boundingBars.graphics.drawRect(maskX + maskWidth, 0, maskX, maskHeight);
		//Lib.stage.addChild(boundingBars);
		var newScale:Float = sprite.stage.stageHeight / intendedHeight;
		sprite.x = maskX;
		sprite.y = maskY;
		return [newScale, maskX, maskY];
	}
	
	private function screenIsNarrower():Array<Float> {
		var maskWidth:Float = sprite.stage.stageWidth;
		var maskHeight:Float = maskWidth * ( 1 / intendedAspectRatio );
		var maskX:Float = 0;
		var maskY:Float = (sprite.stage.stageHeight - maskHeight) * 0.5;
		
		//if(boundingBars == null){
			//boundingBars = new Sprite();
			//Lib.stage.addChild(boundingBars);
		//}
		//boundingBars.graphics.clear();
		//boundingBars.graphics.beginFill(0x000000);
		//boundingBars.graphics.drawRect(0, 0, maskX, maskHeight);
		//boundingBars.graphics.drawRect(maskX + maskWidth, 0, maskX, maskHeight);
		//Lib.stage.addChild(boundingBars);
		
		var newScale:Float = sprite.stage.stageWidth / intendedWidth;
		sprite.y = maskY;
		sprite.x = maskX;
		return [newScale, maskX, maskY];
	}	
}