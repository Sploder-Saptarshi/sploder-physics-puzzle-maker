package nape.constraint;
import nape.geom.Vec2;
import nape.phys.PhysObj;










class Anchor {
	public var la:Vec2;
	public var pa:Vec2;
	
	public var b:PhysObj;
	
	public function new(LA:Vec2,PA:Vec2,B:PhysObj) {
		la = LA;
		pa = PA;
		this.b = B;
	}
}
