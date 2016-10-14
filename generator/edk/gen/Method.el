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

import edk.gen.MacroInstruction;
import edk.gen.Field;

import elec.util.ArrayList;
import elec.util.Integer;
import elec.util.Iterator;
import elec.util.IList;

/**
 * Represents a method in EIR code.
 */
public class Method
{
	/**
	 * Return type (types are defined in the Field class).
	 */
	private int returnType;
	
	/**
	 * Types of arguments.
	 */
	private ArrayList<Integer> argTypes;
	
	/**
	 * The symbol to emit for this function.
	 */
	private String symbol;
	
	/**
	 * List of macro-instructions constituting this method.
	 */
	private ArrayList<MacroInstruction> code = new ArrayList<MacroInstruction>();
	
	public Method(String symbol, int returnType, ArrayList<Integer> argTypes)
	{
		this.symbol = symbol;
		this.returnType = returnType;
		this.argTypes = argTypes;
	};
	
	/**
	 * Add a new macro instruction.
	 */
	public void add(MacroInstruction inst)
	{
		code.add(inst);
	};
	
	/**
	 * Iterate over the code.
	 */
	public Iterator<MacroInstruction> iterate()
	{
		return code.iterate();
	};
	
	/**
	 * Get the return type.
	 */
	public int getReturnType()
	{
		return returnType;
	};
	
	/**
	 * Get the arguments types.
	 */
	public IList<Integer> getArgTypes()
	{
		return argTypes;
	};
	
	/**
	 * Get the symbol for the function.
	 */
	public String getSymbol()
	{
		return symbol;
	};
};
