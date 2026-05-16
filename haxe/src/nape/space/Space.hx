package nape.space;
import cx.Allocator;
import cx.Algorithm;
import cx.FastList;
import nape.geom.VecMath;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.geom.Ray;
import nape.geom.RayResult;
import nape.phys.Body;
import nape.phys.PhysObj;
import nape.phys.Particle;
import nape.phys.Properties;
import nape.phys.Group;
import nape.callbacks.Callbackable;
import nape.callbacks.Callback;
import nape.shape.Shape;
import nape.dynamics.Arbiter;
import nape.dynamics.ObjArb;
import nape.dynamics.GroupArb;
import nape.dynamics.Collide;
import nape.dynamics.SubArbiters;
import nape.constraint.Constraint;
import nape.util.IdRef;
import nape.util.FastMath;
import nape.Const;
import nape.Config;
import nape.space.UniformSleepSpace;

//'newfile' define generated imports
import nape.dynamics.Arbiter_false_false_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_false_false_true_true_Shape_Shape;
import cx.CxFastList_Arbiter;
import cx.CxFastList_ObjArb;
import nape.dynamics.Arbiter_false_false_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_false_false_true_false_Shape_Particle;
import nape.dynamics.Arbiter_true_true_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_true_true_true_true_Shape_Shape;
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastList_Body;
import cx.CxFastList_Particle;
import cx.CxFastList_PhysObj;
import cx.CxFastList_Constraint;
import cx.CxFastList_Group;
import cx.CxFastList_Properties;
import cx.CxFastAllocList_Callback;




































class Space {
	
	 public var gravityx:Float; public var gravityy:Float     ;
	
	public var statics  :CxFastList_Body;
	public var dynamics :CxFastList_Body;
	public var particles:CxFastList_Particle;
	
	public var objects:CxFastList_PhysObj; 
	
	public var visible:CxFastList_PhysObj;
	public var viewport:AABB;
	public var use_viewport:Bool;
	
	public var s_arbiters_false_false_true_true_Shape_Shape:CxFastList_Arbiter_false_false_true_true_Shape_Shape;
		
		
		
		
		
		
		
		
		
		
		
		
	public var s_arbiters_false_false_true_false_Shape_Particle:CxFastList_Arbiter_false_false_true_false_Shape_Particle;
		
		
		
		
		
		
		
		
		
		
		
		
	public var s_arbiters_true_true_true_true_Shape_Shape:CxFastList_Arbiter_true_true_true_true_Shape_Shape;
		
		
		
		
		
		
		
		
		
		
		
		
	public var s_arbiters_true_true_true_false_Shape_Particle:CxFastList_Arbiter_true_true_true_false_Shape_Particle;
		
		
		
		
		
		
		
		
		
		
		
		
	
	
	public var STATIC:Body;
	public var constraints:CxFastList_Constraint;
	public var groups:CxFastList_Group;
		
	public var map_arb_false_false_true_true_Shape_Shape:IntHash<Arbiter_false_false_true_true_Shape_Shape>;
		
	public var map_arb_false_false_true_false_Shape_Particle:IntHash<Arbiter_false_false_true_false_Shape_Particle>;
		
	public var map_arb_true_true_true_true_Shape_Shape:IntHash<Arbiter_true_true_true_true_Shape_Shape>;
		
	public var map_arb_true_true_true_false_Shape_Particle:IntHash<Arbiter_true_true_true_false_Shape_Particle>;
		
	
	public var map_objarb  :IntHash<ObjArb>;
	public var map_grouparb:IntHash<GroupArb>;
	
	public var properties:CxFastList_Properties;
	
	public var stamp:Int;
	public var sleeping:Bool;
	
	public var alloc:Allocator;
	public var collide:Collide;
	
	public var callbacks:CxFastAllocList_Callback;
	public var register:Bool;
	
	public var _dt:Float; 
	
	
	
	public function new(?G:Vec2) {
		FastMath.init();
		
		alloc   = Allocator.GLOBAL;
		collide = new Collide(alloc);
		stamp   = 0;
		
		visible = new CxFastList_PhysObj(alloc);
		viewport = new AABB(-Const.POSINF,-Const.POSINF,Const.POSINF,Const.POSINF);
		
		if(G==null)  { gravityx = 0;   gravityy = 0;   }  else  { gravityx = G.px; gravityy = G.py; } ;
		
		
			map_arb_false_false_true_true_Shape_Shape    = new IntHash<Arbiter_false_false_true_true_Shape_Shape>();
			s_arbiters_false_false_true_true_Shape_Shape = new CxFastList_Arbiter_false_false_true_true_Shape_Shape(alloc);
		
			map_arb_false_false_true_false_Shape_Particle    = new IntHash<Arbiter_false_false_true_false_Shape_Particle>();
			s_arbiters_false_false_true_false_Shape_Particle = new CxFastList_Arbiter_false_false_true_false_Shape_Particle(alloc);
		
			map_arb_true_true_true_true_Shape_Shape    = new IntHash<Arbiter_true_true_true_true_Shape_Shape>();
			s_arbiters_true_true_true_true_Shape_Shape = new CxFastList_Arbiter_true_true_true_true_Shape_Shape(alloc);
		
			map_arb_true_true_true_false_Shape_Particle    = new IntHash<Arbiter_true_true_true_false_Shape_Particle>();
			s_arbiters_true_true_true_false_Shape_Particle = new CxFastList_Arbiter_true_true_true_false_Shape_Particle(alloc);
		
		map_objarb   = new IntHash<ObjArb>  ();
		map_grouparb = new IntHash<GroupArb>();
		
		constraints = new CxFastList_Constraint(alloc);
		properties  = new CxFastList_Properties(alloc);
		
		statics   = new CxFastList_Body    (alloc);
		dynamics  = new CxFastList_Body    (alloc);
		particles = new CxFastList_Particle(alloc);
		objects   = new CxFastList_PhysObj (alloc);
		groups    = new CxFastList_Group   (alloc);
		
		STATIC = new Body(0,0);
		STATIC.imass   = STATIC.smass  = STATIC.imoment = STATIC.smoment = STATIC.cmass = STATIC.cmoment = 0;
		STATIC.mass    = STATIC.moment = Const.POSINF;
		STATIC.rotx    = 0; STATIC.roty = 1;
		STATIC.kinetic = 0;
		STATIC.sleep   = true;
		STATIC.added_to_space = true;
		
		 cb_Begin = new IntHash<Bool>();  cb_End = new IntHash<Bool>();  cb_SenseBegin = new IntHash<Bool>();  cb_SenseEnd = new IntHash<Bool>();  cb_PostSolve = new IntHash<Bool>(); 
		cb_PreSolve = new IntHash<Arbiter->Int>();
		cb_PreBegin = new IntHash<Arbiter->Int>();
		
		callbacks = new CxFastAllocList_Callback(alloc);
	}
	
	
	
	public inline function addProperties(p:Properties) {
		p.count++;
		if(p.count==1) properties.add(p);
	}
	public inline function removeProperties(p:Properties) {
		p.count--;
		if(p.count <= 0) properties.remove(p);
	}
	
	
	
	inline function add_aux(o:PhysObj) o.space = this
	inline function rem_aux(o:PhysObj) o.space = null
	
	

	public inline function addConstraint(c:Constraint) {
		if(!c.live) {
			c.live = true;
			
			if(!constraints.has(c)) {
				constraints.add(c);
				c.addToBodies();
			}
			c.wakeBodies(this);
		}
	}
	public inline function removeConstraint(c:Constraint) {
		c.removeFromBodies();
		c.live = false;
		constraints.remove(c);
		c.wakeBodies(this);
	}
	
	public inline function removeConstraints(o:PhysObj) {
		var cons = o.p_constraints;
		while(!cons.empty()) {
			var c = cons.front();
			cons.pop();
			removeConstraint(c);
		}
	}
	
	public function wakeConstraint(c:Constraint) {
		if(c.canSleep || c.sleep) {
			c.canSleep = c.sleep = false;
			if(!c.live) {
				c.live = true;
				constraints.add(c);
			}
			c.wakeBodies(this);			
		}
	}
	
	
	
	
	public inline function addStatic  (b:Body)     statics  .add(b)
	public inline function addDynamic (b:Body)     dynamics .add(b)
	public inline function addParticle(p:Particle) particles.add(p)
	
	public inline function removeStatic  (b:Body)     return statics  .remove(b)
	public inline function removeDynamic (b:Body)     return dynamics .remove(b)
	public inline function removeParticle(p:Particle) return particles.remove(p)

	
	
