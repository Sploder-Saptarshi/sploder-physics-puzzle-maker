package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.constraint.ClassicCons;
import nape.constraint.Constraint;
import nape.Const;
import nape.util.FastMath;
















class PivotJoint extends ClassicCons {
	
	 public var kt11:Float; public var kt12:Float; public var kt21:Float; public var kt22:Float ;
	
	 public var biasx:Float; public var biasy:Float     ;
	 public var jAccx:Float; public var jAccy:Float     ;
	
	public var jMax:Float;
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,pivot:Vec2) {
		super(obj1,obj2,pivot,pivot);
		 { jAccx = 0;   jAccy = 0;   } ;
	}
	
	
	
	public override function preStep(dt:Float) {
		  { r1x =  (a1x*b1.roty - a1y*b1.rotx) ;     r1y =  (a1x*b1.rotx + a1y*b1.roty) ;      } ;
		  { r2x =  (a2x*b2.roty - a2y*b2.rotx) ;     r2y =  (a2x*b2.rotx + a2y*b2.roty) ;      } ;
		 {
	biasx = (b2.px+r2x)-(b1.px+r1x);
	biasy = (b2.py+r2y)-(b1.py+r1y);
};
		 {
	var mass_sum = b1.cmass + b2.cmass;
	
	kt11 = mass_sum; kt12 = 0.0;
	kt21 = 0.0;      kt22 = mass_sum;
	
	if(b1.smoment!=0) {
		var r1xsq =  r1x*r1x*b1.smoment;
		var r1ysq =  r1y*r1y*b1.smoment;
		var r1nxy = -r1x*r1y*b1.smoment;
		kt11 += r1ysq; kt12 += r1nxy;
		kt21 += r1nxy; kt22 += r1xsq;
	}
	
	if(b2.smoment!=0) {
		var r2xsq =  r2x*r2x*b2.smoment;
		var r2ysq =  r2y*r2y*b2.smoment;
		var r2nxy = -r2x*r2y*b2.smoment;
		kt11 += r2ysq; kt12 += r2nxy;
		kt21 += r2nxy; kt22 += r2xsq;
	}
	
	 {
	var det =  (kt11*kt22 - kt12*kt21) ;
	if(det*det<Const.EPSILON) {
		kt11 = kt22 = 0;
		kt12 = kt21 = 0;
		throw "singular";
	}else {
		var idet = 1.0 / det;
		kt12 = -kt12*idet;
		kt21 = -kt21*idet;
		var t = kt11*idet;
		kt11 = kt22*idet;
		kt22 = t;
	}
};
};
		
		 { biasx *= -biasCoef/dt;   biasy *= -biasCoef/dt;   } ;
		 {
	var ls =  (biasx*biasx + biasy*biasy)   ;
	if(ls>(maxBias)*(maxBias)) {
		ls = (maxBias)*FastMath.invsqrt(ls);
		biasx *= ls;
		biasy *= ls;
	}
};
		
		jMax = maxForce*dt;
		 {
	 { b1.vx -= jAccx*(b1.imass); b1.vy -= jAccy*(b1.imass); } ;
	 { b2.vx += jAccx*(b2.imass); b2.vy += jAccy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jAccy - r1y*jAccx) ;
	b2.w += b2.imoment *  (r2x*jAccy - r2y*jAccx) ;
};
		
		return false;
	}
	
	
	public override function applyImpulse():Bool {
		   var vrx:Float;  var vry:Float      ;  {
	vrx = (r1y*b1.w + b2.vx) - (r2y*b2.w + b1.vx);
	vry = (r2x*b2.w + b2.vy) - (r1x*b1.w + b1.vy);
};
		
		   var jx:Float;  var jy:Float      ;  { jx = biasx-vrx; jy = biasy-vry;  } ;
		 {
	var t = kt11*jx + kt12*jy;
	jy   = kt21*jx + kt22*jy;
	jx   = t;
};
		   var jOldx:Float;  var jOldy:Float      ;  { jOldx = jAccx; jOldy = jAccy; } ;  { jAccx += jx; jAccy += jy; } ;
		
		if(breakable) { if( (jAccx*jAccx + jAccy*jAccy)   >jMax*jMax) return true; }
		 {
	var ls =  (jAccx*jAccx + jAccy*jAccy)   ;
	if(ls>(jMax)*(jMax)) {
		ls = (jMax)*FastMath.invsqrt(ls);
		jAccx *= ls;
		jAccy *= ls;
	}
};

		 { jx = jAccx-jOldx; jy = jAccy-jOldy;  } ;
		 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jy - r1y*jx) ;
	b2.w += b2.imoment *  (r2x*jy - r2y*jx) ;
};
		return false;
	}
	
	
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		if(obj==b1)  { dst.px = -jAccx;   dst.py = -jAccy;   } ;
		else       { dst.px = jAccx; dst.py = jAccy; } ;
	}
}
