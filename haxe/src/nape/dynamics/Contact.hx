package nape.dynamics;
import nape.geom.VecMath;











class Contact {
	
	 public var r1x:Float; public var r1y:Float     ;
	 public var r2x:Float; public var r2y:Float     ;
	
	
	
	 public var nx:Float; public var ny:Float     ;
	 public var px:Float; public var py:Float     ;
	
	
	
	public var dist:Float;
	
	
	
	public var nMass   :Float;
	public var tMass   :Float;
	
	
	
	public var bounce  :Float;
	public var friction:Float;
	public var bias    :Float;
	public var sBias   :Float; 
	
	
	
	public var jnAcc:Float;  public var pjnAcc:Float;
	public var jtAcc:Float;  public var pjtAcc:Float;
	public var jBias:Float;  public var pjBias:Float;
	
	
	
	public var updated:Bool; 
	public var fresh  :Bool; 
	
	
	
	public var hash:Int;
	
	
	
	public var cb_rest:Float;
	public var cb_dyn :Float;
	public var cb_stat:Float;
	
	
	
	public function new() {}
	
	
	
	public var next:Contact;
}
