/*
 * Copyright (c) 2008, The Caffeine-hx project contributors
 * Original author : Russell Weir
 * Contributors:
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
	A two dimensional IntHash. Thread safe for neko
**/

package concurrent;

class ConcurrentXYHash<T> {
	var cache : IntHash<IntHash<T>>;
	#if neko
	var mutex : neko.vm.Mutex;
	#end

	public function new() {
		cache = new IntHash();
		#if neko
			mutex = new neko.vm.Mutex();
			mutex.release();
		#end
	}

	/**
		Compacts the hash by examining each X entry and removing
		those that have no values in the Y hash. Passing null as
		an argument examines the whole hash, or an array of X values
		may be specified.
	**/
	public function compact(?a:Array<Int>) {
		var k : Iterator<Int> = null;
		if(a == null) {
			k = this.keys();
		}
		else {
			k = a.iterator();
		}
		#if neko
			mutex.acquire();
		#end
		for(i in k) {
			if(!cache.exists(i))
				continue;
			var c = cache.get(i);
			if(c == null) {
				cache.remove(i);
				continue;
			}
			var cnt = 0;
			for(j in c) {
				cnt ++;
				break;
			}
			if(cnt == 0)
				cache.remove(i);
		}
		#if neko
			mutex.release();
		#end
	}

	public function exists(x:Int,y:Int) : Bool {
		var c = cache.get(x);
		if(c == null)
			return false;
		return c.exists(y);
	}

	public function get(x:Int, y: Int) : Null<T> {
		var c = cache.get(x);
		if(c == null)
			return null;
		return c.get(y);
	}

	/**
		Returns the IntHash at row X. Modifying the underlying IntHash breaks thread
		safety.
	**/
	public function getRow(x:Int) : Null<IntHash<T>> {
		return cache.get(x);
	}

	public function iterator() : Iterator<IntHash<T>> {
		return cache.iterator();
	}

	public function keys() : Iterator<Int> {
		return cache.keys();
	}

	public function remove(x:Int, y: Int) : Bool {
		#if neko
			mutex.acquire();
		#end
		var c = cache.get(x);
		if(c == null) {
			#if neko
				mutex.release();
			#end
			return false;
		}
		var rv = c.remove(y);
		#if neko
			mutex.release();
		#end
		return rv;
	}

	/**
		Set returns the previous value
	**/
	public function set(x:Int, y:Int, value:T) : Null<T> {
		#if neko
			mutex.acquire();
		#end
		var c = cache.get(x);
		if(c == null) {
			c = new IntHash<T>();
			c.set(y, value);
			cache.set(x, c);
			#if neko
				mutex.release();
			#end
			return null;
		}
		var rv = c.get(y);
		c.set(y, value);

		#if neko
			mutex.release();
		#end
		return rv;
	}

	public function toString() {
		return Std.string(cache);
	}
}