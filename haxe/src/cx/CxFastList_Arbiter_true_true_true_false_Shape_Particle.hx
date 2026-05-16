package cx;
import DummyNapeMain;
import nape.callbacks.Callback;
import nape.callbacks.Callbackable;
import nape.callbacks.CbType;
import nape.Config;
import nape.Const;
import nape.constraint.Anchor;
import nape.constraint.ClassicCons;
import nape.constraint.Constraint;
import nape.constraint.DampedRotarySpring;
import nape.constraint.DampedSpring;
import nape.constraint.GearJoint;
import nape.constraint.GrooveJoint;
import nape.constraint.MPConsPair;
import nape.constraint.MultiPinJoint;
import nape.constraint.MultiSlideJoint;
import nape.constraint.PinJoint;
import nape.constraint.PivotJoint;
import nape.constraint.PulleyJoint;
import nape.constraint.RotaryLimitJoint;
import nape.constraint.SimpleMotor;
import nape.constraint.SlideJoint;
import nape.constraint.TwoConstraint;
import nape.dynamics.Arbiter;
import nape.dynamics.Collide;
import nape.dynamics.Contact;
import nape.dynamics.GroupArb;
import nape.dynamics.ObjArb;
import nape.dynamics.SubArbiters;
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
import nape.space.BruteSpace;
import nape.space.Space;
import nape.space.UniformDynamicSpace;
import nape.space.UniformSleepSpace;
import nape.space.UniformSpace;
import nape.util.Array2;
import nape.util.FastMath;
import nape.util.FixedStep;
import nape.util.IdRef;
import nape.util.Tools;
import cx.Algorithm;
import cx.Allocator;
import cx.MixList;
import DummyCxMain;
import cx.CxFastNode_PhysObj;
import cx.CxFastList_PhysObj;
import cx.CxFastNode_MPConsPair;
import cx.CxFastList_MPConsPair;
import cx.CxFastNode_Anchor;
import cx.CxFastList_Anchor;
import cx.CxFastNode_Contact;
import cx.CxFastList_Contact;
import cx.CxFastNode_ObjArb;
import cx.CxFastList_ObjArb;
import cx.CxFastNode_Arbiter;
import cx.CxFastList_Arbiter;
import cx.CxFastNode_Arbiter_false_false_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_false_false_true_true_Shape_Shape;
import nape.dynamics.Arbiter_false_false_true_true_Shape_Shape;
import cx.CxFastNode_Arbiter_false_false_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_false_false_true_false_Shape_Particle;
import nape.dynamics.Arbiter_false_false_true_false_Shape_Particle;
import cx.CxFastNode_Arbiter_true_true_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_true_true_true_true_Shape_Shape;
import nape.dynamics.Arbiter_true_true_true_true_Shape_Shape;
import cx.CxFastList_Arbiter_true_true_true_false_Shape_Particle;
import nape.dynamics.Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastNode_GeomPoly;
import cx.CxFastList_GeomPoly;
import cx.CxFastNode_UniformSleepCell;
import cx.CxFastList_UniformSleepCell;
import cx.CxFastNode_Constraint;
import cx.CxFastList_Constraint;
import cx.CxFastNode_Shape;
import cx.CxFastList_Shape;
import cx.CxFastNode_Body;
import cx.CxFastList_Body;
import cx.CxFastNode_Particle;
import cx.CxFastList_Particle;
import cx.CxFastNode_Group;
import cx.CxFastList_Group;
import cx.CxFastNode_Properties;
import cx.CxFastList_Properties;
import cx.CxFastNode_Callback;
import cx.CxFastAllocList_Callback;
import cx.CxFastNode_UniformCell;
import cx.CxFastList_UniformCell;

//'newfile' define generated imports
import cx.CxFastNode_Arbiter_true_true_true_false_Shape_Particle;
import cx.CxFastList_Arbiter_true_true_true_false_Shape_Particle;

class CxFastList_Arbiter_true_true_true_false_Shape_Particle {
	
	private var head:CxFastNode_Arbiter_true_true_true_false_Shape_Particle;
	private var alloc:Allocator;
	
	
	
