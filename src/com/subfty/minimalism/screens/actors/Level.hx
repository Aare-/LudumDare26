package com.subfty.minimalism.screens.actors;
import com.subfty.minimalism.Main;
import com.subfty.sub.display.Screen;
import com.subfty.sub.helpers.FixedAspectRatio;
import com.subfty.sub.helpers.Geom;
import com.subfty.sub.helpers.Statics;
import com.subfty.sub.svg.SVGParser;
import nape.callbacks.CbType;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nme.display.Shape;
import nme.display.Sprite;
import nme.geom.Matrix;

/**
 * ...
 * @author Filip Loster
 */

class Level extends Sprite{

	static var levels:Array<Array<LevelBlock>>;
	var activeLevel:Int;
	
	public function new() {
		super();
		levels = new Array<Array<LevelBlock>>();
	}
	
	public function init(levelId:Int) {
		activeLevel = levelId;
		for (block in levels[activeLevel]){
			this.addChild(block);
			block.b.space = Main.space;
		}
	}
	
	public function kill() {
		for (i in 0...this.numChildren)
			this.removeChildAt(0);
		for (block in levels[activeLevel])
			block.b.space = null;
	}
	
	public static function parseLevel(group:Xml) {
		
		var level:Array<LevelBlock> = new Array<LevelBlock>();
		for (el in group.elements()){
			if (el.nodeName.substr(0, 8) == "svg:rect") {
				level.push(new LevelBlock(el));
			}
		}
		
		levels.push(level);
	}
}

class LevelBlock extends Sprite, implements Updatable{
	public var b:Body;
	
	public var w:Float;
	public var h:Float;
	
	public function new(el:Xml) {
		super();
		
		var m:Matrix = SVGParser.applyTransformToRect(el , cast(this));
		
	  //INITING PSYCHIC
		b = new Body(BodyType.STATIC);
		var sensor:Polygon = new Polygon(Polygon.rect( 0, 0, w, h));
		sensor.cbTypes.add(Game.LAYOUT_BOX);
		sensor.userData.owner = this;
		sensor.userData.block = this;
		b.shapes.add(sensor);

		b.position.setxy(x, y);	
		
	  //INITING GRAPHICS
		this.graphics.clear();
		this.graphics.beginFill(SVGParser.getColor(el), 1);
		this.graphics.drawRect( 0, 0, w, h);
		
	  //REGISTERING CALLBACKS
		
		this.x = b.position.x;
		this.y = b.position.y;
		
		b.rotate(b.localPointToWorld(Vec2.weak(w/2, h/2)), Player.degToRad(rotation));
		this.rotation = Player.radToDeg(b.rotation);
		
		this.x = b.position.x;
		this.y = b.position.y;
	}
	
	public function update() {
		
		//.rotation += 
		/*b.space = null;
		
		b.rotate(b.localPointToWorld(Vec2.weak(w/2, h/2)), Player.degToRad(2));
		this.rotation = Player.radToDeg(b.rotation);
		
		this.x = b.position.x;
		this.y = b.position.y;
		b.space = Main.space;*/
	}
}