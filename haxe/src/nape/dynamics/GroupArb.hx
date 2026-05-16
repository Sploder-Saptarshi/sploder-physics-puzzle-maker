package nape.dynamics;
import cx.FastList;
import nape.dynamics.ObjArb;
import nape.phys.Group;

//'newfile' define generated imports
import cx.CxFastList_ObjArb;














class GroupArb {
	public var id:Int;
	
	public var count:Int;
	public var ignore:Bool;
	public var temp_ignore:Bool;
	public var updated:Bool;
	
	public var g1:Group; public var g2:Group;
	public var obj_arbs:CxFastList_ObjArb;
	
	public var next:GroupArb;
	
	public function new() {}
	
	public inline function retire_arb(?arb:ObjArb=null):Bool {
		obj_arbs.remove(arb);
		return (--count)==0;
	}
	
	public inline function assign_arb(?arb:ObjArb=null):Bool {
		obj_arbs.add(arb);
		return count++==0;
	}

	
}
