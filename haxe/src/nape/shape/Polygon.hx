package nape.shape;
import cx.MixList;
import cx.Algorithm;
import nape.shape.Shape;
import nape.phys.Material;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.geom.Axis;
import nape.geom.GeomPoly;
import nape.Const;


















class Polygon extends Shape {
	
	public var lverts: Vec2;
	public var pverts: Vec2;
	
	public var laxi: Axis;
	public var paxi: Axis;
	
	
	
	public function new (vertices:Dynamic, ?offset:Vec2, ?material:Material, ?collision_group:Int=0xffffff,?sensor_group:Int=0) {
		super(Shape.POLYGON,material,collision_group,sensor_group);
		polygon = this;
		
		lverts = new  Vec2();
		pverts = new  Vec2();
		laxi   = new  Axis();
		paxi   = new  Axis();
		
		if(offset==null) offset = new Vec2();
		
		if(Std.is(vertices,Array)) {
			var vl:Array<Vec2> = cast vertices;
			
			var p0 = null;
			var count = vl.length;
			area = 0.0;
			for(i in 0...count) {
				var u = vl[i].clone();
				var v = vl[(i + 1) % count];
				var w = vl[(i + 2) % count];
				area += v.px * (w.py - u.py);
				
				   var nx:Float;  var ny:Float      ;  { nx = u.px-v.px; ny = u.py-v.py;  } ;
				 {
	 {
	var d =  (nx*nx + ny*ny)   ;
	var imag = if(d<Const.EPSILON) 0 else 1.0 / Math.sqrt(d);
	nx *= imag;
	ny *= imag;
};
	var t = nx;
	nx = -ny;
	ny = t;
};
				 { u.px += offset.px; u.py += offset.py; } 
				var a = new Axis(nx,ny,  (nx*u.px + ny*u.py) );
				
				if(i!=0) {
					lverts.add(u);
					pverts.add(u.clone());
				}else p0 = u;
				
				laxi.add(a);
				paxi.add(a.clone());
			}
			lverts.add(p0);
			pverts.add(p0.clone());
			area *= 0.5;
		}else if(Std.is(vertices,GeomPoly)) {
			var vl:GeomPoly = cast vertices;
			var p0 = null;
			area = 0.0;
			var points = vl.points;
			var beg = points.begin();
			var end = points.end();
			var ui = beg;
			while(ui!=end) {
				var next = ui.next;
				var vi = if(next   ==end) beg else next;
				var wi = if(vi.next==end) beg else vi.next;
				
				var u = ui.elem().p.clone();
				var v = vi.elem().p;
				var w = wi.elem().p;
				
				area += v.px * (w.py - u.py);
				
				   var nx:Float;  var ny:Float      ;  { nx = u.px-v.px; ny = u.py-v.py;  } ;
				 {
	 {
	var d =  (nx*nx + ny*ny)   ;
	var imag = if(d<Const.EPSILON) 0 else 1.0 / Math.sqrt(d);
	nx *= imag;
	ny *= imag;
};
	var t = nx;
	nx = -ny;
	ny = t;
};
				 { u.px += offset.px; u.py += offset.py; } 
				var a = new Axis(nx,ny,  (nx*u.px + ny*u.py) );
				
				if(ui!=beg) {
					lverts.add(u);
					pverts.add(u.clone());
				}else p0 = u;
				
				laxi.add(a);
				paxi.add(a.clone());
				
				ui = next;
			}
			lverts.add(p0);
			pverts.add(p0.clone());
			area *= 0.5;
		}
	}
	
	
	
	public inline function inertia():Float {
		var s1 = 0.; var s2 = 0.;
		  {
	var cxiterator = lverts.begin();
	while(cxiterator != lverts.end()) {
		var u = cxiterator.elem();
		{
			
			{
			var v = if(cxiterator.next==lverts.end()) lverts.begin().elem() else cxiterator.next.elem();
			var a = u.cross(v); var b = v.lsq() + v.dot(u) + u.lsq();
			s1 += a * b; s2 += a;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return s1 / (6 * s2);
	}
	
	
	
	public function update() {
		var body = body;
		var aabb = aabb;
		
		var lv = lverts.begin();
		var pv = pverts.begin();
		
		
		transform(lv.elem(),pv.elem());
		aabb.minx = aabb.maxx = pv.elem().px;
		aabb.miny = aabb.maxy = pv.elem().py;
		
		pv = pv.next;
		 {
	var cxiterator = lv.next;
	while(cxiterator != lverts.end()) {
		var l = cxiterator.elem();
		{
			
			{
			var p = pv.elem();
			transform(l,p);
			if ( p.px < aabb.minx ) aabb.minx = p.px;
			if ( p.px > aabb.maxx ) aabb.maxx = p.px;
			if ( p.py < aabb.miny ) aabb.miny = p.py;
			if ( p.py > aabb.maxy ) aabb.maxy = p.py;
			pv = pv.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		
		var pa = paxi.begin();
		  {
	var cxiterator = laxi.begin();
	while(cxiterator != laxi.end()) {
		var l = cxiterator.elem();
		{
			
			{
			var p = pa.elem();
			p.nx = body.ROTXs(l.nx,l.ny);
			p.ny = body.ROTYs(l.nx,l.ny);
			p.d =  (body.px*p.nx + body.py*p.ny)  + l.d;
			pa = pa.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		body.aabb.combine(aabb);
	}
	
	
	
	public inline function COM():Vec2 {
		var area = 0.0;
		var cx = 0.0;
		var cy = 0.0;
		
		var p0:Vec2 = null; var p1:Vec2 = null;
		  {
	var cxiterator = lverts.begin();
	while(cxiterator != lverts.end()) {
		var p2 = cxiterator.elem();
		{
			
			{
			if(p0!=null && p1!=null)
				area += p1.px * (p2.py - p0.py);
			if(p1!=null) {
				var cf =  (p1.px*p2.py - p1.py*p2.px) ;
				cx += (p1.px+p2.px)*cf;
				cy += (p1.py+p2.py)*cf;
			}
			p0 = p1; p1 = p2;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		var p2 = lverts.front();
		area += p1.px * (p2.py - p0.py);
		{
			var cf =  (p1.px*p2.py - p1.py*p2.px) ;
			cx += (p1.px+p2.px)*cf;
			cy += (p1.py+p2.py)*cf;
		}
		
		p0 = p1; p1 = p2; p2 = lverts.begin().next.elem();
		area += p1.px * (p2.py - p0.py);
		area = 1/(3*area);
		return new Vec2(area*cx,area*cy);
	}
	
	
	
	public inline function shift(x:Vec2) {
		var aite = laxi.begin();
		  {
	var cxiterator = lverts.begin();
	while(cxiterator != lverts.end()) {
		var l = cxiterator.elem();
		{
			
			{
			 { l.px += x.px; l.py += x.py; } ;
			var ax = aite.elem();
			ax.d =  (ax.nx*l.px + ax.ny*l.py) ;
			aite = aite.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		update();
	}
}
