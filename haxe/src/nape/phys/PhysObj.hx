package nape.phys;
import cx.FastList;
import nape.callbacks.Callbackable;
import nape.dynamics.SubArbiters;
import nape.dynamics.ObjArb;
import nape.phys.Properties;
import nape.geom.VecMath;
import nape.geom.AABB;
import nape.Config;
import nape.Const;
import nape.phys.Body;
import nape.space.Space;
import flash.display.DisplayObject;

//'newfile' define generated imports
import nape.dynamics.Arbiter_false_false_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_false_false_true_true_Shape_Shape;
import nape.dynamics.Arbiter_false_false_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_false_false_true_false_Shape_Particle;
import nape.dynamics.Arbiter_true_true_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_true_true_true_true_Shape_Shape;
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastList_ObjArb;
import cx.CxFastList_Constraint;






















class PhysObj extends Callbackable {
	
	static var nextId:Int = 0;
	public var id    :Int;
	
	
	
	 public var px:Float; public var py:Float     ; 
	 public var pre_px:Float; public var pre_py:Float     ; 
	
	 public var vx:Float; public var vy:Float     ; 
	 public var fx:Float; public var fy:Float     ; 
	 public var bvx:Float; public var bvy:Float     ; 
	
	
	
	public var mass:Float;
	public var imass:Float;
	public var smass:Float; 
	public var gmass:Float; 
	
	public var cmass:Float; 
	public var ogmass:Float; 
	 
	public var properties:Properties;
	
	public var data:Dynamic;
	
	public var visible:Bool;
	public var pvisible:Bool;
	public var aabb:AABB;
	
	
	
	public var isStatic:Bool; 
	
	
	public var isBody:Bool;
	public var body:Body;
	public var particle:Particle;
	
	
	
	public var hasGraphic:Bool;
	public var graphic:DisplayObject;
	public var rotateGraphic:Bool;
	 public var graphic_deltax:Float; public var graphic_deltay:Float     ;
	
	
	
	
	public var p_arbiters_false_false_true_true_Shape_Shape:CxFastList_Arbiter_false_false_true_true_Shape_Shape;
		
		
	public var p_arbiters_false_false_true_false_Shape_Particle:CxFastList_Arbiter_false_false_true_false_Shape_Particle;
		
		
	public var p_arbiters_true_true_true_true_Shape_Shape:CxFastList_Arbiter_true_true_true_true_Shape_Shape;
		
		
	public var p_arbiters_true_true_true_false_Shape_Particle:CxFastList_Arbiter_true_true_true_false_Shape_Particle;
		
		
	
	public var p_objarb:CxFastList_ObjArb;
	
	
	public var p_constraints:CxFastList_Constraint;
	
	public var added_to_space:Bool;
	public var space:Space;
	
	
	
	
	public var kinetic:Float;
	public var evslp:Int;
	public var evrad:Float;
	
	public var live :Bool;
	public var woken:Bool;
	public var sleep:Bool;
	public var stamp:Int;
	public var plive:Bool;
	
	
	
	
	public var cbSleep      :Bool;
	public var cbWake       :Bool;
	public var cbOutOfBounds:Bool;
	public var cbShow       :Bool;
	public var cbHide       :Bool;
	
	public var cbSleepDef      :Bool;
	public var cbWakeDef       :Bool;
	public var cbOutOfBoundsDef:Bool;
	public var cbShowDef       :Bool;
	public var cbHideDef       :Bool;
	
	
	
	
	public var imoment:Float;
	public var smoment:Float; 
	public var cmoment:Float; 
	public var moment:Float;
	public var a:Float;
	public var pre_a:Float;
	public var w:Float;
	public var t:Float;
	 public var rotx:Float; public var roty:Float     ;
	
	public var group_obj:Group;
	
	
	
	public function new(X:Float,Y:Float,BODY:Bool,?PROP:Properties) {
		 { px = X;   py = Y;   } ;  { pre_px = px; pre_py = py; } ;
		 { vx = 0;   vy = 0;   } ;  { fx = 0;   fy = 0;   } ;  { bvx = 0;   bvy = 0;   } ;
		aabb = new AABB();
		
		properties = if(PROP==null) Config.DEFAULT_PROPERTIES else PROP;
		
		isBody = BODY;
		stamp = 0;
		hasGraphic = false;
		rotateGraphic = true;
		 { graphic_deltax = 0;   graphic_deltay = 0;   } ;
		
		id = nextId++;
		
		kinetic = 0;
		evslp = 1;
		cbType = 0;
		
		cbSleepDef = cbWakeDef = cbOutOfBoundsDef = cbShowDef = cbHideDef = true;
		
		 p_arbiters_false_false_true_true_Shape_Shape = new CxFastList_Arbiter_false_false_true_true_Shape_Shape(); p_arbiters_false_false_true_false_Shape_Particle = new CxFastList_Arbiter_false_false_true_false_Shape_Particle(); p_arbiters_true_true_true_true_Shape_Shape = new CxFastList_Arbiter_true_true_true_true_Shape_Shape(); p_arbiters_true_true_true_false_Shape_Particle = new CxFastList_Arbiter_true_true_true_false_Shape_Particle();
		p_objarb = new CxFastList_ObjArb();
		
		p_constraints = new CxFastList_Constraint();
	}
	
	
	
