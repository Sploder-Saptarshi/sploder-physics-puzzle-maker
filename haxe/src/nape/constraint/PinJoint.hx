package nape.constraint;
import nape.phys.PhysObj;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.constraint.SlideJoint;
import nape.util.FastMath;













class PinJoint extends SlideJoint {
	public function new (obj1:PhysObj,obj2:PhysObj,anchor1:Vec2,anchor2:Vec2) {
		super(obj1,obj2,anchor1,anchor2,0,0);
		
		   var deltax:Float;  var deltay:Float      ;  { deltax = anchor2.px-anchor1.px; deltay = anchor2.py-anchor1.py;  } ;
		jointMin = jointMax =  FastMath.sqrt( (deltax*deltax + deltay*deltay)   ) ;
	}
}
