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

package edk.comp;

import elec.rt.System;
import elec.util.ArrayList;
import elec.io.TextFileOutput;

import edk.parse.Grammar;
import edk.parse.Node;
import edk.parse.Token;
import edk.parse.Node;

public class Main
{
	private static String elecGrammar = "
@number
@operator

<sum> ::= <number a> '+' <sum next> | <number a>

		";
		
	public static void main()
	{
		Grammar grammar = new Grammar(elecGrammar);
		
		ArrayList<Token> tokens = new ArrayList<Token>();
		tokens.add(new Token("meme", 1, 1, "number", "5"));
		tokens.add(new Token("meme", 1, 1, "operator", "+"));
		tokens.add(new Token("meme", 1, 1, "number", "2"));
		
		Node tree = Node.parse(grammar, "sum", tokens);
		TextFileOutput out = new TextFileOutput("test.xml");
		tree.xmlDump(out);
		out.close();
	};
};
