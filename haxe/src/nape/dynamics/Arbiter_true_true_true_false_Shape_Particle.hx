package nape.dynamics;
import cx.Algorithm;
import cx.Allocator;
import nape.callbacks.Callback;
import nape.dynamics.Arbiter;
import nape.geom.VecMath;
import nape.shape.Shape;
import nape.phys.Particle;
import nape.phys.PhysObj;
import nape.util.FastMath;
import nape.Config;
import nape.Const;

//'newfile' define generated imports
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;

class Arbiter_true_true_true_false_Shape_Particle extends Arbiter {
	
	public var next:Arbiter_true_true_true_false_Shape_Particle;
	
	
	public var _s1:Shape;
	public var _s2:Particle;
	
	
	
	public function new () {
		super();
	}

	
	
	public inline function retire() {
		if(p1!=null) {
			p1.p_arbiters_true_true_true_false_Shape_Particle.remove(this);
			p2.p_arbiters_true_true_true_false_Shape_Particle.remove(this);
		}
		live  = false;
		woken = true;
		updated = false;
		ignore = false;
		p1 = p2 = null;
		while(!contacts.empty()) { var c = contacts.front(); contacts.pop(); alloc.CxFree_Contact(c); }
		alloc.CxFree_Arbiter_true_true_true_false_Shape_Particle(this);
		stamp = 0;
	}
	
	
	