	public function clear_special()
	{
		
	}
	public inline function clear() {
		while(!objects.empty()) {
			var obj; removeObject(obj = objects.front());
			if(obj.graphic!=null) {
				if(obj.graphic.parent!=null && obj.graphic.parent.contains(obj.graphic))
					obj.graphic.parent.removeChild(obj.graphic);
			}
		}
		while(!constraints.empty()) removeConstraint(constraints.front());
		while(!groups.empty()) removeGroup(groups.front());
		
		visible.clear();
		
		
			s_arbiters_false_false_true_true_Shape_Shape.clear();
			map_arb_false_false_true_true_Shape_Shape = new IntHash<Arbiter_false_false_true_true_Shape_Shape>();
		
			s_arbiters_false_false_true_false_Shape_Particle.clear();
			map_arb_false_false_true_false_Shape_Particle = new IntHash<Arbiter_false_false_true_false_Shape_Particle>();
		
			s_arbiters_true_true_true_true_Shape_Shape.clear();
			map_arb_true_true_true_true_Shape_Shape = new IntHash<Arbiter_true_true_true_true_Shape_Shape>();
		
			s_arbiters_true_true_true_false_Shape_Particle.clear();
			map_arb_true_true_true_false_Shape_Particle = new IntHash<Arbiter_true_true_true_false_Shape_Particle>();
		
		
		map_objarb   = new IntHash<ObjArb>  ();
		map_grouparb = new IntHash<GroupArb>();
		
		properties.clear();
		statics   .clear();
		dynamics  .clear();
		particles .clear();
		callbacks .clear();
		
		 cb_Begin = new IntHash<Bool>(); cb_End = new IntHash<Bool>(); cb_SenseBegin = new IntHash<Bool>(); cb_SenseEnd = new IntHash<Bool>(); cb_PostSolve = new IntHash<Bool>();
		cb_PreSolve = new IntHash<Arbiter->Int>();
		cb_PreBegin = new IntHash<Arbiter->Int>();
		
		clear_special();
		
		stamp++;
	}
	
	
	
