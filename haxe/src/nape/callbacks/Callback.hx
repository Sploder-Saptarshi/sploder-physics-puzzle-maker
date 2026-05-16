package nape.callbacks;
import nape.phys.PhysObj;
import nape.dynamics.Arbiter;
import nape.dynamics.ObjArb;
import nape.dynamics.GroupArb;
import nape.constraint.Constraint;















class Callback {
	public var id  :Int;
	
	
	
	public var type:Int;
	
	public static inline var END        :Int = 0;
	public static inline var BEGIN      :Int = 1;
	public static inline var SENSE_BEGIN:Int = 2;
	public static inline var SENSE_END  :Int = 3;
	public static inline var POST_SOLVE :Int = 4;
	
	public static inline var CONSTRAINT_BREAK:Int = 5;
	
	public static inline var PHYSOBJ_WAKE       :Int = 6;
	public static inline var PHYSOBJ_SLEEP      :Int = 7;
	public static inline var PHYSOBJ_OUTOFBOUNDS:Int = 8;
	public static inline var PHYSOBJ_SHOW       :Int = 9;
	public static inline var PHYSOBJ_HIDE       :Int = 10;
	
	
	
	public static inline var ARBITER_SHAPE :Int = 0;
	public static inline var ARBITER_OBJECT:Int = 1;
	public static inline var ARBITER_GROUP :Int = 2;
	
	
	
	public static inline var ACCEPT     :Int = 0;
	public static inline var IGNORE_ONCE:Int = 1;
	public static inline var IGNORE     :Int = 2;
	
	
	
	public var arb       :Arbiter;
	public var obj_arb   :ObjArb;
	public var group_arb :GroupArb;
	public var constraint:Constraint;
	public var obj       :PhysObj;
	
	public var arbiter_type:Int;
	
	
	
	public function new() {}
	
	
	
	public var next:Callback;
}
