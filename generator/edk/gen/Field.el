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

/**
 * Represents a field in a type's data area.
 */
public class Field
{
	/**
	 * Whether the symbol emitted is local (false) or global (true)
	 */
	private bool global;
	
	/**
	 * Types of fields.
	 */
	public static int INT = 0;
	public static int UINT = 1;
	public static int FLOAT = 2;
	public static int MAN = 3;		/* managed */
	public static int METHOD = 4;
	
	/**
	 * Type of this field.
	 */
	private int type;
	
	/**
	 * The symbol to emit for this field's offset.
	 */
	private String symbol;
	
	public Field(bool global, int type, String symbol)
	{
		this.global = global;
		this.type = type;
		this.symbol = symbol;
	};
	
	public bool isGlobal()
	{
		return global;
	};
	
	public int getType()
	{
		return type;
	};
	
	public String getSymbol()
	{
		return symbol;
	};
};
