package com.subfty.minimalism.screens.actors;
import browser.display.SpreadMethod;
import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.subfty.minimalism.Main;
import com.subfty.minimalism.screens.Game;
import com.subfty.sub.data.Config;
import com.subfty.sub.display.Screen;
import com.subfty.sub.display.Screen.Updatable;
import com.subfty.sub.helpers.Statics;
import com.subfty.sub.svg.SVGParser;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nme.Assets;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.geom.Matrix;
import nme.media.Sound;

/**
 * ...
 * @author Filip Loster
 */

class Enemy extends Sprite, implements Updatable{
  //ENEMY TYPES
	public static var ENEMY_TYPES:Int = 2;
  
	public static inline var WALKER:Int = 0;
	public static inline var FLOATER:Int = 1;
	
  //ENEMY VALUE
	var life:Int;
	
  //PSYCHIC
	var body:Body;
	
  //SOUND
	var jumpS:Sound;
	var hittedS:Sound;
	
	public function new() {
		super();
		
	  //INITING PSYCHIC
		body = new Body(BodyType.DYNAMIC);
	}
	
	public function spawn(x:Float, y:Float) {
		this.visible = true;
		
		body.rotation = 0;
		body.position.x = x;
		body.position.y = y;
		body.velocity.setxy(0, 0);
		body.angularVel = 0;
		
		jumpS = Assets.getSound ("sounds/eDeath.wav");
		hittedS = Assets.getSound ("sounds/eHitted.wav");
	}
	
	public function kill() {
		
		this.visible = false;
	}
	
	public function hit(value) {
		life -= value;
		
		if (life < 0) {
			jumpS.play();
			kill();
		}else {
			hittedS.play();
			this.alpha = 0.6;
			Actuate.tween(this, 0.75, { alpha: 1 } );
		}
			
		Main.game.score += value * 2;
	}
	
	public function update() {
		if(visible){
			this.x = body.position.x;
			this.y = body.position.y;
			this.rotation = Player.radToDeg(body.rotation);
		}else
			body.space = null;
	}
}

//ENEMY TYPES
class EFrogger extends Enemy {
  //CONFIG
	var JUMP_MIN_DEL:Int;
	var JUMP_MAX_DEL:Int;
	var JUMP_FORCE:Float;
	var ANGLE_DIR_RAND:Float;
	
	var jumpDel:Int;
	
	var directionR:Bool;
	var w:Float;
	var h:Float;
	
	public function new() {
		w = Std.parseFloat(Config.f.node.enemies.node.walker.att.width);
		h = Std.parseFloat(Config.f.node.enemies.node.walker.att.height);
		super();
		
		JUMP_MIN_DEL = Std.parseInt(Config.f.node.enemies.node.walker.att.jumpMinDel );
		JUMP_MAX_DEL = Std.parseInt(Config.f.node.enemies.node.walker.att.jumpMaxDel );
		JUMP_FORCE = Std.parseFloat(Config.f.node.enemies.node.walker.att.jumpForce );
		ANGLE_DIR_RAND = Std.parseFloat(Config.f.node.enemies.node.walker.att.angleDirRand);
		
	  //INITING PSYCHIC
		var sensor:Polygon = new Polygon(Polygon.rect(-w/2, -h/2, w, h));
		sensor.cbTypes.add(Game.ENEMY);
		sensor.filter.collisionGroup = 8;
		sensor.userData.enemy = this;
		body.shapes.add(sensor);
		
	  //INITING GRAPHICS
		graphics.clear();
		graphics.beginFill(0xf1c40f, 1);
		graphics.drawRect(-w/2, -h/2, w, h);
		graphics.endFill();
	}
	
	override public function spawn(x:Float, y:Float) {
		y -= h/2;
		super.spawn(x, y);
		life = Std.parseInt(Config.f.node.enemies.node.walker.att.life);
		directionR = Random.bool();
		
		randNextJumpDel();

		body.space = null;
		Actuate.stop(this);
		this.alpha = 0;
		Actuate.tween(this, 3, { alpha: 1 } )
			   .ease(Sine.easeOut)
			   .onComplete(function() {
					body.space = Main.space; 
					body.velocity.setxy(0, 0);
					body.angularVel = 0;
			   });
	}
	
	override public function update() {
		super.update();
		
		if(this.visible){
			jumpDel -= Main.delta;
			if (jumpDel < 0) {
				jump();
				randNextJumpDel();
			}
		}
	}
	
	function jump() {
		Statics.v1.setxy(0, -JUMP_FORCE);
		Statics.v1.rotate(Player.degToRad(Random.float( -1, 1) * ANGLE_DIR_RAND));
		body.velocity.setxy(body.velocity.x + Statics.v1.x, 
							body.velocity.y + Statics.v1.y);
	}
	
