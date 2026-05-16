package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.TwoConstraint;
import nape.constraint.Constraint;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.Const;















class RotaryLimitJoint extends TwoConstraint {
	
	public var min:Float;
	public var max:Float;
	
	public var jAcc:Float;
	public var iSum:Float;
	public var jMax:Float;
	public var bias:Float;
	
	public var slack:Bool;
	public var scale:Float;
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,min:Float,max:Float) {
		super(obj1,obj2);
		jAcc = 0;
		this.min = min;
		this.max = max;
	}
	
	
	
	public override function preStep(dt:Float):Bool {
		var dist = b2.a-b1.a;
		var pdist = 0.0;

		if(dist>max) {
			pdist = max-dist;
			scale = 1;
			slack = false;
		}else if(dist<min) {
			pdist = dist-min;
			scale = -1;
			slack = false;
		}else {
			jAcc = 0;
			slack = true;
		}
		
		if(!slack) {
			var inSum = b1.smoment+b2.smoment;
			iSum = if(inSum<Const.EPSILON) 0 else 1.0/inSum;
		
			bias = biasCoef/dt*pdist;
			bias = Calc.clamp(bias,maxBias);
			jMax = maxForce*dt;
		
			b1.w -= jAcc*b1.imoment*scale;
			b2.w += jAcc*b2.imoment*scale;
		}
		
		return false;
	}
	
	
	
	public override function applyImpulse():Bool {
		if(slack) return false;
		
		var wr = b2.w-b1.w;
		
		var j = (bias-wr*scale)*iSum;
		var jOld = jAcc; jAcc += j;
		if(breakable) { if(jAcc*jAcc>jMax*jMax) return true; }
		jAcc = Calc.range(jAcc,-jMax,0);
		
		j = (jAcc-jOld)*scale;
		
		b1.w -= j*b1.imoment;
		b2.w += j*b2.imoment;
		
		return false;
	}
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		if(slack)  { dst.px = 0;   dst.py = 0;   } ;
		if(obj==b1)  { dst.px = -jAcc*scale;   dst.py = 0;   } ;
		else         { dst.px = jAcc*scale;   dst.py = 0;   } ;
	}
	
}
