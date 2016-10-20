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

import elec.util.ArrayList;
import elec.util.StringSplitter;
import elec.rt.IllegalArgumentError;

import edk.parse.Term;

/**
 * Represents a grammar rule.
 */
public class Rule
{
	/**
	 * A list of possible formats of this rule.
	 * Each format is described as a list of terms.
	 */
	public ArrayList< ArrayList<Term> > formats = new ArrayList < ArrayList<Term> >();
	
	/**
	 * The name of this rule.
	 */
	public String name;
	
	public Rule(String def)
	{
		StringSplitter scanner = new StringSplitter(def, " ");
		if (scanner.end())
		{
			throw new IllegalArgumentError("illegal grammar rule");
		};
		
		String nameSpec = scanner.get();
		scanner.next();
		
		if ((!nameSpec.startsWith("<")) || (!nameSpec.endsWith(">")))
		{
			throw new IllegalArgumentError("illegal grammar rule");
		};
		
		this.name = nameSpec.substring(1, nameSpec.size()-2);
		
		if (scanner.end())
		{
			throw new IllegalArgumentError("illegal grammar rule");
		};
		
		if (scanner.get() != "::=")
		{
			throw new IllegalArgumentError("::= expected in definition of <" + this.name + ">");
		};
		
		scanner.next();
		
		ArrayList<Term> terms = new ArrayList<Term>();
		for (0; !scanner.end(); scanner.next())
		{
			if (scanner.get() == "|")
			{
				if (terms.size() == 0)
				{
					throw new IllegalArgumentError("empty term list");
				};
				
				formats.add(terms);
				terms = new ArrayList<Term>();
			}
			else if (scanner.get().startsWith("<"))
			{
				if (scanner.get().endsWith(">"))
				{
					terms.add(new Term(Term.SYMBOL, scanner.get().substring(1, scanner.get().size()-2), ""));
				}
				else
				{
					String type = scanner.get().substring(1);
					
					scanner.next();
					if (scanner.end())
					{
						throw new IllegalArgumentError("incomplete named term");
					};
					
					if (!scanner.get().endsWith(">"))
					{
						throw new IllegalArgumentError("invalid named term");
					};
					
					terms.add(new Term(Term.SYMBOL, type, scanner.get().substring(0, scanner.get().size()-1)));
				};
			}
			else if (scanner.get().startsWith("'") && scanner.get().endsWith("'"))
			{
				terms.add(new Term(Term.FIXED, scanner.get().substring(1, scanner.get().size()-2), ""));
			}
			else
			{
				throw new IllegalArgumentError("not a valid term: " + scanner.get());
			};
		};
		
		if (terms.size() == 0)
		{
			throw new IllegalArgumentError("empty term list");
		};
		
		formats.add(terms);
	};
};
