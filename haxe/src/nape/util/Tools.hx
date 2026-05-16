package nape.util;
import flash.display.Sprite;
import cx.Allocator;
import cx.Algorithm;
import nape.phys.PhysObj;
import nape.phys.Body;
import nape.phys.Particle;
import nape.phys.Material;
import nape.phys.Properties;
import nape.geom.GeomPoly;
import nape.geom.Geom;
import nape.geom.VecMath;
import nape.geom.Vec2;
import nape.shape.Polygon;
import nape.shape.Circle;
import nape.Config;

























class Tools {
	
	public static inline function col(m:Material) {
		var cr = Std.int(m.eCoef * 0xff);    if (cr < 0) cr = 0; if(cr>0xff) cr = 0xff;
		var cg = Std.int(m.dyn_fric * 0x40); if (cg < 0) cg = 0; if(cg>0xff) cg = 0xff;
		var cb = Std.int(m.density  * 0x40); if (cb < 0) cb = 0; if(cb>0xff) cb = 0xff;
		return (cr << 16) | (cg << 8) | cb;
	}
	
	
	
	public static function createCircle(
		x:Float, y:Float,
		radius:Float,
		vel_x:Float, vel_y:Float, vel_w:Float,
		
		?_static:Bool = false,
		?rotate_graphic:Bool = true,
		?material:Material,
		?collision_group:Int=0xffffffff,
		?sensor_group:Int=0,
		?properties:Properties)
	{
		var body = new Body(x,y,properties);
		var circle = new Circle(radius, null, material, collision_group, sensor_group);
		body.addShape(circle);
		body.calcProperties();
		body.setVel(vel_x,vel_y,vel_w);
		
		var spr = new Sprite();
		var g = spr.graphics;
		
		g.lineStyle(1,col(circle.material),1);
		g.drawCircle(0,0,radius);
		body.assignGraphic(spr);
		
		if(!_static && rotate_graphic) {
			g.moveTo(0.3*radius, 0);
			g.lineTo(radius, 0);
		}else {
			spr.cacheAsBitmap = true;
			body.rotateGraphic = false;
			body.cbWakeDef = false;
			body.cbSleepDef = false;
		}
		
		if(_static) body.stopAll();
		
		body.update();
		return body;
	}
	
	
	
	public static function createBox(
		x:Float, y:Float,
		width:Float, height:Float,
		vel_x:Float, vel_y:Float, vel_w:Float,
		
		?_static:Bool = false,
		?material:Material,
		?collision_group:Int=0xffffffff,
		?sensor_group:Int=0,
		?properties:Properties)
	{
		var body = new Body(x,y,properties);
		var w = width*0.5;
		var h = height*0.5;
		var poly = new Polygon(
			[new Vec2(-w,h),
			 new Vec2(-w,-h),
			 new Vec2(w,-h),
			 new Vec2(w,h)
			],
			null,
			material,
			collision_group,
			sensor_group
		);
		body.addShape(poly);
		body.calcProperties();
		body.setVel(vel_x,vel_y,vel_w);
		
		var spr = new Sprite();
		var g = spr.graphics;
		
		g.lineStyle(1, col(poly.material), 0.5);
		g.moveTo( -w, -h);
		g.lineTo(  w, -h);
		g.lineTo(  w,  h);
		g.lineTo( -w,  h);
		g.lineTo( -w, -h);
		body.assignGraphic(spr);
		
		if(_static) body.stopAll();
		
		body.update();
		return body;
	}
	
	
	
	public static function createPolyCircle(
		x:Float, y:Float,
		radius_x:Float, radius_y:Float,
		vel_x:Float, vel_y:Float, vel_w:Float,
		
		?_static:Bool = false,
		?angleIndicator:Bool = true,
		?material:Material,
		?collision_group:Int=0xffffffff,
		?sensor_group:Int = 0,
		?properties:Properties)
	{
		var body = new Body(x,y,properties);
		var poly = new Array<Vec2>();
		var ii = Std.int(2*Math.PI/Math.acos(1-0.6/ FastMath.sqrt( (radius_x*radius_x + radius_y*radius_y)   ) ));
		for(i in 0...ii) {
			var ang = Math.PI*2/ii * i;
			poly.push(new Vec2(radius_x*Math.cos(ang), radius_y*Math.sin(ang)));
		}
		
		var shape = new Polygon(poly, null, material, collision_group, sensor_group);
		body.addShape(shape);
		body.calcProperties();
		body.setVel(vel_x, vel_y, vel_w);
		
		var spr = new Sprite();
		var g = spr.graphics;
		
		g.lineStyle(1, col(shape.material), 1);
		g.moveTo(poly[0].px,poly[0].py);
		for(i in 0...ii) {
			var j = (i+1)%ii;
			g.lineTo(poly[j].px,poly[j].py);
		}
		
		if(!_static && angleIndicator) {
			g.moveTo(0.3*radius_x, 0);
			g.lineTo(radius_x, 0);
		}
		body.assignGraphic(spr);
		
		if(_static) body.stopAll();
		
		body.update();
		return body;
	}
	
	
	
