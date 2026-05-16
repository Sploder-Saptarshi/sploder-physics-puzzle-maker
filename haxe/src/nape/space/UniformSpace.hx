package nape.space;
import cx.FastList;
import cx.Algorithm;
import cx.Allocator;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.VecMath;
import nape.phys.PhysObj;
import nape.phys.Particle;
import nape.space.Space;
import nape.dynamics.Collide;
import nape.Const;
import nape.Config;
import nape.util.FastMath;
import nape.util.Array2;
import nape.callbacks.Callback;

//'newfile' define generated imports
import cx.CxFastList_Shape;
import cx.CxFastList_Particle;
import cx.CxFastList_Body;
import cx.CxFastList_UniformCell;




























class UniformCell {
	
	public var static_shapes :CxFastList_Shape;
	public var dynamic_shapes:CxFastList_Shape;
	public var particles     :CxFastList_Particle;
	public var dynamics      :CxFastList_Body;
	public var statics       :CxFastList_Body;
	
	public var stamp:Int;
	public var broad:Bool;
	
	
	
	
		
	public function new () {
		stamp = 0;
		broad = false;
		
		static_shapes  = new CxFastList_Shape   ();
		dynamic_shapes = new CxFastList_Shape   ();
		particles      = new CxFastList_Particle();
		dynamics       = new CxFastList_Body    ();
		statics        = new CxFastList_Body    ();
	}
	
	
		
	public inline function clear() {
		dynamic_shapes.clear();
		particles.clear();
		dynamics.clear();
	}
	
}



class UniformSpace extends Space {
	
	public var cells:Array2<UniformCell>;
	public var broad:CxFastList_UniformCell;
	
	public var x0:Float;
	public var y0:Float;
	public var wid:Int; public var hei:Int;
	public var idim:Float; public var dim:Float;
	
	
	
	public function new (domain:AABB, cell_dimensions:Float, ?gravity:Vec2) {
		super(gravity);
		sleeping = false;
		
		x0 = domain.minx;
		y0 = domain.miny;
		idim = 1 / cell_dimensions;
		dim = cell_dimensions;
		wid = Math.ceil(domain.width() * idim);
		hei = Math.ceil(domain.height() * idim);
		
		cells = new Array2<UniformCell>(wid,hei);
		for (x in 0...wid) {
			for (y in 0...hei) 
				cells.set(x, y, new UniformCell());
		}
		
		broad = new CxFastList_UniformCell();
		
		cellShape = new Polygon([new Vec2(0,0), new Vec2(dim,0), new Vec2(dim,dim), new Vec2(0,dim)], new Vec2());
	}
	
	
	
	
	
	
	public override function clear_special() {
		broad.clear();
		for(x in 0...wid) {
			for (y in 0...hei) {
				var cell = cells.get(x,y);
				cell.clear();
				cell.static_shapes.clear();
				cell.statics.clear();
				cell.broad = false;
			}
		}
	}
	
	
	