	public inline function updateProp(dt:Float) {
		  {
	var cxiterator = properties.begin();
	while(cxiterator != properties.end()) {
		var p = cxiterator.elem();
		{
			
			{
			p.lfdt = Math.pow(p.linDamp, dt);
			p.afdt = Math.pow(p.angDamp, dt);
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	public inline function updateVel_remSleep(dt:Float) {
		
		
		 {
			var pre = null;
			  {
	var cxiterator = dynamics.begin();
	while(cxiterator != dynamics.end()) {
		var cur = cxiterator.elem();
		{
			
			{
				if(cur.stamp<stamp && sleeping) {
					cxiterator = dynamics.erase(pre,cxiterator);
					cur.live = false;
					 {
	if(cur.cbSleep) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SLEEP;
		cb.obj = cur;
		callbacks.add(cb);
	}else if(cur.cbSleepDef)
		Config.DEFAULT_CB_SLEEP(cur);
};
					cur.plive = false;
					removeProperties(cur.properties);
					continue;
				}else if(sleeping && cur.plive) {
					 {
	if(cur.cbWake) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_WAKE;
		cb.obj = cur;
		callbacks.add(cb);
	}else if(cur.cbWakeDef)
		Config.DEFAULT_CB_WAKE(cur);
};
					addProperties(cur.properties);
				}
				cur.plive = false;
				 { cur.fx += gravityx*(cur.gmass); cur.fy += gravityy*(cur.gmass); } ;
				if(cur.isBody) {
					var body = cur.body;
					body.t +=  (body.gpx*gravityy - body.gpy*gravityx) *body.gmass;
				}
				cur.updateVelocity(dt);
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		};
		 {
			var pre = null;
			  {
	var cxiterator = particles.begin();
	while(cxiterator != particles.end()) {
		var cur = cxiterator.elem();
		{
			
			{
				if(cur.stamp<stamp && sleeping) {
					cxiterator = particles.erase(pre,cxiterator);
					cur.live = false;
					 {
	if(cur.cbSleep) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_SLEEP;
		cb.obj = cur;
		callbacks.add(cb);
	}else if(cur.cbSleepDef)
		Config.DEFAULT_CB_SLEEP(cur);
};
					cur.plive = false;
					removeProperties(cur.properties);
					continue;
				}else if(sleeping && cur.plive) {
					 {
	if(cur.cbWake) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_WAKE;
		cb.obj = cur;
		callbacks.add(cb);
	}else if(cur.cbWakeDef)
		Config.DEFAULT_CB_WAKE(cur);
};
					addProperties(cur.properties);
				}
				cur.plive = false;
				 { cur.fx += gravityx*(cur.gmass); cur.fy += gravityy*(cur.gmass); } ;
				if(cur.isBody) {
					var body = cur.body;
					body.t +=  (body.gpx*gravityy - body.gpy*gravityx) *body.gmass;
				}
				cur.updateVelocity(dt);
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		};	
	}
	
	public inline function updatePos(dt:Float) {
		var rem = new CxFastList_PhysObj(alloc);
		
		  {
	var cxiterator = dynamics.begin();
	while(cxiterator != dynamics.end()) {
		var b = cxiterator.elem();
		{
			
			{
			b.updatePosition(dt);
			var lost = true;
			  {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			{
				s.updateShape();
				lost = syncShape(s,false)&&lost;
			};
		}
		cxiterator = cxiterator.next;
	}
};
			if(lost) rem.add(b);
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		  {
	var cxiterator = particles.begin();
	while(cxiterator != particles.end()) {
		var p = cxiterator.elem();
		{
			
			{
			p.updatePosition(dt);
			if(syncParticle(p,false)) rem.add(p);
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		while(!rem.empty()) {
			var p = rem.front();
			removeObject(p);
			 {
	if(p.cbOutOfBounds) {
		var cb = alloc.CxAlloc_Callback();
		cb.type = Callback.PHYSOBJ_OUTOFBOUNDS;
		cb.obj = p;
		callbacks.add(cb);
	}else if(p.cbOutOfBoundsDef)
		Config.DEFAULT_CB_OUTOFBOUNDS(p);
};
			rem.pop();
		}
	}
	
	
	
	
	
	

	public inline function prestep(dt:Float) {
		{
			var pre = null;
			  {
	var cxiterator = s_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				var cb_arb = arb.obj_arb;
				var gr_arb = cb_arb.group_arb;
				
				if(sleeping && arb.sstamp<stamp) {
					arb.live = false;
					cxiterator = s_arbiters_false_false_true_true_Shape_Shape.erase(pre,cxiterator);
					continue;
				}else if(!arb.updated) {
					var b1 = arb.p1;
					var b2 = arb.p2;
					
					var s1 = arb._s1;
					var s2 = arb._s2;
					var gcol = (s1.group &s2.group) !=0;
					var scol = (s1.sensor&s2.sensor)!=0;
					
					if(cb_arb.retire_arb(arb)) {
						cb_arb.retire();
						alloc.CxFree_ObjArb(cb_arb);
						map_objarb.remove(cb_arb.id);
						var id = IdRef.pair(b1.cbType,b2.cbType);
						
						if(gcol)
							 {
		if(b1.cbHasEnd && b2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						if(scol)
							 {
		if(b1.cbHasSenseEnd && b2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						{
							if(gr_arb!=null && gr_arb.retire_arb(cb_arb)) {
								alloc.CxFree_GroupArb(gr_arb);
								map_grouparb.remove(gr_arb.id);
								var g1 = b1.group_obj;
								var g2 = b2.group_obj;
								var id = IdRef.pair(g1.cbType,g2.cbType);
								
								if(gcol)
									 {
		if(g1.cbHasEnd && g2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
								if(scol)
									 {
		if(g1.cbHasSenseEnd && g2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					var id = IdRef.pair(s1.cbType,s2.cbType);
					
					if(gcol)
						 {
		if(s1.cbHasEnd && s2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					if(scol)
						 {
		if(s1.cbHasSenseEnd && s2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					
					cxiterator = s_arbiters_false_false_true_true_Shape_Shape.erase(pre,cxiterator);
					map_arb_false_false_true_true_Shape_Shape.remove(arb.id);
					arb.retire();
					continue;
				}
				arb.preStep();
				
				arb.updated        = false;
				cb_arb.updated     = false;
				cb_arb.temp_ignore = false;
				arb.temp_ignore    = false;
				if(gr_arb!=null) {
					gr_arb.updated = false;
					gr_arb.temp_ignore = false;
				}
				
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}{
			var pre = null;
			  {
	var cxiterator = s_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				var cb_arb = arb.obj_arb;
				var gr_arb = cb_arb.group_arb;
				
				if(sleeping && arb.sstamp<stamp) {
					arb.live = false;
					cxiterator = s_arbiters_false_false_true_false_Shape_Particle.erase(pre,cxiterator);
					continue;
				}else if(!arb.updated) {
					var b1 = arb.p1;
					var b2 = arb.p2;
					
					var s1 = arb._s1;
					var s2 = arb._s2;
					var gcol = (s1.group &s2.group) !=0;
					var scol = (s1.sensor&s2.sensor)!=0;
					
					if(cb_arb.retire_arb(arb)) {
						cb_arb.retire();
						alloc.CxFree_ObjArb(cb_arb);
						map_objarb.remove(cb_arb.id);
						var id = IdRef.pair(b1.cbType,b2.cbType);
						
						if(gcol)
							 {
		if(b1.cbHasEnd && b2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						if(scol)
							 {
		if(b1.cbHasSenseEnd && b2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						{
							if(gr_arb!=null && gr_arb.retire_arb(cb_arb)) {
								alloc.CxFree_GroupArb(gr_arb);
								map_grouparb.remove(gr_arb.id);
								var g1 = b1.group_obj;
								var g2 = b2.group_obj;
								var id = IdRef.pair(g1.cbType,g2.cbType);
								
								if(gcol)
									 {
		if(g1.cbHasEnd && g2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
								if(scol)
									 {
		if(g1.cbHasSenseEnd && g2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					var id = IdRef.pair(s1.cbType,s2.cbType);
					
					if(gcol)
						 {
		if(s1.cbHasEnd && s2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					if(scol)
						 {
		if(s1.cbHasSenseEnd && s2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					
					cxiterator = s_arbiters_false_false_true_false_Shape_Particle.erase(pre,cxiterator);
					map_arb_false_false_true_false_Shape_Particle.remove(arb.id);
					arb.retire();
					continue;
				}
				arb.preStep();
				
				arb.updated        = false;
				cb_arb.updated     = false;
				cb_arb.temp_ignore = false;
				arb.temp_ignore    = false;
				if(gr_arb!=null) {
					gr_arb.updated = false;
					gr_arb.temp_ignore = false;
				}
				
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}{
			var pre = null;
			  {
	var cxiterator = s_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				var cb_arb = arb.obj_arb;
				var gr_arb = cb_arb.group_arb;
				
				if(sleeping && arb.sstamp<stamp) {
					arb.live = false;
					cxiterator = s_arbiters_true_true_true_true_Shape_Shape.erase(pre,cxiterator);
					continue;
				}else if(!arb.updated) {
					var b1 = arb.p1;
					var b2 = arb.p2;
					
					var s1 = arb._s1;
					var s2 = arb._s2;
					var gcol = (s1.group &s2.group) !=0;
					var scol = (s1.sensor&s2.sensor)!=0;
					
					if(cb_arb.retire_arb(arb)) {
						cb_arb.retire();
						alloc.CxFree_ObjArb(cb_arb);
						map_objarb.remove(cb_arb.id);
						var id = IdRef.pair(b1.cbType,b2.cbType);
						
						if(gcol)
							 {
		if(b1.cbHasEnd && b2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						if(scol)
							 {
		if(b1.cbHasSenseEnd && b2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						{
							if(gr_arb!=null && gr_arb.retire_arb(cb_arb)) {
								alloc.CxFree_GroupArb(gr_arb);
								map_grouparb.remove(gr_arb.id);
								var g1 = b1.group_obj;
								var g2 = b2.group_obj;
								var id = IdRef.pair(g1.cbType,g2.cbType);
								
								if(gcol)
									 {
		if(g1.cbHasEnd && g2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
								if(scol)
									 {
		if(g1.cbHasSenseEnd && g2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					var id = IdRef.pair(s1.cbType,s2.cbType);
					
					if(gcol)
						 {
		if(s1.cbHasEnd && s2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					if(scol)
						 {
		if(s1.cbHasSenseEnd && s2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					
					cxiterator = s_arbiters_true_true_true_true_Shape_Shape.erase(pre,cxiterator);
					map_arb_true_true_true_true_Shape_Shape.remove(arb.id);
					arb.retire();
					continue;
				}
				arb.preStep();
				
				arb.updated        = false;
				cb_arb.updated     = false;
				cb_arb.temp_ignore = false;
				arb.temp_ignore    = false;
				if(gr_arb!=null) {
					gr_arb.updated = false;
					gr_arb.temp_ignore = false;
				}
				
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}{
			var pre = null;
			  {
	var cxiterator = s_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				var cb_arb = arb.obj_arb;
				var gr_arb = cb_arb.group_arb;
				
				if(sleeping && arb.sstamp<stamp) {
					arb.live = false;
					cxiterator = s_arbiters_true_true_true_false_Shape_Particle.erase(pre,cxiterator);
					continue;
				}else if(!arb.updated) {
					var b1 = arb.p1;
					var b2 = arb.p2;
					
					var s1 = arb._s1;
					var s2 = arb._s2;
					var gcol = (s1.group &s2.group) !=0;
					var scol = (s1.sensor&s2.sensor)!=0;
					
					if(cb_arb.retire_arb(arb)) {
						cb_arb.retire();
						alloc.CxFree_ObjArb(cb_arb);
						map_objarb.remove(cb_arb.id);
						var id = IdRef.pair(b1.cbType,b2.cbType);
						
						if(gcol)
							 {
		if(b1.cbHasEnd && b2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						if(scol)
							 {
		if(b1.cbHasSenseEnd && b2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
						{
							if(gr_arb!=null && gr_arb.retire_arb(cb_arb)) {
								alloc.CxFree_GroupArb(gr_arb);
								map_grouparb.remove(gr_arb.id);
								var g1 = b1.group_obj;
								var g2 = b2.group_obj;
								var id = IdRef.pair(g1.cbType,g2.cbType);
								
								if(gcol)
									 {
		if(g1.cbHasEnd && g2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
								if(scol)
									 {
		if(g1.cbHasSenseEnd && g2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					var id = IdRef.pair(s1.cbType,s2.cbType);
					
					if(gcol)
						 {
		if(s1.cbHasEnd && s2.cbHasEnd) {
			if(cb_End.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					if(scol)
						 {
		if(s1.cbHasSenseEnd && s2.cbHasSenseEnd) {
			if(cb_SenseEnd.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_END;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
					
					cxiterator = s_arbiters_true_true_true_false_Shape_Particle.erase(pre,cxiterator);
					map_arb_true_true_true_false_Shape_Particle.remove(arb.id);
					arb.retire();
					continue;
				}
				arb.preStep();
				
				arb.updated        = false;
				cb_arb.updated     = false;
				cb_arb.temp_ignore = false;
				arb.temp_ignore    = false;
				if(gr_arb!=null) {
					gr_arb.updated = false;
					gr_arb.temp_ignore = false;
				}
				
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		
		var pre = null;
		  {
	var cxiterator = constraints.begin();
	while(cxiterator != constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var anywake = c.anyBodiesAwake();
			if(c.live && !anywake) {
				c.live = false;
				c.sleep = true;
				cxiterator = constraints.erase(pre,cxiterator);
				continue;
			}
			if(anywake && c.preStep(dt)) {
				cxiterator = constraints.erase(pre,cxiterator);
				c.removeFromBodies();
				c.live = false;
				
				 {
		if(c.cbBreak) {
			var cb = alloc.CxAlloc_Callback();
			cb.type = Callback.CONSTRAINT_BREAK;
			cb.constraint = c;
			callbacks.add(cb);
		}
	};
				continue;
			}
			c.canSleep = true;
			pre = cxiterator;
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	
	
	public inline function iterate_vel(iterations:Int) {
		for(i in 0...iterations) {
			 {
				
				  {
	var cxiterator = s_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulseVel();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				
				  {
	var cxiterator = s_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulseVel();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				
				  {
	var cxiterator = s_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulseVel();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				
				  {
	var cxiterator = s_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulseVel();
		}
		cxiterator = cxiterator.next;
	}
};
			}

			var pre = null;
			  {
	var cxiterator = constraints.begin();
	while(cxiterator != constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
				if(c.anyBodiesAwake() && c.applyImpulse()) {
					cxiterator = constraints.erase(pre,cxiterator);
					c.removeFromBodies();
					c.live = false;
					
					 {
		if(c.cbBreak) {
			var cb = alloc.CxAlloc_Callback();
			cb.type = Callback.CONSTRAINT_BREAK;
			cb.constraint = c;
			callbacks.add(cb);
		}
	};
					continue;
				}
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	public inline function iterate_pos(iterations:Int) {
		for(i in 0...iterations) {
			 {
				  {
	var cxiterator = s_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulsePos();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = s_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulsePos();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = s_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulsePos();
		}
		cxiterator = cxiterator.next;
	}
};
			} {
				  {
	var cxiterator = s_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			arb.applyImpulsePos();
		}
		cxiterator = cxiterator.next;
	}
};
			}

			var pre = null;
			  {
	var cxiterator = constraints.begin();
	while(cxiterator != constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
				if(c.anyBodiesAwake() && c.applyImpulse()) {
					cxiterator = constraints.erase(pre,cxiterator);
					c.removeFromBodies();
					c.live = false;
					
					 {
		if(c.cbBreak) {
			var cb = alloc.CxAlloc_Callback();
			cb.type = Callback.CONSTRAINT_BREAK;
			cb.constraint = c;
			callbacks.add(cb);
		}
	};
					continue;
				}
				pre = cxiterator;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	public inline function warmStart() {
		 {
			  {
	var cxiterator = s_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				arb.applyImpulseCache();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = s_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				arb.applyImpulseCache();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = s_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != s_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				arb.applyImpulseCache();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = s_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != s_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				arb.applyImpulseCache();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	
	
	public inline function eval_sleep() {
		  {
	var cxiterator = constraints.begin();
	while(cxiterator != constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			if(c.anyBodiesAwake()) {
				
				
				c.disallowBodySleep();
				c.wakeBodies(this);
				c.sleep = false;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	public function step (dt:Float, ?elastic:Int=Config.DEFAULT_ELASTIC, ?inelastic:Int=Config.DEFAULT_ITERATIONS) {
		if (dt < Const.EPSILON) dt = 0;
		_dt = dt;
		
		if(dt==0) return;
		
		if(register) {
			registerTypes();
			register = false;
		}
		
		callbacks.clear();
		
		if(use_viewport) {
			  {
	var cxiterator = visible.begin();
	while(cxiterator != visible.end()) {
		var o = cxiterator.elem();
		{
			
			{
				o.pvisible = true;
				o.visible = false;
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		
		
		
		updateProp(dt);
		
		if(sleeping)
			eval_sleep();
		
		
			
		broadphase();
			
		prestep(dt);
		iterate_vel(elastic);
			
		updateVel_remSleep(dt);

		warmStart();
		iterate_pos(inelastic);
		
		stamp++;
		
		
			
		updatePos(dt);
		
		if(use_viewport) visitate();
	}
	
	
	
	public var cb_Begin:IntHash<Bool>;   public var cb_End:IntHash<Bool>;   public var cb_SenseBegin:IntHash<Bool>;   public var cb_SenseEnd:IntHash<Bool>;   public var cb_PostSolve:IntHash<Bool>;   
	
	public var cb_PreSolve:IntHash<Arbiter->Int>;
		 
	public var cb_PreBegin:IntHash<Arbiter->Int>;
		 
		
	public inline function addGroup(g:Group) {
		if(!groups.has(g)) {
			groups.add(g);
			registerBase(g);
			  {
	var cxiterator = g.objs.begin();
	while(cxiterator != g.objs.end()) {
		var p = cxiterator.elem();
		{
			
			addObject(p);
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	public inline function removeGroup(g:Group) {
		if(groups.remove(g)) {
			  {
	var cxiterator = g.objs.begin();
	while(cxiterator != g.objs.end()) {
		var p = cxiterator.elem();
		{
			
			removeObject(p);
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	public function registerTypes() {
		     
		 {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_PreSolve.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasPreSolve = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasPreSolve = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_PreBegin.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasPreBegin = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasPreBegin = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_Begin.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasBegin = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasBegin = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_End.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasEnd = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasEnd = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_SenseBegin.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasSenseBegin = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasSenseBegin = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_SenseEnd.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasSenseEnd = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasSenseEnd = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			var tmap = new IntHash<Bool>();
			var any = false;
			for(id in cb_PostSolve.keys()) {
				tmap.set(IdRef.fst(id),true);
				tmap.set(IdRef.snd(id),true);
			}
			  {
	var cxiterator = objects.begin();
	while(cxiterator != objects.end()) {
		var p = cxiterator.elem();
		{
			
			p.cbHasPostSolve = tmap.exists(p.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
			  {
	var cxiterator = groups.begin();
	while(cxiterator != groups.end()) {
		var g = cxiterator.elem();
		{
			
			g.cbHasPostSolve = tmap.exists(g.cbType);
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	public function registerBase(p:Callbackable) {
		     
		 {
			p.cbHasPreSolve = false;
			for(id in cb_PreSolve.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasPreSolve = true;
					break;
				}
			}
		} {
			p.cbHasPreBegin = false;
			for(id in cb_PreBegin.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasPreBegin = true;
					break;
				}
			}
		} {
			p.cbHasBegin = false;
			for(id in cb_Begin.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasBegin = true;
					break;
				}
			}
		} {
			p.cbHasEnd = false;
			for(id in cb_End.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasEnd = true;
					break;
				}
			}
		} {
			p.cbHasSenseBegin = false;
			for(id in cb_SenseBegin.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasSenseBegin = true;
					break;
				}
			}
		} {
			p.cbHasSenseEnd = false;
			for(id in cb_SenseEnd.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasSenseEnd = true;
					break;
				}
			}
		} {
			p.cbHasPostSolve = false;
			for(id in cb_PostSolve.keys()) {
				if(IdRef.fst(id)==p.cbType||IdRef.snd(id)==p.cbType) {
					p.cbHasPostSolve = true;
					break;
				}
			}
		}
	}
	public inline function registerBody(b:Body) {
		registerBase(b);
		   {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var i = cxiterator.elem();
		{
			
			registerBase(i);
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	public inline function addCbPreSolve  (a:Int,b:Int,cb:Arbiter->Int)   {
		cb_PreSolve.set(IdRef.pair(a,b),cb);
		register = true;
	}
	public inline function addCbPreBegin  (a:Int,b:Int,cb:Arbiter->Int)   {
		cb_PreBegin.set(IdRef.pair(a,b),cb);
		register = true;
	}
	public inline function addCbBegin     (a:Int,b:Int)                   {
		cb_Begin.set(IdRef.pair(a,b),true);
		register = true;
	}
	public inline function addCbEnd       (a:Int,b:Int)                   {
		cb_End.set(IdRef.pair(a,b),true);
		register = true;
	}
	public inline function addCbSenseBegin(a:Int,b:Int)                   {
		cb_SenseBegin.set(IdRef.pair(a,b),true);
		register = true;
	}
	public inline function addCbSenseEnd  (a:Int,b:Int)                   {
		cb_SenseEnd.set(IdRef.pair(a,b),true);
		register = true;
	}
	public inline function addCbPostSolve (a:Int,b:Int)                   {
		cb_PostSolve.set(IdRef.pair(a,b),true);
		register = true;
	}
	
	
	
	public inline function removeCbPreSolve  (a:Int,b:Int)  {
		if(cb_PreSolve.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbPreBegin  (a:Int,b:Int)  {
		if(cb_PreBegin.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbBegin     (a:Int,b:Int)  {
		if(cb_Begin.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbEnd       (a:Int,b:Int)  {
		if(cb_End.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbSenseBegin(a:Int,b:Int)  {
		if(cb_SenseBegin.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbSenseEnd  (a:Int,b:Int)  {
		if(cb_SenseEnd.remove(IdRef.pair(a,b)))
			register = true;
	}
	public inline function removeCbPostSolve (a:Int,b:Int)  {
		if(cb_PostSolve.remove(IdRef.pair(a,b)))
			register = true;
	}
	
	
	
	
	
	
	

	public inline function ignoreConstraint(b1:PhysObj,b2:PhysObj):Bool {
		var ret = false;
		  {
	var cxiterator = b1.p_constraints.begin();
	while(cxiterator != b1.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			if(c.ignore && c.bodyPairExists(b1,b2)) {
				ret = true;
				break;
			}
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return ret;
	}
	
	public inline function narrowPhase_false_false_true_true_Shape_Shape(s1:Shape,s2:Shape) {
		var b1,b2;
		
		
		 b1 = s1.body;
		 b2 = s2.body;
		
		
		
		
		
		
		var gcol = (s1.group &s2.group) !=0;
		var scol = (s1.sensor&s2.sensor)!=0;
		if (!b2.sleep
		&& (gcol||scol)
		&& !(b1.imass==0&&b2.imass==0&&b1.imoment==0&&b2.imoment==0)
		&& !ignoreConstraint(b1,b2)) {
			
			var sa, sb, id; var reverse;
			
			
			{
				if(s1.type > s2.type) { sa = s2; sb = s1; }
				else if (s1.type == s2.type) {
					if( s1.id < s2.id) { sa = s1; sb = s2; }
					else               { sb = s1; sa = s2; }
				}else { sa = s1; sb = s2; }
				reverse = sa == s2;
				id = IdRef._pair(sa.id,sb.id);
			}
			
			var arb = map_arb_false_false_true_true_Shape_Shape.get(id);
			var first = arb==null;
			if(first) {
				arb = alloc.CxAlloc_Arbiter_false_false_true_true_Shape_Shape();
				arb.ignore = false;
				arb.alloc = alloc;
			}else
				reverse = sa != arb._s1;
			
			if(arb.stamp != stamp) {
				var cb_id = IdRef.pair(b1.id,b2.id);
				var cb_arb = map_objarb.get(cb_id);
				
				var g1 = b1.group_obj;
				var g2 = b2.group_obj;
				var use_groups = g1!=null && g2!=null;
				var gr_id = 0, gr_arb = null;
				if(use_groups) {
					gr_id  = IdRef.pair(g1.id,g2.id);
					gr_arb = map_grouparb.get(gr_id);
				}
				
				if(g1!=g2 || g1==null || !g1.ignore) {
					var col = false;
					var fobj = false;
					var fgrp = false;
					if(gcol) {
						if((arb.ignore || arb.temp_ignore)
						|| (cb_arb!=null && (cb_arb.ignore || cb_arb.temp_ignore))
						|| (gr_arb!=null && (gr_arb.ignore || gr_arb.temp_ignore))) {
							arb.contacts.clear();
							if(col = collide.testCollide_Shape_Shape(sa,sb)) {
								if(first) {
									arb.assign(s1,s2,id);
									
									
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									cb_arb.assign_arb(arb);
									if(use_groups)
											gr_arb.assign_arb(cb_arb);
									
									arb.sstamp = stamp;
									arb.live = true;
									arb.sensor = false;
									s_arbiters_false_false_true_true_Shape_Shape.add(arb);
									map_arb_false_false_true_true_Shape_Shape.set(id,arb);
								}else {
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									if(!cb_arb.arbiters.has(arb)) {
										cb_arb.assign_arb(arb);
										if(arb.ignore) cb_arb.ignore = true;
									}
									if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
										gr_arb.assign_arb(cb_arb);
										if(cb_arb.ignore) {
											gr_arb.ignore = true;
											arb.ignore = true;
										}
									}
								}
								
								if(gr_arb!=null && gr_arb.ignore) {
									cb_arb.ignore = arb.ignore = true;
								}else if(cb_arb.ignore) {
									arb.ignore = true;
								}
							}
						}else if(col = collide.contactCollide_false_false_true_true_Shape_Shape(sa,sb,arb,reverse)) {
							if(first) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								
								if(use_groups) {
									if(fgrp = gr_arb.assign_arb(cb_arb)) {
										var id = IdRef.pair(g1.cbType,g2.cbType);
										if(g1.cbHasPreBegin && g2.cbHasPreBegin) {
											var cbm = cb_PreBegin.get(id);
											if(cbm!=null) {
												var res = cbm(arb);
												if(res == 1) {
													gr_arb.temp_ignore = true;
													cb_arb.temp_ignore = true;
													arb.temp_ignore = true;
													arb.contacts.clear();
												}else if(res == 2) {
													gr_arb.ignore = true;
													cb_arb.ignore = true;
													arb.ignore = true;
													arb.contacts.clear();
												}
											}
										}
										 {
		if(g1.cbHasBegin && g2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
									}
								}
								
								
								if(fobj = cb_arb.assign_arb(arb)) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreBegin && b2.cbHasPreBegin) {
										var cbm = cb_PreBegin.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
									 {
		if(b1.cbHasBegin && b2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
								}
								
								
								var cb_id2 = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreBegin && s2.cbHasPreBegin) {
									var cbm = cb_PreBegin.get(cb_id2);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
								 {
		if(s1.cbHasBegin && s2.cbHasBegin) {
			if(cb_Begin.get(cb_id2)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = cb_id2;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
								
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = false;
								s_arbiters_false_false_true_true_Shape_Shape.add(arb);
								map_arb_false_false_true_true_Shape_Shape.set(id,arb);
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								if(!cb_arb.arbiters.has(arb)) {
									cb_arb.assign_arb(arb);
									if(arb.ignore) cb_arb.ignore = true;
								}
								if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
									gr_arb.assign_arb(cb_arb);
									if(cb_arb.ignore) {
										gr_arb.ignore = true;
										arb.ignore = true;
									}
								}
								
								
								if(use_groups && !gr_arb.updated) {
									var id = IdRef.pair(g1.cbType,g2.cbType);
									if(g1.cbHasPreSolve && g2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												gr_arb.temp_ignore = true;
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												gr_arb.ignore = true;
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								
								if(!cb_arb.updated) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreSolve && b2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								id = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreSolve && s2.cbHasPreSolve) {
									var cbm = cb_PreSolve.get(id);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
							}
							
							if(gr_arb!=null && gr_arb.ignore) {
								cb_arb.ignore = arb.ignore = true;
							}else if(cb_arb.ignore) {
								arb.ignore = true;
							}
							
							
							if(use_groups && !gr_arb.updated && !(gr_arb.ignore || gr_arb.temp_ignore)) {
								var id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasPostSolve && g2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!cb_arb.updated && !(cb_arb.ignore || cb_arb.temp_ignore)) {
								var id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasPostSolve && b2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!(arb.ignore || arb.temp_ignore)) {
								var id = IdRef.pair(s1.cbType,s2.cbType);
								 {
		if(s1.cbHasPostSolve && s2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					if(scol) {
						if(!gcol) col = collide.testCollide_Shape_Shape(sa,sb);
						if(col && first) {
							var cont_obj;
							var cont_grp;
							if(!gcol) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = cb_arb.assign_arb(arb);
								if(use_groups) cont_grp = gr_arb.assign_arb(cb_arb);
								else cont_grp = false;
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = fobj;
								cont_grp = fgrp;
							}
							
							
							if(cont_grp) {
								var gr_id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasSenseBegin && g2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(gr_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = gr_id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							if(cont_obj) {
								var cb_id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasSenseBegin && b2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							cb_id = IdRef.pair(s1.cbType,s2.cbType);
							 {
		if(s1.cbHasSenseBegin && s2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							
							if(!gcol) {
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = true;
								s_arbiters_false_false_true_true_Shape_Shape.add(arb);
								map_arb_false_false_true_true_Shape_Shape.set(id,arb);
							}
						}else if(col) {
							
							{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
						}
					}
					
					if(col) {
						arb.updated    = true;
						cb_arb.updated = true;
						if(use_groups) gr_arb.updated = true;
					}
					arb.stamp = stamp;
					
					if(!col && first) arb.retire();
				}else if(first) arb.retire();
			}else if(first) arb.retire();
		}
	}public inline function narrowPhase_false_false_true_false_Shape_Particle(s1:Shape,s2:Particle) {
		var b1,b2;
		
		
		 b1 = s1.body;
		 b2 = s2;
		
		
		
		
		
		
		var gcol = (s1.group &s2.group) !=0;
		var scol = (s1.sensor&s2.sensor)!=0;
		if (!b2.sleep
		&& (gcol||scol)
		&& !(b1.imass==0&&b2.imass==0&&b1.imoment==0&&b2.imoment==0)
		&& !ignoreConstraint(b1,b2)) {
			
			var sa, sb, id; var reverse;
			
			
			{
				id = IdRef._pair(s1.id,s2.id);
				sa = s1; sb = s2;
				reverse = false;
			}
			
			var arb = map_arb_false_false_true_false_Shape_Particle.get(id);
			var first = arb==null;
			if(first) {
				arb = alloc.CxAlloc_Arbiter_false_false_true_false_Shape_Particle();
				arb.ignore = false;
				arb.alloc = alloc;
			}else
				reverse = sa != arb._s1;
			
			if(arb.stamp != stamp) {
				var cb_id = IdRef.pair(b1.id,b2.id);
				var cb_arb = map_objarb.get(cb_id);
				
				var g1 = b1.group_obj;
				var g2 = b2.group_obj;
				var use_groups = g1!=null && g2!=null;
				var gr_id = 0, gr_arb = null;
				if(use_groups) {
					gr_id  = IdRef.pair(g1.id,g2.id);
					gr_arb = map_grouparb.get(gr_id);
				}
				
				if(g1!=g2 || g1==null || !g1.ignore) {
					var col = false;
					var fobj = false;
					var fgrp = false;
					if(gcol) {
						if((arb.ignore || arb.temp_ignore)
						|| (cb_arb!=null && (cb_arb.ignore || cb_arb.temp_ignore))
						|| (gr_arb!=null && (gr_arb.ignore || gr_arb.temp_ignore))) {
							arb.contacts.clear();
							if(col = collide.testCollide_Shape_Particle(sa,sb)) {
								if(first) {
									arb.assign(s1,s2,id);
									
									
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									cb_arb.assign_arb(arb);
									if(use_groups)
											gr_arb.assign_arb(cb_arb);
									
									arb.sstamp = stamp;
									arb.live = true;
									arb.sensor = false;
									s_arbiters_false_false_true_false_Shape_Particle.add(arb);
									map_arb_false_false_true_false_Shape_Particle.set(id,arb);
								}else {
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									if(!cb_arb.arbiters.has(arb)) {
										cb_arb.assign_arb(arb);
										if(arb.ignore) cb_arb.ignore = true;
									}
									if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
										gr_arb.assign_arb(cb_arb);
										if(cb_arb.ignore) {
											gr_arb.ignore = true;
											arb.ignore = true;
										}
									}
								}
								
								if(gr_arb!=null && gr_arb.ignore) {
									cb_arb.ignore = arb.ignore = true;
								}else if(cb_arb.ignore) {
									arb.ignore = true;
								}
							}
						}else if(col = collide.contactCollide_false_false_true_false_Shape_Particle(sa,sb,arb,reverse)) {
							if(first) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								
								if(use_groups) {
									if(fgrp = gr_arb.assign_arb(cb_arb)) {
										var id = IdRef.pair(g1.cbType,g2.cbType);
										if(g1.cbHasPreBegin && g2.cbHasPreBegin) {
											var cbm = cb_PreBegin.get(id);
											if(cbm!=null) {
												var res = cbm(arb);
												if(res == 1) {
													gr_arb.temp_ignore = true;
													cb_arb.temp_ignore = true;
													arb.temp_ignore = true;
													arb.contacts.clear();
												}else if(res == 2) {
													gr_arb.ignore = true;
													cb_arb.ignore = true;
													arb.ignore = true;
													arb.contacts.clear();
												}
											}
										}
										 {
		if(g1.cbHasBegin && g2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
									}
								}
								
								
								if(fobj = cb_arb.assign_arb(arb)) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreBegin && b2.cbHasPreBegin) {
										var cbm = cb_PreBegin.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
									 {
		if(b1.cbHasBegin && b2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
								}
								
								
								var cb_id2 = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreBegin && s2.cbHasPreBegin) {
									var cbm = cb_PreBegin.get(cb_id2);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
								 {
		if(s1.cbHasBegin && s2.cbHasBegin) {
			if(cb_Begin.get(cb_id2)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = cb_id2;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
								
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = false;
								s_arbiters_false_false_true_false_Shape_Particle.add(arb);
								map_arb_false_false_true_false_Shape_Particle.set(id,arb);
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								if(!cb_arb.arbiters.has(arb)) {
									cb_arb.assign_arb(arb);
									if(arb.ignore) cb_arb.ignore = true;
								}
								if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
									gr_arb.assign_arb(cb_arb);
									if(cb_arb.ignore) {
										gr_arb.ignore = true;
										arb.ignore = true;
									}
								}
								
								
								if(use_groups && !gr_arb.updated) {
									var id = IdRef.pair(g1.cbType,g2.cbType);
									if(g1.cbHasPreSolve && g2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												gr_arb.temp_ignore = true;
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												gr_arb.ignore = true;
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								
								if(!cb_arb.updated) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreSolve && b2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								id = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreSolve && s2.cbHasPreSolve) {
									var cbm = cb_PreSolve.get(id);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
							}
							
							if(gr_arb!=null && gr_arb.ignore) {
								cb_arb.ignore = arb.ignore = true;
							}else if(cb_arb.ignore) {
								arb.ignore = true;
							}
							
							
							if(use_groups && !gr_arb.updated && !(gr_arb.ignore || gr_arb.temp_ignore)) {
								var id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasPostSolve && g2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!cb_arb.updated && !(cb_arb.ignore || cb_arb.temp_ignore)) {
								var id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasPostSolve && b2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!(arb.ignore || arb.temp_ignore)) {
								var id = IdRef.pair(s1.cbType,s2.cbType);
								 {
		if(s1.cbHasPostSolve && s2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					if(scol) {
						if(!gcol) col = collide.testCollide_Shape_Particle(sa,sb);
						if(col && first) {
							var cont_obj;
							var cont_grp;
							if(!gcol) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = cb_arb.assign_arb(arb);
								if(use_groups) cont_grp = gr_arb.assign_arb(cb_arb);
								else cont_grp = false;
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = fobj;
								cont_grp = fgrp;
							}
							
							
							if(cont_grp) {
								var gr_id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasSenseBegin && g2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(gr_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = gr_id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							if(cont_obj) {
								var cb_id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasSenseBegin && b2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							cb_id = IdRef.pair(s1.cbType,s2.cbType);
							 {
		if(s1.cbHasSenseBegin && s2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							
							if(!gcol) {
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = true;
								s_arbiters_false_false_true_false_Shape_Particle.add(arb);
								map_arb_false_false_true_false_Shape_Particle.set(id,arb);
							}
						}else if(col) {
							
							{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
						}
					}
					
					if(col) {
						arb.updated    = true;
						cb_arb.updated = true;
						if(use_groups) gr_arb.updated = true;
					}
					arb.stamp = stamp;
					
					if(!col && first) arb.retire();
				}else if(first) arb.retire();
			}else if(first) arb.retire();
		}
	}public inline function narrowPhase_true_true_true_true_Shape_Shape(s1:Shape,s2:Shape) {
		var b1,b2;
		
		
		 b1 = s1.body;
		 b2 = s2.body;
		
		
		
		
		
		
		var gcol = (s1.group &s2.group) !=0;
		var scol = (s1.sensor&s2.sensor)!=0;
		if (b1!=b2 && !(b1.sleep&&b2.sleep)
		&& (gcol||scol)
		&& !(b1.imass==0&&b2.imass==0&&b1.imoment==0&&b2.imoment==0)
		&& !ignoreConstraint(b1,b2)) {
			
			var sa, sb, id; var reverse;
			
			
			{
				if(s1.type > s2.type) { sa = s2; sb = s1; }
				else if (s1.type == s2.type) {
					if( s1.id < s2.id) { sa = s1; sb = s2; }
					else               { sb = s1; sa = s2; }
				}else { sa = s1; sb = s2; }
				reverse = sa == s2;
				id = IdRef._pair(sa.id,sb.id);
			}
			
			var arb = map_arb_true_true_true_true_Shape_Shape.get(id);
			var first = arb==null;
			if(first) {
				arb = alloc.CxAlloc_Arbiter_true_true_true_true_Shape_Shape();
				arb.ignore = false;
				arb.alloc = alloc;
			}else
				reverse = sa != arb._s1;
			
			if(arb.stamp != stamp) {
				var cb_id = IdRef.pair(b1.id,b2.id);
				var cb_arb = map_objarb.get(cb_id);
				
				var g1 = b1.group_obj;
				var g2 = b2.group_obj;
				var use_groups = g1!=null && g2!=null;
				var gr_id = 0, gr_arb = null;
				if(use_groups) {
					gr_id  = IdRef.pair(g1.id,g2.id);
					gr_arb = map_grouparb.get(gr_id);
				}
				
				if(g1!=g2 || g1==null || !g1.ignore) {
					var col = false;
					var fobj = false;
					var fgrp = false;
					if(gcol) {
						if((arb.ignore || arb.temp_ignore)
						|| (cb_arb!=null && (cb_arb.ignore || cb_arb.temp_ignore))
						|| (gr_arb!=null && (gr_arb.ignore || gr_arb.temp_ignore))) {
							arb.contacts.clear();
							if(col = collide.testCollide_Shape_Shape(sa,sb)) {
								if(first) {
									arb.assign(s1,s2,id);
									
									
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									cb_arb.assign_arb(arb);
									if(use_groups)
											gr_arb.assign_arb(cb_arb);
									
									arb.sstamp = stamp;
									arb.live = true;
									arb.sensor = false;
									s_arbiters_true_true_true_true_Shape_Shape.add(arb);
									map_arb_true_true_true_true_Shape_Shape.set(id,arb);
								}else {
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									if(!cb_arb.arbiters.has(arb)) {
										cb_arb.assign_arb(arb);
										if(arb.ignore) cb_arb.ignore = true;
									}
									if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
										gr_arb.assign_arb(cb_arb);
										if(cb_arb.ignore) {
											gr_arb.ignore = true;
											arb.ignore = true;
										}
									}
								}
								
								if(gr_arb!=null && gr_arb.ignore) {
									cb_arb.ignore = arb.ignore = true;
								}else if(cb_arb.ignore) {
									arb.ignore = true;
								}
							}
						}else if(col = collide.contactCollide_true_true_true_true_Shape_Shape(sa,sb,arb,reverse)) {
							if(first) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								
								if(use_groups) {
									if(fgrp = gr_arb.assign_arb(cb_arb)) {
										var id = IdRef.pair(g1.cbType,g2.cbType);
										if(g1.cbHasPreBegin && g2.cbHasPreBegin) {
											var cbm = cb_PreBegin.get(id);
											if(cbm!=null) {
												var res = cbm(arb);
												if(res == 1) {
													gr_arb.temp_ignore = true;
													cb_arb.temp_ignore = true;
													arb.temp_ignore = true;
													arb.contacts.clear();
												}else if(res == 2) {
													gr_arb.ignore = true;
													cb_arb.ignore = true;
													arb.ignore = true;
													arb.contacts.clear();
												}
											}
										}
										 {
		if(g1.cbHasBegin && g2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
									}
								}
								
								
								if(fobj = cb_arb.assign_arb(arb)) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreBegin && b2.cbHasPreBegin) {
										var cbm = cb_PreBegin.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
									 {
		if(b1.cbHasBegin && b2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
								}
								
								
								var cb_id2 = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreBegin && s2.cbHasPreBegin) {
									var cbm = cb_PreBegin.get(cb_id2);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
								 {
		if(s1.cbHasBegin && s2.cbHasBegin) {
			if(cb_Begin.get(cb_id2)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = cb_id2;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
								
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = false;
								s_arbiters_true_true_true_true_Shape_Shape.add(arb);
								map_arb_true_true_true_true_Shape_Shape.set(id,arb);
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								if(!cb_arb.arbiters.has(arb)) {
									cb_arb.assign_arb(arb);
									if(arb.ignore) cb_arb.ignore = true;
								}
								if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
									gr_arb.assign_arb(cb_arb);
									if(cb_arb.ignore) {
										gr_arb.ignore = true;
										arb.ignore = true;
									}
								}
								
								
								if(use_groups && !gr_arb.updated) {
									var id = IdRef.pair(g1.cbType,g2.cbType);
									if(g1.cbHasPreSolve && g2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												gr_arb.temp_ignore = true;
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												gr_arb.ignore = true;
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								
								if(!cb_arb.updated) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreSolve && b2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								id = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreSolve && s2.cbHasPreSolve) {
									var cbm = cb_PreSolve.get(id);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
							}
							
							if(gr_arb!=null && gr_arb.ignore) {
								cb_arb.ignore = arb.ignore = true;
							}else if(cb_arb.ignore) {
								arb.ignore = true;
							}
							
							
							if(use_groups && !gr_arb.updated && !(gr_arb.ignore || gr_arb.temp_ignore)) {
								var id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasPostSolve && g2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!cb_arb.updated && !(cb_arb.ignore || cb_arb.temp_ignore)) {
								var id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasPostSolve && b2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!(arb.ignore || arb.temp_ignore)) {
								var id = IdRef.pair(s1.cbType,s2.cbType);
								 {
		if(s1.cbHasPostSolve && s2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					if(scol) {
						if(!gcol) col = collide.testCollide_Shape_Shape(sa,sb);
						if(col && first) {
							var cont_obj;
							var cont_grp;
							if(!gcol) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = cb_arb.assign_arb(arb);
								if(use_groups) cont_grp = gr_arb.assign_arb(cb_arb);
								else cont_grp = false;
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = fobj;
								cont_grp = fgrp;
							}
							
							
							if(cont_grp) {
								var gr_id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasSenseBegin && g2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(gr_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = gr_id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							if(cont_obj) {
								var cb_id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasSenseBegin && b2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							cb_id = IdRef.pair(s1.cbType,s2.cbType);
							 {
		if(s1.cbHasSenseBegin && s2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							
							if(!gcol) {
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = true;
								s_arbiters_true_true_true_true_Shape_Shape.add(arb);
								map_arb_true_true_true_true_Shape_Shape.set(id,arb);
							}
						}else if(col) {
							
							{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
						}
					}
					
					if(col) {
						arb.updated    = true;
						cb_arb.updated = true;
						if(use_groups) gr_arb.updated = true;
					}
					arb.stamp = stamp;
					
					if(!col && first) arb.retire();
				}else if(first) arb.retire();
			}else if(first) arb.retire();
		}
	}public inline function narrowPhase_true_true_true_false_Shape_Particle(s1:Shape,s2:Particle) {
		var b1,b2;
		
		
		 b1 = s1.body;
		 b2 = s2;
		
		
		
		
		
		
		var gcol = (s1.group &s2.group) !=0;
		var scol = (s1.sensor&s2.sensor)!=0;
		if (!(b1.sleep&&b2.sleep)
		&& (gcol||scol)
		&& !(b1.imass==0&&b2.imass==0&&b1.imoment==0&&b2.imoment==0)
		&& !ignoreConstraint(b1,b2)) {
			
			var sa, sb, id; var reverse;
			
			
			{
				id = IdRef._pair(s1.id,s2.id);
				sa = s1; sb = s2;
				reverse = false;
			}
			
			var arb = map_arb_true_true_true_false_Shape_Particle.get(id);
			var first = arb==null;
			if(first) {
				arb = alloc.CxAlloc_Arbiter_true_true_true_false_Shape_Particle();
				arb.ignore = false;
				arb.alloc = alloc;
			}else
				reverse = sa != arb._s1;
			
			if(arb.stamp != stamp) {
				var cb_id = IdRef.pair(b1.id,b2.id);
				var cb_arb = map_objarb.get(cb_id);
				
				var g1 = b1.group_obj;
				var g2 = b2.group_obj;
				var use_groups = g1!=null && g2!=null;
				var gr_id = 0, gr_arb = null;
				if(use_groups) {
					gr_id  = IdRef.pair(g1.id,g2.id);
					gr_arb = map_grouparb.get(gr_id);
				}
				
				if(g1!=g2 || g1==null || !g1.ignore) {
					var col = false;
					var fobj = false;
					var fgrp = false;
					if(gcol) {
						if((arb.ignore || arb.temp_ignore)
						|| (cb_arb!=null && (cb_arb.ignore || cb_arb.temp_ignore))
						|| (gr_arb!=null && (gr_arb.ignore || gr_arb.temp_ignore))) {
							arb.contacts.clear();
							if(col = collide.testCollide_Shape_Particle(sa,sb)) {
								if(first) {
									arb.assign(s1,s2,id);
									
									
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									cb_arb.assign_arb(arb);
									if(use_groups)
											gr_arb.assign_arb(cb_arb);
									
									arb.sstamp = stamp;
									arb.live = true;
									arb.sensor = false;
									s_arbiters_true_true_true_false_Shape_Particle.add(arb);
									map_arb_true_true_true_false_Shape_Particle.set(id,arb);
								}else {
									
									{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
									
									if(!cb_arb.arbiters.has(arb)) {
										cb_arb.assign_arb(arb);
										if(arb.ignore) cb_arb.ignore = true;
									}
									if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
										gr_arb.assign_arb(cb_arb);
										if(cb_arb.ignore) {
											gr_arb.ignore = true;
											arb.ignore = true;
										}
									}
								}
								
								if(gr_arb!=null && gr_arb.ignore) {
									cb_arb.ignore = arb.ignore = true;
								}else if(cb_arb.ignore) {
									arb.ignore = true;
								}
							}
						}else if(col = collide.contactCollide_true_true_true_false_Shape_Particle(sa,sb,arb,reverse)) {
							if(first) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								
								if(use_groups) {
									if(fgrp = gr_arb.assign_arb(cb_arb)) {
										var id = IdRef.pair(g1.cbType,g2.cbType);
										if(g1.cbHasPreBegin && g2.cbHasPreBegin) {
											var cbm = cb_PreBegin.get(id);
											if(cbm!=null) {
												var res = cbm(arb);
												if(res == 1) {
													gr_arb.temp_ignore = true;
													cb_arb.temp_ignore = true;
													arb.temp_ignore = true;
													arb.contacts.clear();
												}else if(res == 2) {
													gr_arb.ignore = true;
													cb_arb.ignore = true;
													arb.ignore = true;
													arb.contacts.clear();
												}
											}
										}
										 {
		if(g1.cbHasBegin && g2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
									}
								}
								
								
								if(fobj = cb_arb.assign_arb(arb)) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreBegin && b2.cbHasPreBegin) {
										var cbm = cb_PreBegin.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
									 {
		if(b1.cbHasBegin && b2.cbHasBegin) {
			if(cb_Begin.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
								}
								
								
								var cb_id2 = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreBegin && s2.cbHasPreBegin) {
									var cbm = cb_PreBegin.get(cb_id2);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
								 {
		if(s1.cbHasBegin && s2.cbHasBegin) {
			if(cb_Begin.get(cb_id2)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.BEGIN;
				cb.id   = cb_id2;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
								
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = false;
								s_arbiters_true_true_true_false_Shape_Particle.add(arb);
								map_arb_true_true_true_false_Shape_Particle.set(id,arb);
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								if(!cb_arb.arbiters.has(arb)) {
									cb_arb.assign_arb(arb);
									if(arb.ignore) cb_arb.ignore = true;
								}
								if(use_groups && !gr_arb.obj_arbs.has(cb_arb)) {
									gr_arb.assign_arb(cb_arb);
									if(cb_arb.ignore) {
										gr_arb.ignore = true;
										arb.ignore = true;
									}
								}
								
								
								if(use_groups && !gr_arb.updated) {
									var id = IdRef.pair(g1.cbType,g2.cbType);
									if(g1.cbHasPreSolve && g2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												gr_arb.temp_ignore = true;
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												gr_arb.ignore = true;
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								
								if(!cb_arb.updated) {
									var id = IdRef.pair(b1.cbType,b2.cbType);
									if(b1.cbHasPreSolve && b2.cbHasPreSolve) {
										var cbm = cb_PreSolve.get(id);
										if(cbm!=null) {
											var res = cbm(arb);
											if(res == 1) {
												cb_arb.temp_ignore = true;
												arb.temp_ignore = true;
												arb.contacts.clear();
											}else if(res == 2) {
												cb_arb.ignore = true;
												arb.ignore = true;
												arb.contacts.clear();
											}
										}
									}
								}
								
								id = IdRef.pair(s1.cbType,s2.cbType);
								if(s1.cbHasPreSolve && s2.cbHasPreSolve) {
									var cbm = cb_PreSolve.get(id);
									if(cbm!=null) {
										var res = cbm(arb);
										if(res == 1) {
											arb.temp_ignore = true;
											arb.contacts.clear();
										}else if(res == 2) {
											arb.ignore = true;
											arb.contacts.clear();
										}
									}
								}
							}
							
							if(gr_arb!=null && gr_arb.ignore) {
								cb_arb.ignore = arb.ignore = true;
							}else if(cb_arb.ignore) {
								arb.ignore = true;
							}
							
							
							if(use_groups && !gr_arb.updated && !(gr_arb.ignore || gr_arb.temp_ignore)) {
								var id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasPostSolve && g2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!cb_arb.updated && !(cb_arb.ignore || cb_arb.temp_ignore)) {
								var id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasPostSolve && b2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							if(!(arb.ignore || arb.temp_ignore)) {
								var id = IdRef.pair(s1.cbType,s2.cbType);
								 {
		if(s1.cbHasPostSolve && s2.cbHasPostSolve) {
			if(cb_PostSolve.get(id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.POST_SOLVE;
				cb.id   = id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							}
						}
					}
					if(scol) {
						if(!gcol) col = collide.testCollide_Shape_Particle(sa,sb);
						if(col && first) {
							var cont_obj;
							var cont_grp;
							if(!gcol) {
								arb.assign(s1,s2,id);
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = cb_arb.assign_arb(arb);
								if(use_groups) cont_grp = gr_arb.assign_arb(cb_arb);
								else cont_grp = false;
							}else {
								
								
								{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
								
								cont_obj = fobj;
								cont_grp = fgrp;
							}
							
							
							if(cont_grp) {
								var gr_id = IdRef.pair(g1.cbType,g2.cbType);
								 {
		if(g1.cbHasSenseBegin && g2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(gr_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = gr_id;
				cb.group_arb  = gr_arb;
				cb.arbiter_type = Callback.ARBITER_GROUP;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							if(cont_obj) {
								var cb_id = IdRef.pair(b1.cbType,b2.cbType);
								 {
		if(b1.cbHasSenseBegin && b2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.obj_arb  = cb_arb;
				cb.arbiter_type = Callback.ARBITER_OBJECT;
				callbacks.add(cb);
			}
		}
	};
							}
							
							
							cb_id = IdRef.pair(s1.cbType,s2.cbType);
							 {
		if(s1.cbHasSenseBegin && s2.cbHasSenseBegin) {
			if(cb_SenseBegin.get(cb_id)) {
				var cb = alloc.CxAlloc_Callback();
				cb.type = Callback.SENSE_BEGIN;
				cb.id   = cb_id;
				cb.arb  = arb;
				cb.arbiter_type = Callback.ARBITER_SHAPE;
				callbacks.add(cb);
			}
		}
	};
							
							if(!gcol) {
								arb.sstamp = stamp;
								arb.live = true;
								arb.sensor = true;
								s_arbiters_true_true_true_false_Shape_Particle.add(arb);
								map_arb_true_true_true_false_Shape_Particle.set(id,arb);
							}
						}else if(col) {
							
							{
										if(cb_arb==null) {
											cb_arb = alloc.CxAlloc_ObjArb();
											cb_arb.ignore = false;
											if(cb_arb.arbiters==null)
												cb_arb.arbiters = new CxFastList_Arbiter(alloc);
											cb_arb.assign(b1,b2);
											cb_arb.id = cb_id;
											map_objarb.set(cb_id,cb_arb);
										}
										arb.obj_arb = cb_arb;
										
										if(use_groups && gr_arb==null) {
											gr_arb = alloc.CxAlloc_GroupArb();
											gr_arb.ignore = false;
											if(gr_arb.obj_arbs==null)
												gr_arb.obj_arbs = new CxFastList_ObjArb(alloc);
											gr_arb.g1 = g1;
											gr_arb.g2 = g2;
											gr_arb.id = gr_id;
											map_grouparb.set(gr_id,gr_arb);
										}
										cb_arb.group_arb = gr_arb;
									};
						}
					}
					
					if(col) {
						arb.updated    = true;
						cb_arb.updated = true;
						if(use_groups) gr_arb.updated = true;
					}
					arb.stamp = stamp;
					
					if(!col && first) arb.retire();
				}else if(first) arb.retire();
			}else if(first) arb.retire();
		}
	}
	
	
	
	public function broadphase():Void
	{
		
	}
	public function visitate():Void
	{
		
	}
	
	public function addObject   (o:PhysObj):Void
	{
		
	}
	public function removeObject(o:PhysObj):Void
	{
		
	}
	
	public function syncShape   (s:Shape,   check:Bool) return false
	public function syncParticle(p:Particle,check:Bool) return false
	
	public function wakeObject(o:PhysObj):Void
	{
		
	}
	
	public function rayCast(r:Ray):RayResult return null
	
	public inline function sync(p:PhysObj) {
		if(p.isBody) {
			var b = p.body;
			  {
	var cxiterator = b.shapes.begin();
	while(cxiterator != b.shapes.end()) {
		var s = cxiterator.elem();
		{
			
			syncShape(s,true);
		}
		cxiterator = cxiterator.next;
	}
};
		}else
			syncParticle(p.particle,true);
	}
	
	
	
	
	public function objectAtPoint(x:Float,y:Float):PhysObj return null
	
	
	
	public inline function constrained(p:PhysObj):CxFastList_PhysObj {
		var ret = new CxFastList_PhysObj();
		_constrained(p, ret);
		return ret;
	}
	private function _constrained(p:PhysObj, list:CxFastList_PhysObj) {
		list.add(p);
		  {
	var cxiterator = p.p_constraints.begin();
	while(cxiterator != p.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var bodies = c.body_list();
			  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			if(b!=p && !list.has(b)) _constrained(b, list);
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
	
	
	
	public inline function touching(p:PhysObj):CxFastList_PhysObj {
		var ret = new CxFastList_PhysObj();
		_touching(p, ret);
		return ret;
	}
	
	private function _touching(p:PhysObj, list:CxFastList_PhysObj) {
		list.add(p);
		 {
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				var a = arb.p1;
				var b = arb.p2;
				if(a==p) { if(!list.has(b)) _touching(b, list); }
				else     { if(!list.has(a)) _touching(a, list); }
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				var a = arb.p1;
				var b = arb.p2;
				if(a==p) { if(!list.has(b)) _touching(b, list); }
				else     { if(!list.has(a)) _touching(a, list); }
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				var a = arb.p1;
				var b = arb.p2;
				if(a==p) { if(!list.has(b)) _touching(b, list); }
				else     { if(!list.has(a)) _touching(a, list); }
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				var a = arb.p1;
				var b = arb.p2;
				if(a==p) { if(!list.has(b)) _touching(b, list); }
				else     { if(!list.has(a)) _touching(a, list); }
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
	
	
	
	public inline function impactImpulse(p:PhysObj):Vec2 {
		var jsum = new Vec2();
		
		 {
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					if(!c.fresh) { cxiterator = cxiterator.next; continue; };
					
					var jnAcc = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx = c.nx*(jnAcc); jy = c.ny*(jnAcc);  } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					if(!c.fresh) { cxiterator = cxiterator.next; continue; };
					
					var jnAcc = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx = c.nx*(jnAcc); jy = c.ny*(jnAcc);  } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					if(!c.fresh) { cxiterator = cxiterator.next; continue; };
					
					var jnAcc = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx = c.nx*(jnAcc); jy = c.ny*(jnAcc);  } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					if(!c.fresh) { cxiterator = cxiterator.next; continue; };
					
					var jnAcc = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx = c.nx*(jnAcc); jy = c.ny*(jnAcc);  } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		}
		
		return jsum;
	}
	
	public inline function totalImpulsesWithFriction(p:PhysObj):Vec2 {
		var jsum = new Vec2();
		var j    = new Vec2();
		
		 {
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		} {
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsum.px -= jx; jsum.py -= jy; } ;
					else             { jsum.px += jx; jsum.py += jy; } ;
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
		}
		
		  {
	var cxiterator = p.p_constraints.begin();
	while(cxiterator != p.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			c.impulse(p,j);
			 { jsum.px += j.px; jsum.py += j.py; } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		return jsum;
	}
	
	public inline function totalImpulses(p:PhysObj):Vec2 {
		var jsum = new Vec2();
		var j    = new Vec2();
		
		
		
		  {
	var cxiterator = p.p_constraints.begin();
	while(cxiterator != p.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			c.impulse(p,j);
			 { jsum.px += j.px; jsum.py += j.py; } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		return jsum;
	}
	
	
	
	public inline function pressure(p:PhysObj):Float {
		var sum = 0.0;
		 {
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			sum += c.jnAcc + c.pjnAcc;
		}
		cxiterator = cxiterator.next;
	}
};
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			sum += c.jnAcc + c.pjnAcc;
		}
		cxiterator = cxiterator.next;
	}
};
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			sum += c.jnAcc + c.pjnAcc;
		}
		cxiterator = cxiterator.next;
	}
};
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			sum += c.jnAcc + c.pjnAcc;
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
		
		var j = new Vec2();
		  {
	var cxiterator = p.p_constraints.begin();
	while(cxiterator != p.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			c.impulse(p,j);
			sum +=  FastMath.sqrt( (j.px*j.px + j.py*j.py)   ) ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		return sum;
	}
	
	public inline function crushFactor(p:PhysObj):Float {
		var fsum = 0.0;
		     var jsumx:Float = 0; var jsumy:Float = 0 ;
		var j    = new Vec2();
		
		 {
			
			
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsumx -= jx; jsumy -= jy; } ;
					else             { jsumx += jx; jsumy += jy; } ;
					fsum +=  FastMath.sqrt( (jx*jx + jy*jy)   ) ;
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
		} {
			
			
			
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsumx -= jx; jsumy -= jy; } ;
					else             { jsumx += jx; jsumy += jy; } ;
					fsum +=  FastMath.sqrt( (jx*jx + jy*jy)   ) ;
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
		} {
			
			
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsumx -= jx; jsumy -= jy; } ;
					else             { jsumx += jx; jsumy += jy; } ;
					fsum +=  FastMath.sqrt( (jx*jx + jy*jy)   ) ;
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
		} {
			
			
			
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				
				  {
	var cxiterator = arb.contacts.begin();
	while(cxiterator != arb.contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
					   var jcx:Float;  var jcy:Float      ;
					jcx = c.jtAcc + c.pjtAcc;
					jcy = c.jnAcc + c.pjnAcc;
					   var jx:Float;  var jy:Float      ;  { jx =  (jcx*c.ny - jcy*c.nx) ;     jy =  (jcx*c.nx + jcy*c.ny) ;      } ;
					
					if(arb.p1 == p)  { jsumx -= jx; jsumy -= jy; } ;
					else             { jsumx += jx; jsumy += jy; } ;
					fsum +=  FastMath.sqrt( (jx*jx + jy*jy)   ) ;
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
		}
		
		  {
	var cxiterator = p.p_constraints.begin();
	while(cxiterator != p.p_constraints.end()) {
		var c = cxiterator.elem();
		{
			
			{
			c.impulse(p,j);
			fsum +=  FastMath.sqrt( (j.px*j.px + j.py*j.py)   ) ;
			 { jsumx += j.px; jsumy += j.py; } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		return fsum- FastMath.sqrt( (jsumx*jsumx + jsumy*jsumy)   ) ;
	}
	
	
	
	public inline function syncMaterials(p:PhysObj) {
		 {
			  {
	var cxiterator = p.p_arbiters_false_false_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_false_false_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				arb.calcProperties();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_false_false_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_false_false_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				arb.calcProperties();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_true_Shape_Shape.begin();
	while(cxiterator != p.p_arbiters_true_true_true_true_Shape_Shape.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				arb.calcProperties();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		} {
			  {
	var cxiterator = p.p_arbiters_true_true_true_false_Shape_Particle.begin();
	while(cxiterator != p.p_arbiters_true_true_true_false_Shape_Particle.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				if(arb.sensor) { cxiterator = cxiterator.next; continue; };
				arb.calcProperties();
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
	}
}















