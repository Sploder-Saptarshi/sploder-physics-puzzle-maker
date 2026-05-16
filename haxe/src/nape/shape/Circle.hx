package nape.shape;
import nape.shape.Shape;
import nape.phys.Material;
import nape.geom.VecMath;
import nape.geom.Vec2;












class Circle extends Shape {
	
	public var r     :Float; 
	public var offset:Vec2;
	public var centre:Vec2;
	
	public var rolling:Bool;
	
	
	
	public function new (radius:Float, ?offset:Vec2, ?material:Material,?collision_group:Int=0xffffff,?sensor_group:Int=0) {
		super(Shape.CIRCLE,material,collision_group,sensor_group);
		circle = this;
		
		r = radius;
		if(offset==null) this.offset = new Vec2(0,0);
		else             this.offset = offset.clone();
		centre = this.offset.clone();
		rolling = true;
		
		area = Math.PI * r * r;
	}
	
	
	
	public inline function inertia():Float return r * r * 0.5 + offset.lsq()
	
	
	
	public inline function update() {
		transform(offset,centre);
		aabb.setExtents2(centre, r, r);
		body.aabb.combine(aabb);
	}
	
	
	
	public inline function shift(x:Vec2) {
		 { offset.px += x.px; offset.py += x.py; } ;
		update();
	}
	

}
