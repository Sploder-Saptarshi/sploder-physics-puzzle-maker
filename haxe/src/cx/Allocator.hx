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
import cx.FastList;
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
import cx.CxFastNode_Arbiter_true_true_true_false_Shape_Particle;
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








class Allocator {
	
	static public var GLOBAL:Allocator = new Allocator();
	
	
	
	private var pool_CxFastNode_PhysObj:CxFastNode_PhysObj;private var pool_CxFastNode_MPConsPair:CxFastNode_MPConsPair;private var pool_CxFastNode_Anchor:CxFastNode_Anchor;private var pool_CxFastNode_Contact:CxFastNode_Contact;private var pool_CxFastNode_ObjArb:CxFastNode_ObjArb;private var pool_CxFastNode_Arbiter:CxFastNode_Arbiter;private var pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape:CxFastNode_Arbiter_false_false_true_true_Shape_Shape;private var pool_Contact:Contact;private var pool_Arbiter_false_false_true_true_Shape_Shape:Arbiter_false_false_true_true_Shape_Shape;private var pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle:CxFastNode_Arbiter_false_false_true_false_Shape_Particle;private var pool_Arbiter_false_false_true_false_Shape_Particle:Arbiter_false_false_true_false_Shape_Particle;private var pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape:CxFastNode_Arbiter_true_true_true_true_Shape_Shape;private var pool_Arbiter_true_true_true_true_Shape_Shape:Arbiter_true_true_true_true_Shape_Shape;private var pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle:CxFastNode_Arbiter_true_true_true_false_Shape_Particle;private var pool_Arbiter_true_true_true_false_Shape_Particle:Arbiter_true_true_true_false_Shape_Particle;private var pool_CxFastNode_GeomPoly:CxFastNode_GeomPoly;private var pool_CxFastNode_UniformSleepCell:CxFastNode_UniformSleepCell;private var pool_CxFastNode_Constraint:CxFastNode_Constraint;private var pool_CxFastNode_Shape:CxFastNode_Shape;private var pool_Callback:Callback;private var pool_ObjArb:ObjArb;private var pool_GroupArb:GroupArb;private var pool_CxFastNode_Body:CxFastNode_Body;private var pool_CxFastNode_Particle:CxFastNode_Particle;private var pool_CxFastNode_Group:CxFastNode_Group;private var pool_CxFastNode_Properties:CxFastNode_Properties;private var pool_CxFastNode_Callback:CxFastNode_Callback;private var pool_CxFastNode_UniformCell:CxFastNode_UniformCell;private var pool_Vec2:Vec2;

	
	
	public function new() {}

	
	
