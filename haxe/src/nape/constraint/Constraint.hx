package nape.constraint;
import cx.FastList;
import nape.phys.PhysObj;
import nape.geom.Vec2;
import nape.space.Space;
import nape.Const;
import nape.Config;

//'newfile' define generated imports
import cx.CxFastList_PhysObj;















class Constraint {
	public var maxForce:Float;
	public var biasCoef:Float;
	public var maxBias :Float;
	
	public var dt:Float;
	public var ignore:Bool;
	
	
	public var live:Bool;
	public var sleep:Bool;
	public var canSleep:Bool;
	public var sleept:Int;
	public var csleep:Int;
	
	
	public var breakable:Bool;
	public var cbBreak:Bool;
	
	public var data:Dynamic;
	public var id:Int;
	static var nextId:Int = 0;
	
	public function new() {
		maxForce = Const.POSINF;
		maxBias  = Const.POSINF;
		biasCoef = Config.DEFAULT_CONSTRAINT_BIAS;
		live  = false;
		sleep = false;
		breakable = false;
		id = nextId++;
	}
	
	public function preStep(dt:Float):Bool return false
	public function applyImpulse()   :Bool return false
	
	public function impulse(obj:PhysObj, dst:Vec2):Void
	{
		
	}
	
	public function addToBodies     ():Void
	{
		
	}
	public function removeFromBodies():Void {
		
	}
	
	public function wakeBodies(space:Space):Void
	{
		
	}
	
	public function bodyPairExists(a:PhysObj,b:PhysObj):Bool return false
	
	public function body_list():CxFastList_PhysObj return null
	
	public function anyBodiesAwake():Bool return false
	
	public function disallowBodySleep():Void
	{
		
	}
}

class Calc {
	public static inline function sq(x:Float) return x*x
	public static inline function range(x:Float,a:Float,b:Float) return if(x<a) a else if(x>b) b else x
	public static inline function clamp(x:Float,a:Float) return if(x<-a) -a else if(x>a) a else x
}



























