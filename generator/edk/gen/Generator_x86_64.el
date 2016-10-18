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
import edk.gen.Method;
import edk.gen.MacroInstruction;
import edk.gen.Operand;

import elec.io.ITextOutputStream;
import elec.util.ArrayList;
import elec.util.Iterator;
import elec.util.Integer;
import elec.util.IList;
import elec.rt.System;
import elec.rt.IllegalArgumentError;

/**
 * Assembly generator for x86_64.
 */
public class Generator_x86_64 extends Generator
{
	private uint dataSize = (uint)0;
	private int nextSymbolIndex = 0;
	private bool targetPIC = false;
	
	private uint getTypeSize(int type)
	{
		return (uint) 8;
	};
	
	private String getFreeSymbol()
	{
		return "_S" + new String(nextSymbolIndex++);
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
	
	private void generateDelete(ArrayList<Integer> regTypes, int top, int bottom, ITextOutputStream out)
	{		
		int i;
		for (i=top; i>=bottom; i--)
		{
			if (regTypes[i].get() == Field.MAN)
			{
				// decref and destroy if necessary
				String skipSymbol = getFreeSymbol();
				
				out.writeLine("\tmovq -" + new String(8*(i+1)) + "(%rbp), %rdx");
				out.writeLine("\ttest %rdx, %rdx");
				out.writeLine("\tjz " + skipSymbol);
				out.writeLine("\tmovl $-1, %eax");
				out.writeLine("\txadd %rax, (%rdx)");
				out.writeLine("\tjnz " + skipSymbol);
				if (targetPIC)
				{
					out.writeLine("\tcall _Elec_Destroy@plt");
				}
				else
				{
					out.writeLine("\tcall _Elec_Destroy");
				};
				
				out.writeLine(skipSymbol + ":");
			};
			
			regTypes.remove(i);
		};
		
		out.writeLine("\taddq $" + new String(8 * (top - bottom + 1)) + ", %rsp");
	};
	
	private void generateAlloc(ArrayList<Integer> regTypes, int reg, int type, ITextOutputStream out)
	{
		regTypes.add(new Integer(type));
		
		out.writeLine("\tpushq $0");
	};
	
	private void generateLoadInt(int regno, int value, ITextOutputStream out)
	{
		out.writeLine("\tmovq $" + new String(value) + ", %rax");
		out.writeLine("\tmovq %rax, -" + new String(8*(regno+1)) + "(%rbp)");
	};
	
	private void generateLink(String symClass, String symOffset, String symValue, ITextOutputStream out)
	{
		out.writeLine("\tmovq %r15, %rdx");
		
		if (targetPIC)
		{
			out.writeLine("\tmovq " + symClass + "@GOTPCREL(%rip), %rsi");
			out.writeLine("\tcall _Elec_GetData@PLT");
			out.writeLine("\tmovq " + symOffset + "@GOTPCREL(%rip), %r8");
			out.writeLine("\taddq (%r8), %rax");
			out.writeLine("\tleaq " + symValue + "(%rip), %r8");
			out.writeLine("\tmovq %r8, (%rax)");
		}
		else
		{
			out.writeLine("\tleaq " + symClass + "(%rip), %rsi");
			out.writeLine("\tcall _Elec_GetData");
			out.writeLine("\taddq " + symOffset + ", %rax");
			out.writeLine("\tleaq " + symValue + "(%rip), %r8");
			out.writeLine("\tmovq %r8, (%rax)");
		};
	};
	
	private void generateMethod(Method method, ITextOutputStream out)
	{
		/**
		 * Types of registers.
		 */
		ArrayList<Integer> regTypes = new ArrayList<Integer>(method.getArgTypes().iterate());
		
		if (method.getSymbol() != "_init")
		{
			out.writeLine(".globl " + method.getSymbol());
		};
		
		out.writeLine(method.getSymbol() + ":");
		
		/**
		 * Set up the frame. We expect a symbol called "%s_fi", where %s is the function symbol
		 * name, to point to the function information structure.
		 *
		 * We save the previous value of %r15 in fiPriv and then set %r15 to the "this" value
		 * (which is passed in %rdx).
		 */
		out.writeLine("\tsubq $24, %rsp");
		out.writeLine("\tmovq %rbp, (%rsp)");
		out.writeLine("\tmovq $" + method.getSymbol() + "_fi, %rax");
		out.writeLine("\tmovq %rax, 8(%rsp)");
		out.writeLine("\tmovq %r15, 16(%rsp)");
		out.writeLine("\tmovq %rsp, %rbp");
		out.writeLine("\tsubq $" + new String(8*regTypes.size()) + ", %rsp");
		out.writeLine("\tmovq %rdx, %r15");
		out.writeLine("");
		
		/**
		 * Copy the arguments over.
		 */
		int i;
		for (i=0; i<method.getArgTypes().size(); i++)
		{
			out.writeLine("\tmovq " + new String(8 * i) + "(%rsi), %rax");
			out.writeLine("\tmovq %rax, -" + new String(8 * (i+1)) + "(%rbp)");
		};
		out.writeLine("");
		
		String retSymbol = getFreeSymbol();
		
		Iterator<MacroInstruction> it;
		for (it=method.iterate(); !it.end(); it.next())
		{
			MacroInstruction inst = it.get();
			IList<Operand> ops = inst.getOperands();
			
			if (inst.getMacro() == "eir_delete")
			{
				if (ops.size() != 2)
				{
					System.stderr.writeLine("x86_64: 'eir_delete' macro takes 2 register operands");
					System.exit(1);
				};
				
				Operand opTop = ops[0];
				Operand opBottom = ops[1];
				
				if ((opTop.getType() != Operand.REGISTER) || (opBottom.getType() != Operand.REGISTER))
				{
					System.stderr.writeLine("x86_64: 'eir_delete' macro takes 2 register operands");
					System.exit(1);
				};
				
				if (opTop.getValue() < opBottom.getValue())
				{
					System.stderr.writeLine("x86_64: top is less than bottom in 'eir_delete'");
					System.exit(1);
				};
				
				if (opTop.getValue() != (regTypes.size()-1))
				{
					System.stderr.writeLine("x86_64: top register is currently %"
						+ new String(regTypes.size()-1) + " but %" + new String(opTop.getValue())
						+ " was specified for 'eir_delete'");
					System.exit(1);
				};
				
				out.writeLine("\t// eir_delete %" + new String(opTop.getValue()) + ", %"
					+ new String(opBottom.getValue()));
				generateDelete(regTypes, opTop.getValue(), opBottom.getValue(), out);
				out.writeLine("");
			}
			else if (inst.getMacro() == "eir_alloc")
			{
				if (ops.size() != 2)
				{
					System.stderr.writeLine("x86_64: 'eir_alloc' macro takes 2 operands");
					System.exit(1);
				};
				
				Operand opReg = ops[0];
				Operand opType = ops[1];
				
				if ((opReg.getType() != Operand.REGISTER) || (opType.getType() != Operand.NAME))
				{
					System.stderr.writeLine("x86_64: 'eir_alloc' macro operands invalid");
					System.exit(1);
				};
				
				int type;
				try
				{
					type = EIR.getTypeByName(opType.getName());
				}
				catch (IllegalArgumentError e)
				{
					System.stderr.writeLine("x86_64: 'eir_alloc' error: " + e.getMessage());
					System.exit(1);
				};
				
				if (opReg.getValue() != regTypes.size())
				{
					System.stderr.writeLine("x86_64: 'eir_alloc': expecting register %"
						+ new String(regTypes.size()) + ", got %" + new String(opReg.getValue()));
					System.exit(1);
				};
				
				out.writeLine("\t// eir_alloc %" + new String(opReg.getValue()) + ", @" + opType.getName());
				generateAlloc(regTypes, opReg.getValue(), type, out);
				out.writeLine("");
			}
			else if (inst.getMacro() == "eir_ldi")
			{
				if (ops.size() != 2)
				{
					System.stderr.writeLine("x86_64: 'eir_ldi' expects a register and constant operand");
					System.exit(1);
				};
				
				Operand opReg = ops[0];
				Operand opVal = ops[1];
				
				if ((opReg.getType() != Operand.REGISTER) || (opVal.getType() != Operand.CONST))
				{
					System.stderr.writeLine("x86_64: 'eir_ldi' expects a register and constant operand");
					System.exit(1);
				};
				
				int regno = opReg.getValue();
				if (regno >= regTypes.size())
				{
					System.stderr.writeLine("x86_64: 'eir_ldi': register %" + new String(regno) + 
						" is not allocated");
					System.exit(1);
				};
				
				if (regTypes[regno].get() != Field.INT)
				{
					System.stderr.writeLine("x86_64: 'eir_ldi': register %" + new String(regno) +
						" is not of type 'int'");
					System.exit(1);
				};
				
				out.writeLine("\t// eir_ldi %" + new String(regno) + ", $" + new String(opVal.getValue()));
				generateLoadInt(regno, opVal.getValue(), out);
				out.writeLine("");
			}
			else if (inst.getMacro() == "eir_ret")
			{
				if (ops.size() != 1)
				{
					System.stderr.writeLine("x86_64: 'eir_ret' expects a register operand");
					System.exit(1);
				};
				
				Operand opReg = ops[0];
				
				if (opReg.getType() != Operand.REGISTER)
				{
					System.stderr.writeLine("x86_64: 'eir_ret' expects a register operand");
					System.exit(1);
				};
				
				int regno = opReg.getValue();
				if (opReg.getValue() >= regTypes.size())
				{
					System.stderr.writeLine("x86_64: 'eir_ret': register %" + new String(regno)
						+ " is not allocated");
					System.exit(1);
				};
				
				if (regTypes[regno].get() != method.getReturnType())
				{
					System.stderr.writeLine("x86_64: 'eir_ret': register %" + new String(regno)
						+ " does not match return type");
					System.exit(1);
				};
				
				out.writeLine("\t// eir_ret %" + new String(regno));
				
				/**
				 * We no longer need 'this' in %r15 because we're returning; so we load the return
				 * register into it since it's preserved and we may need to call _Elec_Destroy a
				 * few times. The prologue code will expect this.
				 */
				out.writeLine("\tmov -" + new String(8*(regno+1)) + "(%rbp), %r15");
				generateDelete(regTypes, regTypes.size()-1, 0, out);
				out.writeLine("\tjmp " + retSymbol);
				out.writeLine("");
			}
			else if (inst.getMacro() == "eir_link")
			{
				if (ops.size() != 3)
				{
					System.stderr.writeLine("x86_64: 'eir_link' expects 3 name operands");
					System.exit(1);
				};
				
				Operand opClass = ops[0];
				Operand opOffset = ops[1];
				Operand opSymbol = ops[2];
				
				if ((opClass.getType() != Operand.NAME) || (opOffset.getType() != Operand.NAME)
					|| (opSymbol.getType() != Operand.NAME))
				{
					System.stderr.writeLine("x86_64: 'eir_link' expects 3 name operands");
					System.exit(1);
				};
				
				out.writeLine("\t// eir_link @" + opClass.getName() + ", @" + opOffset.getName()
						+ ", @" + opSymbol.getName());
				generateLink(opClass.getName(), opOffset.getName(), opSymbol.getName(), out);
				out.writeLine("");
			}
			else
			{
				System.stderr.writeLine("x86_64: unrecognised macro: '" + inst.getMacro() + "'");
				System.exit(1);
			};
		};
		
		/**
		 * We expect the return value in %r15 (see eir_ret as to why), and we default it to "0" (or "null"
		 * for managed types) if the function falls to the end.
		 *
		 * Remember that %rbp will still be inside that red zone when %rsp is updated! This avoids us using
		 * an extra mov.
		 */
		out.writeLine("\txor %r15, %r15");
		out.writeLine(retSymbol + ":");
		out.writeLine("\tmovq %r15, %rax");
		out.writeLine("\tmovq 16(%rbp), %r15");	// restore old %r15
		out.writeLine("\tleaq 24(%rbp), %rsp");
		out.writeLine("\tmovq (%rbp), %rbp");	// resotre old %rbp
		out.writeLine("\tret");
		
		out.writeLine(".size " + method.getSymbol() + ", .-" + method.getSymbol());
		out.writeLine("");
	};
	
	private void generateMethods(EIR eir, ITextOutputStream out)
	{
		Iterator<Method> it;
		for (it=eir.getMethods().iterate(); !it.end(); it.next())
		{
			generateMethod(it.get(), out);
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
		out.writeLine("\t.quad _init");					/* tdInstanceInit */
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
		out.writeLine("");
		
		// Compile the methods.
		generateMethods(eir, out);
	};
};
