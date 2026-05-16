package nape.phys;







class Material {
	
	
	public var eCoef:Float;
	
	public var dyn_fric:Float;
	
	public var stat_fric:Float;
	
	public var density:Float;
	
	
	
	
	public function new(elasticity:Float, dynamic_friction:Float, static_friction:Float, ?density:Float=1.0) {
		eCoef     = elasticity;
		dyn_fric  = dynamic_friction;
		stat_fric = static_friction;
		this.density = density;
	}
	
	
	
	
	public static inline var Wood   = new Material(0.4, 0.2,  0.38, 0.7);
	public static inline var Steel  = new Material(0.2, 0.57, 0.74, 7.8);
	public static inline var Ice    = new Material(0.3, 0.03, 0.1,  0.9);
	public static inline var Rubber = new Material(0.8, 1.0,  1.4,  1.5);
	public static inline var Glass  = new Material(0.4, 0.4,  0.94, 2.6);
	
	
	
	
	public static inline var SoftPart = new Material(0.0, 1.0, 1.4, 1.0);
	public static inline var Tire     = new Material(0.2, 2.5, 2.0, 1.5);
	
}
