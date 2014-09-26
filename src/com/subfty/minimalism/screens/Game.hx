package com.subfty.minimalism.screens;
import com.eclecticdesignstudio.motion.Actuate;
import com.subfty.minimalism.Main;
import com.subfty.minimalism.screens.actors.Enemy;
import com.subfty.minimalism.screens.actors.Enemy.EnemyOverlord;
import com.subfty.minimalism.screens.actors.Level;
import com.subfty.minimalism.screens.actors.Player;
import com.subfty.sub.data.Config;
import com.subfty.sub.display.Screen;
import com.subfty.sub.helpers.Statics;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.phys.Body;
import nape.shape.Shape;
import nme.display.Sprite;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;

/**
 * ...
 * @author Filip Loster
 */

class Game extends Screen {
  //CBTYPES
	public static var PLAYER:CbType;
	public static var LAYOUT_BOX:CbType;
	public static var CORNER:CbType;
	public static var ENEMY:CbType;
	public static var BULLET:CbType;
	
  //CONFIG
	var VMARGIN_LEFT:Float;
	var VMARGIN_RIGHT:Float;
	var VMARGIN_TOP:Float;
	var VMARGIN_BOTTOM:Float;
	var CAM_MOV_SPEED:Float;
	var PARAL_1_SPEED:Float;
	var PARAL_2_SPEED:Float;
	var PARAL_3_SPEED:Float;
	
	var camera:Sprite;
	var paralaxCam1:Sprite;
	var paralaxCam2:Sprite;
	var paralaxCam3:Sprite;
	
	public var score:Int;
	
  //ACTORS
	public var player:Player;
	public var level:Level;
	public var scoreT:TextField;
	
  //OVERLORDS
	public var bullets:BulletOverlord;
	public var enemies:EnemyOverlord;
	
