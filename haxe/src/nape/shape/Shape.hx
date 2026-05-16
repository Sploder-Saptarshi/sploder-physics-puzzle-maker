package nape.shape;
import cx.MixList;
import cx.Algorithm;
import nape.callbacks.Callbackable;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.Config;


















class Shape extends Callbackable {
	
	public static var nextId:Int = 0;
	public var id    :Int;
	
	public static inline var CIRCLE :Int = 0;
	public static inline var POLYGON:Int = 1;
	public var type:Int;
	
	
	public var circle :Circle;
	public var polygon:Polygon;
	public var body   :Body;
	
	 
	public var next:Shape;
	
	
	
	
	public inline function add(o:Shape) {
		var temp = _new(o);
		temp.next = begin();
		_setbeg(temp);
	}
	public inline function addAll(list: Shape) {
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
		_setbeg(ret.next);
		_delelt(ret.elem());
		_delete(ret);
	}
	public inline function remove(obj:Shape):Bool {
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
	public inline function erase(pre:Shape,cur:Shape):Shape {
		var old = cur; cur = cur.next;
		if(pre==null) _setbeg   (cur);
		else          pre.next = cur;
		_delelt(old.elem());
		_delete(old);
		return cur;
	}
	public inline function splice(pre:Shape,cur:Shape,n:Int):Shape {
		while(n-->0 && cur!=end())
			cur = erase(pre,cur);
		return cur;
	}
	public inline function clear() {
		if(_clear()) {
			while(!empty()) {
				var old = begin();
				_setbeg(old.next);
				_delelt(old.elem());
				_delete(old);
			}
		}else _setbeg(end());
	}
	public inline function reverse() {
		if(!empty()) {
			var ui = begin().next;
			begin().next = end();
			while(ui!=end()) {
				var next = ui.next;
				ui.next = begin();
				_setbeg(ui);
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
	public inline function has(obj:Shape) return  ({
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
	
	public inline function insert(cur:Shape,o:Shape) {
		if(cur==null) { add(o); return begin(); }
		else {
			var temp = _new(o);
			temp.next = cur.next;
			cur.next = temp;
			return temp;
		}
	}
	
	public inline function free(o:Shape) {}

	
	
	
	public inline function begin():Shape return next
	public inline function end  ():Shape return null
	
	
	public inline function _setbeg(ite:Shape) next = ite
	public inline function _new   (obj:Shape):Shape  return obj
	public inline function _delete(ite:Shape)    {}
	public inline function _delelt(obj:Shape)    {}
	public inline function _clear () return false

	public inline function elem():Shape return this

	
	public var aabb:AABB;
	
	public var area:Float;
	public var material:Material;
	
	public var group :Int;
	public var sensor:Int;
	
	public var data:Dynamic;
	
	
	
	public function new(?TYPE:Int=0xffff,?MAT:Material,?GROUP:Int=0xffffff,?SENSOR:Int=0) {
		type = TYPE;
		group = GROUP;
		sensor = SENSOR;
		material = if(MAT==null) Config.DEFAULT_MATERIAL else MAT;
		area = 0;
		aabb = new AABB(0,0,0,0);
		
		id = nextId++;
	}
	
	
	
	private inline function transform(dis:Vec2,dst:Vec2) {
		dst.px = body.px + body.ROTX(dis);
		dst.py = body.py + body.ROTY(dis);
	}

	
		
	public inline function updateShape() {
		if(type == CIRCLE) circle.update();
		else              polygon.update();
	}
}
