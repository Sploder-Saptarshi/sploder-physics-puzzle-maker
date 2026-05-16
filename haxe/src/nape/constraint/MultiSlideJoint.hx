package nape.constraint;
import cx.FastList;
import cx.Algorithm;
import nape.geom.Vec2;
import nape.geom.VecMath;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.util.FastMath;
import nape.Const;
import nape.constraint.Constraint;
import nape.constraint.Anchor;
import nape.constraint.MPConsPair;

//'newfile' define generated imports
import cx.CxFastList_PhysObj;
import cx.CxFastList_MPConsPair;
import cx.CxFastList_Anchor;




















class MultiSlideJoint extends Constraint {
	public var bodies:CxFastList_PhysObj;
	public var bodycnt:IntHash<Int>;
	
	public var cpairs:CxFastList_MPConsPair;
	public var apairs:CxFastList_Anchor;
	
	public var nMass:Float;
	public var bias:Float;
	public var jnAcc:Float;
	public var jnMax:Float;
	
	public var jointMin:Float;
	public var jointMax:Float;
	public var slack:Bool;
	public var scale:Float;
	
	
	
	public function new (objects:Array<PhysObj>,anchors:Array<Vec2>,?ratios:Array<Float>, min:Float,max:Float) {
		super();
		bodies  = new CxFastList_PhysObj();
		bodycnt = new IntHash<Int>();
		cpairs  = new CxFastList_MPConsPair();
		apairs  = new CxFastList_Anchor();
		jointMin = min;
		jointMax = max;
		jnAcc = 0;
		
		if(ratios==null) {
			ratios = new Array<Float>();
			for(i in 0...(objects.length>>1)) ratios.push(1.0);
		}
		
		var bi = null;
		for(b in objects) {
			if(bodycnt.exists(b.id)) bodycnt.set(b.id,bodycnt.get(b.id)+1);
			else {
				bodycnt.set(b.id,1);
				bi = bodies.insert(bi,b);
			}
		}
		
		var i = 0;
		var ai = null;
		for(a in anchors) {
			var nv = new Vec2();
			var b = objects[i++];
			 {
	   var tx:Float;  var ty:Float      ;
	 { tx = a.px-b.px; ty = a.py-b.py;  } ;
	 { nv.px = tx*b.roty+ty*b.rotx; nv.py = ty*b.roty-tx*b.rotx;} ;
};
			ai = apairs.insert(ai, new Anchor(nv,new Vec2(),b));
		}
		
		ai = apairs.begin();
		var ci = null;
		   var deltax:Float;  var deltay:Float      ;
		for(r in ratios) {
			var a1 = ai.elem(); var a2 = (ai=ai.next).elem(); ai=ai.next;
			var cp = new MPConsPair(a1,a2,r);
			ci = cpairs.insert(ci,cp);
		}
	}
	
	
	
