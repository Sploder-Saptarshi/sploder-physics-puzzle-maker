package nape.phys;
import nape.phys.PhysObj;
import nape.phys.Properties;
import nape.phys.Material;
import nape.geom.VecMath;
import nape.Const;
import nape.Config;














class Particle extends PhysObj {
	
	public var material:Material;

	public var group:Int;
	public var sensor:Int;
	
	
	
	public function new(?x:Float=0,?y:Float=0,?mass:Float=1,?vel_x:Float=0,?vel_y:Float=0,?material:Material,?collision_group:Int=0xffffffff,?sensor_group:Int=0,?properties:Properties) {
		super(x,y,false,properties);
		group = collision_group;
		sensor = sensor_group;
		 { vx = vel_x; vy = vel_y; } ;
		particle = this;
		
		this.mass = gmass = mass;
		if (mass > Const.FMAX) imass = 0.0;
		else                   imass = 1.0 / mass;
		cmass = smass = imass;
		
		cmoment = smoment = imoment = 0;
		moment = Const.POSINF;
		w = t = 0;
		rotx = 0;
		roty = 1;
		
		this.material = if (material==null) Config.DEFAULT_MATERIAL else material;
	}
	
	
	
	public override function update() {
		updatePosition(0);
	}
	
	public inline function updateVelocity(dt:Float) updateVelocity_linear(dt)
	public inline function updatePosition(dt:Float) {
		updatePosition_linear(dt);
		 { aabb.minx = px-Config.PARTICLE_RADIUS;   aabb.miny = py-Config.PARTICLE_RADIUS;   } ;
		 { aabb.maxx = px+Config.PARTICLE_RADIUS;   aabb.maxy = py+Config.PARTICLE_RADIUS;   } ;
	}

}
