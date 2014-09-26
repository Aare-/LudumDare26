package com.subfty.minimalism.screens;

import com.eclecticdesignstudio.motion.Actuate;
import com.subfty.minimalism.Main;
import com.subfty.sub.data.Config;
import com.subfty.sub.display.Screen;
import com.subfty.sub.svg.SVGParser;
import nme.Assets;
import nme.display.Sprite;
import nme.media.Sound;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.ui.Keyboard;

/**
 * ...
 * @author Filip Loster
 */

class Death extends Screen{
	
	var restart:Bool;
	var textF:TextField;
	var canRestart:Bool;
	
  //SOUNDS
	var newGame:Sound;
	
	public function new(parent:Sprite, name:String){
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
		
		this.addChild(textF);
		
		newGame = Assets.getSound ("sounds/newGame.wav");
	}
	
	override public function load() {
		super.load();
		restart = false;
		textF.text = "GAME OVER\nSCORE: " + Main.game.score + "\nPRESS SPACE TO PLAY AGAIN";
		textF.alpha = 0;
		canRestart = false;
		Actuate.tween(textF, 2, { alpha: 1 } )
			   .onComplete(function() {
				 canRestart = true;  
			   });
		if (Main.keyboard[Keyboard.SPACE])
			restart = false;
		else
			restart = true;
	}
	
	override public function step() {
		super.step();
		
		if (Main.keyboard[Keyboard.SPACE]) {
			if (restart && canRestart){
				canRestart = false;
				Actuate.tween(textF, 1, { alpha: 0 } )
					   .onComplete(function() {
						 newGame.play();
						 Main.screen = Main.game;
					   });
				
			}
		}else {
			restart = true;
		}
	}
}