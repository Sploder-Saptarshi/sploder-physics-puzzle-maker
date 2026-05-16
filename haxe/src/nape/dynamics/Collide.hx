package nape.dynamics;
import cx.Allocator;
import cx.Algorithm;
import nape.Config;
import nape.Const;
import nape.dynamics.Arbiter;
import nape.dynamics.Contact;
import nape.dynamics.GroupArb;
import nape.dynamics.ObjArb;
import nape.dynamics.SubArbiters;
import nape.util.FastMath;
import nape.geom.AABB;
import nape.geom.Axis;
import nape.geom.Geom;
import nape.geom.GeomPoly;
import nape.geom.GeomVert;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.phys.Body;
import nape.phys.Group;
import nape.phys.Material;
import nape.phys.Particle;
import nape.phys.PhysObj;
import nape.phys.Properties;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.dynamics.Arbiter_false_false_true_true_Shape_Shape;
import nape.dynamics.Arbiter_false_false_true_false_Shape_Particle;
import nape.dynamics.Arbiter_true_true_true_true_Shape_Shape;
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;

//'newfile' define generated imports
import nape.dynamics.Arbiter_false_false_true_true_Shape_Shape;
import nape.dynamics.Arbiter_false_false_true_false_Shape_Particle;
import nape.dynamics.Arbiter_true_true_true_true_Shape_Shape;
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;


















class Collide {
	
	private var alloc:Allocator;
	
	
	
	public function new(ALLOC:Allocator) alloc = ALLOC
	
	
	
	public inline function polyAxisProject(a:Axis, s:Polygon) {
		var min = Const.FMAX;
		  {
	var cxiterator = s.pverts.begin();
	while(cxiterator != s.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
			var k =  (a.nx*v.px + a.ny*v.py) ;
			if (k<min) min = k;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return min-a.d;
	}
	public inline function polyContains(s:Polygon, p:Vec2) {
		return  (! ({
	var ret = false;
	  {
	var cxiterator = s.paxi.begin();
	while(cxiterator != s.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
		if(!( (a.nx*p.px + a.ny*p.py) <=a.d)) {
			ret = true;
			break;
		}
	};
		}
		cxiterator = cxiterator.next;
	}
};
	ret;
})) ;
	}
	public inline function circleContains(c:Circle, p:Vec2 ) {
		   var dx:Float;  var dy:Float      ;  { dx = p.px-c.centre.px; dy = p.py-c.centre.py;  } ;
		return  (dx*dx + dy*dy)   <c.r*c.r;
	}
	public inline function partContains(t:Particle, p:Vec2 ) {
		   var dx:Float;  var dy:Float      ;  { dx = p.px-t.px; dy = p.py-t.py;  } ;
		return  (dx*dx + dy*dy)   <Config.PARTICLE_RADIUS*Config.PARTICLE_RADIUS;
	}
	public inline function polyPartContains(s:Polygon, p:Vec2, nx:Float, ny:Float) {
		var ret = true;
		  {
	var cxiterator = s.paxi.begin();
	while(cxiterator != s.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			if( (a.nx*nx + a.ny*ny) <0.0) { cxiterator = cxiterator.next; continue; };
			if( (a.nx*p.px + a.ny*p.py)  > a.d) {
				ret = false;
				break;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return ret;
	}
	
	
	
	public inline function bodyContains(b:Body,p:Vec2) {
		return  ({
	var ret = false;
	  {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
		if(if(s.type==Shape.CIRCLE) circleContains(s.circle, p)
			else                     polyContains  (s.polygon,p)) {
			ret = true;
			break;
		}
	};
		}
		cxiterator = cxiterator.next;
	}
};
	ret;
});
	}
	
	
	
