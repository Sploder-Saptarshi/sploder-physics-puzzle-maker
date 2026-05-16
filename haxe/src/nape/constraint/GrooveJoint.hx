package nape.constraint;
import nape.constraint.TwoConstraint;
import nape.constraint.Constraint;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.space.Space;
import nape.phys.PhysObj;
import nape.util.FastMath;
import nape.Const;
















class GrooveJoint extends TwoConstraint {
	
	 public var gax:Float; public var gay:Float     ;  public var tax:Float; public var tay:Float     ;
	 public var gbx:Float; public var gby:Float     ;  public var tbx:Float; public var tby:Float     ;
	 public var gnx:Float; public var gny:Float     ;  public var tnx:Float; public var tny:Float     ;
	
	 public var a2x:Float; public var a2y:Float     ;
	
	 public var r1x:Float; public var r1y:Float     ;
	 public var r2x:Float; public var r2y:Float     ;
	
	 public var jAccx:Float; public var jAccy:Float     ;
	 public var biasx:Float; public var biasy:Float     ;
	public var clamp:Float;
	public var jMax :Float;
	
	 public var kt11:Float; public var kt12:Float; public var kt21:Float; public var kt22:Float ;
	
	public inline function calcNorm() {
		 { gnx = gbx-gax; gny = gby-gay;  } ;
		 {
	 {
	var d =  (gnx*gnx + gny*gny)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	gnx *= imag;
	gny *= imag;
};
	var t = gnx;
	gnx = -gny;
	gny = t;
};
	}
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,groove1:Vec2,groove2:Vec2,anchor2:Vec2) {
		super(obj1,obj2);
		
		   var tx:Float;  var ty:Float      ;
		 {
	   var tx:Float;  var ty:Float      ;
	 { tx = groove1.px-obj1.px; ty = groove1.py-obj1.py;  } ;
	 { gax = tx*obj1.roty+ty*obj1.rotx; gay = ty*obj1.roty-tx*obj1.rotx;} ;
};
		 {
	   var tx:Float;  var ty:Float      ;
	 { tx = groove2.px-obj1.px; ty = groove2.py-obj1.py;  } ;
	 { gbx = tx*obj1.roty+ty*obj1.rotx; gby = ty*obj1.roty-tx*obj1.rotx;} ;
};
		 {
	   var tx:Float;  var ty:Float      ;
	 { tx = anchor2.px-obj2.px; ty = anchor2.py-obj2.py;  } ;
	 { a2x = tx*obj2.roty+ty*obj2.rotx; a2y = ty*obj2.roty-tx*obj2.rotx;} ;
};
		
		calcNorm();
		
		 { jAccx = 0;   jAccy = 0;   } ;
	}
	
	
	
	public override function preStep(dt:Float) {
		  { tax =  (gax*b1.roty - gay*b1.rotx) ;     tay =  (gax*b1.rotx + gay*b1.roty) ;      } ;  { tax += b1.px; tay += b1.py; } ;
		  { tbx =  (gbx*b1.roty - gby*b1.rotx) ;     tby =  (gbx*b1.rotx + gby*b1.roty) ;      } ;  { tbx += b1.px; tby += b1.py; } ;
		
		  { tnx =  (gnx*b1.roty - gny*b1.rotx) ;     tny =  (gnx*b1.rotx + gny*b1.roty) ;      } ;
		  { r2x =  (a2x*b2.roty - a2y*b2.rotx) ;     r2y =  (a2x*b2.rotx + a2y*b2.roty) ;      } ;
		
		   var bpx:Float;  var bpy:Float      ;  { bpx = b2.px+r2x; bpy = b2.py+r2y;  } ;
		var td =  (bpx*tny - bpy*tnx) ;
		if(td <=  (tax*tny - tay*tnx) ) {
			clamp = 1.0;
			 { r1x = tax-b1.px; r1y = tay-b1.py;  } ;
		}else if(td >=  (tbx*tny - tby*tnx) ) {
			clamp = -1.0;
			 { r1x = tbx-b1.px; r1y = tby-b1.py;  } ;
		}else  {
			clamp = 0.0;
			var d =  (tax*tnx + tay*tny) ;
			r1x = (tnx*d)+(tny*td)-b1.px;
			r1y = (tny*d)-(tnx*td)-b1.py;
		}

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
		
		jMax = maxForce*dt;
		
		   var dx:Float;  var dy:Float      ;  {
	dx = (b2.px+r2x)-(b1.px+r1x);
	dy = (b2.py+r2y)-(b1.py+r1y);
};
		 { biasx = dx*(-biasCoef/dt); biasy = dy*(-biasCoef/dt);  } ;
		 {
	var ls =  (biasx*biasx + biasy*biasy)   ;
	if(ls>(maxBias)*(maxBias)) {
		ls = (maxBias)*FastMath.invsqrt(ls);
		biasx *= ls;
		biasy *= ls;
	}
};
		
		 {
	 { b1.vx -= jAccx*(b1.imass); b1.vy -= jAccy*(b1.imass); } ;
	 { b2.vx += jAccx*(b2.imass); b2.vy += jAccy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jAccy - r1y*jAccx) ;
	b2.w += b2.imoment *  (r2x*jAccy - r2y*jAccx) ;
};
		
		return false;
	}
	
	
	
	public override function applyImpulse() {
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
		if(clamp* (jAccx*tny - jAccy*tnx)  <= 0.0)  {
	var sv =  (jAccx*tnx + jAccy*tny) ;
	 { jAccx = tnx*(sv); jAccy = tny*(sv);  } ;
};
		
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
