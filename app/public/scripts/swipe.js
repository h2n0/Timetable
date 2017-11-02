var Swipe = function(dom){
	dom = dom || document;
	
	
	var self = this;
	
	function handleEvent(e){
		e.preventDefault();
		switch(e.type){
		
			case "pointerdown":
			case "mousedown":
			case "touchstart":
				self.swipeStart(e);
				break;
				
			case "pointermove":
			case "mousemove":
			case "touchmove":
				self.swipeChange(e);
				break;
				
			case "pointerup":
			case "pointercancel":
			case "mouseup":
			case "touchend":
			case "touchcancel":
				self.swipeEnd(e);
				break;
				
		}
	}
	
	this.onUp = null;
	this.onDown = null;
	this.onLeft = null;
	this.onRight = null;
	
	
	if(window.PointerEvent){ // Do we have pointers
		dom.addEventListener("pointerdown", handleEvent, true);
		dom.addEventListener("pointermove", handleEvent, true);
		dom.addEventListener("pointerup", handleEvent, true);
		dom.addEventListener("pointercancel", handleEvent, true);
	}else{ // We don't, use mouse and touch instead
		dom.addEventListener("touchstart", handleEvent, true);
		dom.addEventListener("touchmove", handleEvent, true);
		dom.addEventListener("touchend", handleEvent, true);
		dom.addEventListener("touchcancel", handleEvent, true);
		dom.addEventListener("mousedown", handleEvent, true);
		dom.addEventListener("mousemove", handleEvent, true);
		dom.addEventListener("mouseup", handleEvent, true);
	}
}

Swipe.prototype.touches = {
	"start" : {"x": -1, "y" : -1},
	"move" : {"x" : -1, "y" : -1},
	"end" : false,
	"dir" : "none"
}

Swipe.prototype.swipeStart = function(e){
		e.preventDefault();
		if(!e.touches || e.touches.length > 1){
			return;
		}
		var t = e.touches[0];
		var x = t.clientX;
		var y = t.clientY;
		
		this.touches["start"].x = x;
		this.touches["start"].y = y;
}

Swipe.prototype.swipeChange = function(e){	
	e.preventDefault();
	if(!e.touches || e.touches.length > 1){
		return;
	}
	var t = e.touches[0];
	var x = t.clientX;
	var y = t.clientY;
	this.touches["move"].x = x;
	this.touches["move"].y = y;
}

Swipe.prototype.swipeEnd = function(e){
	e.preventDefault();
	this.touches.end = true;
	
	var dx = this.touches["move"].x - this.touches["start"].x;
	var dy = this.touches["move"].y - this.touches["start"].y;
	
	var limit = 30;
	
	if(dy < 0 && Math.abs(dx) < 30)this.onUp();
	if(dy > 0 && Math.abs(dx) < 30)this.onDown();
	if(dx < 0 && Math.abs(dy) < 30)this.onLeft();
	if(dx > 0 && Math.abs(dy) < 30)this.onRight();
}