	public inline function contactCollide_false_false_true_true_Shape_Shape(s1:Shape, s2:Shape, arb:Arbiter_false_false_true_true_Shape_Shape, rev:Bool) {
		
		
		
		
		{
			if(s2.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else if(s1.type == Shape.POLYGON)
					 poly2poly_false_false_true_true(s1.polygon,s2.polygon,arb,rev);
				else circle2poly_false_false_true_true(s1.circle,s2.polygon,arb,rev);
			}else
				return circle2circle_false_false_true_true(s1.circle,s2.circle,arb,rev);
		}
	}public inline function contactCollide_false_false_true_false_Shape_Particle(s1:Shape, s2:Particle, arb:Arbiter_false_false_true_false_Shape_Particle, rev:Bool) {
		
		
		
		
		{
			if (s1.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else poly2particle_false_false_true(s1.polygon, s2, arb);
			} else
				return circle2particle_false_false_true(s1.circle, s2, arb);
		}
	}public inline function contactCollide_true_true_true_true_Shape_Shape(s1:Shape, s2:Shape, arb:Arbiter_true_true_true_true_Shape_Shape, rev:Bool) {
		
		
		
		
		{
			if(s2.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else if(s1.type == Shape.POLYGON)
					 poly2poly_true_true_true_true(s1.polygon,s2.polygon,arb,rev);
				else circle2poly_true_true_true_true(s1.circle,s2.polygon,arb,rev);
			}else
				return circle2circle_true_true_true_true(s1.circle,s2.circle,arb,rev);
		}
	}public inline function contactCollide_true_true_true_false_Shape_Particle(s1:Shape, s2:Particle, arb:Arbiter_true_true_true_false_Shape_Particle, rev:Bool) {
		
		
		
		
		{
			if (s1.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else poly2particle_true_true_true(s1.polygon, s2, arb);
			} else
				return circle2particle_true_true_true(s1.circle, s2, arb);
		}
	}
	
	
	
	public inline function testCollide_Shape_Shape(s1:Shape, s2:Shape) {
		
		
		
		
		{
			if(s2.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else if(s1.type == Shape.POLYGON)
					 poly2poly_test(s1.polygon,s2.polygon);
				else circle2poly_test(s1.circle,s2.polygon);
			}else
				return circle2circle_test(s1.circle,s2.circle);
		}
	}public inline function testCollide_Shape_Particle(s1:Shape, s2:Particle) {
		
		
		
		
		{
			if (s1.type == Shape.POLYGON) {
				return if(!s1.aabb.intersect(s2.aabb)) false;
				else poly2particle_test(s1.polygon, s2);
			} else
				return circle2particle_test(s1.circle, s2);
		}
	}
	
	
	
	private inline function circle2circle_false_false_true_true(c1:Circle,c2:Circle,arb:Arbiter_false_false_true_true_Shape_Shape, rev:Bool) {
		return circle2circle_query_false_false_true_true(c1.centre,c2.centre,arb,c1.r,c2.r,rev);
	}private inline function circle2circle_true_true_true_true(c1:Circle,c2:Circle,arb:Arbiter_true_true_true_true_Shape_Shape, rev:Bool) {
		return circle2circle_query_true_true_true_true(c1.centre,c2.centre,arb,c1.r,c2.r,rev);
	}
	private inline function circle2circle_test(c1:Circle,c2:Circle) {
		return circle2circle_query_test(c1.centre,c2.centre,c1.r,c2.r);
	}
	
