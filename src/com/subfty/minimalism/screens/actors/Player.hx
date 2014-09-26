package com.subfty.minimalism.screens.actors;

import com.eclecticdesignstudio.motion.Actuate;
import com.eclecticdesignstudio.motion.easing.Bounce;
import com.eclecticdesignstudio.motion.easing.Elastic;
import com.eclecticdesignstudio.motion.easing.Sine;
import com.subfty.minimalism.screens.actors.Level.LevelBlock;
import com.subfty.minimalism.Main;
import com.subfty.sub.data.Config;
import com.subfty.sub.display.Screen;
import com.subfty.sub.helpers.Statics;
import com.subfty.sub.svg.SVGParser;
import nape.callbacks.CbType;
import nape.dynamics.InteractionFilter;
import nape.geom.Ray;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Circle;
import nape.shape.Polygon;
import nme.Assets;
import nme.display.Sprite;
import nme.media.Sound;
import nme.ui.Keyboard;
import nme.Vector;
import nme.Vector;

/**
 * ...
 * @author Filip Loster
 */

class Player extends Sprite, implements Updatable {
  //CONFIG
	var MOV_SPEED:Float;
	var JUMP_SPEED:Float;
	var ACC_SPEED:Float;
	var RADIUS:Float;
	var MAX_ANG_SPEED:Float;
	var ANG_IM_MOV:Float;
	
	public var body:Body;
	var jumped:Bool;
	public var disableGunsAfterBadJump:Bool;
	var dead:Bool;
	
	public var disableAllGuns:Int;
	
	var acc:Float;
	public var lastCollidedBlock:LevelBlock;
	
  //SOUNDS
	var jumpS:Sound;
	var deathS:Sound;
  
  //GUNS
	public var guns:Array<Gun>;
	
	var playerImg:Sprite;
	
	public function new(game:Screen) {
		super();
		
		MOV_SPEED = Std.parseFloat(Config.f.node.player.att.movSpeed);
		JUMP_SPEED = Std.parseFloat(Config.f.node.player.att.jumpSpeed);
		ACC_SPEED = Std.parseFloat(Config.f.node.player.att.accSpeed);
		RADIUS = Std.parseFloat(Config.f.node.player.att.radius);
		MAX_ANG_SPEED = Std.parseFloat(Config.f.node.player.att.max_ang_speed);
		ANG_IM_MOV = Std.parseFloat(Config.f.node.player.att.ang_mov);
		
	  //INITING GUNS
		guns = new Array<Gun>();
		var a = 210;
		for (i in 0...3) {
			var g:Gun = new Gun(game, i, guns, Math.cos(degToRad(30)) * RADIUS * 2);
			g.x = Math.cos(degToRad(120 * i + a )) * Math.sin(degToRad(30)) * RADIUS;
			g.y = Math.sin(degToRad(120 * i + a )) * Math.sin(degToRad(30)) * RADIUS;
			g.rotation = 120 * i + 120;
			guns.push(g);
		}
		
	  //DRAWING TRIANGLE
		playerImg = new Sprite();
		var verticesPos:Array<Array<Float>> = [[ -Math.cos(degToRad(30)) * RADIUS, Math.sin(degToRad(30)) * RADIUS], 
											   [0, -RADIUS], 
											   [Math.cos(degToRad(30)) * RADIUS, Math.sin(degToRad(30)) * RADIUS]];
		playerImg.graphics.clear();
		playerImg.graphics.beginFill(SVGParser.getColor(Config.f.node.player.x));
		playerImg.graphics.moveTo(verticesPos[0][0], verticesPos[0][1]);
		playerImg.graphics.lineTo (verticesPos[1][0], verticesPos[1][1]);
		playerImg.graphics.lineTo (verticesPos[2][0], verticesPos[2][1]);
		playerImg.graphics.endFill ();
		playerImg.scaleX = playerImg.scaleY = 20;
		
	  //ADDING TO STAGE
		for(g in guns)
			this.addChild(g);
		this.addChild(playerImg);
		
	  //INITING PSYCHICS
		body = new Body(BodyType.DYNAMIC, 
						Vec2.weak(Std.parseFloat(Config.f.node.player.att.init_x), 
						 		  Std.parseFloat(Config.f.node.player.att.init_y)));
		//MAIN BODY						  
		var sensor:Polygon = new Polygon(Polygon.regular(RADIUS, RADIUS, 3));
		sensor.cbTypes.add(Game.PLAYER);
		sensor.userData.owner = this;
		sensor.filter.collisionGroup = 2;
		body.shapes.add(sensor);
		body.rotation = degToRad(-30);
		
		//CORNER SENSORS
		for (i in 0...3) {
			var X:Float = verticesPos[i][0] - 5;
			var Y:Float = verticesPos[i][1] - 5;
			
			if (i == 0) {
				X += 7;
				Y += 7;
			}else if (i == 1) {
				X -= 10;
				Y += 4;
			}else {
				X += 4;
				Y -= 10;
			}
			
			var corner:Polygon = new Polygon(Polygon.rect( X, 
														   Y, 
														   10, 10));
			corner.cbTypes.add(Game.CORNER);
			corner.userData.gun = guns[(i + 1) % 3];
			body.shapes.add(corner);
		}
	
	  //LOADING SOUNDS
		jumpS = Assets.getSound ("sounds/jump.wav");
		deathS  = Assets.getSound ("sounds/death.wav");
	}
	
