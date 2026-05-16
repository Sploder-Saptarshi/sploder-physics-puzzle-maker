package nape.space;
import cx.FastList;
import cx.Algorithm;
import cx.Allocator;
import nape.shape.Shape;
import nape.geom.Vec2;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.VecMath;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.dynamics.Collide;
import nape.Const;
import nape.Config;
import nape.util.FastMath;
import nape.callbacks.Callback;

//'newfile' define generated imports
import cx.CxFastList_Shape;
























class BruteSpace extends Space {
	
	public var static_shapes :CxFastList_Shape;
	public var dynamic_shapes:CxFastList_Shape;
	
	
	
	public function new (?gravity:Vec2) {
		super(gravity);
		sleeping = false;
		
		static_shapes  = new CxFastList_Shape();
		dynamic_shapes = new CxFastList_Shape();
	}
	
	
	
	public override function addObject(o:PhysObj):Void {
		if(o.added_to_space) return;
		objects.add(o); o.added_to_space = true;
		add_aux(o);
		
		o.visible = o.pvisible = false;
		
		if (o.isBody) {
			var body = o.body;
			if (body.isStatic = (body.imass == 0 && body.imoment == 0)) {
				addStatic(body);
				body.updatePosition(0);
				  {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
					static_shapes.add(s);
					s.updateShape();
				};
		}
		cxiterator = cxiterator.next;
	}
};
			}else {
				addDynamic(body);
				   {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var i = cxiterator.elem();
		{
			
			dynamic_shapes.add(i);
		}
		cxiterator = cxiterator.next;
	}
};
				addProperties(o.properties);
			}
			registerBody(body);
		}else {
			var part = o.particle;
			addParticle(part);
			registerBase(part);
			addProperties(o.properties);
		}
	}
	public override function removeObject(o:PhysObj):Void {
		if(objects.remove(o)) {
			rem_aux(o);
			
			o.added_to_space = false;
			if(o.pvisible || o.visible) {
				visible.remove(o);
				 {
	if(o.cbHide) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_HIDE;
		cb.obj = o;
		callbacks.add(cb);
	}else if(o.cbHideDef)
		Config.DEFAULT_CB_HIDE(o);
};
			}
			o.visible = o.pvisible = false;
		
			if (o.isBody) {
				var body = o.body;
				if (body.isStatic) {
					removeStatic(body);
					   {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var i = cxiterator.elem();
		{
			
			static_shapes.remove(i);
		}
		cxiterator = cxiterator.next;
	}
};
				}else {
					removeDynamic(body);
					   {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var i = cxiterator.elem();
		{
			
			dynamic_shapes.remove(i);
		}
		cxiterator = cxiterator.next;
	}
};
					removeProperties(o.properties);
				}
			}else {
				var part = o.particle;
				removeParticle(part);
				removeProperties(o.properties);
			}
			removeConstraints(o);
		}
	}
	
	
	
	public override function broadphase():Void {
		  {
	var cxiterator = static_shapes.begin();
	while(cxiterator != static_shapes.end()) {
		var stat = cxiterator.elem();
		{
			
			{
			  {
	var cxiterator = dynamic_shapes.begin();
	while(cxiterator != dynamic_shapes.end()) {
		var dyn = cxiterator.elem();
		{
			
			narrowPhase_false_false_true_true_Shape_Shape(stat,dyn );
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = particles.begin();
	while(cxiterator != particles.end()) {
		var part = cxiterator.elem();
		{
			
			narrowPhase_false_false_true_false_Shape_Particle(stat,part);
		}
		cxiterator = cxiterator.next;
	}
};
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  {
	var cxiterator = dynamic_shapes.begin();
	while(cxiterator != dynamic_shapes.end()) {
		var i = cxiterator.elem();
		{
			
			{
			 {
	var cxiterator = cxiterator.next;
	while(cxiterator != dynamic_shapes.end()) {
		var j = cxiterator.elem();
		{
			
			narrowPhase_true_true_true_true_Shape_Shape(i,j);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = particles.begin();
	while(cxiterator != particles.end()) {
		var part = cxiterator.elem();
		{
			
			narrowPhase_true_true_true_false_Shape_Particle(i,part);
		}
		cxiterator = cxiterator.next;
	}
};
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	public override function objectAtPoint(x:Float,y:Float):PhysObj {
		var p = new Vec2(x,y);
		  {
	var cxiterator = dynamics.begin();
	while(cxiterator != dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			{
			if(collide.bodyContains(b.body,p))
				return b;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  {
	var cxiterator = statics.begin();
	while(cxiterator != statics.end()) {
		var s = cxiterator.elem();
		{
			
			{
			if(collide.bodyContains(s.body,p))
				return s;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  {
	var cxiterator = particles.begin();
	while(cxiterator != particles.end()) {
		var t = cxiterator.elem();
		{
			
			{
			if(collide.partContains(t,p))
				return t;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return null;
	}
	
	
	
	public override function rayCast(r:Ray):RayResult {
		var mint:Float = RayCast.FAIL;
		var mino:PhysObj = null;
		var mins:Shape = null;
		     var polynx:Float = 0; var polyny:Float = 0 ;
		var tempn:Vec2 = new Vec2();
		
		
		   {
	var cxiterator = dynamics.begin();
	while(cxiterator != dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			{
			  {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
				var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
				        else                       RayCast.rayPolygon(r,s.polygon,tempn);
				if(t<mint) {
					mint = t;
					mino = b;
					mins = s;
					 { polynx = tempn.px; polyny = tempn.py; } ;
				}
			};
		}
		cxiterator = cxiterator.next;
	}
};
		};
		}
		cxiterator = cxiterator.next;
	}
};
		   {
	var cxiterator = statics.begin();
	while(cxiterator != statics.end()) {
		var b = cxiterator.elem();
		{
			
			{
			  {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
				var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
				        else                       RayCast.rayPolygon(r,s.polygon,tempn);
				if(t<mint) {
					mint = t;
					mino = b;
					mins = s;
					 { polynx = tempn.px; polyny = tempn.py; } ;
				}
			};
		}
		cxiterator = cxiterator.next;
	}
};
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		if(mint!=RayCast.FAIL) {
			var ret = new RayResult();
			ret.obj = mino;
			ret.shape = mins;
			 { ret.px = r.ax; ret.py = r.ay; } ;
			 { ret.px += r.vx*(mint); ret.py += r.vy*(mint); } ;
			if(ret.shape.type == Shape.CIRCLE) {
				 { ret.nx = ret.px-ret.shape.circle.centre.px; ret.ny = ret.py-ret.shape.circle.centre.py;  } ;
				 {
	var d =  (ret.nx*ret.nx + ret.ny*ret.ny)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	ret.nx *= imag;
	ret.ny *= imag;
};
			}else {
				 { ret.nx = polynx; ret.ny = polyny; } ;
			}
			ret.t = mint;
			return ret;
		}else
			return null;
	}
	
	
	
	public override function visitate() {
		var vi = visible.begin();
		var pi = null;
		
		  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var o = cxiterator.elem();
		{
			
			{
			if(o.aabb.intersect(viewport)) {
				if(!o.pvisible) {
					o.pvisible = true;
					visible.add(o);
					 {
	if(o.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = o;
		callbacks.add(cb);
	}else if(o.cbShowDef)
		Config.DEFAULT_CB_SHOW(o);
};
					if(pi==null) pi = visible.begin();
				}
				o.visible = true;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		
		 {
	var cxiterator = vi;
	while(cxiterator != visible.end()) {
		var o = cxiterator.elem();
		{
			
			{
			if(!o.visible) {
				o.pvisible = false;
				 {
	if(o.cbHide) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_HIDE;
		cb.obj = o;
		callbacks.add(cb);
	}else if(o.cbHideDef)
		Config.DEFAULT_CB_HIDE(o);
};
				cxiterator = visible.erase(pi,cxiterator);
				continue;
			}
			pi = cxiterator;
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
}
