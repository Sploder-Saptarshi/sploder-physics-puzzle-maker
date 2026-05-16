package nape.constraint;
import nape.geom.VecMath;
import nape.constraint.Anchor;










class MPConsPair {
	public var a1:Anchor;
	public var a2:Anchor;
	 public var nx:Float; public var ny:Float     ;
	
	public var coef:Float;
	
	public function new(A1:Anchor,A2:Anchor,CF:Float) {
		a1 = A1;
		a2 = A2;
		coef = CF;
	}
}
