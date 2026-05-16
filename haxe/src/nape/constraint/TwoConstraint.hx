package nape.constraint;
import cx.FastList;
import nape.phys.PhysObj;
import nape.space.Space;

//'newfile' define generated imports
import cx.CxFastList_PhysObj;












class TwoConstraint extends Constraint {
	public var b1:PhysObj;
	public var b2:PhysObj;
	
	public function new(a:PhysObj,b:PhysObj) {
		super();
		b1 = a;
		b2 = b;
	}
	
	public override function addToBodies() {
		b1.p_constraints.add(this);
		b2.p_constraints.add(this);
	}
	public override function removeFromBodies() {
		b1.p_constraints.remove(this);
		b2.p_constraints.remove(this);
	}
	
	public override function wakeBodies(space:Space) {
		space.wakeObject(b1);
		space.wakeObject(b2);
	}
	
	public override function bodyPairExists(a:PhysObj,b:PhysObj)
		return (b1==a&&b2==b)||(b1==b&&b2==a)
	
	public override function body_list() {
		var ret = new CxFastList_PhysObj();
		ret.add(b1);
		ret.add(b2);
		return ret;
	}
	
	public override function anyBodiesAwake()
		return !b1.sleep || !b2.sleep
	
	public override function disallowBodySleep() {
		if(b1.id!=0) b1.evslp = 0;
		if(b2.id!=0) b2.evslp = 0;
	}
}
