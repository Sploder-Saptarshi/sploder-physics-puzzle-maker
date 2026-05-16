package com.sploder.data 
{
	import flash.geom.Point;
	import flash.utils.describeType;
	
	/**
	 * ...
	 * @author Geoff
	 */
	public class DataManifest
	{
		
		public static function describe (obj:Object):String {
			
			var params:XMLList = describeType(obj)..accessor;
			var p:Array = [];
			var n:String;
			
			for each (var param:XML in params) {
				n = param.@name;
				if (param.@access == "readwrite") {
					p.push(n);
				}
			}
			
			p.sort();
			
			return '"' + p.join('","') + '"';
			
		}
		
		public static function pointToString (pt:Point):String { 
			
			return pt.x + ":" + pt.y;
			
		}
		
		public static function stringToPoint (ptString:String, pt:Point = null):Point {
			
			if (ptString == null || ptString.indexOf(":") == -1) return new Point();
			
			var p:Array = ptString.split(":");
			
			if (pt) {
				pt.x = parseInt(p[0]);
				pt.y = parseInt(p[1]);
				return pt;
			}
			
			return new Point(parseInt(p[0]), parseInt(p[1]));
			
		}
		
		public static const modelObjectPropertiesProps:Array = [
		
			"shape",
			"width",
			"height",
			"vertices",
			"constraint",
			"material",
			"strength",
			"locked",
			"collision_group",
			"passthru_group",
			"sensor_group",
			"color",
			"line",
			"texture",
			"zlayer",
			"opaque",
			"scribble",
			"actions",
			"graphic",
			"graphic_version",
			"graphic_flip",
			"animation",
			"custom_texture"
				
		];
		
		public static const stringMap:Array = [
		
			"icon_shape_none", 
			"icon_shape_poly", 
			"icon_shape_hex", 
			"icon_shape_pent", 
			"icon_shape_box", 
			"icon_shape_ramp", 
			"icon_shape_circle", 
			"icon_shape_square",
			
			"icon_movement_static", 
			"icon_movement_slide", 
			"icon_movement_pin", 
			"icon_movement_free",
			
			"icon_material_tire", 
			"icon_material_glass", 
			"icon_material_rubber", 
			"icon_material_ice", 
			"icon_material_steel", 
			"icon_material_wood", 
			"icon_material_air_balloon", 
			"icon_material_helium_balloon", 
			"icon_material_magnet", 
			
			"icon_strength_perm", 
			"icon_strength_strong", 
			"icon_strength_medium", 
			"icon_strength_weak",
			
			"modifier_pusher", 
			"modifier_pinjoint", 
			"modifier_bolt", 
			"modifier_dampedspring", 
			"modifier_loosespring", 
			"modifier_groovejoint", 
			"modifier_motor", 
			"modifier_rotator", 
			"modifier_mover", 
			"modifier_slider", 
			"modifier_launcher", 
			"modifier_selector", 
			"modifier_adder", 
			"modifier_elevator", 
			"modifier_spawner", 
			"modifier_connector", 
			"modifier_magnet", 
			"modifier_factory", 
			"modifier_unlocker", 
			"modifier_switcher", 
			"modifier_jumper", 
			"modifier_emagnet",
			"modifier_gearjoint",
			"modifier_aimer",
			"modifier_pointer",
			"modifier_dragger",
			"icon_material_superball",
			"modifier_thruster",
			"modifier_propeller",
			"modifier_clicker",
			"modifier_arcademover"
		];	
		
	}

}