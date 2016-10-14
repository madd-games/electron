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

import elec.util.Integer;
import elec.rt.IllegalArgumentError;

/**
 * Represents an operand to a macro.
 */
public class Operand
{
	/**
	 * Types of operands.
	 */
	public static int CONST = 0;		// $x
	public static int REGISTER = 1;		// %x
	public static int NAME = 2;		// @x
	
	private int type;
	private int value;			// only valid if type != NAME
	private String name;			// only valid if type == NAME
	
	public Operand(int type, int value)
	{
		this.type = type;
		this.value = value;
		this.name = "";
	};
	
	public Operand(String name)
	{
		this.type = NAME;
		this.value = 0;
		this.name = name;
	};
	
	/**
	 * Parse an operand string (EIR text representation) and return it as an Operand object.
	 */
	public static Operand parse(String token)
	{
		if (token.endsWith(","))
		{
			return parse(token.substring(0, token.size()-1));
		};
		
		if (token.startsWith("$"))
		{
			return new Operand(CONST, new Integer(token.substring(1)).get());
		}
		else if (token.startsWith("%"))
		{
			return new Operand(REGISTER, new Integer(token.substring(1)).get());
		}
		else if (token.startsWith("@"))
		{
			return new Operand(token.substring(1));
		}
		else
		{
			throw new IllegalArgumentError("unknown operand type: " + token);
		};
	};
	
	/**
	 * Get the type of operand.
	 */
	public int getType()
	{
		return type;
	};
	
	/**
	 * Get the value of the operand if it's numeric (CONST or REGISTER).
	 */
	public int getValue()
	{
		if ((type == CONST) || (type == REGISTER))
		{
			return value;
		}
		else
		{
			throw new IllegalArgumentError("getValue() called on an operand that is not CONST not REGISTER");
		};
	};
	
	/**
	 * Get the name, if this is an operand of type NAME.
	 */
	public String getName()
	{
		if (type == NAME)
		{
			return name;
		}
		else
		{
			throw new IllegalArgumentError("getName() called on an operand that is not a NAME");
		};
	};
};
