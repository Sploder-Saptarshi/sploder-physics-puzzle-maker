package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.MultiSlideJoint;
import nape.geom.Vec2;












class PulleyJoint extends MultiSlideJoint {
	public function new (obj1:PhysObj,obj2:PhysObj,obj3:PhysObj,
                         anchor1:Vec2,   anchor2:Vec2,   anchor3_1:Vec2,anchor3_2:Vec2,
                         ratio:Float, min:Float,max:Float)
	{
		super([obj1,obj3,  obj2,obj3 ],
		      [anchor1,anchor3_1, anchor2,anchor3_2],
			  [1.0,    ratio ],
			  min,max
			 );
	}
}
