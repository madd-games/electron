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

package edk.parse;

import elec.util.TableMap;
import elec.util.ArrayList;
import elec.util.StringSplitter;
import elec.io.ITextInputStream;

import edk.parse.Rule;
import edk.parse.Term;

/**
 * Represents a grammar.
 */
public class Grammar
{
	/**
	 * Terminal symbols of this grammar.
	 */
	public ArrayList<String> terminalSymbols = new ArrayList<String>();
	
	/**
	 * Grammar rules (non-terminal symbols).
	 */
	public TableMap<String, Rule> rules = new TableMap<String, Rule>();
	
	/**
	 * Parse a grammar.
	 */
	public Grammar(String spec)
	{
		StringSplitter splitter;
		for (splitter=new StringSplitter(spec, "\n"); !splitter.end(); splitter.next())
		{
			String line = splitter.get();
			
			if (line.startsWith("<"))
			{
				Rule rule = new Rule(line);
				rules[rule.name] = rule;
			}
			else if (line.startsWith("@"))
			{
				terminalSymbols.add(line.substring(1));
			};
			
			// everything else is a comment!
		};
	};
};
