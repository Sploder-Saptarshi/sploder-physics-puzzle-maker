/*
 * Stage size 800x600
 * Stage fps  whatever, i chose 60 due to fp10.1 fps cap.
*/

package;

import flash.display.StageQuality;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;

import nape.constraint.DampedSpring;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.phys.Material;
import nape.phys.PhysObj;
import nape.space.Space;
import nape.space.UniformSleepSpace;
import nape.util.Tools;


class Main {
	static var space:Space;
	static var fps:TextField;
	
	static function main() {
		fps = new TextField(); fps.x = fps.y = 10;
		Lib.current.addChild(fps);
		
		space = new UniformSleepSpace(new AABB(0, 0, 800, 600), 15, new Vec2(0, 250));
		
		//space border.
		var p:PhysObj;
		space.addObject(p = Tools.createBox(-5,  300, 30,  600, 0, 0, 0, true, Material.Wood));
		Lib.current.addChild(p.graphic);
		space.addObject(p = Tools.createBox(805, 300, 30,  600, 0, 0, 0, true, Material.Wood));
		Lib.current.addChild(p.graphic);
		space.addObject(p = Tools.createBox(400, -5,  800, 30,  0, 0, 0, true, Material.Wood));
		Lib.current.addChild(p.graphic);
		space.addObject(p = Tools.createBox(400, 605, 800, 30,  0, 0, 0, true, Material.Wood));
		Lib.current.addChild(p.graphic);
		
		//pyramid
		var bw = 7.0;
		var bh = 15.5;
		
		var yc = 37;
		for (y in 1...(yc + 1)) {
			for (x in 0...y) {
				var ax = 400 + (x - (y-1)*0.5) * bw;
				var ay = 590 - bh * (yc - y + 0.5);
				
				space.addObject(p = Tools.createBox(ax, ay, bw, bh, 0, 0, 0, false, Material.Tire));
				Lib.current.addChild(p.graphic);
			}
		}
		
		//set graphical quality to medium
		Lib.current.stage.quality = StageQuality.MEDIUM;
		
		//set up events
		Lib.current.addEventListener(Event.ENTER_FRAME, enterFrame);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, md);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, mu);
	}
	
	static var c:DampedSpring;
	static function md(_) {
		var x = Lib.current.stage.mouseX;
		var y = Lib.current.stage.mouseY;
		//query object at mouse position, null implies no object exists.
		var p = space.objectAtPoint(x, y);
		if(p!=null) {
			c = new DampedSpring(p, space.STATIC, new Vec2(x, y), new Vec2(), 0, 200000, 120);
			c.maxForce = 4000000;
			space.addConstraint(c);
		}
	}
	static function mu(_) {
		if (c != null) {
			space.removeConstraint(c);
			c = null;
		}
	}
	
	// important for stability that time step does not fluctuate wildly
	// and that the time step used does not make any large leaps.
	// thus the time step is lerp'd between it's current value and a
	// capped target time step.
	
	static var pt = 0;
	static var dt = 1.0/60.0; // initial time step
	static function enterFrame(ev) {
		if (c != null) {
			//wake the constraint in case the body it has been connected to
			//and therefore the constraint also, has been put to sleep.
			space.wakeConstraint(c);
			//update anchor point on space.STATIC to mouse coordinate
			c.a2x = Lib.current.mouseX;
			c.a2y = Lib.current.mouseY;
		}
		
		var ct = Lib.getTimer();
		fps.text = Std.string(1000 / (ct - pt)).substr(0, 5);
		
		//target time step, capped at 20fps below
		var tdt = (ct - pt) * 0.001;
		if (tdt > 1 / 20) tdt = 1 / 20;
		
		//limit difference between actual and target to 10ms
		var ddt = tdt - dt;
		if (ddt < -0.01) ddt = -0.01;
		else if (ddt > 0.01) ddt = 0.01;
		//lerp timestep towards target.
		dt += ddt * 0.1;
		pt = ct;
		
		space.step(dt, 11, 11);
	}
}