package com.subfty.sub.data;
import haxe.xml.Fast;
import nme.filesystem.File;
import nme.filesystem.StorageVolume;
import nme.filesystem.StorageVolumeInfo;
import nme.JNI;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

/**
 * Reads game configuration file
 * @author Filip Loster
 */
class Config implements Singleton {
	public static var f;
	
	public static function loadXmlData() {	
		var data = nme.Assets.getText("data/config.xml");
		
		data = data.substr(data.indexOf("<game"));
		
		f = new Fast(haxe.xml.Parser.parse(data)
									 .firstChild());
	}
	
	public static function getColor(x:Xml):Int {
		return parseColor(Std.parseInt(x.get("r")), 
						  Std.parseInt(x.get("g")), 
						  Std.parseInt(x.get("b")));
	}
	public static function formatTextField(textF:TextField, x:Xml):TextField{
		var font:String = x.get("font");// if (font == null) font = Art.F_GAME_SCORE;
		var size:Float = (x.get("size") == null ) ? 30 : Std.parseFloat(x.get("size"));
		var color:Int = getColor(x);
		var align:String = x.get("align"); if (align == null) align = "left"; else align = align.toLowerCase();
		
		var textFormat = new TextFormat(font, size, color);
		textF.width = (x.get("width") == null ) ? 100 : Std.parseFloat(x.get("width"));
		
		if (align == "left") textFormat.align = TextFormatAlign.LEFT;
		if (align == "right") textFormat.align = TextFormatAlign.RIGHT;
		if (align == "center") textFormat.align = TextFormatAlign.CENTER;
		if (align == "justify") textFormat.align = TextFormatAlign.JUSTIFY;
		
		textF.defaultTextFormat = textFormat;
		textF.x = Std.parseFloat(x.get("x"));
		textF.y = Std.parseFloat(x.get("y"));
		
		textF.mouseEnabled = false;
		textF.selectable = false;
		
		return textF;
	}
	public static function parseColor(r:Int, g:Int, b:Int):Int {
		return (r << 16) + (g << 8) + b;
	}
}