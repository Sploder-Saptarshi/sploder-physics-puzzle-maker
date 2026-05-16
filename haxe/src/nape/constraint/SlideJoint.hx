package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.constraint.ClassicCons;
import nape.constraint.Constraint;
import nape.Const;
import nape.util.FastMath;
















class SlideJoint extends ClassicCons {

	 public var nx:Float; public var ny:Float     ;
	
	public var jointMin:Float;
	public var jointMax:Float;
	
	public var nMass:Float;
	public var bias :Float;
	public var jnAcc:Float;
	public var jnMax:Float;
	
	public var slack:Bool;
	public var scale:Float;
	
	
	
	public function new (obj1:PhysObj,obj2:PhysObj,anchor1:Vec2,anchor2:Vec2,min:Float,max:Float) {
		super(obj1,obj2,anchor1,anchor2);
		
		   var spx:Float;  var spy:Float      ;  { spx = anchor1.px-anchor2.px; spy = anchor1.py-anchor2.py;  } ;
		jointMin = min;
		jointMax = max;
		jnAcc = 0;
	}
	
	
	
	public override function preStep(dt:Float) {
		  { r1x =  (a1x*b1.roty - a1y*b1.rotx) ;     r1y =  (a1x*b1.rotx + a1y*b1.roty) ;      } ;
		  { r2x =  (a2x*b2.roty - a2y*b2.rotx) ;     r2y =  (a2x*b2.rotx + a2y*b2.roty) ;      } ;
		
		 {
	nx = (b2.px+r2x)-(b1.px+r1x);
	ny = (b2.py+r2y)-(b1.py+r1y);
};
		var dist;  {
	var idist; dist =  (nx*nx + ny*ny)   ;
	if(dist>Const.EPSILON) { idist = FastMath.invsqrt(dist); dist = 1.0/idist; }
	else                   idist = 0;
	 { nx *= idist;   ny *= idist;   } ;
};
		
		if(dist>jointMax)  {
			dist = jointMax-dist;
			scale = 1;
			slack = false;
		}else if(dist<jointMin) {
			dist = dist-jointMin;
			scale = -1;
			slack = false;
		}else {
			dist  = 0;
			jnAcc = 0;
			slack = true;
		}
		
		if(!slack) {
			nMass = 1.0 /  ({
	var ret = b1.smass+b2.smass+b1.smoment*Calc.sq( (r1x*ny - r1y*nx) )+b2.smoment*Calc.sq( (r2x*ny - r2y*nx) );
	if(ret<Const.EPSILON) ret = Const.FMAX;
	ret;
});
			bias = biasCoef*dist/dt;
			bias = Calc.clamp(bias,maxBias);
			jnMax = maxForce*dt;
		
			 {
	var jx = nx*jnAcc*scale - ny*0;
	var jy = ny*jnAcc*scale + nx*0;
	 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jy - r1y*jx) ;
	b2.w += b2.imoment *  (r2x*jy - r2y*jx) ;
};
};
		}
		
		return false;
	}
	
	
	
	public override function applyImpulse() {
		if(slack) return false;
		
		   var vrx:Float;  var vry:Float      ;  {
	vrx = (r1y*b1.w + b2.vx) - (r2y*b2.w + b1.vx);
	vry = (r2x*b2.w + b2.vy) - (r1x*b1.w + b1.vy);
};
		var jn = nMass*(bias- (vrx*nx + vry*ny) *scale);
		var jnOld = jnAcc; jnAcc += jn;
		
		if(breakable) { if(jnAcc*jnAcc>jnMax*jnMax) return true; }
		jnAcc = Calc.range(jnAcc,-jnMax,0);
		
		jn = (jnAcc-jnOld)*scale;
		 {
	var jx = nx*jn - ny*0;
	var jy = ny*jn + nx*0;
	 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jy - r1y*jx) ;
	b2.w += b2.imoment *  (r2x*jy - r2y*jx) ;
};
};
		
		return false;
	}
	
	
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		if(slack)  { dst.px = 0;   dst.py = 0;   } ;
		else {
			if(obj==b1)  { dst.px = nx*(-jnAcc*scale); dst.py = ny*(-jnAcc*scale);  } ;
			else         { dst.px = nx*(jnAcc*scale); dst.py = ny*(jnAcc*scale);  } ;
		}
	}
}
