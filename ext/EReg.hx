/*
 * Copyright (c) 2005, The haXe Project Contributors
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

/**
	Regular expressions are a way to find regular patterns into
	Strings. Have a look at the tutorial on haXe website to learn
	how to use them.
**/
class EReg {

	var r : Dynamic;
	#if flash9
	var result : {> Array<String>, index : Int, input : String };
	#end
	#if neko
	var last : String;
	var global : Bool;
	#end
	#if hllua
	var _pat :String;
	var orig : String;
	var start : Int;
	var end : Int;
	var result : Dynamic;
	//var global : Bool;
	#end

	/**
		Creates a new regular expression with pattern [r] and
		options [opt].
	**/
	public function new( r : String, opt : String ) {
		#if neko
		var a = opt.split("g");
		global = a.length > 1;
		if( global )
			opt = a.join("");
		this.r = regexp_new_options(untyped r.__s, untyped opt.__s);
		#else js
		opt = opt.split("u").join(""); // 'u' (utf8) depends on page encoding
		this.r = untyped __new__("RegExp",r,opt);
		#else flash9
		this.r = untyped __new__(__global__["RegExp"],r,opt);
		#else flash
		throw "Regular expressions are not implemented for Flash <= 8";
		#else hllua
// 		var a = opt.split("g");
// 		global = a.length > 1;
// 		if( global )
// 			opt = a.join("");
		this._pat = r;
		//this.r = untyped __lua__("rex_pcre.new(r,opt)");
		this.r = rex_new(r,opt);
		rex_exec = lua.Lib.getFunction(this.r, "exec");
		#else error
		#end
	}

	/**
		Tells if the regular expression matches the String.
		Updates the internal state accordingly.
	**/
	public function match( s : String ) : Bool {
		#if neko
		var p = regexp_match(r,untyped s.__s,0,s.length);
		if( p )
			last = s;
		else
			last = null;
		return p;
		#else js
		untyped {
			r.m = r.exec(s);
			r.s = s;
			r.l = RegExp.leftContext;
			r.r = RegExp.rightContext;
			return (r.m != null);
		}
		#else flash9
		result = untyped r.exec(s);
		return (result != null);
		#else flash
		throw "EReg::match not implemented";
		return false;
		#else hllua
		orig = s;
		untyped {
		result = untyped __lua__("{}");
		//__lua__("self.start,self._end,self.result = self.r:exec(s, 0)");
		__returnList__(rex_exec(r,s,0), start, end,result);
		if(result == null) {
			result = untyped __lua__("{}");
			result[0] = "";
			return false;
		}
		else {
			var i : Int = 1;
			var c : Int = 1;
			result[0] = s.substr(start-1,end-start+1);
			while(result[i] != null) {
				var begin : Int = result[i];
				var top : Int = result[i+1];
				if(top == null) top = end;
				if(untyped __typeof__(begin) != "boolean")
					result[c] = s.substr(begin-1,top-begin+1);
				else
					result[c] = "";
				i = i + 2;
				c = c + 1;
			}
		}
		return (start != null);
		}
		#else error
		#end
	}

	/**
		Returns a matched group or throw an expection if there
		is no such group. If [n = 0], the whole matched substring
		is returned.
	**/
	public function matched( n : Int ) : String {
		#if neko
		return new String(regexp_matched(r,n));
		#else js
		return untyped if( r.m != null && n >= 0 && n < r.m.length ) r.m[n] else throw "EReg::matched";
		#else flash9
		return untyped if( result != null && n >= 0 && n < result.length ) result[n] else throw "EReg::matched";
		#else flash
		throw "EReg::matched not implemented";
		return "";
		#else hllua
		return untyped if( result != null && n >= 0 && result[n] != null ) result[n] else throw "EReg::matched";
		#else error
		#end
	}

	/**
		Returns the part of the string that was as the left of
		of the matched substring.
	**/
	public function matchedLeft() : String {
		#if neko
		var p = regexp_matched_pos(r,0);
		return last.substr(0,p.pos);
		#else js
		untyped {
			if( r.m == null ) throw "EReg::matchedLeft";
			if( r.l == null ) return r.s.substr(0,r.m.index);
			return r.l;
		}
		#else flash9
		if( result == null ) throw "No string matched";
		return result.input.substr(0,result.index);
		#else flash
		throw "EReg::matchedLeft not implemented";
		return null;
		#else hllua
		if( result == null ) throw "No string matched";
		//return untyped __lua__("string.sub(self.result[0], 1, self.start)");
		return untyped __lua__("string.sub(self.orig,1,self.start-1)");
		#else error
		#end
	}

	/**
		Returns the part of the string that was as the right of
		of the matched substring.
	**/
	public function matchedRight() : String {
		#if neko
		var p = regexp_matched_pos(r,0);
		var sz = p.pos+p.len;
		return last.substr(sz,last.length-sz);
		#else js
		untyped {
			if( r.m == null ) throw "EReg::matchedRight";
			if( r.r == null ) {
				var sz = r.m.index+r.m[0].length;
				return r.s.substr(sz,r.s.length-sz);
			}
			return r.r;
		}
		#else flash9
		if( result == null ) throw "No string matched";
		var rl = result.index + result[0].length;
		return result.input.substr(rl,result.input.length - rl);
		#else flash
		throw "EReg::matchedRight not implemented";
		return null;
		#else hllua
		if( result == null ) throw "No string matched";
		return untyped __lua__("string.sub(self.orig, self._end+1)");
		#else error
		#end
	}