	public function init() {
		body.position.setxy(Std.parseFloat(Config.f.node.player.att.init_x), 
						    Std.parseFloat(Config.f.node.player.att.init_y));
		body.velocity.setxy(0, 0);
		body.angularVel = 0;
		
		dead = false;
		body.rotation = degToRad(-30);
		body.space = Main.space;
		lastCollidedBlock = null;
		disableGunsAfterBadJump = false;
		for (g in guns){
			g.fireable = false;
			g.visible = false;
		}
			
		playerImg.scaleX = playerImg.scaleY = 60;
		Actuate.tween(playerImg, 1, { scaleX: 1, scaleY: 1 } );
		Actuate.timer(0.5)
			   .onComplete(function() {
					Actuate.tween(Main, 1, { pausePsychic: 1 } );
				});
	}
	
	public function kill() {
		if (dead) return;
		dead = true;
		
		deathS.play();
		
		Actuate.tween(Main.game.scoreT, 1, { alpha: 0 } );
		Actuate.tween(playerImg, 1, { scaleX: 60, scaleY: 60 } )
				.delay(1.5)
				.onComplete(function() {
					Main.screen = Main.death;
				})
				.ease(Sine.easeOut);
		Actuate.timer(0)
			   .onComplete(function() {
					Actuate.tween(Main, 1, { pausePsychic: 0 });
				});
	}
	
	public function update() {	
		this.x = body.position.x;
		this.y = body.position.y;
		this.rotation = radToDeg(body.rotation) - 30;
		body.angularVel = Math.min(Math.max(body.angularVel, -MAX_ANG_SPEED ), MAX_ANG_SPEED );
		
		if (dead) return;
	  //FIRING UP ACTIONS
		if (Main.keyboard[Keyboard.LEFT])
			move( -MOV_SPEED);
		else if (Main.keyboard[Keyboard.RIGHT])
			move(MOV_SPEED);
		else
			acc = 0;
			
		if (Main.keyboard[Keyboard.SPACE])
			jump();
		else
			jumped = false;
		if (Main.keyboard[Keyboard.S])
			shoot();
				
		
		/*for (g in guns)
			if (disableAllGuns > 0 || disableGunsAfterBadJump) 
				g.visible = false;
			else
				g.visible = true;*/
		
	}

  //ACTIONS
	public function move(x:Float) {
		acc += ACC_SPEED * Main.delta;
		if (acc > 1) acc = 1;
		
		body.velocity.x = x * acc;
		
		var num:Int = 0;
		
		
	  //ROTATE TRIANGLE WHEN MOVED
		//TODO: when fully touching ground
	}
	public function jump() {
		if (jumped || lastCollidedBlock == null) return;
		
		body.velocity.setxy(body.velocity.x, body.velocity.y - JUMP_SPEED);
		
		jumped = true;
		jumpS.play();
		
		if (disableAllGuns > 0) 
			disableGunsAfterBadJump = true;
		else
			disableGunsAfterBadJump = false;
	}
	public function shoot() {
		for (g in guns)
			g.fire();
	}
	
  //UTILS
	public inline static function degToRad(deg:Float):Float{
		return Math.PI / 180 * deg;
	}
	public inline static function radToDeg(rad:Float):Float{
		return 180 / Math.PI * rad;
	}
}

class Gun extends Sprite, implements Updatable{
  //CONFIG
	var BLOCK_FREQUENCY:Int;
	var ROUND_FREQUENCY:Int;
	var CHARGE_FREQUENCY:Int;
	
  //SOUNDS
	var weaponChanged:Sound;
	
	var shot0:Sound;
	var shot1:Sound;
	var shot2:Sound;
	
  //GUN TYPE
	public static var BLOCK:Int = 0;
	public static var ROUND:Int = 1;
	public static var CHARGE:Int = 2;
	
	public static var colors:Array<Int>;
	
	var otherGuns:Array<Gun>;
	var frequency:Int;
	
	public var fireable:Bool;
	
	var h:Float;
	public static var edgeLen:Float;
	
	var gunId:Int;
	
	public var hitted:Bool;
	