	public override function addObject(o:PhysObj):Void {
		if(o.added_to_space) return;
		add_aux(o);
		o.added_to_space = true;
		objects.add(o);
		
		o.visible = o.pvisible = false;
		
		if (o.isBody) {
			var body = o.body;
			if (body.isStatic = (body.smass == 0 && body.smoment == 0)) {
				addStatic(body);
				body.updatePosition(0);
				  {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
					s.updateShape();
					syncStatic(s);
				};
		}
		cxiterator = cxiterator.next;
	}
};
			}
			else {
				addDynamic(body);
				  {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			syncShape(s,false);
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
			syncParticle(part,false);
			addProperties(o.properties);
			registerBase(part);
		}
	}
	public override function removeObject(o:PhysObj):Void {
		if(!objects.remove(o)) return;
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
		var s = cxiterator.elem();
		{
			
			{
					
	var au0 = ((s.aabb.minx-x0)*idim); var u0 = Math.floor(au0); if(au0==u0) u0--;
	var av0 = ((s.aabb.miny-y0)*idim); var v0 = Math.floor(av0); if(av0==v0) v0--;
	var v1 = Math.floor((s.aabb.maxy - y0)*idim) + 1;
	var u1 = Math.floor((s.aabb.maxx - x0)*idim) + 1;
	
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

					for (v in v0...v1) {
						for (u in u0...u1) {
							var c = cells.get(u, v);
							if(c.static_shapes.remove(s)) {
								if(c.stamp<stamp) c.clear();
								broadcell(c);
								c.statics.remove(body);
							}
						}
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
			}else {
				removeDynamic(body);
				  {
	var cxiterator = body.shapes.begin();
	while(cxiterator != body.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
					
	var au0 = ((s.aabb.minx-x0)*idim); var u0 = Math.floor(au0); if(au0==u0) u0--;
	var av0 = ((s.aabb.miny-y0)*idim); var v0 = Math.floor(av0); if(av0==v0) v0--;
	var v1 = Math.floor((s.aabb.maxy - y0)*idim) + 1;
	var u1 = Math.floor((s.aabb.maxx - x0)*idim) + 1;
	
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

					for (v in v0...v1) {
						for (u in u0...u1) {
							var c = cells.get(u, v);
							if(c.stamp!=stamp) continue;
							
							if(c.dynamic_shapes.remove(s)) {
								c.dynamics.remove(body);
								broadcell(c);
							}
						}
					}
				};
		}
		cxiterator = cxiterator.next;
	}
};
				removeProperties(o.properties);
			}
		}else {
			var p = o.particle;
			removeParticle(p);
			
	var u0 = Math.floor((p.px-Config.PARTICLE_RADIUS - x0) * idim); var u1 = Math.floor((p.px+Config.PARTICLE_RADIUS - x0) * idim) + 1;
	var v0 = Math.floor((p.py-Config.PARTICLE_RADIUS - y0) * idim); var v1 = Math.floor((p.py+Config.PARTICLE_RADIUS - y0) * idim) + 1;
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

			for (u in u0...u1) {
				for (v in v0...v1) {
					var c = cells.get(u, v);
					if(c.stamp!=stamp) continue;
							
					if(c.particles.remove(p))
						broadcell(c);
				}
			}
			removeProperties(o.properties);
		}
		removeConstraints(o);
	}
	
	
	
	public var cellShape:Polygon;
	public inline function syncStatic(s:Shape):Void {
		
	var au0 = ((s.aabb.minx-x0)*idim); var u0 = Math.floor(au0); if(au0==u0) u0--;
	var av0 = ((s.aabb.miny-y0)*idim); var v0 = Math.floor(av0); if(av0==v0) v0--;
	var v1 = Math.floor((s.aabb.maxy - y0)*idim) + 1;
	var u1 = Math.floor((s.aabb.maxx - x0)*idim) + 1;
	
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

		
		var pverts = cellShape.pverts;
		var aabb   = cellShape.aabb;
		var paxi   = cellShape.paxi;
		var laxi   = cellShape.laxi;
		
		for (u in u0...u1) {
			for (v in v0...v1) {
				var c = cells.get(u, v);
				
				var ax = x0+u*dim;
				var ay = y0+v*dim;
				
				var ite = pverts.begin();
				var p:Vec2;
				p = ite.elem();  { p.px = ax;   p.py = ay;   } ;         ite = ite.next;
				p = ite.elem();  { p.px = ax;   p.py = ay+dim;   } ;     ite = ite.next;
				p = ite.elem();  { p.px = ax+dim;   p.py = ay+dim;   } ; ite = ite.next;
				p = ite.elem();  { p.px = ax+dim;   p.py = ay;   } ;
				aabb.minx = ax;
				aabb.maxx = ax+dim;
				aabb.miny = ay;
				aabb.maxy = ay+dim;
				
				var lte = laxi.begin();
				  {
	var cxiterator = paxi.begin();
	while(cxiterator != paxi.end()) {
		var pax = cxiterator.elem();
		{
			
			{
					pax.d =  (ax*pax.nx + ay*pax.ny)  + lte.elem().d;
					lte = lte.next;
				};
		}
		cxiterator = cxiterator.next;
	}
};
				
				var b = s.body;
				if(!c.statics.has(b)) c.statics.add(b);
				
				if(!collide.testCollide_Shape_Shape(s,cellShape)) continue;
				
				if (c.stamp < stamp) { c.clear(); c.stamp = stamp; }
				c.static_shapes.add(s);
				broadcell(c);
			}
		}
	}

	public override function syncShape(s:Shape,check:Bool):Bool {
		
	var au0 = ((s.aabb.minx-x0)*idim); var u0 = Math.floor(au0); if(au0==u0) u0--;
	var av0 = ((s.aabb.miny-y0)*idim); var v0 = Math.floor(av0); if(av0==v0) v0--;
	var v1 = Math.floor((s.aabb.maxy - y0)*idim) + 1;
	var u1 = Math.floor((s.aabb.maxx - x0)*idim) + 1;
	
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

		var ret = true;
		for (u in u0...u1) {
			for (v in v0...v1) {
				var c = cells.get(u, v);
				if (c.stamp < stamp) { c.clear(); c.stamp = stamp; }
				
				if(!check || !c.dynamic_shapes.has(s))
					c.dynamic_shapes.add(s);
				
				var b = s.body;
				if(!c.dynamics.has(b)) c.dynamics.add(b);
					
				broadcell(c);
				ret = false;
			}
		}
		return ret;
	}
	public override function syncParticle(p:Particle,check:Bool):Bool {
		
	var u0 = Math.floor((p.px-Config.PARTICLE_RADIUS - x0) * idim); var u1 = Math.floor((p.px+Config.PARTICLE_RADIUS - x0) * idim) + 1;
	var v0 = Math.floor((p.py-Config.PARTICLE_RADIUS - y0) * idim); var v1 = Math.floor((p.py+Config.PARTICLE_RADIUS - y0) * idim) + 1;
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;

		var ret = true;
		for (u in u0...u1) {
			for (v in v0...v1) {
				var c = cells.get(u, v);
				if (c.stamp < stamp) { c.clear(); c.stamp = stamp; }
				if(!check || !c.particles.has(p))
					c.particles.add(p);
				broadcell(c);
				ret = false;
			}
		}
		return ret;
	}
	
	public inline function broadcell(c:UniformCell):Void {
		if(!c.broad) {
			if (!c.static_shapes.empty()) {
				if(!c.dynamic_shapes.empty() || !c.particles.empty()) {
					c.broad = true;
					broad.add(c);
				}
			}else if (!c.dynamic_shapes.empty()) {
				if (c.dynamic_shapes.begin().next != c.dynamic_shapes.end() || !c.particles.empty()) {
					c.broad = true;
					broad.add(c);
				}
			}
		}
	}
	
	
	
	public override function broadphase():Void {
		while(!broad.empty()) {
			var c = broad.front();
			
			
			c.broad = false;
			  {
	var cxiterator = c.static_shapes.begin();
	while(cxiterator != c.static_shapes.end()) {
		var stat = cxiterator.elem();
		{
			
			{
				  {
	var cxiterator = c.dynamic_shapes.begin();
	while(cxiterator != c.dynamic_shapes.end()) {
		var dyn = cxiterator.elem();
		{
			
			narrowPhase_false_false_true_true_Shape_Shape(stat,dyn);
		}
		cxiterator = cxiterator.next;
	}
};
				  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var part = cxiterator.elem();
		{
			
			narrowPhase_false_false_true_false_Shape_Particle(stat, part);
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
	var cxiterator = c.dynamic_shapes.begin();
	while(cxiterator != c.dynamic_shapes.end()) {
		var i = cxiterator.elem();
		{
			
			{
				 {
	var cxiterator = cxiterator.next;
	while(cxiterator != c.dynamic_shapes.end()) {
		var j = cxiterator.elem();
		{
			
			narrowPhase_true_true_true_true_Shape_Shape(i,j);
		}
		cxiterator = cxiterator.next;
	}
};
				  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
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
			broad.pop();
		}
	}
	
	
	
	public override function objectAtPoint(x:Float,y:Float):PhysObj {
		var u = Std.int((x - x0) * idim);
		var v = Std.int((y - y0) * idim);
		if(u<0||v<0||u>=wid||v>=hei) return null;
		
		var p = alloc.CxAlloc_Vec2();  { p.px = x; p.py = y; } ;
		
		var c = cells.get(u,v);
		if(c.stamp<stamp) {
			  {
	var cxiterator = c.static_shapes.begin();
	while(cxiterator != c.static_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
				var b = s.body;
				if(collide.bodyContains(b,p))
					return b;
			};
		}
		cxiterator = cxiterator.next;
	}
};
			return null;
		}
		
		  {
	var cxiterator = c.dynamic_shapes.begin();
	while(cxiterator != c.dynamic_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var b = s.body;
			if(collide.bodyContains(b,p))
				return b;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  {
	var cxiterator = c.static_shapes.begin();
	while(cxiterator != c.static_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var b = s.body;
			if(collide.bodyContains(b,p))
				return b;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
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
		
		var u0 = Math.floor((r.ax-x0)*idim);
		var v0 = Math.floor((r.ay-y0)*idim);
		
		if(u0<0||v0<0||u0>=wid||v0>=hei) {
			var int = false;
			var ct = 16.0;
			{
				var y1 = y0+hei*dim;
				var x1 = x0+wid*dim;
				if(r.vx>0) {
					var t = (x0-r.ax)/r.vx;
					if(t<ct && !(t<0||t>1)) {
						var y = r.ay+r.vy*t;
						if(!(y<y0||y>y1)) ct = t;
					}
				}else if(r.vx<0) {
					var t = (x1-r.ax)/r.vx;
					if(t<ct && !(t<0||t>1)) {
						var y = r.ay+r.vy*t;
						if(!(y<y0||y>y1)) ct = t;
					}
				}
				
				if(r.vy>0) {
					var t = (y0-r.ay)/r.vy;
					if(t<ct && !(t<0||t>1)) {
						var x = r.ax+r.vx*t;
						if(!(x<x0||x>x1)) ct = t;
					}
				}else if(r.vy<0) {
					var t = (y1-r.ay)/r.vy;
					if(t<ct && !(t<0||t>1)) {
						var x = r.ax+r.vx*t;
						if(!(x<x0||x>x1)) ct = t;
					}
				}
			}
			if(!(ct<0||ct>1)) {
				 { r.ax += r.vx*(ct); r.ay += r.vy*(ct); } ;
				 { r.vx *= (1-ct);   r.vy *= (1-ct);   } ;
				u0 = Math.floor((r.ax-x0)*idim);
				v0 = Math.floor((r.ay-y0)*idim);
				if(u0==wid) u0 = wid-1;
				if(v0==hei) v0 = hei-1;
			}else return null;
		}
		
		var g0x = x0 + u0*dim;
		var g0y = y0 + v0*dim;
		
		var tx0 = Const.FMAX;
		var ty0 = Const.FMAX;
		var du = 0; var dv = 0;
		var dtx = 0.0;
		var dty = 0.0;
		if(r.vx>0) {
			du = 1;
			tx0 = (g0x+dim-r.ax)/r.vx;
			dtx = dim/r.vx;
		}else if(r.vx<0) {
			du = -1;
			tx0 = (g0x-r.ax)/r.vx;
			dtx = -dim/r.vx;
		}
		if(r.vy>0) {
			dv = 1;
			ty0 = (g0y+dim-r.ay)/r.vy;
			dty = dim/r.vy;
		}else if(r.vy<0) {
			dv = -1;
			ty0 = (g0y-r.ay)/r.vy;
			dty = -dim/r.vy;
		}
		
		var ct = 0.0; var cu = u0; var cv = v0;
		var tx = tx0-dtx;
		var ty = ty0-dty;
		
		var ret:RayResult = null;
		while(ct<1 && cu>=0 && cv>=0 && cu<wid && cv<hei) {
			var nt; var nu; var nv;
			var ntx = tx+dtx;
			var nty = ty+dty;
			if(ntx<nty) {
				nt = tx = ntx;
				nu = cu+du;
				nv = cv;
			}else {
				nt = ty = nty;
				nu = cu;
				nv = cv+dv;
			}
			if(nt>1) nt = 1;
			
			var cell = cells.get(cu,cv);
			if(cell.stamp==stamp) {
				if( {
		var mint:Float = RayCast.FAIL;
		var mino:PhysObj = null;
		var mins:Shape = null;
		     var polynx:Float = 0; var polyny:Float = 0 ;
		var tempn:Vec2 = new Vec2();
		
		
		if(!false)    {
	var cxiterator = cell.dynamic_shapes.begin();
	while(cxiterator != cell.dynamic_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
			        else                       RayCast.rayPolygon(r,s.polygon,tempn);
			if(t<mint) {
				mint = t;
				mino = s.body;
				mins = s;
				 { polynx = tempn.px; polyny = tempn.py; } ;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		   {
	var cxiterator = cell.static_shapes.begin();
	while(cxiterator != cell.static_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
			        else                       RayCast.rayPolygon(r,s.polygon,tempn);
			if(t<mint) {
				mint = t;
				mino = s.body;
				mins = s;
				 { polynx = tempn.px; polyny = tempn.py; } ;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		var retv;
		if(!(mint<ct||mint>nt) && mint!=RayCast.FAIL) {
			if(ret==null) ret = new RayResult();
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
			retv = true;
		}else retv = false;
		
		retv;
	})
					return ret;
			}else if(!cell.static_shapes.empty()) {
				if( {
		var mint:Float = RayCast.FAIL;
		var mino:PhysObj = null;
		var mins:Shape = null;
		     var polynx:Float = 0; var polyny:Float = 0 ;
		var tempn:Vec2 = new Vec2();
		
		
		if(!true)    {
	var cxiterator = cell.dynamic_shapes.begin();
	while(cxiterator != cell.dynamic_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
			        else                       RayCast.rayPolygon(r,s.polygon,tempn);
			if(t<mint) {
				mint = t;
				mino = s.body;
				mins = s;
				 { polynx = tempn.px; polyny = tempn.py; } ;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		   {
	var cxiterator = cell.static_shapes.begin();
	while(cxiterator != cell.static_shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
			var t = if(s.type == Shape.CIRCLE) RayCast.rayCircle (r,s.circle );
			        else                       RayCast.rayPolygon(r,s.polygon,tempn);
			if(t<mint) {
				mint = t;
				mino = s.body;
				mins = s;
				 { polynx = tempn.px; polyny = tempn.py; } ;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		var retv;
		if(!(mint<ct||mint>nt) && mint!=RayCast.FAIL) {
			if(ret==null) ret = new RayResult();
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
			retv = true;
		}else retv = false;
		
		retv;
	})
					return ret;
			}
			
			cu = nu;
			cv = nv;
			ct = nt;
		}
		
		return null;
	}
	
	
	
	public override function visitate()  {
	
	var au0 = ((viewport.minx-x0)*idim); var u0 = Math.floor(au0); if(au0==u0) u0--;
	var av0 = ((viewport.miny-y0)*idim); var v0 = Math.floor(av0); if(av0==v0) v0--;
	var v1 = Math.floor((viewport.maxy - y0)*idim) + 1;
	var u1 = Math.floor((viewport.maxx - x0)*idim) + 1;
	
	if (u0 < 0) u0 = 0; if(u1 >= wid) u1 = wid;
	if (v0 < 0) v0 = 0; if(v1 >= hei) v1 = hei;


	var pi = null;
	var vi = visible.begin();
	
	
	
	
	
	
	
	
	
	
	for(u in (u0+1)...(u1-1)) {
		for(v in (v0+1)...(v1-1)) {
			var c = cells.get(u,v);
			 {
		if(c.stamp==stamp ) {
			  {
	var cxiterator = c.dynamics.begin();
	while(cxiterator != c.dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			 {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var b = cxiterator.elem();
		{
			
			 {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		  {
	var cxiterator = c.statics.begin();
	while(cxiterator != c.statics.end()) {
		var b = cxiterator.elem();
		{
			
			 {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
	};
		}
	}
	for(u in u0...u1) {
		var c = cells.get(u,v0);
		 {
		if(c.stamp==stamp ) {
			  {
	var cxiterator = c.dynamics.begin();
	while(cxiterator != c.dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		  {
	var cxiterator = c.statics.begin();
	while(cxiterator != c.statics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
	};
		c = cells.get(u,v1-1);
		 {
		if(c.stamp==stamp ) {
			  {
	var cxiterator = c.dynamics.begin();
	while(cxiterator != c.dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		  {
	var cxiterator = c.statics.begin();
	while(cxiterator != c.statics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
	};
	}
	for(v in (v0+1)...(v1-1)) {
		var c = cells.get(u0,v);
		 {
		if(c.stamp==stamp ) {
			  {
	var cxiterator = c.dynamics.begin();
	while(cxiterator != c.dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		  {
	var cxiterator = c.statics.begin();
	while(cxiterator != c.statics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
	};
		c = cells.get(u1-1,v);
		 {
		if(c.stamp==stamp ) {
			  {
	var cxiterator = c.dynamics.begin();
	while(cxiterator != c.dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = c.particles.begin();
	while(cxiterator != c.particles.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		  {
	var cxiterator = c.statics.begin();
	while(cxiterator != c.statics.end()) {
		var b = cxiterator.elem();
		{
			
			if(viewport.intersect(b.aabb))  {
		if(!b.pvisible) {
			b.pvisible = true;
			visible.add(b);
			if(pi==null) pi = visible.begin();
			 {
	if(b.cbShow) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SHOW;
		cb.obj = b;
		callbacks.add(cb);
	}else if(b.cbShowDef)
		Config.DEFAULT_CB_SHOW(b);
};
		}
		b.visible = true;
	};
		}
		cxiterator = cxiterator.next;
	}
};
	};
	}
	
	
	
	
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