	public function update():Void
	{
		
	}
	
	public inline function updateVelocity_linear(dt:Float) {
		evslp = -1;
		if(smass!=0.0) {
			var d = dt*imass;
			 { vx *= properties.lfdt;   vy *= properties.lfdt;   } ;  { vx += fx*(d); vy += fy*(d); } ;
		}
		 { fx = 0;   fy = 0;   } ;
	}
	public inline function updatePosition_linear(dt:Float) {
		 { pre_px = px; pre_py = py; } ;
		if(smass!=0.0) {
			 { px += vx*(dt); py += vy*(dt); } ;  { px += bvx; py += bvy; } ;
			 { bvx = 0;   bvy = 0;   } ;
		}
		if(hasGraphic) {
			if(isBody) {
				graphic.x = px +  (graphic_deltax*roty - graphic_deltay*rotx) ;
				graphic.y = py +  (graphic_deltax*rotx + graphic_deltay*roty) ;
			}else {
				 { graphic.x = px; graphic.y = py; } ;
				 { graphic.x += graphic_deltax; graphic.y += graphic_deltay; } ;
			}
		}
	}
	
	
	
	public inline function sleep_base() {
		 { vx = 0;   vy = 0;   } ;
		imass = 0;
		sleep = true;
		woken = false;
	}
	public inline function wake_base() {
		sleep = false;
		imass = smass;
	}
	
	
	
	public inline function stopMovement() {
		mass  = Const.FMAX;
		imass = smass = 0;
		
		
		 { vx = 0;   vy = 0;   } ;  { fx = 0;   fy = 0;   } ;  { bvx = 0;   bvy = 0;   } ;
	}
	public inline function allowMovement() {
		mass = 1.0/cmass;
		
		imass = smass = cmass;
	}
	public inline function stopAll() {
		stopMovement();
		if(isBody)
			cast (this,Body).stopRotation();
	}
	public inline function allowAll() {
		allowMovement();
		if(isBody)
			cast (this,Body).allowRotation();
	}
	
	
	
	public inline function assignGraphic(g:DisplayObject) {
		graphic = g;
		hasGraphic = g!=null;
	}
	
	
	
	public inline function activeMotion() {
		if(evslp==-1) {
			evslp = 1;
			if( (vx*vx + vy*vy)   >=Config.REST_LINEAR) evslp = 0;
			if(evslp!=0 && w*w*evrad>=Config.REST_ANGULAR) evslp = 0;
			
			
			
			
			
			
			
			if(space!=null) {
				if(evslp!=0) {
					var da = (a - pre_a)/space._dt;
					if(da*da*evrad>Config.REST_BIAS_ANGULAR) evslp = 0;
				}
				if(evslp!=0) {
					   var dpx:Float;  var dpy:Float      ;  { dpx = px; dpy = py; } ;  { dpx -= pre_px; dpy -= pre_py; } ;   { dpx *= 1.0/space._dt;   dpy *= 1.0/space._dt;   }  ;
					if( (dpx*dpx + dpy*dpy)   >Config.REST_BIAS_LINEAR) evslp = 0;
				}
			}
		}
		return evslp == 0;
	}
	
	
	
	public inline function applyGlobalForce(fx:Float,fy:Float,gx:Float,gy:Float) {
		 { this.fx += fx; this.fy += fy; } ;
		if(isBody) {
			   var rx:Float;  var ry:Float      ;  { rx = gx-px; ry = gy-py;  } ;
			t +=  (rx*fy - ry*fx) ;
		}
	}
	
	public inline function applyRelativeForce(fx:Float,fy:Float,rx:Float,ry:Float) {
		 { this.fx += fx; this.fy += fy; } ;
		if(isBody)
			t +=  (rx*fy - ry*fx) ;
	}
	
	
	
	public inline function setPos(x:Float, y:Float, ?angle:Float):Void {
		 { px = x; py = y; } ;
		if (isBody && angle != null) body.setAngle(angle);
	}
	public inline function setVel(x:Float, y:Float, ?w:Float):Void {
		 { vx = x; vy = y; } ;
		if (isBody && w != null) this.w = w;
	}
}
