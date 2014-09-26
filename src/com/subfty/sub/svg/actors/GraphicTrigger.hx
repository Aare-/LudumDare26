package com.subfty.sub.svg.actors;

import com.subfty.sub.helpers.Geom;
import com.subfty.sub.helpers.Statics;
import com.subfty.sub.svg.actors.Trigger;
import com.subfty.sub.svg.SVGParser;
import nme.display.Sprite;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Transform;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

/**
 * ...
 * @author Filip Loster
 */

class GraphicTrigger extends Trigger{
	
	var color:Int;
	
	public function new(xml:Xml) {
		super(xml);
		
		if(xml.get("label") != null){
			var textF:TextField = new TextField();
			textF.text = xml.get("label");
			
			textF.x = 0;// this.x;
			textF.y = this.h * 0.20;// this.y;
			textF.width = this.w;
			textF.height = this.h;
			
			var tForm = new TextFormat(null, this.h * 0.5, 0x000000);
			tForm.align = TextFormatAlign.CENTER;
			
			textF.setTextFormat(tForm);
			
			textF.mouseEnabled = false;
			textF.selectable = false;
			
			this.addChild(textF);
		}
		
		color = SVGParser.getColor(xml);
		
		updateVisuals();
	}
	
	public function updateVisuals() {
		graphics.clear();
		graphics.beginFill(color, 1);
		graphics.drawRect(0, 0, w, h);
	}
}