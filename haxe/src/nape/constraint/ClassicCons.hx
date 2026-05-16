package nape.constraint;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.phys.PhysObj;
import nape.constraint.TwoConstraint;
import nape.constraint.Constraint;











class ClassicCons extends TwoConstraint {
	 public var a1x:Float; public var a1y:Float     ;  public var r1x:Float; public var r1y:Float     ;
	 public var a2x:Float; public var a2y:Float     ;  public var r2x:Float; public var r2y:Float     ;
	
	public function new (a:PhysObj,b:PhysObj,A1:Vec2,A2:Vec2) {
		super(a,b);
		 {
	   var tx:Float;  var ty:Float      ;
	 { tx = A1.px-b1.px; ty = A1.py-b1.py;  } ;
	 { a1x = tx*b1.roty+ty*b1.rotx; a1y = ty*b1.roty-tx*b1.rotx;} ;
};
		 {
	   var tx:Float;  var ty:Float      ;
	 { tx = A2.px-b2.px; ty = A2.py-b2.py;  } ;
	 { a2x = tx*b2.roty+ty*b2.rotx; a2y = ty*b2.roty-tx*b2.rotx;} ;
};
	}
}