	private inline function circle2circle_query_false_false_true_true(p1:Vec2, p2:Vec2, arb:Arbiter_false_false_true_true_Shape_Shape,r1:Float,r2:Float,rev:Bool,?hash:Int=0) {
		var minDist = r1+r2;
		   var px:Float;  var py:Float      ;  { px = p2.px-p1.px; py = p2.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		if(distSqr >= minDist*minDist) return false;
		else {
			var invDist = FastMath.invsqrt(distSqr); 
			var dist = if(invDist<Const.EPSILON) Const.FMAX else 1.0 / invDist;
			var df   = 0.5 + (r1 - 0.5*minDist) * invDist;
			if (rev) arb.injectContact(p1.px + px*df, p1.py + py*df,-px*invDist,-py*invDist, dist-minDist, hash);
			else     arb.injectContact(p1.px + px*df, p1.py + py*df, px*invDist, py*invDist, dist-minDist, hash);
			return true;
		}
	}private inline function circle2circle_query_true_true_true_true(p1:Vec2, p2:Vec2, arb:Arbiter_true_true_true_true_Shape_Shape,r1:Float,r2:Float,rev:Bool,?hash:Int=0) {
		var minDist = r1+r2;
		   var px:Float;  var py:Float      ;  { px = p2.px-p1.px; py = p2.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		if(distSqr >= minDist*minDist) return false;
		else {
			var invDist = FastMath.invsqrt(distSqr); 
			var dist = if(invDist<Const.EPSILON) Const.FMAX else 1.0 / invDist;
			var df   = 0.5 + (r1 - 0.5*minDist) * invDist;
			if (rev) arb.injectContact(p1.px + px*df, p1.py + py*df,-px*invDist,-py*invDist, dist-minDist, hash);
			else     arb.injectContact(p1.px + px*df, p1.py + py*df, px*invDist, py*invDist, dist-minDist, hash);
			return true;
		}
	}
	private inline function circle2circle_query_test(p1:Vec2,p2:Vec2,r1:Float,r2:Float) {
		var minDist = r1+r2;
		   var px:Float;  var py:Float      ;  { px = p2.px-p1.px; py = p2.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		return distSqr < minDist*minDist;
	}
	
	
	
	
	private inline function poly2poly_false_false_true_true(p1:Polygon,p2:Polygon,arb:Arbiter_false_false_true_true_Shape_Shape,rev:Bool) {
		var cont = true;
		
		var max1  = -Const.FMAX;
		var axis1:Axis = null;
		  {
	var cxiterator = p1.paxi.begin();
	while(cxiterator != p1.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p2);
			if (min>0) { cont = false; break; }
			if (min>max1) {
				max1  = min;
				axis1 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
		if(cont) {
			
		var max2  = -Const.FMAX;
		var axis2:Axis = null;
		  {
	var cxiterator = p2.paxi.begin();
	while(cxiterator != p2.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p1);
			if (min>0) { cont = false; break; }
			if (min>max2) {
				max2  = min;
				axis2 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
			if(!cont) return false;
			else {
				if (max1>max2) findVerts_false_false_true_true (arb, p1, p2, axis1,  1, max1, rev);
				else           findVerts_false_false_true_true (arb, p1, p2, axis2, -1, max2, rev);
				return true;
			}
		}else return false;
	}private inline function poly2poly_true_true_true_true(p1:Polygon,p2:Polygon,arb:Arbiter_true_true_true_true_Shape_Shape,rev:Bool) {
		var cont = true;
		
		var max1  = -Const.FMAX;
		var axis1:Axis = null;
		  {
	var cxiterator = p1.paxi.begin();
	while(cxiterator != p1.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p2);
			if (min>0) { cont = false; break; }
			if (min>max1) {
				max1  = min;
				axis1 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
		if(cont) {
			
		var max2  = -Const.FMAX;
		var axis2:Axis = null;
		  {
	var cxiterator = p2.paxi.begin();
	while(cxiterator != p2.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p1);
			if (min>0) { cont = false; break; }
			if (min>max2) {
				max2  = min;
				axis2 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
			if(!cont) return false;
			else {
				if (max1>max2) findVerts_true_true_true_true (arb, p1, p2, axis1,  1, max1, rev);
				else           findVerts_true_true_true_true (arb, p1, p2, axis2, -1, max2, rev);
				return true;
			}
		}else return false;
	}
	private inline function poly2poly_test(p1:Polygon,p2:Polygon) {
		var cont = true;
		
		var max1  = -Const.FMAX;
		var axis1:Axis = null;
		  {
	var cxiterator = p1.paxi.begin();
	while(cxiterator != p1.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p2);
			if (min>0) { cont = false; break; }
			if (min>max1) {
				max1  = min;
				axis1 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
		if(cont) {
			
		var max2  = -Const.FMAX;
		var axis2:Axis = null;
		  {
	var cxiterator = p2.paxi.begin();
	while(cxiterator != p2.paxi.end()) {
		var ax = cxiterator.elem();
		{
			
			{
			var min = polyAxisProject(ax,p1);
			if (min>0) { cont = false; break; }
			if (min>max2) {
				max2  = min;
				axis2 = ax;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
}
	;
			return cont;
		}else return false;
	}
	
	private inline function findVerts_false_false_true_true(arb:Arbiter_false_false_true_true_Shape_Shape,p1:Polygon,p2:Polygon,n:Axis,nCoef:Float,dist:Float,rev:Bool) {
		var id:Int = 0;
		var c = 0;
		   var nx:Float;  var ny:Float      ;  { nx = n.nx*(nCoef); ny = n.ny*(nCoef);  } ;
		var cont = true;
		
		
		
		
			  {
	var cxiterator = p1.pverts.begin();
	while(cxiterator != p1.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyContains(p2,v)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
		if(cont) {
			id = 1000;
			
			  {
	var cxiterator = p2.pverts.begin();
	while(cxiterator != p2.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyContains(p1,v)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
			
			if(c==0) {
				id = 0;
				
			  {
	var cxiterator = p1.pverts.begin();
	while(cxiterator != p1.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyPartContains(p2,v,-nx,-ny)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
				if(cont) {
					id = 1000;
					
			  {
	var cxiterator = p2.pverts.begin();
	while(cxiterator != p2.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyPartContains(p1,v,nx,ny)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
				}
			}
		}
	}private inline function findVerts_true_true_true_true(arb:Arbiter_true_true_true_true_Shape_Shape,p1:Polygon,p2:Polygon,n:Axis,nCoef:Float,dist:Float,rev:Bool) {
		var id:Int = 0;
		var c = 0;
		   var nx:Float;  var ny:Float      ;  { nx = n.nx*(nCoef); ny = n.ny*(nCoef);  } ;
		var cont = true;
		
		
		
		
			  {
	var cxiterator = p1.pverts.begin();
	while(cxiterator != p1.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyContains(p2,v)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
		if(cont) {
			id = 1000;
			
			  {
	var cxiterator = p2.pverts.begin();
	while(cxiterator != p2.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyContains(p1,v)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
			
			if(c==0) {
				id = 0;
				
			  {
	var cxiterator = p1.pverts.begin();
	while(cxiterator != p1.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyPartContains(p2,v,-nx,-ny)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
				if(cont) {
					id = 1000;
					
			  {
	var cxiterator = p2.pverts.begin();
	while(cxiterator != p2.pverts.end()) {
		var v = cxiterator.elem();
		{
			
			{
				if(polyPartContains(p1,v,nx,ny)) {
					if(rev) arb.injectContact(v.px,v.py,-nx,-ny,dist,id);
					else    arb.injectContact(v.px,v.py, nx, ny,dist,id);
					if (++c > 2) { cont = false; break; }
				}
				id++;
			};
		}
		cxiterator = cxiterator.next;
	}
}
		;
				}
			}
		}
	}
	
	
	
	private inline function circle2poly_false_false_true_true(circle:Circle,poly:Polygon,arb:Arbiter_false_false_true_true_Shape_Shape,rev:Bool) {
		var a0 = null, vi = null;
		var cont = true;
		var max = -Const.FMAX;
		
		var v = poly.pverts.begin();
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var dist =  (a.nx*circle.centre.px + a.ny*circle.centre.py)  - a.d - circle.r;
			if (dist>0) { cont = false; break; }
			if (dist>max) {
				max = dist;
				a0 = a;
				vi = v;
			}
			v = v.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		if(cont) {
			var v0 = vi.elem();
			var v1 = if(vi.next==poly.pverts.end()) poly.pverts.begin().elem(); else vi.next.elem();
			
			var dt =  (a0.nx*circle.centre.py - a0.ny*circle.centre.px) ;
			if      (dt <   (a0.nx*v1.py - a0.ny*v1.px) ) return circle2circle_query_false_false_true_true(circle.centre, v1, arb, circle.r, 0, rev, 0);
			else if (dt >=  (a0.nx*v0.py - a0.ny*v0.px) ) return circle2circle_query_false_false_true_true(circle.centre, v0, arb, circle.r, 0, rev, 0);
			else {
				   var nx:Float;  var ny:Float      ;  { nx = a0.nx*(circle.r+max*0.5); ny = a0.ny*(circle.r+max*0.5);  } ;
				   var px:Float;  var py:Float      ;  { px = circle.centre.px-nx; py = circle.centre.py-ny;  } ;
				if(circle.rolling) {
					var dr = circle.r*Config.ROLLING_FRICTION;
					   var tx:Float;  var ty:Float      ;  { tx = -a0.ny*dr;   ty = a0.nx*dr;   } ;
					
					   var p0x:Float;  var p0y:Float      ;  { p0x = px+tx; p0y = py+ty;  } ;
					   var p1x:Float;  var p1y:Float      ;  { p1x = px-tx; p1y = py-ty;  } ;
					if( (p0x*tx + p0y*ty)  >  (v0.px*tx + v0.py*ty) )  { p0x = v0.px; p0y = v0.py; } ;
					if( (p1x*tx + p1y*ty)  <  (v1.px*tx + v1.py*ty) )  { p1x = v1.px; p1y = v1.py; } ;
					 
					   var n0x:Float;  var n0y:Float      ;  { n0x = circle.centre.px-p0x; n0y = circle.centre.py-p0y;  } ;  {
	var d =  (n0x*n0x + n0y*n0y)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	n0x *= imag;
	n0y *= imag;
};
					   var n1x:Float;  var n1y:Float      ;  { n1x = circle.centre.px-p1x; n1y = circle.centre.py-p1y;  } ;  {
	var d =  (n1x*n1x + n1y*n1y)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	n1x *= imag;
	n1y *= imag;
};
					if( (n0x*a0.nx + n0y*a0.ny) <0) {
						 { n0x *= -1;   n0y *= -1;   } ;
						 { n1x *= -1;   n1y *= -1;   } ;
					}
					if(rev) {
						arb.injectContact(p0x,p0y,n0x,n0y,max,0);
						arb.injectContact(p1x,p1y,n1x,n1y,max,1);
					}else {
						arb.injectContact(p0x,p0y,-n0x,-n0y,max,0);
						arb.injectContact(p1x,p1y,-n1x,-n1y,max,1);
					}
				}else {
					if(rev) arb.injectContact(px,py, a0.nx, a0.ny,max,0);
					else    arb.injectContact(px,py,-a0.nx,-a0.ny,max,0);
				}
				return true;
			}
		}else return false;
	}private inline function circle2poly_true_true_true_true(circle:Circle,poly:Polygon,arb:Arbiter_true_true_true_true_Shape_Shape,rev:Bool) {
		var a0 = null, vi = null;
		var cont = true;
		var max = -Const.FMAX;
		
		var v = poly.pverts.begin();
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var dist =  (a.nx*circle.centre.px + a.ny*circle.centre.py)  - a.d - circle.r;
			if (dist>0) { cont = false; break; }
			if (dist>max) {
				max = dist;
				a0 = a;
				vi = v;
			}
			v = v.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		if(cont) {
			var v0 = vi.elem();
			var v1 = if(vi.next==poly.pverts.end()) poly.pverts.begin().elem(); else vi.next.elem();
			
			var dt =  (a0.nx*circle.centre.py - a0.ny*circle.centre.px) ;
			if      (dt <   (a0.nx*v1.py - a0.ny*v1.px) ) return circle2circle_query_true_true_true_true(circle.centre, v1, arb, circle.r, 0, rev, 0);
			else if (dt >=  (a0.nx*v0.py - a0.ny*v0.px) ) return circle2circle_query_true_true_true_true(circle.centre, v0, arb, circle.r, 0, rev, 0);
			else {
				   var nx:Float;  var ny:Float      ;  { nx = a0.nx*(circle.r+max*0.5); ny = a0.ny*(circle.r+max*0.5);  } ;
				   var px:Float;  var py:Float      ;  { px = circle.centre.px-nx; py = circle.centre.py-ny;  } ;
				if(circle.rolling) {
					var dr = circle.r*Config.ROLLING_FRICTION;
					   var tx:Float;  var ty:Float      ;  { tx = -a0.ny*dr;   ty = a0.nx*dr;   } ;
					
					   var p0x:Float;  var p0y:Float      ;  { p0x = px+tx; p0y = py+ty;  } ;
					   var p1x:Float;  var p1y:Float      ;  { p1x = px-tx; p1y = py-ty;  } ;
					if( (p0x*tx + p0y*ty)  >  (v0.px*tx + v0.py*ty) )  { p0x = v0.px; p0y = v0.py; } ;
					if( (p1x*tx + p1y*ty)  <  (v1.px*tx + v1.py*ty) )  { p1x = v1.px; p1y = v1.py; } ;
					 
					   var n0x:Float;  var n0y:Float      ;  { n0x = circle.centre.px-p0x; n0y = circle.centre.py-p0y;  } ;  {
	var d =  (n0x*n0x + n0y*n0y)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	n0x *= imag;
	n0y *= imag;
};
					   var n1x:Float;  var n1y:Float      ;  { n1x = circle.centre.px-p1x; n1y = circle.centre.py-p1y;  } ;  {
	var d =  (n1x*n1x + n1y*n1y)   ;
	var imag = if(d<Const.EPSILON) 0 else FastMath.invsqrt(d);
	n1x *= imag;
	n1y *= imag;
};
					if( (n0x*a0.nx + n0y*a0.ny) <0) {
						 { n0x *= -1;   n0y *= -1;   } ;
						 { n1x *= -1;   n1y *= -1;   } ;
					}
					if(rev) {
						arb.injectContact(p0x,p0y,n0x,n0y,max,0);
						arb.injectContact(p1x,p1y,n1x,n1y,max,1);
					}else {
						arb.injectContact(p0x,p0y,-n0x,-n0y,max,0);
						arb.injectContact(p1x,p1y,-n1x,-n1y,max,1);
					}
				}else {
					if(rev) arb.injectContact(px,py, a0.nx, a0.ny,max,0);
					else    arb.injectContact(px,py,-a0.nx,-a0.ny,max,0);
				}
				return true;
			}
		}else return false;
	}
	private inline function circle2poly_test(circle:Circle,poly:Polygon) {
		var a0 = null, vi = null;
		var cont = true;
		var max = -Const.FMAX;
		
		var v = poly.pverts.begin();
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var dist =  (a.nx*circle.centre.px + a.ny*circle.centre.py)  - a.d - circle.r;
			if (dist>0) { cont = false; break; }
			if (dist>max) {
				max = dist;
				a0 = a;
				vi = v;
			}
			v = v.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		if(cont) {
			var v0 = vi.elem();
			var v1 = if(vi.next==poly.pverts.end()) poly.pverts.begin().elem(); else vi.next.elem();
			
			var dt =  (a0.nx*circle.centre.py - a0.ny*circle.centre.px) ;
			if      (dt <   (a0.nx*v1.py - a0.ny*v1.px) ) return circle2circle_query_test(circle.centre, v1, circle.r, 0);
			else if (dt >=  (a0.nx*v0.py - a0.ny*v0.px) ) return circle2circle_query_test(circle.centre, v0, circle.r, 0);
			else    return true;
		}else return false;
	}
	
	
	
	private inline function particleQuery_false_false_true(arb:Arbiter_false_false_true_false_Shape_Particle,p1:Vec2,part:Particle,r1:Float) {
		var minDist = r1 + Config.PARTICLE_RADIUS;
		   var px:Float;  var py:Float      ;  { px = part.px-p1.px; py = part.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		if(distSqr >= minDist*minDist)
			return false;
		else {
			var invDist = FastMath.invsqrt(distSqr); 
			var dist = if(invDist<Const.EPSILON) Const.FMAX else 1.0 / invDist;
			var df = 0.5 + (r1 - 0.5*minDist) * invDist;
			
			arb.injectContact(p1.px+px*df,p1.py+py*df,px*invDist,py*invDist,dist-minDist,0);
			return true;
		}
	}private inline function particleQuery_true_true_true(arb:Arbiter_true_true_true_false_Shape_Particle,p1:Vec2,part:Particle,r1:Float) {
		var minDist = r1 + Config.PARTICLE_RADIUS;
		   var px:Float;  var py:Float      ;  { px = part.px-p1.px; py = part.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		if(distSqr >= minDist*minDist)
			return false;
		else {
			var invDist = FastMath.invsqrt(distSqr); 
			var dist = if(invDist<Const.EPSILON) Const.FMAX else 1.0 / invDist;
			var df = 0.5 + (r1 - 0.5*minDist) * invDist;
			
			arb.injectContact(p1.px+px*df,p1.py+py*df,px*invDist,py*invDist,dist-minDist,0);
			return true;
		}
	}
	private inline function particleQuery_test(p1:Vec2,part:Particle,r1:Float) {
		var minDist = r1 + Config.PARTICLE_RADIUS;
		   var px:Float;  var py:Float      ;  { px = part.px-p1.px; py = part.py-p1.py;  } ;
		var distSqr =  (px*px + py*py)   ;
		return distSqr < minDist*minDist;
	}
	
	private inline function circle2particle_false_false_true(circ:Circle,part:Particle,arb:Arbiter_false_false_true_false_Shape_Particle) {
		return particleQuery_false_false_true(arb,circ.centre,part,circ.r);
	}private inline function circle2particle_true_true_true(circ:Circle,part:Particle,arb:Arbiter_true_true_true_false_Shape_Particle) {
		return particleQuery_true_true_true(arb,circ.centre,part,circ.r);
	}
	private inline function circle2particle_test(circ:Circle,part:Particle) {
		return particleQuery_test(circ.centre,part,circ.r);
	}
	
	
	
	private inline function poly2particle_false_false_true(poly:Polygon,part:Particle,arb:Arbiter_false_false_true_false_Shape_Particle) {
		var max  = -Const.FMAX;
		var axis = null;
		var cont = true;
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var min =  (a.nx*part.px + a.ny*part.py)  - a.d - Config.PARTICLE_RADIUS;
			if (min>0) { cont = false; break; }
			if (min>max) {
				max  = min;
				axis = a;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		if(cont) {
			   var nx:Float;  var ny:Float      ;  { nx = axis.nx*(Config.PARTICLE_RADIUS + max*0.5); ny = axis.ny*(Config.PARTICLE_RADIUS + max*0.5);  } ;
			arb.injectContact(part.px-nx,part.py-ny,axis.nx,axis.ny,max,0);
			return true;
		}else return false;
	}private inline function poly2particle_true_true_true(poly:Polygon,part:Particle,arb:Arbiter_true_true_true_false_Shape_Particle) {
		var max  = -Const.FMAX;
		var axis = null;
		var cont = true;
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var min =  (a.nx*part.px + a.ny*part.py)  - a.d - Config.PARTICLE_RADIUS;
			if (min>0) { cont = false; break; }
			if (min>max) {
				max  = min;
				axis = a;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		if(cont) {
			   var nx:Float;  var ny:Float      ;  { nx = axis.nx*(Config.PARTICLE_RADIUS + max*0.5); ny = axis.ny*(Config.PARTICLE_RADIUS + max*0.5);  } ;
			arb.injectContact(part.px-nx,part.py-ny,axis.nx,axis.ny,max,0);
			return true;
		}else return false;
	}
	private inline function poly2particle_test(poly:Polygon,part:Particle) {
		var max  = -Const.FMAX;
		var axis = null;
		var cont = true;
		  {
	var cxiterator = poly.paxi.begin();
	while(cxiterator != poly.paxi.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var min =  (a.nx*part.px + a.ny*part.py)  - a.d - Config.PARTICLE_RADIUS;
			if (min>0) { cont = false; break; }
			if (min>max) {
				max  = min;
				axis = a;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return cont;
	}
}



class RayCast {
	
	static public inline var FAIL:Float = 10.0; 
	static public inline function rayCircle(r:Ray,c:Circle) {
		   var acx:Float;  var acy:Float      ;  { acx = r.ax-c.centre.px; acy = r.ay-c.centre.py;  } ;
		var A =  (r.vx*r.vx + r.vy*r.vy)   ;
		var B = 2* (r.vx*acx + r.vy*acy) ;
		var C =  (acx*acx + acy*acy)    - c.r*c.r;
		
		var D = B*B-4*A*C;
		if(D>=0) {
			D = FastMath.sqrt(D);
			A = 1/(2*A);
			
			var t = (-B-D)*A;
			if(t<0) t += 2*A*D;
			if(t<0 || t>1) return RayCast.FAIL;
			else return t;
		}else
			return RayCast.FAIL;
	}
	
	
	
	static private inline function rayPoly(r:Ray,p:Polygon,n:Vec2) {
		var ret = RayCast.FAIL;
		
		var pre:Vec2 = null;
		var ite = p.paxi.begin();
		var pax = p.paxi.front();
		var rneg:Bool = false;
		  {
	var cxiterator = p.pverts.begin();
	while(cxiterator != p.pverts.end()) {
		var cur = cxiterator.elem();
		{
			
			{
			if(pre!=null) {
				var neg:Bool;
				var t;  {
		   var qx:Float;  var qy:Float      ;  { qx = cur.px-pre.px; qy = cur.py-pre.py;  } ;
		var denom =  (r.vx*qy - r.vy*qx) ;
		neg = denom<0;
		if(denom==0) t = RayCast.FAIL;
		else {
			denom = 1/denom;
			   var bax:Float;  var bay:Float      ;  { bax = pre.px-r.ax; bay = pre.py-r.ay;  } ;
			
			var t0 =  (bax*qy - bay*qx) *denom;
			if(!(t0<0||t0>1)) {
				var s =  (bax*r.vy - bay*r.vx) *denom;
				if(!(s<0||s>1)) t = t0;
				else t = RayCast.FAIL;
			}else t = RayCast.FAIL;
		}
	};
				if(t<ret) {
					ret = t;
					 { n.px = pax.nx; n.py = pax.ny; } ;
					rneg = neg;
				}
			}
			pre = cur;
			pax = ite.elem();
			ite = ite.next;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		var neg:Bool;
		var t;  {
		   var qx:Float;  var qy:Float      ;  { qx = p.pverts.front().px-pre.px; qy = p.pverts.front().py-pre.py;  } ;
		var denom =  (r.vx*qy - r.vy*qx) ;
		neg = denom<0;
		if(denom==0) t = RayCast.FAIL;
		else {
			denom = 1/denom;
			   var bax:Float;  var bay:Float      ;  { bax = pre.px-r.ax; bay = pre.py-r.ay;  } ;
			
			var t0 =  (bax*qy - bay*qx) *denom;
			if(!(t0<0||t0>1)) {
				var s =  (bax*r.vy - bay*r.vx) *denom;
				if(!(s<0||s>1)) t = t0;
				else t = RayCast.FAIL;
			}else t = RayCast.FAIL;
		}
	};
		if(t<ret) {
			ret = t;
			 { n.px = pax.nx; n.py = pax.ny; } ;
			rneg = neg;
		}
		
		if(rneg)  {
	n.px = -n.px;
	n.py = -n.py;
};
		
		return ret;
	}
	
	static public inline function rayPolygon(r:Ray,p:Polygon,n:Vec2) {
		var aabb = p.aabb;
		if(aabb.contains2(r.ax,r.ay)) {
			return rayPoly(r,p,n);
		}else {
			var int = false;
			{
				if(r.vx>0) {
					var t = (aabb.minx-r.ax)/r.vx;
					if(!(t<0||t>1)) {
						var y = r.ay+r.vy*t;
						if(!(y<aabb.miny||y>aabb.maxy)) int = true;
					}
				}else if(r.vx<0) {
					var t = (aabb.maxx-r.ax)/r.vx;
					if(!(t<0||t>1)) {
						var y = r.ay+r.vy*t;
						if(!(y<aabb.miny||y>aabb.maxy)) int = true;
					}
				}
				
				if(!int) {
					if(r.vy>0) {
						var t = (aabb.miny-r.ay)/r.vy;
						if(!(t<0||t>1)) {
							var x = r.ax+r.vx*t;
							if(!(x<aabb.minx||x>aabb.maxx)) int = true;
						}
					}else if(r.vy<0) {
						var t = (aabb.maxy-r.ay)/r.vy;
						if(!(t<0||t>1)) {
							var x = r.ax+r.vx*t;
							if(!(x<aabb.minx||x>aabb.maxx)) int = true;
						}
					}
				}
			}
			
			if(int) {
				return rayPoly(r,p,n);
			}else
				return RayCast.FAIL;
		}
	}
}