	function randNextJumpDel() {
		jumpDel = Math.round(Random.float(0, 1) * (JUMP_MAX_DEL - JUMP_MIN_DEL) + JUMP_MIN_DEL);
	}
}
class EFloater extends Enemy {
  //CONFIG
	var MOV_SPEED:Int;
	var MOV_FORCE:Float;
	
	var w:Float;
	var h:Float;
	
	var target_x:Float;
	var target_y:Float;
	var movSpeedCall:Int;
	
	var movRect:Rectangle;
	
	public function new(movRect:Rectangle) {
		w = Std.parseFloat(Config.f.node.enemies.node.floater.att.width);
		h = Std.parseFloat(Config.f.node.enemies.node.floater.att.height);
		MOV_SPEED = Std.parseInt(Config.f.node.enemies.node.floater.att.speed);
		MOV_FORCE = Std.parseFloat(Config.f.node.enemies.node.floater.att.movForce);
		
		this.movRect = movRect;
		
		super();
		
	  //INITING PSYCHIC
		//body.gravMassScale = 0;
		var sensor:Polygon = new Polygon(Polygon.rect(-w/2, -h/2, w, h));
		sensor.cbTypes.add(Game.ENEMY);
		//sensor.filter.collisionGroup = 2;
		body.shapes.add(sensor);
		
	  //INITING GRAPHICS
		graphics.clear();
		graphics.beginFill(0x00FF00, 1);
		graphics.drawRect(-w/2, -h/2, w, h);
		graphics.endFill();
	}
	
	override public function update() {
		super.update();
		
		if (movSpeedCall < 0) 
			moveToNext();
		else 
			movSpeedCall -= Main.delta;
		
		Statics.v1.setxy((body.position.x - target_x), 
						 body.position.y - target_y);
		Statics.v1.normalise();
		body.velocity.setxy(Statics.v1.x * MOV_FORCE, 
							Statics.v1.y * MOV_FORCE);
		
	}
	
	function moveToNext() {
		target_x = movRect.x + movRect.width * Random.float(0, 1);
		target_y = movRect.y - movRect.height * Random.float(0, 1);
		movSpeedCall = MOV_SPEED;
	}
	
	override public function spawn(x:Float, y:Float) {
		super.spawn(x, y);
		moveToNext();
	}
	
	override public function kill() {
		super.kill();
		Actuate.stop(this);
	}
}

class EnemyOverlord extends Sprite {
	
	var bestiary:Array<Array<Enemy>>;
	
	public function new() {
		super();
		
		bestiary = new Array<Array<Enemy>>();
		for (i in 0...Enemy.ENEMY_TYPES) 
			bestiary.push(new Array<Enemy>());
		
	}
	
	public function init() {
		for (best in bestiary)
			for (e in best)
				if (e.visible)
					e.kill();
	}
	
	public function spawn(x:Float, y:Float, type:Int=Enemy.WALKER, rect:Rectangle) {
		var enemy:Enemy = null;
		for (e in bestiary[type])
			if (!e.visible){
				enemy = e;
				break;
			}
		if (enemy == null) {
			switch(type) {
			case Enemy.FLOATER:
				enemy = new EFloater(rect);
			default:
				enemy = new EFrogger();
			}
			bestiary[type].push(enemy);
			Main.game.registerUpdatable(enemy);
			this.addChild(enemy);
		}
		
		enemy.spawn(x, y);
		return enemy;
	}
}

class Spawn extends Sprite, implements Updatable {
	public var relatedEnemy:Enemy;
	
	static var r1:Rectangle = new Rectangle();
	static var r2:Rectangle = new Rectangle();
	
	var w:Float;
	var h:Float;
	
	var onlyEnemy:Int = -1;
	
	public function new(el:Xml) {
		super();
		
		var m:Matrix = SVGParser.applyTransformToRect(el , cast(this));
		
		if (el.exists("only"))
			onlyEnemy = Std.parseInt(el.get("only"));
	}
	
	public function update() {
		if (relatedEnemy == null)
			populateWithEnemy(false);
		else if(!relatedEnemy.visible)
			populateWithEnemy();
	}
	
	function populateWithEnemy(testIntersection:Bool = true) {
		Statics.v1.setxy(Main.game.player.body.position.x - this.x, 
						 Main.game.player.body.position.y - this.y);
						 
		if (!testIntersection || Statics.v1.length > Math.max(w/2, h/2)) {
			var eType:Int = (onlyEnemy == -1) ? (Random.int(0, Enemy.ENEMY_TYPES - 1)) : (onlyEnemy);
			relatedEnemy = Main.game.enemies.spawn(this.x + this.w * Random.float(0, 1),
												   this.y + this.h * Random.float(0, 1),
												   eType,
												   r1);
		}
	}
}