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

import edk.parse.ParseError;
import edk.parse.Token;

import elec.re.Tokenizer;
import elec.rt.*;
import elec.util.*;
import elec.io.*;

/**
 * Tokenizer for Electron code.
 */
public class Lexer extends Tokenizer
{
	private String filename;
	private int lineno = 0;
	private int column = 0;
	private IList<Token> tokens = new LinkedList<Token>();
	
	// maps specific identifiers to their token types, e.g. "if" to ""keyword"".
	private IMap<String, String> idMap = new TableMap<String, String>();
	
	public Lexer(String filename, String data)
	{
		this.filename = filename;
		lineno = 1;
		column = 0;
		
		idMap["private"] = "access-qualifier";
		idMap["protected"] = "access-qualifier";
		idMap["public"] = "access-qualifier";
		
		idMap["abstract"] = "storage-qualifier";
		idMap["static"] = "storage-qualifier";
		idMap["final"] = "storage-qualifier";
		idMap["synchronized"] = "storage-qualifier";
		
		idMap["extern"] = "keyword";
		idMap["class"] = "keyword";
		idMap["interface"] = "keyword";
		idMap["extends"] = "keyword";
		idMap["implements"] = "keyword";
		idMap["package"] = "keyword";
		idMap["import"] = "keyword";
		idMap["void"] = "keyword";
		idMap["as"] = "keyword";
		idMap["instanceof"] = "keyword";
		idMap["return"] = "keyword";
		idMap["if"] = "keyword";
		idMap["for"] = "keyword";
		idMap["while"] = "keyword";
		idMap["break"] = "keyword";
		idMap["continue"] = "keyword";
		idMap["new"] = "keyword";
		idMap["do"] = "keyword";
		idMap["switch"] = "keyword";
		idMap["case"] = "keyword";
		idMap["default"] = "keyword";
		idMap["else"] = "keyword";
		idMap["try"] = "keyword";
		idMap["catch"] = "keyword";
		idMap["atomically"] = "keyword";
		idMap["true"] = "keyword";
		idMap["false"] = "keyword";
		idMap["this"] = "keyword";
		idMap["null"] = "keyword";
		
		idMap["int"] = "primitive";
		idMap["uint"] = "primitive";
		idMap["float"] = "primitive";
		idMap["bool"] = "primitive";
		idMap["int8"] = "primitive";
		idMap["int16"] = "primitive";
		idMap["int32"] = "primitive";
		idMap["int64"] = "primitive";
		idMap["uint8"] = "primitive";
		idMap["uint16"] = "primitive";
		idMap["uint32"] = "primitive";
		idMap["uint64"] = "primitive";

		addTokenType("identifier", "[_a-zA-Z][_0-9a-zA-Z]*");
		addTokenType("char", "(\\'[^']\\'|\\'\\\\.\\')");
		addTokenType("float", "[0-9]*\\.[0-9]+(e[\\+\\-][0-9]+)?[fF]?");
		addTokenType("dec-int", "[1-9][0-9]*");
		addTokenType("hex-int", "0x[0-9a-fA-F]+");
		addTokenType("oct-int", "0[0-7]*");
		addTokenType("whitespace", "$+");
		addTokenType("line-comment", "\\/\\/(%n)!*%n");
		addTokenType("block-comment", "\\/\\*(\\*\\/)!*\\*\\/");
		addTokenType("string", "\\\"(\\\\\\\\|\\\\\\\"|\\\"!)*\\\"");
		addTokenType("tok_operator", "(\\<\\<\\=|\\>\\>\\=|\\<\\<|\\>\\>|\\!\\=|\\=\\=|\\[\\]|\\<\\=|\\>\\=|\\&\\&|\\|\\||\\+\\=|\\-\\=|\\*\\=|\\/\\=|\\%\\=|\\&\\=|\\^\\=|\\|\\=|\\+\\+|\\-\\-|\\,|\\.|\\+|\\-|\\*|\\/|\\%|\\!|\\=|\\(|\\)|\\[|\\]|\\{|\\}|\\;|\\<|\\>|\\||\\&|\\^|\\~|\\:)");
		feed(data);
		
		Token tokEnd = new Token();
		tokEnd.filename = filename;
		tokEnd.lineno = lineno;
		tokEnd.column = column;
		tokEnd.type = "end";
		tokEnd.value = "<EOF>";
		tokens.add(tokEnd);
	};
	
	protected void onToken(String type, String value)
	{
		StringStream ss = new StringStream(value);
		while (ss.getBuffer().size() > 0)
		{
			uint c = ss.readU8();
			if (c == (uint)10)
			{
				// newline
				lineno++;
				column = 0;
			}
			else
			{
				column++;
			};
		};
		
		if (type == "identifier")
		{
			if (idMap.containsKey(value))
			{
				type = idMap[value];
			};
		};
		
		if ((type != "whitespace") && (type != "line-comment") && (type != "block-comment"))
		{
			tokens.add(new Token(filename, lineno, column, type, value));
		};
	};
	
	protected void onChoke(String data)
	{
		throw new ParseError(filename + ":" + new String(lineno) + ":" + new String(column) + ": invalid character in srouce file: '" + data.substring(0, 1) + "'");
	};
	
	public IList<Token> getList()
	{
		return tokens;
	};
};