	public override function preStep(dt:Float) {
		  {
	var cxiterator = apairs.begin();
	while(cxiterator != apairs.end()) {
		var a = cxiterator.elem();
		{
			
			{
			var la = a.la; var pa = a.pa; var b = a.b;
			  { pa.px =  (la.px*b.roty - la.py*b.rotx) ;     pa.py =  (la.px*b.rotx + la.py*b.roty) ;      } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		var tot_dist = 0.0;
		var inMass   = 0.0;
		  {
	var cxiterator = cpairs.begin();
	while(cxiterator != cpairs.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var a1 = c.a1; var b1 = a1.b; var p1 = a1.pa;
			var a2 = c.a2; var b2 = a2.b; var p2 = a2.pa;
			
			 {
	c.nx = (b2.px+p2.px)-(b1.px+p1.px);
	c.ny = (b2.py+p2.py)-(b1.py+p1.py);
};
			var dist;  {
	var idist; dist =  (c.nx*c.nx + c.ny*c.ny)   ;
	if(dist>Const.EPSILON) { idist = FastMath.invsqrt(dist); dist = 1.0/idist; }
	else                   idist = 0;
	 { c.nx *= idist;   c.ny *= idist;   } ;
};
			
			tot_dist += dist*c.coef;
			inMass += c.coef*c.coef*( (b1.smass+b1.smoment*Calc.sq( (p1.px*c.ny - p1.py*c.nx) ))*bodycnt.get(b1.id)
			                        + (b2.smass+b2.smoment*Calc.sq( (p2.px*c.ny - p2.py*c.nx) ))*bodycnt.get(b2.id));
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		nMass = if(inMass<Const.EPSILON) 0.0 else 1.0 / inMass;
		jnMax = maxForce*dt;
		
		var dist;
		if(tot_dist>jointMax)  {
			dist = jointMax  - tot_dist;
			bias = Calc.clamp(biasCoef*dist/dt,maxBias);
			slack = false;
			scale = 1;
		}else if(tot_dist<jointMin) {
			dist = tot_dist - jointMin;
			bias = Calc.clamp(biasCoef*dist/dt,maxBias);
			slack = false;
			scale = -1;
		} else {
			dist  = 0;
			jnAcc = 0;
			nMass = 0;
			bias = 0;
			slack = true;
		}
		
		if(bias!=0) {
			  {
	var cxiterator = cpairs.begin();
	while(cxiterator != cpairs.end()) {
		var c = cxiterator.elem();
		{
			
			{
				var a1 = c.a1; var b1 = a1.b; var p1 = a1.pa;
				var a2 = c.a2; var b2 = a2.b; var p2 = a2.pa;
				
				var jn = jnAcc*c.coef*scale;
				 {
	var jx = c.nx*jn - c.ny*0;
	var jy = c.ny*jn + c.nx*0;
	 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (p1.px*jy - p1.py*jx) ;
	b2.w += b2.imoment *  (p2.px*jy - p2.py*jx) ;
};
};
			};
		}
		cxiterator = cxiterator.next;
	}
};
		}
		
		return false;
	}
	
	public override function applyImpulse() {
		if(slack) return false;
		
		var vdot = 0.0;
		   var vrx:Float;  var vry:Float      ;
		  {
	var cxiterator = cpairs.begin();
	while(cxiterator != cpairs.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var a1 = c.a1; var b1 = a1.b; var p1 = a1.pa;
			var a2 = c.a2; var b2 = a2.b; var p2 = a2.pa;
			
			 {
	vrx = (p1.py*b1.w + b2.vx) - (p2.py*b2.w + b1.vx);
	vry = (p2.px*b2.w + b2.vy) - (p1.px*b1.w + b1.vy);
};
			vdot +=  (vrx*c.nx + vry*c.ny) *c.coef;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		var jn = nMass*(bias-vdot*scale);
		var jnOld = jnAcc; jnAcc += jn;
		if(breakable) { if(jnAcc*jnAcc>jnMax*jnMax) return true; }
		
		jnAcc = Calc.range(jnAcc,-jnMax,0);
		jn = jnAcc-jnOld;
		
		  {
	var cxiterator = cpairs.begin();
	while(cxiterator != cpairs.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var a1 = c.a1; var b1 = a1.b; var p1 = a1.pa;
			var a2 = c.a2; var b2 = a2.b; var p2 = a2.pa;
			
			var pjn = jn*c.coef*scale;
			 {
	var jx = c.nx*pjn - c.ny*0;
	var jy = c.ny*pjn + c.nx*0;
	 {
	 { b1.vx -= jx*(b1.imass); b1.vy -= jy*(b1.imass); } ;
	 { b2.vx += jx*(b2.imass); b2.vy += jy*(b2.imass); } ;
	b1.w -= b1.imoment *  (p1.px*jy - p1.py*jx) ;
	b2.w += b2.imoment *  (p2.px*jy - p2.py*jx) ;
};
};
		};
		}
		cxiterator = cxiterator.next;
	}
};
		
		return false;
	}
	

	
	
	public override function impulse(obj:PhysObj,dst:Vec2) {
		if(slack) return;
		
		 { dst.px = 0;   dst.py = 0;   } ;
		  {
	var cxiterator = cpairs.begin();
	while(cxiterator != cpairs.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var b1 = c.a1.b;
			var b2 = c.a2.b;
			if     (obj==b1)  { dst.px -= c.nx*(jnAcc*c.coef*scale); dst.py -= c.ny*(jnAcc*c.coef*scale); } ;
			else if(obj==b2)  { dst.px += c.nx*(jnAcc*c.coef*scale); dst.py += c.ny*(jnAcc*c.coef*scale); } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	
	
	public override function addToBodies() {
		  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			b.p_constraints.add(this);
		}
		cxiterator = cxiterator.next;
	}
};
	}
	public override function removeFromBodies() {
		  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			b.p_constraints.remove(this);
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	public override function wakeBodies(space:Space) {
		  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			space.wakeObject(b);
		}
		cxiterator = cxiterator.next;
	}
};
	}
	
	public override function bodyPairExists(a:PhysObj,b:PhysObj) {
		var fst = false; var snd = false;
		  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var x = cxiterator.elem();
		{
			
			{
			if(x==a) fst = true;
			if(x==b) snd = true;
			if(fst&&snd) return true;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return false;
	}
		
	
	public override function body_list() return bodies
	
	public override function anyBodiesAwake()
		return  ({
	var ret = false;
	  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			{
		if(!b.sleep) {
			ret = true;
			break;
		}
	};
		}
		cxiterator = cxiterator.next;
	}
};
	ret;
})
	
	public override function disallowBodySleep() {
		  {
	var cxiterator = bodies.begin();
	while(cxiterator != bodies.end()) {
		var b = cxiterator.elem();
		{
			
			if(b.id!=0) b.evslp=0;
		}
		cxiterator = cxiterator.next;
	}
};
	}
}
