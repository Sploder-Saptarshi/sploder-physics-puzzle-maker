package nape.dynamics;
import cx.FastList;
import cx.Allocator;
import cx.Algorithm;
import nape.dynamics.ObjArb;
import nape.dynamics.Contact;
import nape.phys.PhysObj;
import nape.phys.Body;
import nape.geom.Vec2;
import nape.geom.VecMath;

//'newfile' define generated imports
import cx.CxFastList_Contact;




















class Arbiter {
	public var id:Int;
	
	
	public var obj_arb:ObjArb;
	public var ignore:Bool;
	public var temp_ignore:Bool;
	public var sensor:Bool;
	
	
	
	public var dyn_fric :Float;
	public var stat_fric:Float;
	public var restitution:Float;
	
	
	
	
	public var stamp:Int;
	public var updated:Bool;
	public var alloc:Allocator;
	
	
	
	
	public var contacts:CxFastList_Contact;
	public var p1:PhysObj; public var b1:Body; 
	public var p2:PhysObj; public var b2:Body;
	
	
	
	
	public var live:Bool;
	public var woken:Bool;
	public var sstamp:Int;
	
	
	
	public function new () {
		contacts = new CxFastList_Contact();
	}
	
	
	
	
	public inline function getObjectA():Dynamic return untyped this._s1
	public inline function getObjectB():Dynamic return untyped this._s2
	
	
	
	public inline function impactImpulse():Vec2 {
		var ret = new Vec2();
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			if(!c.fresh) { cxiterator = cxiterator.next; continue; };
			
			var jnAcc = c.jnAcc + c.pjnAcc;
			 { ret.px += c.nx*(jnAcc); ret.py += c.ny*(jnAcc); } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return ret;
	}
	
	public inline function totalImpulse():Vec2 {
		var ret = new Vec2();
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			var jnAcc = c.jnAcc + c.pjnAcc;
			 { ret.px += c.nx*(jnAcc); ret.py += c.ny*(jnAcc); } ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return ret;
	}
	
	public inline function totalImpulseWithFriction():Vec2 {
		var ret = new Vec2();
		  {
	var cxiterator = contacts.begin();
	while(cxiterator != contacts.end()) {
		var c = cxiterator.elem();
		{
			
			{
			   var jx:Float;  var jy:Float      ;
			jx = c.jtAcc + c.pjtAcc;
			jy = c.jnAcc + c.pjnAcc;
			ret.px +=  (jx*c.ny - jy*c.nx) ;
			ret.py +=  (jx*c.nx + jy*c.ny) ;
		};
		}
		cxiterator = cxiterator.next;
	}
};
		return ret;
	}
	
}
