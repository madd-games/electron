/*
	Electron Development Kit (EDK)

	Copyright (c) 2016, Madd Games.
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	* Redistributions of source code must retain the above copyright notice, this
	  list of conditions and the following disclaimer.
	
	* Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package edk.gen;

import edk.gen.EIR;
import edk.gen.Generator;
import edk.gen.Field;

import elec.io.ITextOutputStream;
import elec.util.ArrayList;
import elec.util.Iterator;

/**
 * Assembly generator for x86_64.
 */
public class Generator_x86_64 extends Generator
{
	private uint dataSize = (uint)0;
	
	private uint getTypeSize(int type)
	{
		return (uint) 8;
	};
	
	private void generateFields(EIR eir, ITextOutputStream out)
	{
		Iterator<Field> it;
		for (it=eir.getFields().iterate(); !it.end(); it.next())
		{
			uint size = getTypeSize(it.get().getType());
			dataSize = (dataSize + size - (uint)1) & (~(size-(uint)1));
			
			uint offset = dataSize;
			dataSize += size;
			
			if (it.get().isGlobal())
			{
				out.writeLine(".globl " + it.get().getSymbol());
			};
			
			out.writeLine(it.get().getSymbol() + ":");
			out.writeLine(".quad " + new String(offset));
			out.writeLine(".size " + it.get().getSymbol() + ", .-" + it.get().getSymbol());
			out.writeLine("");
		};
	};
	
	public void generate(EIR eir, ITextOutputStream out)
	{
		// Global symbol declarations.
		out.writeLine(".globl " + eir.getTypedefSymbol());
		out.writeLine("");

		out.writeLine(".section .rodata");
		// Field offsets
		generateFields(eir, out);

		// Type definition
		uint tdFlagsAndDataSize = ((uint) eir.getFlags() << (uint)56) + dataSize;
		ArrayList<String> implSymbols = eir.getImplSymbols();
		
		out.writeLine(eir.getTypedefSymbol() + ":");
		out.writeLine("\t.quad " + new String(tdFlagsAndDataSize));	/* tdFlagsAndDataSize */
		out.writeLine("\t.quad " + eir.getParentSymbol());		/* tdParentClass */
		out.writeLine("\t.quad 0");					/* tdInstanceInit */
		out.writeLine("\t.quad " + new String(implSymbols.size()));	/* tdNumInterfaces */
		out.writeLine("\t.quad _interfaces");				/* tdInterfaces */
		out.writeLine("\t.quad 64");					/* tdSize */
		out.writeLine("\t.quad _class_name");				/* tdName */
		out.writeLine("\t.quad 0");					/* tdInstanceFini */
		out.writeLine("");
		out.writeLine("_class_name:");
		out.writeLine(".string \"" + eir.getFullName() + "\"");
		out.writeLine("_interfaces:");
		
		Iterator<String> it;
		for (it=implSymbols.iterate(); !it.end(); it.next())
		{
			out.writeLine("\t.quad " + it.get());
		};
		
		out.writeLine(".size " + eir.getTypedefSymbol() + ", .-" + eir.getTypedefSymbol());
	};
};
