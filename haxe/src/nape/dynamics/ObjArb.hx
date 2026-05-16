package nape.dynamics;
import cx.FastList;
import nape.dynamics.GroupArb;
import nape.dynamics.Arbiter;
import nape.phys.PhysObj;

//'newfile' define generated imports
import cx.CxFastList_Arbiter;















class ObjArb {
	public var id:Int;
	
	public var count:Int;
	public var ignore:Bool;
	public var temp_ignore:Bool;
	public var updated:Bool;
	
	public var next:ObjArb;
	public var group_arb:GroupArb;
	
	public var p1:PhysObj; public var p2:PhysObj;
	public var arbiters:CxFastList_Arbiter;
	
	public function new() {}
	
	public inline function assign(_p1:PhysObj,_p2:PhysObj) {
		p1 = _p1;
		p2 = _p2;
		p1.p_objarb.add(this);
		p2.p_objarb.add(this);
	}
	
	public inline function retire() {
		p1.p_objarb.remove(this);
		p2.p_objarb.remove(this);
	}
	
	public inline function retire_arb(?arb:Arbiter=null):Bool {
		arbiters.remove(arb);
		return (--count)==0;
	}
	
	public inline function assign_arb(?arb:Arbiter=null):Bool {
		arbiters.add(arb);
		return count++==0;
	}
}
