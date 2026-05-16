package nape.phys;
import cx.FastList;
import cx.MixList;
import cx.Algorithm;
import nape.phys.PhysObj;
import nape.phys.Properties;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.shape.Shape;
import nape.Const;
import nape.space.UniformSpace;
import nape.space.UniformSleepSpace;

//'newfile' define generated imports
import cx.CxFastList_UniformSleepCell;





















class Body extends PhysObj {
	
	public var bw:Float; 
	
	 public var glx:Float; public var gly:Float     ; 
	 public var gpx:Float; public var gpy:Float     ; 
	
	
	
	
	public var shapes: Shape;
	
	
	public var uniformsleepcells:CxFastList_UniformSleepCell;
	
	
	
	public function new(?x:Float=0,?y:Float=0,?properties:Properties) {
		super(x,y,true,properties);
		body = this;
		a = w = t = bw = 0;
		shapes = new  Shape();
		 { rotx = 0;   roty = 1;   } ;
	}
	
	
	
	public inline function setAngle(angle:Float):Void {
		a = angle;
		 { rotx = Math.sin(a);   roty = Math.cos(a);   } ;
		 { gpx =  (glx*roty - gly*rotx) ;     gpy =  (glx*rotx + gly*roty) ;      } ;
	}
	
	public override function update() {
		updatePosition(0);
		  {
	var cxiterator = shapes.begin();
	while(cxiterator != shapes.end()) {
		var s = cxiterator.elem();
		{
			
			s.updateShape();
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	public inline function updateVelocity(dt:Float) {
		updateVelocity_linear(dt);
		if(smoment!=0.0) {
			w = w * properties.afdt + t * dt * imoment;
		}
		t = 0;
	}
	public inline function updatePosition(dt:Float) {
		aabb.minx = aabb.miny = Const.POSINF;
		aabb.maxx = aabb.maxy = -Const.POSINF;
		
		updatePosition_linear(dt);
		pre_a = a;
		if(smoment!=0.0) {
			a += w * dt + bw;
			bw = 0;
		}
		 { rotx = Math.sin(a);   roty = Math.cos(a);   } ;
		 { gpx =  (glx*roty - gly*rotx) ;     gpy =  (glx*rotx + gly*roty) ;      } ;
		if(hasGraphic && rotateGraphic)
			graphic.rotation = (a*Const.RAD_TO_DEG)%360;
	}
	
	
	
	public inline function addShape(s:Shape) {
		if(s.body!=this) {
			if(s.body!=null)
				s.body.removeShape(s);
			s.body = this;
			shapes.add(s);
			return true;
		}else return false;
	}
	public function removeShape(s:Shape) {
		if(shapes.remove(s)) {
			s.body = null;
			 {
				  {
	var cxiterator = p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
					var obj = arb.obj_arb;
					if(obj!=null && (obj.p1==this || obj.p2==this)) {
						obj.retire_arb(arb);
						arb.obj_arb = null;
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
					var obj = arb.obj_arb;
					if(obj!=null && (obj.p1==this || obj.p2==this)) {
						obj.retire_arb(arb);
						arb.obj_arb = null;
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
					var obj = arb.obj_arb;
					if(obj!=null && (obj.p1==this || obj.p2==this)) {
						obj.retire_arb(arb);
						arb.obj_arb = null;
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
					var obj = arb.obj_arb;
					if(obj!=null && (obj.p1==this || obj.p2==this)) {
						obj.retire_arb(arb);
						arb.obj_arb = null;
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
			}
			return true;
		}else return false;
	}
	
	
	
	public function calcProperties():Void {
		var m = 0.;
		var i = 0.;
		evrad = 0.;
		  {
	var cxiterator = shapes.begin();
	while(cxiterator != shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var sm = s.area * s.material.density;
			m += sm;
			if(s.type==Shape.CIRCLE) i += s.circle .inertia() * sm;
			else                     i += s.polygon.inertia() * sm;
			if(s.type==Shape.CIRCLE) evrad += s.circle .inertia();
			else                     evrad += s.polygon.inertia();
		};
		}
		cxiterator = cxiterator.next;
	}
};
		if (m > 0) { mass    = m;          imass    = 1 / m; }
		else       { mass    = Const.FMAX; imass    = 0;     }
		if (i > 0) { moment  = i;          imoment  = 1 / i; }
		else       { moment  = Const.FMAX; imoment  = 0;     }
		cmass = smass = imass;
		cmoment = smoment = imoment;
		gmass = mass;
		
		var p = COM();  { glx = p.px; gly = p.py; } ;
		 { gpx = glx; gpy = gly; } ;
	}
	
	
	
	public inline function ROTX(v:Vec2) return  (v.px*roty - v.py*rotx) 
	public inline function ROTY(v:Vec2) return  (v.px*rotx + v.py*roty) 
	
	public inline function ROTXs(vx:Float,vy:Float) return  (vx*roty - vy*rotx) 
	public inline function ROTYs(vx:Float,vy:Float) return  (vx*rotx + vy*roty) 
	
	
	
	public inline function stopRotation() {
		moment = Const.POSINF;
		w = t = bw = 0;
		imoment = smoment = 0;
		#if flash9 if(hasGraphic) graphic.cacheAsBitmap = true; #end
	}
	public inline function allowRotation() {
		moment = 1.0/cmoment;
		imoment = smoment = cmoment;
		#if flash9 if(hasGraphic && rotateGraphic) graphic.cacheAsBitmap = false; #end
	}
	
	
	
	public inline function COM():Vec2 {
		var ret = new Vec2(0,0);
		var msum = 0.0;
		  {
	var cxiterator = shapes.begin();
	while(cxiterator != shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var sm = s.area * s.material.density;
			if(s.type == Shape.CIRCLE)  { ret.px += s.circle.offset.px*(sm); ret.py += s.circle.offset.py*(sm); } ;
			else                        { ret.px += s.polygon.COM().px*(sm); ret.py += s.polygon.COM().py*(sm); } ;
			msum += sm;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  { ret.px *= 1.0/msum;   ret.py *= 1.0/msum;   }  ;
		return ret;
	}
	
	public inline function shift(x:Vec2) {
		  {
	var cxiterator = shapes.begin();
	while(cxiterator != shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			if(s.type == Shape.CIRCLE) s.circle .shift(x);
			else                       s.polygon.shift(x);
		};
		}
		cxiterator = cxiterator.next;
	}
};
		 { glx += x.px; gly += x.py; } ;
	}
	
	public inline function align() {
		var x = COM();
		x.px = -x.px;
		x.py = -x.py;
		shift(x);
	}
	
}