	public function new(game:Screen, gunId:Int, otherGuns:Array<Gun>, eLen:Float) {
		super();
		
		BLOCK_FREQUENCY = Std.parseInt(Config.f.node.player.node.gun.att.blockFreq);
		ROUND_FREQUENCY = Std.parseInt(Config.f.node.player.node.gun.att.roundFreq);
		CHARGE_FREQUENCY = Std.parseInt(Config.f.node.player.node.gun.att.chargeFreq);
		
		//BASIC_FREQUENCY = Std.parseInt(Config.f.node.player.node.gun.att.basicFrequency);
		
		this.gunId = gunId;
		this.otherGuns = otherGuns;
		h = Std.parseFloat(Config.f.node.player.node.gun.att.height);
		
		edgeLen = eLen * Std.parseFloat(Config.f.node.player.node.gun.att.percent) / 100.0;
		
	  //LOADING COLORS
		if(colors == null){
			colors = new Array<Int>();
			colors.push(SVGParser.getColor(Config.f.node.player.node.gun.node.def.x));
			colors.push(SVGParser.getColor(Config.f.node.player.node.gun.node.round.x));
			colors.push(SVGParser.getColor(Config.f.node.player.node.gun.node.ray.x));
		}
		
	  //DRAWING GUNS
		graphics.beginFill(colors[gunId], 1);
		switch(gunId) {
		case 0:
			graphics.drawRect( -edgeLen / 2, -h / 2, edgeLen, h);
			
			frequency = BLOCK_FREQUENCY;
		case 2:
			graphics.drawRect( -edgeLen / 2 + edgeLen * 0.4, -h / 2, edgeLen*0.2, h * 2);
			
			frequency = CHARGE_FREQUENCY;
		default:
			graphics.drawRect( -edgeLen / 2, -h / 2, edgeLen * 0.2, h * 2);
			graphics.drawRect( -edgeLen / 2 + edgeLen * 0.8, -h / 2, edgeLen*0.2, h * 2);
			
			frequency = ROUND_FREQUENCY;
		}
		graphics.endFill();
		
	  //REGISTERING CALLBACKS
		game.registerUpdatable(this);
		
		this.alpha = 0;
		hitted = false;
		
	  //LOADING SOUNDS
		weaponChanged = Assets.getSound ("sounds/weaponChanged.wav");
		shot0 = Assets.getSound ("sounds/shot0.wav");
		shot1 = Assets.getSound ("sounds/shot1.wav");
		shot2 = Assets.getSound ("sounds/shot2.wav");
	}
	
	public function fire() {
		if (!fireable || !visible) return;
		
		if (frequency <= 0) {
			var ang:Float = Player.degToRad(30 + 120 * (gunId + 1));
			
			Statics.v1.setxy(Main.game.player.x, Main.game.player.y);
			Statics.v2.setxy(1, 0);
			Statics.v2.rotate(ang);
			Main.game.bullets.fire(Statics.v1, 
								   Statics.v2,
								   Math.floor(Math.min(2, gunId)));
			
								   
		    switch(gunId) {
			case 0:
				shot0.play();
				frequency = BLOCK_FREQUENCY;
			case 1:
				shot1.play();
				frequency = ROUND_FREQUENCY;
			case 2:
				shot2.play();
				frequency = CHARGE_FREQUENCY;
			default:
			}
		}
	}
	
  //GUN STATE
	public function activate() {
		if (!fireable) {
		fireable = true; 
		Actuate.stop(this);
		
		weaponChanged.play();
		Actuate.tween(this, 0.2, { alpha:1 }, false)
			   .delay(0.05)
			   .onComplete(function() {
				  frequency = 0;
			   });
		}
	}
	public function deactivate() {
		if(fireable){
			Actuate.stop(this);
			
			fireable = false;
			Actuate.tween(this, 0.3, { alpha:0 }, false);
		}
	}

	public function update() {
		if (frequency > 0)
			frequency -= Main.delta;
	}
}

//BULLETS
class Bullet extends Sprite, implements Updatable{
  //CONFIG
	var MAX_LIFESPAN:Int = -1;
	var DEF_B_RADIUS:Float = -1;
	var SPEED:Float = -1;
	
	public var body:Body;
	var lifeSpan:Int;
	var evaporating:Bool;
	public var deathable:Int;
	
	public var B_TYPE:Int;
	
	public function new(parent:Sprite, uOverlord:Screen) {
		B_TYPE = 0;
		super();
		
		MAX_LIFESPAN = Std.parseInt(Config.f.node.player.node.gun.att.bulletLifespan);
		deathable = Std.parseInt(Config.f.node.player.node.gun.node.def.att.death);
		loadConfig();
		initPsychics();
		initVisuals();
		
	  //REGISTERING CALLBACKS
		uOverlord.registerUpdatable(this);
		parent.addChild(this);
	}
	
