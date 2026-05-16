package nape.geom;
import nape.geom.VecMath;
import nape.phys.PhysObj;
import nape.shape.Shape;













class RayResult {
	
	 public var px:Float; public var py:Float     ;
	
	 public var nx:Float; public var ny:Float     ;
	
	
	public var t:Float;
	
	
	public var obj  :PhysObj;
	
	public var shape:Shape;
	
	public function new() {}
}