	public inline function CxAlloc_CxFastNode_PhysObj(){
		if(pool_CxFastNode_PhysObj==null) {
			return new CxFastNode_PhysObj();
		}
		else {
			var ret = pool_CxFastNode_PhysObj;
			pool_CxFastNode_PhysObj = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_MPConsPair(){
		if(pool_CxFastNode_MPConsPair==null) {
			return new CxFastNode_MPConsPair();
		}
		else {
			var ret = pool_CxFastNode_MPConsPair;
			pool_CxFastNode_MPConsPair = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Anchor(){
		if(pool_CxFastNode_Anchor==null) {
			return new CxFastNode_Anchor();
		}
		else {
			var ret = pool_CxFastNode_Anchor;
			pool_CxFastNode_Anchor = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Contact(){
		if(pool_CxFastNode_Contact==null) {
			return new CxFastNode_Contact();
		}
		else {
			var ret = pool_CxFastNode_Contact;
			pool_CxFastNode_Contact = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_ObjArb(){
		if(pool_CxFastNode_ObjArb==null) {
			return new CxFastNode_ObjArb();
		}
		else {
			var ret = pool_CxFastNode_ObjArb;
			pool_CxFastNode_ObjArb = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Arbiter(){
		if(pool_CxFastNode_Arbiter==null) {
			return new CxFastNode_Arbiter();
		}
		else {
			var ret = pool_CxFastNode_Arbiter;
			pool_CxFastNode_Arbiter = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Arbiter_false_false_true_true_Shape_Shape(){
		if(pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape==null) {
			return new CxFastNode_Arbiter_false_false_true_true_Shape_Shape();
		}
		else {
			var ret = pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape;
			pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Contact(){
		if(pool_Contact==null) {
			return new Contact();
		}
		else {
			var ret = pool_Contact;
			pool_Contact = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Arbiter_false_false_true_false_Shape_Particle(){
		if(pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle==null) {
			return new CxFastNode_Arbiter_false_false_true_false_Shape_Particle();
		}
		else {
			var ret = pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle;
			pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Arbiter_true_true_true_true_Shape_Shape(){
		if(pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape==null) {
			return new CxFastNode_Arbiter_true_true_true_true_Shape_Shape();
		}
		else {
			var ret = pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape;
			pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Arbiter_true_true_true_false_Shape_Particle(){
		if(pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle==null) {
			return new CxFastNode_Arbiter_true_true_true_false_Shape_Particle();
		}
		else {
			var ret = pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle;
			pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_GeomPoly(){
		if(pool_CxFastNode_GeomPoly==null) {
			return new CxFastNode_GeomPoly();
		}
		else {
			var ret = pool_CxFastNode_GeomPoly;
			pool_CxFastNode_GeomPoly = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_UniformSleepCell(){
		if(pool_CxFastNode_UniformSleepCell==null) {
			return new CxFastNode_UniformSleepCell();
		}
		else {
			var ret = pool_CxFastNode_UniformSleepCell;
			pool_CxFastNode_UniformSleepCell = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Constraint(){
		if(pool_CxFastNode_Constraint==null) {
			return new CxFastNode_Constraint();
		}
		else {
			var ret = pool_CxFastNode_Constraint;
			pool_CxFastNode_Constraint = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Shape(){
		if(pool_CxFastNode_Shape==null) {
			return new CxFastNode_Shape();
		}
		else {
			var ret = pool_CxFastNode_Shape;
			pool_CxFastNode_Shape = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Callback(){
		if(pool_Callback==null) {
			return new Callback();
		}
		else {
			var ret = pool_Callback;
			pool_Callback = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Arbiter_false_false_true_true_Shape_Shape(){
		if(pool_Arbiter_false_false_true_true_Shape_Shape==null) {
			return new Arbiter_false_false_true_true_Shape_Shape();
		}
		else {
			var ret = pool_Arbiter_false_false_true_true_Shape_Shape;
			pool_Arbiter_false_false_true_true_Shape_Shape = ret.next;
			return ret;
		}
	}public inline function CxAlloc_ObjArb(){
		if(pool_ObjArb==null) {
			return new ObjArb();
		}
		else {
			var ret = pool_ObjArb;
			pool_ObjArb = ret.next;
			return ret;
		}
	}public inline function CxAlloc_GroupArb(){
		if(pool_GroupArb==null) {
			return new GroupArb();
		}
		else {
			var ret = pool_GroupArb;
			pool_GroupArb = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Arbiter_false_false_true_false_Shape_Particle(){
		if(pool_Arbiter_false_false_true_false_Shape_Particle==null) {
			return new Arbiter_false_false_true_false_Shape_Particle();
		}
		else {
			var ret = pool_Arbiter_false_false_true_false_Shape_Particle;
			pool_Arbiter_false_false_true_false_Shape_Particle = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Arbiter_true_true_true_true_Shape_Shape(){
		if(pool_Arbiter_true_true_true_true_Shape_Shape==null) {
			return new Arbiter_true_true_true_true_Shape_Shape();
		}
		else {
			var ret = pool_Arbiter_true_true_true_true_Shape_Shape;
			pool_Arbiter_true_true_true_true_Shape_Shape = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Arbiter_true_true_true_false_Shape_Particle(){
		if(pool_Arbiter_true_true_true_false_Shape_Particle==null) {
			return new Arbiter_true_true_true_false_Shape_Particle();
		}
		else {
			var ret = pool_Arbiter_true_true_true_false_Shape_Particle;
			pool_Arbiter_true_true_true_false_Shape_Particle = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Body(){
		if(pool_CxFastNode_Body==null) {
			return new CxFastNode_Body();
		}
		else {
			var ret = pool_CxFastNode_Body;
			pool_CxFastNode_Body = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Particle(){
		if(pool_CxFastNode_Particle==null) {
			return new CxFastNode_Particle();
		}
		else {
			var ret = pool_CxFastNode_Particle;
			pool_CxFastNode_Particle = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Group(){
		if(pool_CxFastNode_Group==null) {
			return new CxFastNode_Group();
		}
		else {
			var ret = pool_CxFastNode_Group;
			pool_CxFastNode_Group = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Properties(){
		if(pool_CxFastNode_Properties==null) {
			return new CxFastNode_Properties();
		}
		else {
			var ret = pool_CxFastNode_Properties;
			pool_CxFastNode_Properties = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_Callback(){
		if(pool_CxFastNode_Callback==null) {
			return new CxFastNode_Callback();
		}
		else {
			var ret = pool_CxFastNode_Callback;
			pool_CxFastNode_Callback = ret.next;
			return ret;
		}
	}public inline function CxAlloc_CxFastNode_UniformCell(){
		if(pool_CxFastNode_UniformCell==null) {
			return new CxFastNode_UniformCell();
		}
		else {
			var ret = pool_CxFastNode_UniformCell;
			pool_CxFastNode_UniformCell = ret.next;
			return ret;
		}
	}public inline function CxAlloc_Vec2(){
		if(pool_Vec2==null) {
			return new Vec2();
		}
		else {
			var ret = pool_Vec2;
			pool_Vec2 = ret.next;
			return ret;
		}
	}
	
	

	public inline function CxFree_CxFastNode_PhysObj(obj:CxFastNode_PhysObj) {
		obj.next = pool_CxFastNode_PhysObj;
		pool_CxFastNode_PhysObj = obj;
	}public inline function CxFree_CxFastNode_MPConsPair(obj:CxFastNode_MPConsPair) {
		obj.next = pool_CxFastNode_MPConsPair;
		pool_CxFastNode_MPConsPair = obj;
	}public inline function CxFree_CxFastNode_Anchor(obj:CxFastNode_Anchor) {
		obj.next = pool_CxFastNode_Anchor;
		pool_CxFastNode_Anchor = obj;
	}public inline function CxFree_CxFastNode_Contact(obj:CxFastNode_Contact) {
		obj.next = pool_CxFastNode_Contact;
		pool_CxFastNode_Contact = obj;
	}public inline function CxFree_CxFastNode_ObjArb(obj:CxFastNode_ObjArb) {
		obj.next = pool_CxFastNode_ObjArb;
		pool_CxFastNode_ObjArb = obj;
	}public inline function CxFree_CxFastNode_Arbiter(obj:CxFastNode_Arbiter) {
		obj.next = pool_CxFastNode_Arbiter;
		pool_CxFastNode_Arbiter = obj;
	}public inline function CxFree_CxFastNode_Arbiter_false_false_true_true_Shape_Shape(obj:CxFastNode_Arbiter_false_false_true_true_Shape_Shape) {
		obj.next = pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape;
		pool_CxFastNode_Arbiter_false_false_true_true_Shape_Shape = obj;
	}public inline function CxFree_Contact(obj:Contact) {
		obj.next = pool_Contact;
		pool_Contact = obj;
	}public inline function CxFree_Arbiter_false_false_true_true_Shape_Shape(obj:Arbiter_false_false_true_true_Shape_Shape) {
		obj.next = pool_Arbiter_false_false_true_true_Shape_Shape;
		pool_Arbiter_false_false_true_true_Shape_Shape = obj;
	}public inline function CxFree_CxFastNode_Arbiter_false_false_true_false_Shape_Particle(obj:CxFastNode_Arbiter_false_false_true_false_Shape_Particle) {
		obj.next = pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle;
		pool_CxFastNode_Arbiter_false_false_true_false_Shape_Particle = obj;
	}public inline function CxFree_Arbiter_false_false_true_false_Shape_Particle(obj:Arbiter_false_false_true_false_Shape_Particle) {
		obj.next = pool_Arbiter_false_false_true_false_Shape_Particle;
		pool_Arbiter_false_false_true_false_Shape_Particle = obj;
	}public inline function CxFree_CxFastNode_Arbiter_true_true_true_true_Shape_Shape(obj:CxFastNode_Arbiter_true_true_true_true_Shape_Shape) {
		obj.next = pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape;
		pool_CxFastNode_Arbiter_true_true_true_true_Shape_Shape = obj;
	}public inline function CxFree_Arbiter_true_true_true_true_Shape_Shape(obj:Arbiter_true_true_true_true_Shape_Shape) {
		obj.next = pool_Arbiter_true_true_true_true_Shape_Shape;
		pool_Arbiter_true_true_true_true_Shape_Shape = obj;
	}public inline function CxFree_CxFastNode_Arbiter_true_true_true_false_Shape_Particle(obj:CxFastNode_Arbiter_true_true_true_false_Shape_Particle) {
		obj.next = pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle;
		pool_CxFastNode_Arbiter_true_true_true_false_Shape_Particle = obj;
	}public inline function CxFree_Arbiter_true_true_true_false_Shape_Particle(obj:Arbiter_true_true_true_false_Shape_Particle) {
		obj.next = pool_Arbiter_true_true_true_false_Shape_Particle;
		pool_Arbiter_true_true_true_false_Shape_Particle = obj;
	}public inline function CxFree_CxFastNode_GeomPoly(obj:CxFastNode_GeomPoly) {
		obj.next = pool_CxFastNode_GeomPoly;
		pool_CxFastNode_GeomPoly = obj;
	}public inline function CxFree_CxFastNode_UniformSleepCell(obj:CxFastNode_UniformSleepCell) {
		obj.next = pool_CxFastNode_UniformSleepCell;
		pool_CxFastNode_UniformSleepCell = obj;
	}public inline function CxFree_CxFastNode_Constraint(obj:CxFastNode_Constraint) {
		obj.next = pool_CxFastNode_Constraint;
		pool_CxFastNode_Constraint = obj;
	}public inline function CxFree_CxFastNode_Shape(obj:CxFastNode_Shape) {
		obj.next = pool_CxFastNode_Shape;
		pool_CxFastNode_Shape = obj;
	}public inline function CxFree_ObjArb(obj:ObjArb) {
		obj.next = pool_ObjArb;
		pool_ObjArb = obj;
	}public inline function CxFree_GroupArb(obj:GroupArb) {
		obj.next = pool_GroupArb;
		pool_GroupArb = obj;
	}public inline function CxFree_CxFastNode_Body(obj:CxFastNode_Body) {
		obj.next = pool_CxFastNode_Body;
		pool_CxFastNode_Body = obj;
	}public inline function CxFree_CxFastNode_Particle(obj:CxFastNode_Particle) {
		obj.next = pool_CxFastNode_Particle;
		pool_CxFastNode_Particle = obj;
	}public inline function CxFree_CxFastNode_Group(obj:CxFastNode_Group) {
		obj.next = pool_CxFastNode_Group;
		pool_CxFastNode_Group = obj;
	}public inline function CxFree_CxFastNode_Properties(obj:CxFastNode_Properties) {
		obj.next = pool_CxFastNode_Properties;
		pool_CxFastNode_Properties = obj;
	}public inline function CxFree_Callback(obj:Callback) {
		obj.next = pool_Callback;
		pool_Callback = obj;
	}public inline function CxFree_CxFastNode_Callback(obj:CxFastNode_Callback) {
		obj.next = pool_CxFastNode_Callback;
		pool_CxFastNode_Callback = obj;
	}public inline function CxFree_CxFastNode_UniformCell(obj:CxFastNode_UniformCell) {
		obj.next = pool_CxFastNode_UniformCell;
		pool_CxFastNode_UniformCell = obj;
	}
	
	
	
	
}
