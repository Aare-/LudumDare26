package com.subfty.minimalism.screens;

import com.subfty.sub.display.Screen;
import com.eclecticdesignstudio.motion.Actuate;
import com.subfty.minimalism.Main;
import com.subfty.sub.data.Config;
import com.subfty.sub.display.Screen;
import com.subfty.sub.svg.SVGParser;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.ui.Keyboard;

/**
 * ...
 * @author Filip Loster
 */

class Intro extends Screen{
	var textF:TextField;
	
	public function new(parent:Sprite, name:String) {
		super(parent, name);
		textF = new TextField();
		textF.selectable = false;
		textF.multiline = true;
		textF.defaultTextFormat = new TextFormat("_sans", 30, 0xecf0f1, true);
		textF.defaultTextFormat.align = TextFormatAlign.CENTER;
		textF.x = 80;
		textF.y = 130;
		textF.width = Main.STAGE_W;
		textF.height = Main.STAGE_H;
		textF.text = "#LD48 'MINIMALISM'\nMINICAVE\n@FilipLoster\n";
		
		this.addChild(textF);
	}
	
	override public function load() {
		super.load();
		
		textF.alpha = 0;
		Actuate.tween(textF, 1, { alpha: 1 }, false )
			   .delay(1);
		Actuate.tween(textF, 1, { alpha: 0 }, false )
			   .delay(4)
			   .onComplete(function() {
				   Main.screen = Main.game;
			   });
	}
}