	public function new(?a:Allocator) {
		alloc = if(a==null) Allocator.GLOBAL else a;
	}
	
	
	
	
	public inline function add(o:Arbiter_true_true_true_false_Shape_Particle) {
		var temp =  {
		var ret = alloc.CxAlloc_CxFastNode_Arbiter_true_true_true_false_Shape_Particle();
		ret.elt = o;
		ret;
	};
		temp.next = begin();
		 head=temp;
	}
	public inline function addAll(list:CxFastList_Arbiter_true_true_true_false_Shape_Particle) {
		   {
	var cxiterator = list.begin();
	while(cxiterator != list.end()) {
		var i = cxiterator.elem();
		{
			
			add(i);
		}
		cxiterator = cxiterator.next;
	}
};
	}
	public inline function pop():Void {
		var ret = begin();
		 head=ret.next;
		 {};
		 alloc.CxFree_CxFastNode_Arbiter_true_true_true_false_Shape_Particle(ret);
	}
	public inline function remove(obj:Arbiter_true_true_true_false_Shape_Particle):Bool {
		var pre = null;
		var cur = begin();
		var ret = false;
		while(cur!=end()) {
			if(cur.elem()==obj) {
				cur = erase(pre,cur);
				ret = true;
				break;
			}
			pre = cur;
			cur = cur.next;
		}
		return ret;
	}
	public inline function erase(pre:CxFastNode_Arbiter_true_true_true_false_Shape_Particle,cur:CxFastNode_Arbiter_true_true_true_false_Shape_Particle):CxFastNode_Arbiter_true_true_true_false_Shape_Particle {
		var old = cur; cur = cur.next;
		if(pre==null)  head=cur;
		else          pre.next = cur;
		 {};
		 alloc.CxFree_CxFastNode_Arbiter_true_true_true_false_Shape_Particle(old);
		return cur;
	}
	public inline function splice(pre:CxFastNode_Arbiter_true_true_true_false_Shape_Particle,cur:CxFastNode_Arbiter_true_true_true_false_Shape_Particle,n:Int):CxFastNode_Arbiter_true_true_true_false_Shape_Particle {
		while(n-->0 && cur!=end())
			cur = erase(pre,cur);
		return cur;
	}
	public inline function clear() {
		if(true) {
			while(!empty()) {
				var old = begin();
				 head=old.next;
				 {};
				 alloc.CxFree_CxFastNode_Arbiter_true_true_true_false_Shape_Particle(old);
			}
		}else  head=end();
	}
	public inline function reverse() {
		if(!empty()) {
			var ui = begin().next;
			begin().next = end();
			while(ui!=end()) {
				var next = ui.next;
				ui.next = begin();
				 head=ui;
				ui = next;
			}
		}
	}
	
	public inline function empty():Bool return begin()==end()
	public inline function size():Int {
		var cnt = 0;
		var cur = begin();
		while(cur!=end()) { cnt++; cur=cur.next; }
		return cnt;
	}
	public inline function has(obj:Arbiter_true_true_true_false_Shape_Particle) return  ({
	var ret = false;
	  {
	var cxiterator = this.begin();
	while(cxiterator != this.end()) {
		var cxite = cxiterator.elem();
		{
			
			{
		if(cxite==obj) {
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
	
	public inline function front() return begin().elem()
	
	public inline function back() {
		var ret = begin();
		var cur = ret;
		while(cur!=end()) { ret = cur; cur = cur.next; }
		return ret.elem();
	}
	
	public inline function at(ind:Int) return iterator_at(ind).elem()
	public inline function iterator_at(ind:Int) {
		var ret = begin();
		while(ind-->0) ret = ret.next;
		return ret;
	}
	
	public inline function insert(cur:CxFastNode_Arbiter_true_true_true_false_Shape_Particle,o:Arbiter_true_true_true_false_Shape_Particle) {
		if(cur==null) { add(o); return begin(); }
		else {
			var temp =  {
		var ret = alloc.CxAlloc_CxFastNode_Arbiter_true_true_true_false_Shape_Particle();
		ret.elt = o;
		ret;
	};
			temp.next = cur.next;
			cur.next = temp;
			return temp;
		}
	}
	
	public inline function free(o:Arbiter_true_true_true_false_Shape_Particle) {}

	
	
	
	public inline function begin() return head
	public inline function end  () return null
	
	
	
	
	
}