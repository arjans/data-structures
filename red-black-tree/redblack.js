const rd = 0,
bk = 1,
bb = 2,
nb = -1,
log = console.log;

class Node {
	constructor(c, l, v, r) {
		this.v = v;
		this.c = c;
		this.l = l;
		this.r = r;
		this.mt = false;
	}
}

class mtNode {
	constructor() {
		this.l = null;
		this.r = null;
		this.c = false;
		this.mt = true;
	}
}

const mt = () => new mtNode();
const node = (c, l, v, r) => new Node(c, l, v, r);

function insert(v, n) {
	function insertHelper(v, n) {
		if (n.mt) return node(rd, mt(), v, mt());
		if (v > n.v) return bal(node(n.c, n.l, n.v, insertHelper(v, n.r)));
		if (v < n.v) return bal(node(n.c, insertHelper(v, n.l), n.v, n.r));
		else return n;
	}
	const root = insertHelper(v, n);
	return node(bk, root.l, root.v, root.r);
}

function bal(n) {
	// double-black - negative-black
	if (n.l.c === nb) 
		return node(bk,
								node(bk, 
										 bal(node(rd, n.l.l.l, n.l.l.v, n.l.l.r)), 
										 n.l.v,
										 n.l.r.l),
								n.l.r.v,
								node(bk, n.l.r.r, n.v, n.r))
	if (n.r.c === nb)
		return node(bk,
								node(bk, n.l, n.v, n.r.l.l),
								n.r.l.v,
								node(bk,
										 n.r.l.r,
										 n.r.v,
										 bal(node(rd, n.r.r.l, n.r.r.v, n.r.r.r))));
	// double-black - red - red
	if (n.c === bb){
		if (twoLefts(n))
			return node(bk, 
									node(bk, n.l.l.l, n.l.l.v, n.l.l.r),
									n.l.v, 
									node(bk, n.l.r , n.v, n.r))
		if (twoRights(n))
			return node(bk, 
									node(bk, n.l, n.v, n.r.l),
									n.r.v, 
									node(bk, n.r.r.l, n.r.r.v, n.r.r.r))		
		if(mixedRight(n))
			return node(bk, 
									node(bk, n.l, n.v, n.r.r),
									n.r.l.v, 
									node(bk, n.r.l.r, n.r.v, n.r.r))		
		if(mixedLeft(n))
			return node(bk, 									
									node(bk, n.l.l, n.l.v, n.l.r.l),
									n.l.r.v, 
									node(bk, n.l.r.r, n.v, n.r))
	}
  // black - red - red
	if (n.c === bk) {
	  if (twoLefts(n)) {
	  	return node(rd,
	  		node(bk, n.l.l.l, n.l.l.v, n.l.l.r),
	  		n.l.v,
	  		node(bk, n.l.r, n.v, n.r));
	  }
	  if (twoRights(n)) {
	  	return node(rd,
	  		node(bk, n.l, n.v, n.r.l),
	  		n.r.v,
	  		node(bk, n.r.r.l, n.r.r.v, n.r.r.r));
	  }
	  //Case 2
	  if (mixedLeft(n)) {
	  	return node(rd,
	  		node(bk, n.l.l, n.l.v, n.l.r.l),
	  		n.l.r.v,
	  		node(bk, n.l.r.r, n.v, n.r));
	  }
	  if (mixedRight(n)) {
	  	return node(rd,
	  		node(bk, n.l, n.v, n.r.l.l),
	  		n.r.l.v,
	  		node(bk, n.r.l.r, n.r.v, n.r.r));
	  }
	}
  return n;
}

function twoLefts(n) {
	return n.l.c === rd && n.l.l.c === rd;
}

function twoRights(n) {
	return n.r.c === rd && n.r.r.c === rd;
}

function mixedLeft(n) {
	return n.l.c === rd && n.l.r.c === rd;
}

function mixedRight(n) {
	return n.r.c === rd && n.r.l.c === rd;
}

function del(v, n) {
	if (n === null) return mt();
	// if n is grandparent of v then bubble 
	if (isTargetBlackLeaf(n.l, v)) 
		return node(n.c + 1, mt(), n.v, node(rd, n.r.l, n.r.v, n.r.r));
	if (isTargetBlackLeaf(n.r, v)) 
		return node(n.c + 1, node(rd, n.l.l, n.l.v, n.l.r), n.v, mt());

	if (v > n.v) return bubble(node(n.c, n.l, n.v, del(v, n.r)));
	if (v < n.v) return bubble(node(n.c, del(v, n.l), n.v, n.r));

	// v === n.v
	if ((n.c === rd) && n.l.mt && n.r.mt) return mt();
	if (n.l.mt && !n.r.mt) return node(bk, n.r.l, n.r.v, n.r.r);
	if (n.r.mt && !n.l.mt) return node(bk, n.l.l, n.l.v, n.l.r);
	if (!n.r.mt && !n.l.mt) {
		const m = min(n.r);
		return bubble(node(n.c, n.l, m, del(m, n.r)));
	}
}

function bubble(n) {
	if(n.c === rd || n.c === bk) 
		if(n.l.c === bb || n.r.c === bb)
			return bal(node(n.c + 1,
									node(n.l.c - 1, n.l.l, n.l.v, n.l.r),
									n.v,
									node(n.r.c - 1, n.r.l, n.r.v, n.r.r)));
	return n;
}

function isTargetBlackLeaf(n, v) {
	return (n.v === v) && (n.c === bk) && n.l.mt && n.r.mt;
}

function min(n) {
	if (n.l.mt) { 
		return n.v;
	}	else {
		return min(n.l);
	}
}

function printNode(n) {
	if (n.mt) return '';
	const color = c => { 
		let col = null;
		switch (c) {
		case 1:
			 col = 'black';
			 break;
		case 0:
			 col = 'red';
			 break;
		case 2:
			 col = 'double black';
			 break;
		case -1:
			 col = 'negative black';
			 break;
		}
	return col
	}
	return [n.v + ' ' + color(n.c), printNode(n.l), printNode(n.r)];
}

const t = [5,2,9,8,6,11].reduce((acc, curr) => insert(curr, acc), mt())
const t1 = del(8,t);
// log(treeify.asTree(t1, true, true));
log(JSON.stringify(t1, null, 4));
