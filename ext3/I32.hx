/*
 * Copyright (c) 2009, The Caffeine-hx project contributors
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
 * THIS SOFTWARE IS PROVIDED BY THE CAFFEINE-HX PROJECT CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE CAFFEINE-HX PROJECT CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */


/**
* Static methods for cross platform use of 32 bit Int. All methods are inline,
* so there is no performance penalty.
*
* The Int32 typedef wraps either an I32 in neko, or Int on all other platforms.
* In general, do not define variables or functions typed as I32, use the
* Int32 typedef instead. This allows for native operations without having to
* call the I32 functions.
*
* @author		Russell Weir
**/
class I32 {
    /**
	* Returns byte 4 (highest byte) from the 32 bit int.
	* This is equivalent to v >>> 24 (which is the same as v >> 24 & 0xFF)
	*/
	public static inline function B4(v : haxe.Int32) : haxe.Int32
	{
		return v >> 24;
	}

	/**
	* Returns byte 3 (second highest byte) from the 32 bit int.
	* This is equivalent to v >>> 16 & 0xFF
	*/
	public static inline function B3(v : haxe.Int32) : haxe.Int32
	{
		return (v >> 16) & 0xFF;
	}

	/**
	* Returns byte 2 (second lowest byte) from the 32 bit int.
	* This is equivalent to v >>> 8 & 0xFF
	*/
	public static inline function B2(v : haxe.Int32) : haxe.Int32
	{
		return (v >> 8) & 0xFF;
	}

	/**
	* Returns byte 1 (lowest byte) from the 32 bit int.
	* This is equivalent to v & 0xFF
	*/
	public static inline function B1(v : haxe.Int32) : haxe.Int32
	{
		return v & 0xFF;
	}

	/**
	*	Encode a 32 bit int to String in base [radix].
	*
	*	@param v Integer to convert
	*	@param radix Number base to convert to, from 2-32
	*	@return String representation of the number in the given base.
	**/
	public static function baseEncode(v : haxe.Int32, radix : Int) : String
	{
		if(radix < 2 || radix > 36)
			throw "radix out of range";
		var sb = "";
		var av : haxe.Int32 = v < 0?-v:v;
		var radix32 : haxe.Int32 = radix;
		while(true) {
			var r32 : haxe.Int32 = av % radix32;
			sb = Constants.DIGITS_BN.charAt(r32) + sb;
			av = Std.int((av-r32) / radix32);
			if(av == 0)
				break;
		}
		if(v < 0)
			return "-" + sb;
		return sb;
	}


	/**
	* Encode an Int32 to a big endian string.
	**/
	public static function encodeBE(i : haxe.Int32) : Bytes
	{
		var b = Bytes.alloc(4);
		b.set(0, untyped B4(i));
		b.set(1, untyped B3(i));
		b.set(2, untyped B2(i));
		b.set(3, untyped B1(i));
		return b;
	}

	/**
	* Encode an Int32 to a little endian string. Lowest byte is first in string so
	* 0xA0B0C0D0 encodes to [D0,C0,B0,A0]
	**/
	public static function encodeLE(i : haxe.Int32) : Bytes
	{
		var b = Bytes.alloc(4);
		b.set(0, untyped B1(i));
		b.set(1, untyped B2(i));
		b.set(2, untyped B3(i));
		b.set(3, untyped B4(i));
		return b;
	}

	/**
	* Decode 4 big endian encoded bytes to a 32 bit integer.
	**/
	public static function decodeBE( s : Bytes, ?pos : Int ) : haxe.Int32
	{
		if(pos == null)
			pos = 0;
		var b0 : haxe.Int32 = s.get(pos+3);
		var b1 : haxe.Int32 = s.get(pos+2);
		var b2 : haxe.Int32 = s.get(pos+1);
		var b3 : haxe.Int32 = s.get(pos);
		b1 <<= 8;
		b2 <<= 16;
		b3 <<= 24;
		return b0 + b1 + b2 + b3;
	}

	/**
	* Decode 4 little endian encoded bytes to a 32 bit integer.
	**/
	public static function decodeLE( s : Bytes, ?pos : Int ) : haxe.Int32
	{
		if(pos == null)
			pos = 0;
		var b0 : haxe.Int32 = s.get(pos);
		var b1 : haxe.Int32 = s.get(pos+1);
		var b2 : haxe.Int32 = s.get(pos+2);
		var b3 : haxe.Int32 = s.get(pos+3);
		b1 <<= 8;
		b2 <<= 16;
		b3 <<= 24;
		return b0 + b1 + b2 + b3;
	}

	/**
	* Convert an array of 32bit integers to a big endian buffer.
	*
	* @param l Array of Int32 types
	* @return Bytes big endian encoded.
	**/
	public static function packBE(l : Array<haxe.Int32>) : Bytes
	{
		var sb = new BytesBuffer();
		for(i in 0...l.length) {
			sb.addByte( B4(l[i]) );
			sb.addByte( B3(l[i]) );
			sb.addByte( B2(l[i]) );
			sb.addByte( B1(l[i]) );
		}
		return sb.getBytes();
	}

	/**
	* Convert an array of 32bit integers to a little endian buffer.
	*
	* @param l Array of Int32 types
	* @return Bytes little endian encoded.
	**/
	public static function packLE(l : Array<haxe.Int32>) : Bytes
	{
		var sb = new BytesBuffer();
		for(i in 0...l.length) {
			sb.addByte( B1(l[i]) );
			sb.addByte( B2(l[i]) );
			sb.addByte( B3(l[i]) );
			sb.addByte( B4(l[i]) );
		}
		return sb.getBytes();
	}

	/**
	* On platforms where there is a native 32 bit int, this will
	* cast an Int32 array properly without overflows thrown.
	*
	* @throws String Overflow in neko only if 32 bits are required.
	public static inline function toNativeArray(v : Array<Int32>) : Array<Int> {
		#if neko
			var a = new Array<Int>();
			for(i in v)
				a.push(toInt(i));
			return a;
		#else
			return cast v;
		#end
	}**/

	/**
	* Convert a buffer containing 32bit integers to an array of ints.
	* If the buffer length is not a multiple of 4, an exception is thrown
	**/
	public static function unpackLE(s : Bytes) : Array<haxe.Int32>
	{
		if(s == null || s.length == 0)
			return new Array();
		if(s.length % 4 != 0)
			throw "Buffer not multiple of 4 bytes";

		var a = new Array<haxe.Int32>();
		var pos = 0;
		var i = 0;
		var len = s.length;
		while(pos < len) {
			a[i] = decodeLE( s, pos );
			pos += 4;
			i++;
		}
		return a;
	}

	/**
	* Convert a buffer containing 32bit integers to an array of ints.
	* If the buffer length is not a multiple of 4, an exception is thrown
	**/
	public static function unpackBE(s : Bytes) : Array<haxe.Int32>
	{
		if(s == null || s.length == 0)
			return new Array();
		if(s.length % 4 != 0)
			throw "Buffer not multiple of 4 bytes";

		var a = new Array();
		var pos = 0;
		var i = 0;
		while(pos < s.length) {
			a[i] = decodeBE( s, pos );
			pos += 4;
			i++;
		}
		return a;
	}
}