	public inline function injectContact(px:Float,py:Float,nx:Float,ny:Float,dist:Float,hash:Int) {
		var c:Contact = null;
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var cur = cxiterator.elem();
		{
			
			if(hash==cur.hash) { c = cur; break; };
		}
		cxiterator = cxiterator.next;
	}
};
		if(c==null) {
			c = alloc.CxAlloc_Contact();
			c.cb_rest = c.cb_dyn = c.cb_stat = -1;
			c.hash   = hash;
			c.jnAcc  = c.jtAcc = 0;
			c.sBias  = -1;
			c.fresh  = true;
			contacts.add(c);
		}else c.fresh = false;
		 { c.px = px; c.py = py; } ;
		 { c.nx = nx; c.ny = ny; } ;
		c.dist = dist;
		c.updated = true;
	}
	
	
	
	public inline function assign(s1:Shape,s2:Particle,ID:Int) {
		
		
		 p1 = b1 = s1.body;
		 p2 = s2;
		_s1 = s1;
		_s2 = s2;
		id = ID;
		
		p1.p_arbiters_true_true_true_false_Shape_Particle.add(this);
		p2.p_arbiters_true_true_true_false_Shape_Particle.add(this);
		
		calcProperties();
		
		live  = false;
		woken = true;
	}
	
	public inline function calcProperties() {
		restitution = FastMath.sqrt(_s1.material.eCoef     * _s2.material.eCoef    );
		dyn_fric    = FastMath.sqrt(_s1.material.dyn_fric  * _s2.material.dyn_fric );
		stat_fric   = FastMath.sqrt(_s1.material.stat_fric * _s2.material.stat_fric);
	}
	
	
	
	
	
	
	
	
	
	public inline function preStep() {
		var mass_sum = (if(true) p1.smass else 0)
					 + (if(true) p2.smass else 0);
		var pre = null;
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			if (!c.updated) {
				cxiterator = contacts.erase(pre,cxiterator);
				alloc.CxFree_Contact(c);
				continue;
			}
			c.updated = false;
			
			var kn = mass_sum;
			var kt = mass_sum;
			
			if(true)  {
		 { c.r1x = c.px-p1.px; c.r1y = c.py-p1.py;  } 
		var rcn =  (c.r1x*c.ny - c.r1y*c.nx) ;
		var rct =  (c.r1x*c.nx + c.r1y*c.ny) ;
		kn += b1.smoment * rcn*rcn;
		kt += b1.smoment * rct*rct;
	};
			if(false)  {
		 { c.r2x = c.px-p2.px; c.r2y = c.py-p2.py;  } 
		var rcn =  (c.r2x*c.ny - c.r2y*c.nx) ;
		var rct =  (c.r2x*c.nx + c.r2y*c.ny) ;
		kn += b2.smoment * rcn*rcn;
		kt += b2.smoment * rct*rct;
	};
			c.nMass = if(kn<Const.EPSILON) 0 else 1.0/kn;
			c.tMass = if(kt<Const.EPSILON) 0 else 1.0/kt;
			
			   var vrx:Float;  var vry:Float      ;  {
		vrx = (if(true) c.r1y * b1.w else 0)
		     - (if(false) c.r2y * b2.w else 0)
		     - (if(true) p1.vx        else 0)
		     + (if(true) p2.vx        else 0);
		
		vry = (if(false) c.r2x * b2.w else 0)
		     - (if(true) c.r1x * b1.w else 0)
		     - (if(true) p1.vy        else 0)
		     + (if(true) p2.vy        else 0);
	}
			var vdot =  (c.nx*vrx + c.ny*vry) ;
			c.bias = c.dist+Config.OVERLAP;
			var nb = Config.MAX_BIAS_COEF - Config.DEL_BIAS_COEF / (1 + Config.VEL_BIAS_COEF * vdot*vdot - c.bias*Config.BIAS_PEN_COEF);
			if(c.sBias==-1) c.sBias = nb;
			else            c.sBias = Config.INT_BIAS_COEF * c.sBias + Config.SUB_BIAS_COEF * nb;
			
			if(c.bias>0) c.bias = 0;
			else         c.bias = -c.sBias*c.bias;
			c.jBias = 0;
			
			if(c.cb_rest!=-1) c.bounce = vdot*c.cb_rest;
			else              c.bounce = vdot*restitution;
			
			vdot =  (c.nx*vry - c.ny*vrx) ;
			if(vdot*vdot>Config.STATIC_VELSQ) {
				if(c.cb_dyn!=-1) c.friction = c.cb_dyn;
				else             c.friction = dyn_fric;
			}else {
				if(c.cb_stat!=-1) c.friction = c.cb_stat;
				else              c.friction = stat_fric;
			}
			
			c.cb_rest = c.cb_dyn = c.cb_stat = -1;
				
			pre = cxiterator;
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	
	
	
	
	public inline function applyImpulseCache() {
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			c.pjnAcc = c.jnAcc;
			c.pjtAcc = c.jtAcc;
			c.pjBias = c.jBias;
			 {
		var jx = c.nx*c.jnAcc - c.ny*c.jtAcc;
		var jy = c.ny*c.jnAcc + c.nx*c.jtAcc;
		
		if(true)  { p1.vx -= jx*(p1.imass); p1.vy -= jy*(p1.imass); } ;
		if(true)  { p2.vx += jx*(p2.imass); p2.vy += jy*(p2.imass); } ;
		if(true) b1.w -= b1.imoment *  (c.r1x*jy - c.r1y*jx) ;
		if(false) b2.w += b2.imoment *  (c.r2x*jy - c.r2y*jx) ;
	};
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	
	
	public inline function applyImpulsePos()  {
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			   var vrx:Float;  var vry:Float      ;  {
		vrx = (if(true) c.r1y * b1.bw else 0)
		     - (if(false) c.r2y * b2.bw else 0)
		     - (if(true) p1.bvx        else 0)
		     + (if(true) p2.bvx        else 0);
		
		vry = (if(false) c.r2x * b2.bw else 0)
		     - (if(true) c.r1x * b1.bw else 0)
		     - (if(true) p1.bvy        else 0)
		     + (if(true) p2.bvy        else 0);
	}
			
			
			var jbn = (c.bias -  (vrx*c.nx + vry*c.ny) ) * c.nMass;
			var jbnOld = c.jBias;
			var cjBias = jbnOld + jbn; if (cjBias < 0) cjBias = 0;
			var jb = cjBias - jbnOld;
			c.jBias = cjBias;
			
			 {
		var jx = c.nx*jb - c.ny*0;
		var jy = c.ny*jb + c.nx*0;
		
		if(true)  { p1.bvx -= jx*(p1.imass); p1.bvy -= jy*(p1.imass); } ;
		if(true)  { p2.bvx += jx*(p2.imass); p2.bvy += jy*(p2.imass); } ;
		if(true) b1.bw -= b1.imoment *  (c.r1x*jy - c.r1y*jx) ;
		if(false) b2.bw += b2.imoment *  (c.r2x*jy - c.r2y*jx) ;
	};
			
			 {
		vrx = (if(true) c.r1y * b1.w else 0)
		     - (if(false) c.r2y * b2.w else 0)
		     - (if(true) p1.vx        else 0)
		     + (if(true) p2.vx        else 0);
		
		vry = (if(false) c.r2x * b2.w else 0)
		     - (if(true) c.r1x * b1.w else 0)
		     - (if(true) p1.vy        else 0)
		     + (if(true) p2.vy        else 0);
	}
			
			var jn = ((if(false) c.bounce else 0 ) +  (c.nx*vrx + c.ny*vry) )*c.nMass;
			var jnOld = c.jnAcc;
			var cjnAcc = jnOld - jn; if (cjnAcc<0) cjnAcc = 0;
			jn = cjnAcc - jnOld;
			c.jnAcc = cjnAcc;
			
			
			var jt = ( (c.nx*vry - c.ny*vrx) ) * c.tMass;
			var jtMax = c.friction * c.jnAcc;
			var jtOld = c.jtAcc;
			var cjtAcc = jtOld - jt; if (cjtAcc>jtMax) cjtAcc = jtMax else if(cjtAcc<-jtMax) cjtAcc = -jtMax;
			jt = cjtAcc - jtOld;
			c.jtAcc = cjtAcc;

			 {
		var jx = c.nx*jn - c.ny*jt;
		var jy = c.ny*jn + c.nx*jt;
		
		if(true)  { p1.vx -= jx*(p1.imass); p1.vy -= jy*(p1.imass); } ;
		if(true)  { p2.vx += jx*(p2.imass); p2.vy += jy*(p2.imass); } ;
		if(true) b1.w -= b1.imoment *  (c.r1x*jy - c.r1y*jx) ;
		if(false) b2.w += b2.imoment *  (c.r2x*jy - c.r2y*jx) ;
	};
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	public inline function applyImpulseVel()  {
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			   var vrx:Float;  var vry:Float      ;  {
		vrx = (if(true) c.r1y * b1.bw else 0)
		     - (if(false) c.r2y * b2.bw else 0)
		     - (if(true) p1.bvx        else 0)
		     + (if(true) p2.bvx        else 0);
		
		vry = (if(false) c.r2x * b2.bw else 0)
		     - (if(true) c.r1x * b1.bw else 0)
		     - (if(true) p1.bvy        else 0)
		     + (if(true) p2.bvy        else 0);
	}
			
			
			var jbn = (c.bias -  (vrx*c.nx + vry*c.ny) ) * c.nMass;
			var jbnOld = c.jBias;
			var cjBias = jbnOld + jbn; if (cjBias < 0) cjBias = 0;
			var jb = cjBias - jbnOld;
			c.jBias = cjBias;
			
			 {
		var jx = c.nx*jb - c.ny*0;
		var jy = c.ny*jb + c.nx*0;
		
		if(true)  { p1.bvx -= jx*(p1.imass); p1.bvy -= jy*(p1.imass); } ;
		if(true)  { p2.bvx += jx*(p2.imass); p2.bvy += jy*(p2.imass); } ;
		if(true) b1.bw -= b1.imoment *  (c.r1x*jy - c.r1y*jx) ;
		if(false) b2.bw += b2.imoment *  (c.r2x*jy - c.r2y*jx) ;
	};
			
			 {
		vrx = (if(true) c.r1y * b1.w else 0)
		     - (if(false) c.r2y * b2.w else 0)
		     - (if(true) p1.vx        else 0)
		     + (if(true) p2.vx        else 0);
		
		vry = (if(false) c.r2x * b2.w else 0)
		     - (if(true) c.r1x * b1.w else 0)
		     - (if(true) p1.vy        else 0)
		     + (if(true) p2.vy        else 0);
	}
			
			var jn = ((if(true) c.bounce else 0 ) +  (c.nx*vrx + c.ny*vry) )*c.nMass;
			var jnOld = c.jnAcc;
			var cjnAcc = jnOld - jn; if (cjnAcc<0) cjnAcc = 0;
			jn = cjnAcc - jnOld;
			c.jnAcc = cjnAcc;
			
			
			var jt = ( (c.nx*vry - c.ny*vrx) ) * c.tMass;
			var jtMax = c.friction * c.jnAcc;
			var jtOld = c.jtAcc;
			var cjtAcc = jtOld - jt; if (cjtAcc>jtMax) cjtAcc = jtMax else if(cjtAcc<-jtMax) cjtAcc = -jtMax;
			jt = cjtAcc - jtOld;
			c.jtAcc = cjtAcc;

			 {
		var jx = c.nx*jn - c.ny*jt;
		var jy = c.ny*jn + c.nx*jt;
		
		if(true)  { p1.vx -= jx*(p1.imass); p1.vy -= jy*(p1.imass); } ;
		if(true)  { p2.vx += jx*(p2.imass); p2.vy += jy*(p2.imass); } ;
		if(true) b1.w -= b1.imoment *  (c.r1x*jy - c.r1y*jx) ;
		if(false) b2.w += b2.imoment *  (c.r2x*jy - c.r2y*jx) ;
	};
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
}