	/**
		Returns the position of the matched substring within the
		original matched string.
	**/
	public function matchedPos() : { pos : Int, len : Int } {
		#if neko
		return regexp_matched_pos(r,0);
		#else js
		if( untyped r.m == null ) throw "EReg::matchedPos";
		return untyped { pos : r.m.index, len : r.m[0].length };
		#else flash9
		if( result == null ) throw "No string matched";
		return { pos : result.index, len : result[0].length };
		#else flash
		throw "EReg::matchedPos not implemented";
		return null;
		#else hllua
		if( result == null ) throw "No string matched";
		return { pos : start-1, len : end-start+1 };
		#else error
		#end
	}

	/**
		Split a string by using the regular expression to match
		the separators.
	**/
	public function split( s : String ) : Array<String> {
		#if neko
		var pos = 0;
		var len = s.length;
		var a = new Array();
		var first = true;
		do {
			if( !regexp_match(r,untyped s.__s,pos,len) )
				break;
			var p = regexp_matched_pos(r,0);
			if( p.len == 0 && !first ) {
				if( p.pos == s.length )
					break;
				p.pos += 1;
			}
			a.push(s.substr(pos,p.pos - pos));
			var tot = p.pos + p.len - pos;
			pos += tot;
			len -= tot;
			first = false;
		} while( global );
		a.push(s.substr(pos,len));
		return a;
		#else (js || flash9)
		// we can't use directly s.split because it's ignoring the 'g' flag
		var d = "#__delim__#";
		return untyped s.replace(r,d).split(d);
		#else hllua
		var d = "#__delim__#";
		var l = replace(s,d);
		return l.split(d);
		#else flash
		throw "EReg::split not implemented";
		return null;
		#else error
		#end
	}

	/**
		Replaces a pattern by another string. The [by] format can
		contains [$1] to [$9] that will correspond to groups matched
		while replacing. [$$] means the [$] character.
	**/
	public function replace( s : String, by : String ) : String {
		#if neko
		var b = new StringBuf();
		var pos = 0;
		var len = s.length;
		var a = by.split("$");
		var first = true;
		do {
			if( !regexp_match(r,untyped s.__s,pos,len) )
				break;
			var p = regexp_matched_pos(r,0);
			if( p.len == 0 && !first ) {
				if( p.pos == s.length )
					break;
				p.pos += 1;
			}
			b.addSub(s,pos,p.pos-pos);
			if( a.length > 0 )
				b.add(a[0]);
			var i = 1;
			while( i < a.length ) {
				var k = a[i];
				var c = k.charCodeAt(0);
				// 1...9
				if( c >= 49 && c <= 57 ) {
					var p = try regexp_matched_pos(r,c-48) catch( e : String ) null;
					if( p == null ){
						b.add("$");
						b.add(k);
					}else{
					b.addSub(s,p.pos,p.len);
					b.addSub(k,1,k.length - 1);
					}
				} else if( c == null ) {
					b.add("$");
					i++;
					var k2 = a[i];
					if( k2 != null && k2.length > 0 )
						b.add(k2);
				} else
					b.add("$"+k);
				i++;
			}
			var tot = p.pos + p.len - pos;
			pos += tot;
			len -= tot;
			first = false;
		} while( global );
		b.addSub(s,pos,len);
		return b.toString();
		#else (js || flash9)
		return untyped s.replace(r,by);
		#else hllua
		var l = _pat.length;
		var i = 0;
		var hasMatch = false;

		while(i < l) {
			if(_pat.charAt(i) == '\'')
				i += 2;
			else if(_pat.charAt(i) == "(") {
				hasMatch = true;
				break;
			}
			else
				i += 1;
		}
		by = by.split("%").join("%%");
		by = by.split("$$").join("%_D_o_L_l_a_r_%");
		var ap : Array<String> = by.split("$");
		by = "";
		for(x in 0...ap.length) {
			by = by + ap[x];
			if(ap[x+1] != null) {
				if(StringTools.isNum(ap[x+1],0) && hasMatch) {
					by = by + "%";
				}
				else {
					by = by + "$";
				}
			}
		}
		by = by.split("%_D_o_L_l_a_r_%").join("$");
		//return untyped __lua__("rex_pcre.gsub(s,self._pat,by)");
		return rex_gsub(s,_pat,by);
		#else flash
		throw "EReg::replace not implemented";
		return null;
		#else error
		#end
	}

	/**
		For each occurence of the pattern in the string [s], the function [f] is called and
		can return the string that needs to be replaced. All occurences are matched anyway,
		and setting the [g] flag might cause some incorrect behavior on some platforms.
	**/
	public function customReplace( s : String, f : EReg -> String ) : String {
		var buf = new StringBuf();
		while( true ) {
			if( !match(s) )
				break;
			buf.add(matchedLeft());
			buf.add(f(this));
			s = matchedRight();
		}
		buf.add(s);
		return buf.toString();
	}

#if neko
	static var regexp_new_options = neko.Lib.load("regexp","regexp_new_options",2);
	static var regexp_match = neko.Lib.load("regexp","regexp_match",4);
	static var regexp_matched = neko.Lib.load("regexp","regexp_matched",2);
	static var regexp_matched_pos : Dynamic -> Int -> { pos : Int, len : Int } = neko.Lib.load("regexp","regexp_matched_pos",2);
#end

#if hllua
	static var rexlib = lua.Lib.loadLib("rex_pcre");
	static var rex_new = lua.Lib.load("rex_pcre", "new");
	static var rex_gsub = lua.Lib.load("rex_pcre","gsub");
	var rex_exec : Dynamic;
#end

}