	public static function createConcave(
		polygon:GeomPoly,
		vel_x:Float,vel_y:Float,vel_w:Float,
		
		?_static:Bool=false,
		?material:Material,
		?collision_group:Int = 0xffffffff,
		?sensor_group:Int = 0,
		?properties:Properties)
	{
		var body = new Body(0,0,properties);
		var spr = new Sprite();
		var g = spr.graphics;
		body.setVel(vel_x,vel_y,vel_w);
		
		var opoly = polygon.clone();
		var tris = polygon.decompose();
		  {
	var cxiterator = tris.begin();
	while(cxiterator != tris.end()) {
		var tri = cxiterator.elem();
		{
			
			{
			if(!tri.points.empty()) {
				var poly = new Polygon(tri, null, material, collision_group, sensor_group);
				body.addShape(poly);
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		if(tris.empty()) return null;
		
		var com = body.COM();
		 {
	com.px = -com.px;
	com.py = -com.py;
};
		body.shift(com);
		body.calcProperties();
		
		g.lineStyle(1, col(body.shapes.front().material), 1);
		var points = opoly.points;
		var ui = points.begin();
		var u = ui.elem();
		g.moveTo(u.p.px+com.px, u.p.py+com.py);
		 {
	var cxiterator = ui.next;
	while(cxiterator != points.end()) {
		var u = cxiterator.elem();
		{
			
			g.lineTo(u.p.px+com.px,u.p.py+com.py);
		}
		cxiterator = cxiterator.next;
	}
};
		g.lineTo(u.p.px+com.px,u.p.py+com.py);
		body.assignGraphic(spr);
		
		if(_static) body.stopAll();
		
		body.setPos(-com.px,-com.py);
		body.update();
		return body;
	}
	
	
	
	public static function createParticle(
		x:Float, y:Float,
		mass:Float,
		vel_x:Float, vel_y:Float,
		
		?_static:Bool=false,
		?material:Material,
		?collision_group:Int=0xffffffff,
		?sensor_group:Int=0,
		?properties:Properties)
	{
		var part = new Particle(
			x,y,
			mass,
			vel_x,vel_y,
			material,
			collision_group,
			sensor_group,
			properties
		);
		
		var spr = new Sprite();
		var g = spr.graphics;
		g.lineStyle(1,col(part.material),1);
		g.drawCircle(0,0,Config.PARTICLE_RADIUS);
		part.assignGraphic(spr);
		
		if(_static) part.stopAll();
		
		part.update();
		return part;
	}
	
	
	
	public static function createRegular(
		x:Float,y:Float,
		radius_x:Float, radius_y:Float,
		edge_count:Int,
		vel_x:Float,vel_y:Float,vel_w:Float,
		
		?_static:Bool=false,
		?angleIndicator:Bool=true,
		?material:Material,
		?collision_group:Int=0xffffffff,
		?sensor_group:Int=0,
		?properties:Properties)
	{
		var body = new Body(x,y,properties);
		
		var poly = new Array<Vec2>();
		var angi = Math.PI*2/edge_count;
		for(i in 0...edge_count) {
			var ang = angi*i;
			poly.push(new Vec2(radius_x*Math.cos(ang),radius_y*Math.sin(ang)));
		}
		
		var shape = new Polygon(poly, null, material,collision_group, sensor_group);
		body.addShape(shape);
		body.calcProperties();
		body.setVel(vel_x,vel_y,vel_w);
		
		var spr = new Sprite();
		var g = spr.graphics;
		
		g.lineStyle(1, col(shape.material), 1);
		g.moveTo(poly[0].px,poly[0].py);
		for(i in 0...edge_count) {
			var j = (i+1)%edge_count;
			g.lineTo(poly[j].px,poly[j].py);
		}
		if(!_static&&angleIndicator) {
			g.moveTo(0.3*radius_x,0);
			g.lineTo(radius_x,0);
		}
		body.assignGraphic(spr);
		
		if (_static) body.stopAll();
		
		body.update();
		return body;
	}
}