	public function new(parent:Sprite, name:String) {
	  //INITING CBTYPES
		PLAYER = new CbType();
		LAYOUT_BOX = new CbType();
		CORNER = new CbType();
		ENEMY = new CbType();
		BULLET = new CbType();
		
	  //LOADING CONFIG
		CAM_MOV_SPEED = Std.parseFloat(Config.f.att.speed);
		VMARGIN_LEFT = Main.STAGE_W * Std.parseFloat(Config.f.att.margin_x) / 100.0;
		VMARGIN_RIGHT = Main.STAGE_W * (1.0 - Std.parseFloat(Config.f.att.margin_x) / 100.0);
		VMARGIN_TOP = Main.STAGE_H * (1.0 - Std.parseFloat(Config.f.att.margin_y) / 100.0);
		VMARGIN_BOTTOM = Main.STAGE_H * Std.parseFloat(Config.f.att.margin_y) / 100.0;
		PARAL_1_SPEED = Std.parseFloat(Config.f.att.paralaxCam1);
		PARAL_2_SPEED = Std.parseFloat(Config.f.att.paralaxCam2);
		PARAL_3_SPEED = Std.parseFloat(Config.f.att.paralaxCam2);
		
	  //INITIALISATION
		//PRESETUP
		level = new Level();
		bullets = new BulletOverlord();
		enemies = new EnemyOverlord();
		camera = new Sprite();
		paralaxCam1 = new Sprite();
		paralaxCam2 = new Sprite();
		paralaxCam3 = new Sprite();
		
		scoreT = new TextField();
		
		scoreT.x = -0;
		scoreT.y = -0;
		scoreT.width = Main.STAGE_W;
		scoreT.height = 50;
		
		scoreT.defaultTextFormat = new TextFormat("_sans", 1, 0xecf0f1, true);
		scoreT.scaleX = scoreT.scaleY = 15;
		scoreT.mouseEnabled = false;
		scoreT.selectable = false;
		
		super(parent, name);
		
		//POSTSETUP
		player = new Player(this);
		//ADDING SPAWNERS TO UPDATE LIST
		var spawners:Sprite = cast(this.getChildByName("spawners"));
		for (i in 0...spawners.numChildren)
			registerUpdatable(cast(spawners.getChildAt(i)));
		
	  //ADDING TO STAGE
		paralaxCam1.addChild(this.getChildByName("ParalaxCam1"));
		paralaxCam2.addChild(this.getChildByName("ParalaxCam2"));
		paralaxCam3.addChild(this.getChildByName("ParalaxCam3"));
	  
		camera.addChild(level);
		camera.addChild(enemies);
		camera.addChild(bullets);
		camera.addChild(this.getChildByName("levelAdditions"));
		camera.addChild(player);
		
		this.addChild(paralaxCam1);
		this.addChild(paralaxCam2);
		this.addChild(paralaxCam3);
		this.addChild(camera);
		this.addChild(scoreT);
		
	  //REGISTERING UPDATABLES
		registerUpdatable(player);
		
	  //REGISTERING LISTENERS
		Main.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
			PLAYER,
			CbType.ANY_SHAPE,
            preCollision
        ));
		Main.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
			PLAYER,
			ENEMY,
            playerEnemyColl
        ));
		Main.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
			BULLET,
			CbType.ANY_SHAPE,
            bulletHitt
        ));
		Main.space.listeners.add(new InteractionListener(
            CbEvent.END,
			InteractionType.COLLISION,
			PLAYER,
			LAYOUT_BOX,
            collisionEnds
        ));
		Main.space.listeners.add(new PreListener(
            InteractionType.COLLISION,
			CORNER,
			CbType.ANY_SHAPE,
            cornerColl
        ));
		Main.space.listeners.add(new InteractionListener(
			CbEvent.END,
			InteractionType.COLLISION,
			CORNER,
			CbType.ANY_SHAPE,
			cornerCollEnd
		));
	}
	
	override public function load() {
		super.load();
		
		score = 0;
		
		camera.x = camera.y = 0;
		
		player.init();
		for (g in player.guns)
			g.deactivate();
		level.init(0);
		enemies.init();
		var spawners:Sprite = cast(this.getChildByName("spawners"));
		for (i in 0...spawners.numChildren)
			cast(spawners.getChildAt(i), Spawn).relatedEnemy = null;
		
		Main.pausePsychic = 0;
		
		scoreT.alpha = 0;
		Actuate.tween(scoreT, 1, { alpha: 1 } )
			   .delay(2);
		
		for (i in 0...level.numChildren) {
			if(Math.abs(level.getChildAt(i).rotation) > 0.0001)
				registerUpdatable(cast(level.getChildAt(i)));
		}
	}
	
	override public function unload() {
		super.unload();
		
		player.kill();
		level.kill();
	}
	
	override public function step() {
		super.step();
		
		
		Statics.getPositionOnScreen(player);
		
		//SCROLLING SCREEN
		if (Statics.p1.x < VMARGIN_LEFT)
			camera.x += (VMARGIN_LEFT - Statics.p1.x) * CAM_MOV_SPEED * Main.delta;
		if (Statics.p1.x > VMARGIN_RIGHT)
			camera.x += (VMARGIN_RIGHT - Statics.p1.x) * CAM_MOV_SPEED * Main.delta;
			
		if (Statics.p1.y < VMARGIN_BOTTOM)
			camera.y += (VMARGIN_BOTTOM - Statics.p1.y) * CAM_MOV_SPEED * Main.delta;
		if (Statics.p1.y > VMARGIN_TOP)
			camera.y += (VMARGIN_TOP - Statics.p1.y) * CAM_MOV_SPEED * Main.delta;
			
		paralaxCam1.x = camera.x * PARAL_1_SPEED;
		paralaxCam1.y = camera.y * PARAL_1_SPEED;
		
		paralaxCam2.x = camera.x * PARAL_2_SPEED;
		paralaxCam2.y = camera.y * PARAL_2_SPEED;
		
		paralaxCam3.x = camera.x * PARAL_3_SPEED;
		paralaxCam3.y = camera.y * PARAL_3_SPEED;
		
		scoreT.text = "SCORE: "+score;
	}

  //LISTENER
	//PRE
	function bulletHitt(cb:PreCallback) {
		var partial:Shape = cast(cb.int1);
		var other:Shape = cast(cb.int2);
		
		var bullet:Bullet = null;
		
		if (partial.userData.bullet != null) {
			bullet = cast(partial.userData.bullet);
			if (other.userData.enemy != null) {
				
				var e:Enemy = cast(other.userData.enemy);
				
				e.hit(bullet.deathable);
				bullet.visible = false;
				if (bullet.B_TYPE == 1){
					return PreFlag.IGNORE;
				}else{
					return PreFlag.ACCEPT;
					
				}
			}
		}
		
		return PreFlag.ACCEPT;
	}
	function preCollision(cb:PreCallback) {
		var coll : {p:Player, b:LevelBlock} = confirmCollision(cb.int1, cb.int2);
		if (coll.p != null && coll.b != null) {
		  //CAN JUMP AGAIN
			coll.p.lastCollidedBlock = coll.b;
		}
		
		return PreFlag.ACCEPT;
	}
	function playerEnemyColl(cb:PreCallback) {
		player.kill();
		return PreFlag.ACCEPT;
	}
	function cornerColl(cb:PreCallback) {
		var partial:Shape = cast(cb.int1);
		var other:Shape = cast(cb.int2);
		
		if(other.userData.block != null){
		var gun:Gun = null;
		if (partial.userData != null && Std.is(partial.userData.gun, Gun)) 
			gun = cast(partial.userData.gun);
		if (other.userData != null && Std.is(other.userData.gun, Gun)) 
			gun = cast(other.userData.gun);
		
		if (gun != null) { 
			var anyOtherHitted:Bool = false;
			for (g in player.guns) {
				if (g.hitted){
					anyOtherHitted = true;
					break;
				}
			}
			gun.hitted = true;
			if(!anyOtherHitted){
				for (g in player.guns)
					g.deactivate();
				gun.activate();
			}
		}
		}
		
		return PreFlag.IGNORE;
	}
	//POST
	function collisionEnds(cb:InteractionCallback) {
		var coll : {p:Player, b:LevelBlock} = confirmCollision(cb.int1, cb.int2);
		if (coll.p != null && coll.b != null) {
			if (coll.p.lastCollidedBlock == coll.b)
				coll.p.lastCollidedBlock = null;
		}
	}
	function cornerCollEnd(cb:InteractionCallback) {
		var partial:Shape = cast(cb.int1);
		var other:Shape = cast(cb.int2);
		
		var gun:Gun = null;
		if (partial.userData != null && Std.is(partial.userData.gun, Gun)) 
			gun = cast(partial.userData.gun);
		if (other.userData != null && Std.is(other.userData.gun, Gun)) 
			gun = cast(other.userData.gun);
		
		if (gun != null)
			gun.hitted = false;
	}
	
	
	function confirmCollision(int1, int2):{p:Player, b:LevelBlock} {
		var partial:Shape = cast(int1);
		var other:Shape = cast(int2);
		
		var player:Player = null;
		var block:LevelBlock = null;
		
		if (Std.is(partial.userData.owner, Player))
			player = cast(partial.userData.owner);
		if (Std.is(other.userData.owner, Player))
			player = cast(other.userData.owner);
			
		if (Std.is(partial.userData.owner, LevelBlock))
			block = cast(partial.userData.owner);
		if (Std.is(other.userData.owner, LevelBlock))
			block = cast(other.userData.owner);
		
		return { p : player , b : block};
	}
}

//POINTS
class Point extends Sprite{

}

class PointOverlord extends Sprite{
	
}