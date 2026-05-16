package nape.phys;
import cx.FastList;
import cx.Algorithm;
import nape.callbacks.Callbackable;
import nape.phys.PhysObj;

//'newfile' define generated imports
import cx.CxFastList_PhysObj;















class Group extends Callbackable {
	static var nextId:Int;
	public var id:Int;
	
	public var objs:CxFastList_PhysObj;
	public var ignore:Bool;
	
	
	public var data:Dynamic;
	
	public function new() {
		id = nextId++;
		objs = new CxFastList_PhysObj();
		
	}
	
	public inline function addObject(p:PhysObj) {
		if(!objs.has(p)) {
			objs.add(p);
			p.group_obj = this;
			return true;
		}else return false;
	}
	public inline function removeObject(p:PhysObj) {
		if(objs.remove(p)) {
			p.group_obj = null;
			  {
	var cxiterator = p.p_objarb.begin();
	while(cxiterator != p.p_objarb.end()) {
		var arb = cxiterator.elem();
		{
			
			{
				var grp = arb.group_arb;
				if(grp!=null && (grp.g1==this || grp.g2==this)) {
					grp.retire_arb(arb);
					arb.group_arb = null;
				}
			};
		}
		cxiterator = cxiterator.next;
	}
};
			return true;
		}else return false;
	}
}

