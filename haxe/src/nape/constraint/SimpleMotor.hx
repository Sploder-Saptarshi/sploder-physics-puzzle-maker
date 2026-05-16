package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.TwoConstraint;
import nape.constraint.Constraint;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.Const;















class SimpleMotor extends TwoConstraint {
	
	public var rate:Float;
	public var ratio:Float;
	
	public var jAcc:Float;
	public var iSum:Float;
	public var jMax:Float;
	
	
	
	public function new(obj1:PhysObj,obj2:PhysObj,rate:Float,ratio:Float) {
		super(obj1,obj2);
		jAcc = 0;
		this.ratio = ratio;
		this.rate = rate;
	}

	
	
	public override function preStep(dt:Float):Bool {
		var inSum = b1.smoment+b2.smoment*ratio*ratio;
		iSum = if(inSum<Const.EPSILON) 0 else 1.0/inSum;
		
		jMax = maxForce*dt;
		
		b1.w -= jAcc*b1.imoment;
		b2.w += jAcc*b2.imoment*ratio;
		
		return false;
	}
	
	
	
	public override function applyImpulse():Bool {
		var wr = b2.w*ratio - b1.w - rate;
		
		var j = -wr*iSum;
		var jOld = jAcc; jAcc += j;
		if(breakable) { if(jAcc*jAcc>jMax*jMax) return true; }
		jAcc = Calc.range(jAcc,-jMax,jMax);
		j = jAcc-jOld;
		
		b1.w -= j*b1.imoment;
		b2.w += j*b2.imoment*ratio;
		
		return false;
	}
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		if(obj==b1)  { dst.px = -jAcc;   dst.py = 0;   } ;
		else         { dst.px = jAcc*ratio;   dst.py = 0;   } ;
	}
}
