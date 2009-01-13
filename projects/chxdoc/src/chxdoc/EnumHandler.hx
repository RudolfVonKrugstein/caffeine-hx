/*
 * Copyright (c) 2008-2009, The Caffeine-hx project contributors
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

package chxdoc;

import haxe.rtti.CType;
import chxdoc.Defines;
import chxdoc.Types;

class EnumHandler extends TypeHandler<EnumCtx> {

	var current : Enumdef;

	public function new() {
		super();
	}

	public function pass1(e : Enumdef) : EnumCtx {
		current = e;

		var ctx = newEnumCtx(e);

		for(c in e.constructors)
			ctx.constructorInfo.push(newEnumFieldCtx(c));

		ctx.constructorInfo.sort(TypeHandler.ctxFieldSorter);

		return ctx;
	}

	/**
		<pre>Types -> create documentation</pre>
	**/
	public function pass2(ctx : EnumCtx) {
		if(ctx.originalDoc != null)
			ctx.docs = processDoc(ctx.originalDoc);
		else
			ctx.docs = null;
		for(f in ctx.constructorInfo) {
			if(f.originalDoc == null)
				f.docs = null;
			else
				f.docs = processDoc(f.originalDoc);
		}
	}

	/**
		<pre>Types	-> Resolve all super classes, inheritance, subclasses</pre>
	**/
	public function pass3(ctx : EnumCtx) {
	}

	public static function write(ctx : EnumCtx) : String  {
		var t = new mtwin.templo.Loader("enum.mtt");
		try {
			var rv = t.execute(ctx);
			return rv;
		} catch(e : Dynamic) {
			trace("ERROR generating doc for " + ctx.path + ". Check enum.mtt");
			return neko.Lib.rethrow(e);
		}
	}

	function newEnumCtx(t : Enumdef) : EnumCtx {
		var c = createCommon(t, "enum");
		c.setField("constructorInfo", new Array<FieldCtx>());
		return cast c;
	}

	function newEnumFieldCtx(f : EnumField) : FieldCtx {
		var ctx = createField(f.name, false, f.platforms, f.doc);
		if(f.args != null) {
			var me = this;
			ctx.args = doStringBlock( function() {
				me.display(f.args, function(a) {
					if( a.opt )
						me.print("?");
					me.print(a.name);
					me.print(" : ");
					me.processType(a.t);
				},",");
			});
		}
		ctx.type = "enumfield";
		return ctx;
	}

}