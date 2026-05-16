package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.ClassicCons;
import nape.constraint.Constraint;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.util.FastMath;
import nape.Const;
















class DampedSpring extends ClassicCons {

	 public var nx:Float; public var ny:Float     ;
	 public var fx:Float; public var fy:Float     ;
	
	public var restLength:Float;
	public var stiffness:Float;
	public var damping:Float;
	
	public var damp_val:Float;
	public var nMass:Float;
	public var targ_vrn:Float;
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,anchor1:Vec2,anchor2:Vec2,rest_length:Float,stiffness:Float,dampening:Float) {
		super(obj1,obj2,anchor1,anchor2);
		
		restLength = rest_length;
		this.stiffness = stiffness;
		damping = dampening;
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

		nMass = 1.0/ ({
	var ret = b1.smass+b2.smass+b1.smoment*Calc.sq( (r1x*ny - r1y*nx) )+b2.smoment*Calc.sq( (r2x*ny - r2y*nx) );
	if(ret<Const.EPSILON) ret = Const.FMAX;
	ret;
});
		
		var f_spring = (restLength-dist)*stiffness; 
		 { fx = nx*(f_spring); fy = ny*(f_spring);  } ;
		if(breakable) { if( (fx*fx + fy*fy)    > maxForce*maxForce) return true; }
		 {
	var ls =  (fx*fx + fy*fy)   ;
	if(ls>(maxForce)*(maxForce)) {
		ls = (maxForce)*FastMath.invsqrt(ls);
		fx *= ls;
		fy *= ls;
	}
};
		
		 {
	 { b1.fx -= fx; b1.fy -= fy; } ;
	 { b2.fx += fx; b2.fy += fy; } ;
	if(b1.imoment!=0) b1.t -=  (r1x*fy - r1y*fx) ;
	if(b2.imoment!=0) b2.t +=  (r2x*fy - r2y*fx) ;
};
		
		targ_vrn = 0;
		damp_val = 1.0-Math.exp(-damping*dt/nMass);
		this.dt = dt;
		return false;
	}
	
	
	
	public override function applyImpulse():Bool {
		   var vrx:Float;  var vry:Float      ;  {
	vrx = (r1y*b1.w + b2.vx) - (r2y*b2.w + b1.vx);
	vry = (r2x*b2.w + b2.vy) - (r1x*b1.w + b1.vy);
};
		var vrn =  (vrx*nx + vry*ny) -targ_vrn;
		
		var vdamp = -vrn*damp_val;
		targ_vrn = vrn + vdamp;
		   var jx:Float;  var jy:Float      ;  { jx = nx*(vdamp*nMass); jy = ny*(vdamp*nMass);  } ;
		 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (r1x*jy - r1y*jx) ;
	b2.w += b2.imoment *  (r2x*jy - r2y*jx) ;
};
		return false;
	}
	
	
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		   var vrx:Float;  var vry:Float      ;  {
	vrx = (r1y*b1.w + b2.vx) - (r2y*b2.w + b1.vx);
	vry = (r2x*b2.w + b2.vy) - (r1x*b1.w + b1.vy);
};
		var vrn =  (vrx*nx + vry*ny) -targ_vrn;
		
		var vdamp = -vrn*damp_val;
		targ_vrn = vrn + vdamp;
		   var jx:Float;  var jy:Float      ;  { jx = nx*(vdamp*nMass); jy = ny*(vdamp*nMass);  } ;
		
		if(obj==b1) {  { dst.px = fx*(-dt); dst.py = fy*(-dt);  } ;  { dst.px -= jx; dst.py -= jy; } ; }
		else      {  { dst.px = fx*(dt); dst.py = fy*(dt);  } ;  { dst.px += jx; dst.py += jy; } ; }
	}
}
