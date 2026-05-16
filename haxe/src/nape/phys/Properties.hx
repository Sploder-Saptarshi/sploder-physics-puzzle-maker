package nape.phys;








class Properties {
	
	
	public static var nextId:Int = 0;
	
	public var id    :Int;
	
	public var count :Int;
	
	
	
	
	public var linDamp:Float; 
	
	public var angDamp:Float;
	
	
	public var lfdt:Float;
	
	public var afdt:Float;
	
	
	
	
	public function new(linear_dampening:Float, angular_dampening:Float) {
		linDamp  = linear_dampening;
		angDamp  = angular_dampening;
		
		lfdt = afdt = 0;
		
		id    = nextId++;
		count = 0;
	}
	
}
