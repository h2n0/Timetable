function $(id) {
	return document.getElementById(id);
}

function hsvToRgb(h, s, v) {
	var r, g, b;
	var i;
	var f, p, q, t;
	while (h > 360) h -= 360;
	while (h < 0) h += 360;
	// Make sure our arguments stay in-range
	h = Math.max(0, Math.min(360, h));
	s = Math.max(0, Math.min(100, s));
	v = Math.max(0, Math.min(100, v));
	// We accept saturation and value arguments from 0 to 100 because that's
	// how Photoshop represents those values. Internally, however, the
	// saturation and value are calculated from a range of 0 to 1. We make
	// That conversion here.
	s /= 100;
	v /= 100;
	if (s == 0) {
		// Achromatic (grey)
		r = g = b = v;
		return [
			Math.round(r * 255),
			Math.round(g * 255),
			Math.round(b * 255)
		];
	}
	h /= 60; // sector 0 to 5
	i = Math.floor(h);
	f = h - i; // factorial part of h
	p = v * (1 - s);
	q = v * (1 - s * f);
	t = v * (1 - s * (1 - f));
	switch (i) {
		case 0:
			r = v;
			g = t;
			b = p;
			break;
		case 1:
			r = q;
			g = v;
			b = p;
			break;
		case 2:
			r = p;
			g = v;
			b = t;
			break;
		case 3:
			r = p;
			g = q;
			b = v;
			break;
		case 4:
			r = t;
			g = p;
			b = v;
			break;
		default: // case 5:
			r = v;
			g = p;
			b = q;
	}
	return [
		Math.round(r * 255),
		Math.round(g * 255),
		Math.round(b * 255)
	];
}

function setColor(array, index, col) {
	array[index] = col[0];
	array[index + 1] = col[1];
	array[index + 2] = col[2];
	array[index + 3] = 255;
}

function setColorXY(array, x, y, col) {
	var pos = (x * 4) + y * can.width * 4;
	setColor(array, pos, col);
}

function sqr(array, x, y, r, col) {
	for (var xx = x - r; xx < x + r; xx++) {
		for (var yy = y - r; yy < y + r; yy++) {
			setColorXY(array, xx, yy, col);
		}
	}
}

var can = null;
var ctx = null;
var opened = false;
var onchange = null;
var onfinish = null;
var cols = null;

function paintInit(dom){
	if(opened)return;
	dom = dom || document.body;
	var div = document.createElement("div");
	var ncan = document.createElement("canvas");
	ncan.id = "can";
	var np = document.createElement("p");
	np.innerHTML = "Done!";
	np.style.display = "inline";
	
	div.appendChild(ncan);
	div.appendChild(np);
	dom.appendChild(div);
	can = $("can");
	ctx = can.getContext("2d");
	can.width = 150;
	can.height = 150;
	opened = true;
	console.log(dom);
	drawMid(0);
	
	np.onmousedown = function(e){
		if(onfinish){
			onfinish(dom, cols);
		}
	}
	
	can.onmousemove = function(e) {
		if (mdown) {
			change(e, function(val){
				cols = val;
				onchange(dom, val);
			});
		}
	}
	
	can.onmousedown = function(e) {
		mdown = true;
		change(e, function(val){
			cols = val;
			onchange(dom, val);
		});
	}
	
	can.onmouseup = function(e) {
		mdown = false;
	}
}

function drawMid(h, update) {
	update = update || false;
	var data = ctx.getImageData(0, 0, can.width, can.height);
	var s = can.width;
	var p = 40;
	for (var i = p; i < can.width - p; i++) {
		for (var j = p; j < can.height - p; j++) {
			var sa = (100 / ((can.width - p) - p)) * (i - p);
			var vo = 100 - (100 / ((can.width - p) - p)) * (j - p);
			var c = hsvToRgb(h, sa, vo);
			var pos = (i * 4) + j * data.width * 4;
			setColor(data.data, pos, c);
		}
	}
	if (!update) {
		drawWheel(data.data);
	}
	ctx.putImageData(data, 0, 0);
}

function drawWheel(data) {
	var cx = Math.round(can.width / 2);
	var cy = Math.round(can.height / 2);
	for (var i = 0; i < 360; i += 2) {
		var rad = i / 180 * Math.PI;
		for (var j = 55; j < 65; j++) {
			var dx = cx + Math.round(Math.cos(rad) * j);
			var dy = cy + Math.round(Math.sin(rad) * j);
			sqr(data, dx, dy, 2, hsvToRgb(i, 100, 100));
		}
	}
}
var mdown = false;
var h = 0;
var s = 0;
var l = 0;
//drawMid(h);

function change(e, callback) {
	var rect = can.getBoundingClientRect();
	var mx = e.layerX - rect.left;
	var my = e.layerY - rect.top;
	var dx = (can.width / 2) - mx;
	var dy = (can.height / 2) - my;
	var p = 40;
	if (mx >= p && my >= p && mx <= can.width - p && my <= can.height - p) {
		var sa = ((mx - p) / ((can.width - p) - p)) * 100;
		var vo = ((my - p) / ((can.height - p) - p)) * 100;
		vo = 100 - vo;
		sa = Math.max(0, Math.floor(sa));
		vo = Math.max(0, Math.floor(vo));
		var col = hsvToRgb(h, sa, vo);
		if (callback) {
			callback(col);
		}
	} else {
		var rad = Math.atan2(dy, dx);
		h = rad * 180 / Math.PI;
		h += 180;
		drawMid(h, false);
	}
}