  //INITIALISATION
	function loadConfig() {
		DEF_B_RADIUS = Std.parseFloat(Config.f.node.player.node.gun.node.def.att.radius);
		SPEED = Std.parseFloat(Config.f.node.player.node.gun.node.def.att.speed);
	}
	function initPsychics() {
		body = new Body(BodyType.DYNAMIC);
		var sensor:Polygon = new Polygon(Polygon.rect(-Gun.edgeLen/2, -Gun.edgeLen/2, Gun.edgeLen, Gun.edgeLen));
		sensor.filter.collisionMask = ~(4|2);
		sensor.filter.collisionGroup = 4;
		sensor.cbTypes.add(Game.BULLET);
		sensor.userData.bullet = this;
		body.shapes.add(sensor);
		body.isBullet = true;
	}
	function initVisuals() {
		graphics.clear();
		graphics.beginFill(Gun.colors[0], 1);
		graphics.drawRect(-Gun.edgeLen/2, -Gun.edgeLen/2, Gun.edgeLen, Gun.edgeLen);
		graphics.endFill();
	}
	
	public function fire(from:Vec2, direction:Vec2) {
		body.position.set(from);
		
		direction.rotate(Main.game.player.body.rotation + Player.degToRad(30));
		direction.normalise();
		
		direction.x *= SPEED;
		direction.y *= SPEED;
		
		body.velocity.set(direction);
		body.velocity.dot(Main.game.player.body.velocity);
		body.rotation = Main.game.player.body.rotation;
		body.angularVel = 0;
		
		body.space = Main.space;
		lifeSpan = MAX_LIFESPAN;
		this.visible = true;
		
		this.alpha = 1;
		evaporating = false;
	}
	public function evaporate() {
		if (evaporating) return;
		evaporating = true;
		
		//TODO: add explosion
		//graphics.clear();
		//graphics.
		
		Actuate.tween(this, 1.0, { alpha: 0 }, false)
			   .onComplete(function() {
					if(body != null)
						body.space = null;
					this.visible = false; 
			   });
	}
	
	public function update() {
		if (!this.visible) { 
			if(body != null)
				body.space = null;
			return;
		}
		
		lifeSpan -= Main.delta;
		if (lifeSpan < 0) 
			evaporate();
			
		if(body != null){
			this.x = body.position.x;
			this.y = body.position.y;
			this.rotation = Player.radToDeg(body.rotation);
		}
	}
}

class RoundBullet extends Bullet {
	
	public function new(parent:Sprite, uOverlord:Screen) {
		super(parent, uOverlord);
		
		B_TYPE = 1;
		deathable = Std.parseInt(Config.f.node.player.node.gun.node.round.att.death);
	}
	
	override function initPsychics() {
		body = new Body(BodyType.DYNAMIC);
		var sensor:Circle = new Circle(DEF_B_RADIUS);
		sensor.filter.collisionMask = ~(4|2);
		sensor.filter.collisionGroup = 4;
		sensor.cbTypes.add(Game.BULLET);
		sensor.userData.bullet = this;
		body.shapes.add(sensor);
		body.isBullet = true;
	}
	override function initVisuals() {
		graphics.clear();
		graphics.beginFill(Gun.colors[1], 1);
		graphics.drawCircle(0, 0, DEF_B_RADIUS);
		graphics.endFill();
	}
	override function loadConfig() {
		DEF_B_RADIUS = Std.parseFloat(Config.f.node.player.node.gun.node.round.att.radius);
		SPEED = Std.parseFloat(Config.f.node.player.node.gun.node.round.att.speed);
	}
	
}

class BulletOverlord extends Sprite {
	
	var bullets:Array<Array<Sprite>>;
	
	public function new() {
		super();
		
		bullets = new Array<Array<Sprite>>();
		for (i in 0...2)
			bullets[i] = new Array<Sprite>();
	}
	
	public function init() {
		for (blt in bullets) {
			var b:Bullet = cast(blt);
			Actuate.stop(b);
			b.body.space = null;
			b.visible = false;
		}
	}
	
	public function fire(from:Vec2, direction:Vec2, bulletType:Int=0):Bullet {
		var blet:Bullet = null;
		bulletType = Math.floor(Math.min(1, bulletType));
		for (i in 0...bullets[bulletType].length) 
			if (!cast(bullets[bulletType][i], Bullet).visible) {
				blet = cast(bullets[bulletType][i]);
				break;
			}
		if (blet == null) {
			switch(bulletType) {
			case 0:
				blet = new Bullet(this, Main.game);
			default:
				blet = new RoundBullet(this, Main.game);
			}
			
			bullets[bulletType].push(blet);
			this.addChild(blet);
		}
		
		blet.fire(from, direction);
		return blet;
	}
}