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

import elec.io.*;
import elec.util.StringSplitter;
import elec.util.ArrayList;
import elec.rt.BoundError;
import elec.rt.System;
import elec.util.Integer;
import elec.rt.IllegalArgumentError;
import elec.util.Iterator;

import edk.gen.Field;

/**
 * In-memory representation of an EIR file.
 */
public class EIR
{
	private TextFileInput infile;
	private String filename;
	
	/**
	 * Name of the symbol to mark the type definition with.
	 */
	private String typedefSymbol;
	
	/**
	 * Names the symbol that defines the parent class (_Elec_TypeDef_*)
	 */
	private String parentSymbol;
	
	/**
	 * Type definition flags.
	 */
	private int flags = 0;
	
	/**
	 * Full name (path) of the class or interface.
	 */
	private String fullName;
	
	/**
	 * Names of the symbols marking interfaces implemented by this class/interface.
	 */
	private ArrayList<String> implSymbols = new ArrayList<String>();
	
	/**
	 * Fields in the data area.
	 */
	private ArrayList<Field> fields = new ArrayList<Field>();
	
	public EIR(String filename)
	{
		this.filename = filename;
		infile = new TextFileInput(filename);
	};
	
	private void fail(int lineno, String msg)
	{
		System.stderr.writeLine(filename + ":" + new String(lineno) + ":error: " + msg);
		System.exit(1);
	};
	
	private int parseLayout(int lineno)
	{
		String line;
		
		while (!infile.eof())
		{
			lineno++;
			
			try
			{
				line = infile.readLine();
			}
			catch (IOError e)
			{
				break;
			};
			
			if (line == "")
			{
				continue;
			};
			
			if (line.startsWith("#"))
			{
				continue;
			};
			
			StringSplitter splitter = new StringSplitter(line, " ");
			ArrayList<String> tokens = new ArrayList<String>(splitter);
			
			if (tokens.size() == 1)
			{
				if (tokens[0] == ".end")
				{
					break;
				};
			};
			
			if (tokens.size() != 3)
			{
				fail(lineno, "invalid syntax for field definition");
			};
			
			bool global;
			if (tokens[0] == "local")
			{
				global = false;
			}
			else if (tokens[0] == "global")
			{
				global = true;
			}
			else
			{
				fail(lineno, "a field definition must be 'local' or 'global', not '" + tokens[0] + "'");
			};
			
			int type;
			if (tokens[1] == "int")
			{
				type = Field.INT;
			}
			else if (tokens[1] == "uint")
			{
				type = Field.UINT;
			}
			else if (tokens[1] == "float")
			{
				type = Field.FLOAT;
			}
			else if (tokens[1] == "man")
			{
				type = Field.MAN;
			}
			else if (tokens[1] == "method")
			{
				type = Field.METHOD;
			}
			else
			{
				fail(lineno, "unknown type name '" + tokens[1] + "'");
			};
			
			fields.add(new Field(global, type, tokens[2]));
		};
		
		return lineno;
	};
	
	public void parse()
	{
		String line;
		
		int lineno = 0;
		while (!infile.eof())
		{	
			lineno++;
			
			try
			{
				line = infile.readLine();
			}
			catch (IOError e)
			{
				break;
			};
			
			if (line == "")
			{
				continue;
			};
			
			if (line.startsWith("#"))
			{
				continue;
			};
			
			StringSplitter splitter = new StringSplitter(line, " ");
			ArrayList<String> tokens = new ArrayList<String>(splitter);
			
			if (tokens[0] == ".typedef")
			{
				try
				{
					typedefSymbol = tokens[1];
				}
				catch (BoundError e)
				{
					fail(lineno, "the '.typedef' directive expects a parameter");
				};
			}
			else if (tokens[0] == ".parent")
			{
				try
				{
					parentSymbol = tokens[1];
				}
				catch (BoundError e)
				{
					fail(lineno, "the '.parent' directive expects a parameter");
				};
			}
			else if (tokens[0] == ".flags")
			{
				try
				{
					flags = new Integer(tokens[1]).get();
				}
				catch (BoundError e)
				{
					fail(lineno, "the '.flags' directive expects a parameter");
				}
				catch (IllegalArgumentError e)
				{
					fail(lineno, "the '.flags' directive expects a decimal integer parameters, not '"
							+ tokens[1] + "'");
				};
			}
			else if (tokens[0] == ".name")
			{
				try
				{
					fullName = tokens[1];
				}
				catch (BoundError e)
				{
					fail(lineno, "the '.name' directive expects a parameter");
				};
			}
			else if (tokens[0] == ".implements")
			{
				Iterator<String> it = tokens.iterate();
				it.next();
				implSymbols = new ArrayList<String>(it);
			}
			else if (tokens[0] == ".layout")
			{
				lineno = parseLayout(lineno);
			}
			else
			{
				fail(lineno, "unknown directive '" + tokens[0] + "'");
			};
		};
		
		if (!(typedefSymbol instanceof Object))
		{
			fail(lineno, "EOF but no typedef symbol name specified");
		};
		
		if (!(parentSymbol instanceof Object))
		{
			fail(lineno, "EOF and no parent symbol name specified");
		};
		
		infile.close();
	};
	
	public String getTypedefSymbol()
	{
		return typedefSymbol;
	};
	
	public String getParentSymbol()
	{
		return parentSymbol;
	};
	
	public int getFlags()
	{
		return flags;
	};
	
	public String getFullName()
	{
		return fullName;
	};
	
	public ArrayList<String> getImplSymbols()
	{
		return implSymbols;
	};
	
	public ArrayList<Field> getFields()
	{
		return fields;
	};
};
