package nape.geom;
import nape.geom.VecMath;
import nape.geom.Vec2;












class Ray {
	
	 public var ax:Float; public var ay:Float     ;
	
	 public var vx:Float; public var vy:Float     ;
	
	
	public function new(origin:Vec2,direction:Vec2) {
		 { ax = origin.px; ay = origin.py; } ;
		 { vx = direction.px; vy = direction.py; } ;
	}
}
