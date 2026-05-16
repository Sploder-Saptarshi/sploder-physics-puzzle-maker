package nape.constraint;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.constraint.MultiSlideJoint;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.util.FastMath;














class MultiPinJoint extends MultiSlideJoint {
	public function new (objects:Array<PhysObj>,anchors:Array<Vec2>,?ratios:Array<Float>) {
		if(ratios==null) {
			ratios = new Array<Float>();
			for(i in 0...(objects.length>>1)) ratios.push(1.0);
		}
		super(objects,anchors,ratios,0,0);
		
		jointMin = 0;
		var i = 0;
		   var deltax:Float;  var deltay:Float      ;
		for(r in ratios) {
			var ga1 = anchors[i<<1];
			var ga2 = anchors[(i<<1)+1];
			 { deltax = ga1.px-ga2.px; deltay = ga1.py-ga2.py;  } ;
			jointMin +=  FastMath.sqrt( (deltax*deltax + deltay*deltay)   ) *r;
			i++;
		}
		jointMax = jointMin;
	}
}

