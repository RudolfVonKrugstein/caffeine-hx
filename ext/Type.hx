
/**
	An abstract type that represents an Enum.
	See [Type] for the haXe Reflection API.
**/
extern class Enum {
}

/**
	The diffent possible runtime types of a value.
	See [Type] for the haXe Reflection API.
**/
enum ValueType {
	TNull;
	TInt;
	TFloat;
	TBool;
	TObject;
	TFunction;
	TClass( c : Class<Dynamic> );
	TEnum( e : Enum );
	TUnknown;
}

/**
	The haXe Reflection API enables you to retreive informations about any value,
	Classes and Enums at runtime.
**/
class Type {

	/**
		Converts a value to an Enum or returns [null] if the value is not an Enum.
	**/
	public static function toEnum( t : Dynamic ) : Enum untyped {
		try {
		#if flash9
			if( !t.__isenum )
				return null;
		#else true
			if( t.__ename__ == null )
				return null;
		#end
			return t;
		} catch( e : Dynamic ) {
		}
		return null;
	}

	/**
		Converts a value to a Class or returns [null] if the value is not a Class.
	**/
	public static function toClass( t : Dynamic ) : Class<Dynamic> untyped {
		try {
		#if (flash9 || hllua)
			if( !t.hasOwnProperty("prototype") )
				return null;
		#else true
			if( t.__name__ == null )
				return null;
		#end
			return t;
		} catch( e : Dynamic ) {
		}
		return null;
	}

