class Base implements Dynamic {
	static var guh : Int = 2;
	var dynVar : Void -> Int;

	public static function sguh() {
		return Math.abs(1);
	}

	public function new() {
		dynVar = val;
	}

	public function val() : Int {
		var v = 0;
		try {
			v = 1;
		}
		catch(e:Int) {
		}
		catch(e:Float) {
		}
		catch(e:Test) {
		}
		catch(e:Dynamic) {
		}
		return guh;
	}

	public dynamic function dynFunc(j:Int) : Int {
		return j;
	}
}

class Test extends Base {
	var aClassVar : Int;
	var aClassField : Dynamic;
	public function new(va : Int) {
		super();
		aClassVar = va;
	}

	override public function val() : Int {
		var v = super.val();
		var i = "abcdef".substr(0,3);
		trace(i);
		aClassField = Test.main;
		var f = function(b:Int, c:Int) {
			var j : Int = 0;
			for(i in 0...b) j++;
			return j;
			b = v;
			var s = i;
		}
		f(4,5);
		return v;
	}

	public function callbackFunc() : Dynamic {
		var f = function(b:Int, c:Int) {
			var j : Int = 0;
			for(i in 0...c) j++;
			return b;
		}
		return callback(f, 2);
	}

	public static function main() {
		trace("Hello world");

		var s = new Test(67);
		var ms = "Hi";
		var fs = ms + " there";
		trace(fs);
		var sb = new StringBuf();
		sb.add("Hi");
		trace(sb.toString());
		trace(sb.toString().charCodeAt(1));

		//var g :Test= Type.createInstance(Test,[]);
		//trace(g.val());
		trace("--- Fields for Test ---");
		var a = Reflect.fields(Test);
		for(i in 0...a.length) {
			trace(a[i]);
		}

		trace("--- Fields for Base ---");
		var a = Reflect.fields(Base);
		for(i in 0...a.length) {
			trace(a[i]);
		}

		trace("--- Instance fields for Test ---");
		a = Type.getInstanceFields(Test);
		for(i in 0...a.length) {
			trace(a[i]);
		}

		trace("--- hasField Test --");
		trace(Reflect.hasField(Test, "a"));
		trace(Reflect.hasField(Test, "main"));
		trace("Deleting main:" + Reflect.deleteField(Test,"main"));
		trace(Reflect.hasField(Test, "val"));

		trace("--- instance aClassVar == 67 ---");
		trace(s.aClassVar);

		s.aClassVar = if(s.aClassVar > 5) 2 else 8;
	}
}
