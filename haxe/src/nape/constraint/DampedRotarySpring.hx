package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.TwoConstraint;
import nape.constraint.Constraint;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.Const;















class DampedRotarySpring extends TwoConstraint {
	
	public var restAngle:Float;
	public var stiffness:Float;
	public var damping  :Float;
	
	public var iSum:Float;
	public var f_spring:Float;
	public var f:Float;
	public var targ_w:Float;
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,rest_angle:Float,stiffness:Float,dampening:Float) {
		super(obj1,obj2);
		restAngle = rest_angle;
		this.stiffness = stiffness;
		damping   = dampening;
	}
	
	
	
	public override function preStep(dt:Float):Bool {
		var inSum = b1.smoment+b2.smoment;
		iSum = if(inSum<Const.EPSILON) 0 else 1.0/inSum;
		
		targ_w = 0;
		f_spring = 1.0 - Math.exp(-damping*dt/iSum);
		
		f = b2.a-b1.a;
		f = (restAngle-f)*stiffness;
		if(breakable) { if(f*f>maxForce*maxForce) return true; }
		f = Calc.clamp(f, maxForce);
		
		if(b1.imoment!=0) b1.t -= f;
		if(b2.imoment!=0) b2.t += f;
		
		return false;
	}
	
	
	
	public override function applyImpulse():Bool {
		var wr = b1.w-b2.w;
		
		var w_damp = wr*f_spring;
		targ_w = wr - w_damp;
		
		var j_damp = w_damp*iSum;
		b1.w -= j_damp*b1.imoment;
		b2.w += j_damp*b2.imoment;
		
		return false;
	}
	
	
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		var wr = b1.w-b2.w;
		
		var w_damp = wr*f_spring;
		targ_w = wr - w_damp;
		
		var j_damp = w_damp*iSum;
		
		if(obj==b1)  { dst.px = -f-j_damp;   dst.py = 0;   } ;
		else         { dst.px = f+j_damp;   dst.py = 0;   } ;
	}
}