	/**
		Returns the class of a value or [null] if this value is not a Class instance.
	**/
	public static #if !(flash9 || hllua) inline #end function getClass<T>( o : T ) : Class<T> untyped {
		#if flash9
			var cname = __global__["flash.utils.getQualifiedClassName"](o);
			if( cname == "null" || cname == "Object" || cname == "int" || cname == "Number" || cname == "Boolean" )
				return null;
			if( o.hasOwnProperty("prototype") )
				return null;
			var c = __as__(__global__["flash.utils.getDefinitionByName"](cname),Class);
			if( c.__isenum )
				return null;
			return c;
		#else flash
			// Needs var obj; because of inline
			var obj = if( o.__enum__ != null ) null else o.__class__;
			return obj;
		#else js
			return if( o != null && o.__enum__ == null ) o.__class__;
		#else neko
			return if( __dollar__typeof(o) != __dollar__tobject ) null else {
				var p = __dollar__objgetproto(o);
				if( p != null ) p.__class__;
			}
		#else hllua
			//return if( o != null && o.__enum__ == null ) o.__class__;
			var cname = __global__["Haxe.getQualifiedClassName"](o);
			if( cname == null || cname == "Object" || cname == "int" || cname == "Number" || cname == "Boolean" )
				return null;
			if( cname == "String") return "String";
			if( hasOwnProperty(o, "prototype") )
				return null;
			return if( o.__enum__ != null ) null else o.__class__;
		#else error
		#end
	}

	/**
		Returns the enum of a value or [null] if this value is not an Enum instance.
	**/
	public static #if !flash9 inline #end function getEnum( o : Dynamic ) : Enum untyped {
		#if flash9
			var cname = __global__["flash.utils.getQualifiedClassName"](o);
			if( cname == "null" || cname.substr(0,8) == "builtin." )
				return null;
			// getEnum(Enum) should be null
			if( o.hasOwnProperty("prototype") )
				return null;
			var c = __as__(__global__["flash.utils.getDefinitionByName"](cname),Class);
			if( !c.__isenum )
				return null;
			return c;
		#else flash
			return o.__enum__;
		#else js
			return if( o != null ) o.__enum__;
		#else neko
			return if( __dollar__typeof(o) == __dollar__tobject ) o.__enum__;
		#else hllua
			return if( o != null ) o.__enum__;
		#else error
		#end
	}


	/**
		Returns the super-class of a class, or null if no super class.
	**/
	public static inline function getSuperClass( c : Class<Dynamic> ) : Class<Dynamic> untyped {
		#if flash9
			var cname = __global__["flash.utils.getQualifiedSuperclassName"](c);
			// Needed sc to force the Class<Dynamic> type, or flash gives a reconcile error...
			var sc:Class<Dynamic> = if( cname == "Object" ) null else __as__(__global__["flash.utils.getDefinitionByName"](cname),Class);
			return sc;
		#else true
			return c.__super__;
		#end
	}


	/**
		Returns the complete name of a class.
	**/
	public static function getClassName( c : Class<Dynamic> ) : String {
		#if flash9
			return if( c != null ) {
				var str : String = untyped __global__["flash.utils.getQualifiedClassName"](c);
				str.split("::").join(".");
			}
		#else hllua
			return if( c != null ) untyped __global__["Haxe.getQualifiedClassName"](c);
		#else true
			return if( c != null ) untyped c.__name__.join(".");
		#end
	}

	/**
		Returns the complete name of an enum.
	**/
	public static #if !hllua inline #end function getEnumName( e : Enum ) : String {
		#if flash9
			return untyped __global__["flash.utils.getQualifiedClassName"](e);
		#else hllua
			var a : Array<String> = untyped e.__ename__;
			return a.join(".");
		#else true
			return untyped e.__ename__.join(".");
		#end
	}

	/**
		Evaluates a class from a name. The class must have been compiled
		to be accessible.
	**/
	public static function resolveClass( name : String ) : Class<Dynamic> {
		var cl : Class<Dynamic>;
		untyped {
		#if flash9
			try {
				cl = __as__(__global__["flash.utils.getDefinitionByName"](name),Class);
				if( cl.__isenum )
					return null;
				return cl; // skip test below
			} catch( e : Dynamic ) {
				return null;
			}
		#else flash
			cl = __eval__(name);
		#else js
			try {
				cl = eval(name);
			} catch( e : Dynamic ) {
				cl = null;
			}
		#else neko
			var path = name.split(".");
			cl = Reflect.field(untyped neko.Boot.__classes,path[0]);
			var i = 1;
			while( cl != null && i < path.length ) {
				cl = Reflect.field(cl,path[i]);
				i += 1;
			}
		#else hllua
			cl = Reflect.field(untyped __lua__("_G.package.loaded"),name);
		#else error
		#end
		// ensure that this is a class
		if( cl == null || cl.__name__ == null )
			return null;
		}
		return cl;
	}


	/**
		Evaluates an enum from a name. The enum must have been compiled
		to be accessible.
	**/
	public static function resolveEnum( name : String ) : Enum {
		var e : Dynamic;
		untyped {
		#if flash9
			try {
				e = __global__["flash.utils.getDefinitionByName"](name);
				if( !e.__isenum )
					return null;
				return e;
			} catch( e : Dynamic ) {
				return null;
			}
		#else flash
			e = __eval__(name);
		#else js
			try {
				e = eval(name);
			} catch( e : Dynamic ) {
				e = null;
			}
		#else neko
			var path = name.split(".");
			e = Reflect.field(neko.Boot.__classes,path[0]);
			var i = 1;
			while( e != null && i < path.length ) {
				e = Reflect.field(e,path[i]);
				i += 1;
			}
		#else hllua
			e = Reflect.field(untyped __lua__("_G.package.loaded"),name);
		#else error
		#end
		// ensure that this is an enum
		if( e == null || e.__ename__ == null )
			return null;
		}
		return e;
	}

	/**
		Creates an instance of the given class with the list of constructor arguments.
	**/
	public static function createInstance<T>( cl : Class<T>, args : Array<Dynamic> ) : T untyped {
		#if flash9
			return switch( args.length ) {
			case 0: __new__(cl);
			case 1: __new__(cl,args[0]);
			case 2: __new__(cl,args[0],args[1]);
			case 3: __new__(cl,args[0],args[1],args[2]);
			case 4: __new__(cl,args[0],args[1],args[2],args[3]);
			case 5: __new__(cl,args[0],args[1],args[2],args[3],args[4]);
			default: throw "Too many arguments";
			}
		#else flash
			var o = { __constructor__ : cl, __proto__ : cl.prototype };
			cl["apply"](o,args);
			return o;
		#else neko
			return untyped __dollar__call(__dollar__objget(cl,__dollar__hash("new".__s)),cl,args.__neko());
		#else (js || hllua)
			if( args.length >= 6 ) throw "Too many arguments";
			return untyped __new__(cl,args[0],args[1],args[2],args[3],args[4],args[5]);
		#else error
		#end
	}

	/**
		Similar to [Reflect.createInstance] excepts that the constructor is not called.
		This enables you to create an instance without any side-effect.
	**/
	public static function createEmptyInstance<T>( cl : Class<T> ) : T untyped {
		#if flash9
			try {
				flash.Boot.skip_constructor = true;
				var i = __new__(cl);
				flash.Boot.skip_constructor = false;
				return i;
			} catch( e : Dynamic ) {
				flash.Boot.skip_constructor = false;
				throw e;
			}
			return null;
		#else flash
			var o : Dynamic = __new__(_global["Object"]);
			o.__proto__ = cl.prototype;
			return o;
		#else js
			return __new__(cl,__js__("$_"));
		#else neko
			var o = __dollar__new(null);
			__dollar__objsetproto(o,cl.prototype);
			return o;
		#else hllua
			var o = untyped __lua__("cl:__construct__()");
			return o;
		#else error
		#end
	}

	#if flash9
	static function describe( t : Dynamic, fact : Bool ) {
		var fields = new Array();
		var xml : Dynamic = untyped __global__["flash.utils.describeType"](t);
		if( fact )
			xml = xml.factory;
		var methods = xml.child("method");
		for( i in 0...methods.length() )
			fields.push( Std.string(untyped methods[i].attribute("name")) );
		var vars = xml.child("variable");
		for( i in 0...vars.length() )
			fields.push( Std.string(untyped vars[i].attribute("name")) );
		return fields;
	}
	#end

	/**
		Returns the list of instance fields.
	**/
	public static function getInstanceFields( c : Class<Dynamic> ) : Array<String> {
		#if flash9
			return describe(c,true);
		#else true
			var a = Reflect.fields(untyped c.prototype);
			c = untyped c.__super__;
			while( c != null ) {
				a = a.concat(Reflect.fields(untyped c.prototype));
				c = untyped c.__super__;
			}
			while( a.remove(__unprotect__("__class__")) ) {
				#if neko
				a.remove("__serialize");
				a.remove("__string");
				#end
			}
			return a;
		#end
	}

	/**
		Returns the list of a class static fields.
	**/
	public static function getClassFields( c : Class<Dynamic> ) : Array<String> {
		#if flash9
			var a = describe(c,false);
			a.remove("__construct__");
			return a;
		#else hllua
			return untyped __keys__(c.__statics__);
		#else true
			var a = Reflect.fields(c);
			a.remove(__unprotect__("__name__"));
			a.remove(__unprotect__("__interfaces__"));
			a.remove(__unprotect__("__super__"));
			#if js
			a.remove("prototype");
			#end
			#if (neko || hllua)
			a.remove("__construct__");
			a.remove("prototype");
			a.remove("new");
			#end
			return a;
		#end
	}

	/**
		Returns all the available constructor names for an enum.
	**/
	public static inline function getEnumConstructs( e : Enum ) : Array<String> {
		return untyped e.__constructs__;
	}

	/**
		Returns the runtime type of a value.
	**/
	public static function typeof( v : Dynamic ) : ValueType untyped {
		#if neko
		return switch( __dollar__typeof(v) ) {
		case __dollar__tnull: TNull;
		case __dollar__tint: TInt;
		case __dollar__tfloat: TFloat;
		case __dollar__tbool: TBool;
		case __dollar__tfunction: TFunction;
		case __dollar__tobject:
			var c = v.__class__;
			if( c != null )
				TClass(c);
			else {
				var e = v.__enum__;
				if( e != null )
					TEnum(e);
				else
					TObject;
			}
		default: TUnknown;
		}
		#else flash9
		var cname = __global__["flash.utils.getQualifiedClassName"](v);
		switch(cname) {
		case "null": return TNull;
		case "void": return TNull; // undefined
		case "int": return TInt;
		case "Number": return TFloat;
		case "Boolean": return TBool;
		case "Object": return TObject;
		default:
			var c : Dynamic;
			try {
				c = __global__["flash.utils.getDefinitionByName"](cname);
				if( v.hasOwnProperty("prototype") )
					return TObject;
				if( c.__isenum )
					return TEnum(c);
				return TClass(c);
			} catch( e : Dynamic ) {
				if( cname == "builtin.as$0::MethodClosure" || cname.indexOf("-") != -1 )
					return TFunction;
				return if( c == null ) TFunction else TClass(c);
			}
		}
		return null;
		#else (flash || js || hllua)
		switch( #if flash __typeof__ #else hllua __lua__("type") #else true __js__("typeof") #end(v) ) {
		#if flash
		case "null": return TNull;
		#end
		#if hllua
		case "nil" : return TNull;
		#end
		case "boolean": return TBool;
		case "string": return TClass(String);
		case "number":
			if( v+1 == v )
				return TFloat;
			if( Math.ceil(v) == v )
				return TInt;
			return TFloat;
		#if hllua
		case "table":
		#else true
		case "object":
		#end
			#if js
			if( v == null )
				return TNull;
			#end
			var e = v.__enum__;
			if( e != null )
				return TEnum(e);
			var c = v.__class__;
			if( c != null ) {
				#if hllua
				if( hasOwnProperty(v, "prototype") )
					return TObject;
				#end
				return TClass(c);
			}
			return TObject;
		case "function":
			#if !hllua
			if( v.__name__ != null )
				return TObject;
			#end
			return TFunction;
		case "undefined":
			return TNull;
		default:
			return TUnknown;
		}
		#else error
		#end
	}

	/**
		Recursively compare two enums constructors and parameters.
	**/
	public static function enumEq<T>( a : T, b : T ) : Bool untyped {
		if( a == b )
			return true;
		#if neko
		try {
			if( a.__enum__ == null || a.tag != b.tag )
				return false;
		} catch( e : Dynamic ) {
			return false;
		}
		for( i in 0...__dollar__asize(a.args) )
			if( !enumEq(a.args[i],b.args[i]) )
				return false;
		#else flash9
		try {
			if( a.tag != b.tag )
				return false;
			for( i in 0...a.params.length )
				if( !enumEq(a.params[i],b.params[i]) )
					return false;
		} catch( e : Dynamic ) {
			return false;
		}
		#else hllua
		if(untyped __typeof__(a) != untyped __typeof__(b))
			return false;
		if(untyped __typeof__(a) == "table") {
			if( a[0] != b[0] )
				return false;
			for( i in 2...a.length )
				if( !enumEq(a[i],b[i]) )
					return false;
			var e = a.__enum__;
			if( e != b.__enum__ || e == null )
				return false;
		}
		else {
			if(a == b) return true;
			return false;
		}
		#else true
		if( a[0] != b[0] )
			return false;
		for( i in 2...a.length )
			if( !enumEq(a[i],b[i]) )
				return false;
		var e = a.__enum__;
		if( e != b.__enum__ || e == null )
			return false;
		#end
		return true;
	}

	/**
		Returns the constructor of an enum
	**/
	public static inline function enumConstructor( e : Dynamic ) : String {
	#if neko
		return new String(e.tag);
	#else flash9
		return e.tag;
	#else true
		return e[0];
	#end
	}

	/**
		Returns the parameters of an enum
	**/
	public static function enumParameters( e : Dynamic ) : Array<Dynamic> {
	#if neko
		return if( e.args == null ) [] else untyped Array.new1(e.args,__dollar__asize(e.args));
	#else flash9
		return if( e.params == null ) [] else e.params;
	#else true
		return e.slice(2);
	#end
	}

	/**
		Returns the index of the constructor of an enum
	**/
	public static inline function enumIndex( e : Dynamic ) : Int {
	#if (neko || flash9)
		return e.index;
	#else true
		return e[1];
	#end
	}

#if hllua
	static var hasOwnProperty = lua.Lib.load("Haxe","hasOwnProperty");
#end
}

