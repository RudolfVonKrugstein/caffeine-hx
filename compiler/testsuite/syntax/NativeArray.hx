package syntax;

import unit.Assert;

class NativeArray {
	public function new() {}
	private var dy : Dynamic;
	private var ar : Array<Int>;
	
	public function testNullable() {
		var a : Null<Array<Int>> = [1];
		Assert.equals(1, a.length);
	}
		
	public function testD() {
		var a : Dynamic = [1, 2];
		ar = [1, 2];
		Assert.equals(2, a.length);
		Assert.equals(1, a[0]);
		Assert.equals(2, ar.length);
		Assert.equals(1, ar[0]);
	}
	
	public function testDRef() {
		var a = [1, 2];
		ar = [1, 2];
		var d = adref(a);
		dy = adref(ar);
		Assert.equals(2, d.length);
		Assert.equals(2, dy.length);
		Assert.equals(2, adref([1, 2]).length);
	}
	
	public function testDArg() {
		var a = [1, 2];
		ar = [1, 2];
		var d = adarg(a);
		dy = adarg(ar);
		Assert.equals(2, d.length);
		Assert.equals(2, dy.length);
		Assert.equals(2, adarg([1, 2]).length);
	}
	
	public function testUntypedCast() {
		var d1 = [1];
		var a : Array<Int> = cast d1;
		Assert.equals(1, a.length);
		Assert.equals(1, d1.length);
	}
	
	public function testCast() {
		var d1 = [1];
		var a : Array<Dynamic> = cast(d1, Array<Dynamic>);
		Assert.equals(1, a.length);
		Assert.equals(1, d1.length);
	}
	
	public function testEnum() {
		var a1 = arr([1]);
		var a2 = darr([1]);
		enumAssert(a1, [1]);
		enumAssert(a2, [1]);
	}
	
	static function enumAssert(e : NativesArrayEnum, ?aeq : Array<Int>, ?seq : String) {
		switch(e) {
			case arr(a):
				Assert.equals(aeq.length, a.length);
				Assert.equals(aeq[0], a[0]);
			case darr(a):
				Assert.equals(aeq.length, a.length);
				Assert.equals(aeq[0], a[0]);
			default:
				Assert.fail();
		}
	}
	
	static function darg(d : Dynamic) : Dynamic {
		return d;
	}

	
	static function adref(a : Array<Int>) : Dynamic {
		return a;
	}
	
	static function adarg(a : Dynamic) : Array<Int> {
		return a;
	}
	
	public function testReflectField() {
		var a = [1, 2];
		Assert.equals(2, Reflect.field(a, 'length'));
		var f = Reflect.field(a, 'pop');
		Assert.equals(2, f());
	}
	
	public function testReflectCallMethod() {
		var a = [1, 2];
		Assert.equals(2, Reflect.callMethod(a, 'pop', []));
	}
	
	public function testReflectFields() {
		var fields = Reflect.fields([]);
		var expected = ["push", "concat", "join", "pop", "reverse", "shift", "slice", "sort", "splice", "toString", "copy", "unshift", "insert", "remove", "iterator", "length"];
		Assert.isTrue(fields.length > 0);
		for(field in fields)
			Assert.isTrue(Lambda.has(expected, field));
	}
	
	public function testReflectIsFunction1() {
		Assert.isTrue(Reflect.isFunction([].join));
	}
	
	public function testReflectIsFunction2() {
		var f = Reflect.field([], 'concat');
		Assert.isTrue(Reflect.isFunction(f));
	}

	public function testReflectCompareMethods() {
		var a = [];
		Assert.equals(a.pop, a.pop);
		Assert.equals([].pop, [].pop);
	}
	
	public function testReflectIsObject() {
		var a = [];
		var d : Dynamic = [];
		Assert.isTrue(Reflect.isObject(a));
		Assert.isTrue(Reflect.isObject(d));
	}
	
	public function testReflectCopy() {
		var a1 = [1];
		var a2 = Reflect.copy(a1);
		Assert.equals(a1.length, a2.length);
		Assert.equals(a1[0], a2[0]);
	}
	
	public function testCreateInstance() {
		var a = Type.createInstance(Array, []);
		// TODO, check other platforms on this
		Assert.equals(0, a.length);
	}
	
	public function testCreateEmptyInstance() {
		var a = Type.createEmptyInstance(Array);
		// TODO, check other platforms on this
		Assert.equals(0, a.length);
	}
	
	public function testTypeGetInstanceFields() {
		var fields = Type.getInstanceFields(Array);
		var expected = ["push", "concat", "join", "pop", "reverse", "shift", "slice", "sort", "splice", "toString", "copy", "unshift", "insert", "remove", "iterator", "length"];
		Assert.isTrue(fields.length > 0);
		for(field in fields)
			Assert.isTrue(Lambda.has(expected, field));
	}
	
	public function testTypeGetClassFields() {
		var fields = Type.getClassFields(Array);
		var expected = [];
		Assert.isTrue(fields.length == 0);
	}
}

enum NativesArrayEnum {
	arr(a : Array<Int>);
	darr(a : Dynamic);
}