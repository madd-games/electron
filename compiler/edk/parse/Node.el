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
import elec.util.IList;
import elec.util.Iterator;
import elec.util.ArrayList;
import elec.util.KeyValuePair;
import elec.io.ITextOutputStream;

import edk.parse.Grammar;
import edk.parse.Rule;
import edk.parse.Term;
import edk.parse.Token;
import edk.parse.ParseError;

/**
 * Represents a parse tree node generated from a token list by a grammar.
 */
public class Node
{
	/**
	 * Source of the node.
	 */
	public String filename;
	public int lineno;
	public int column;
	
	/**
	 * Type of node.
	 */
	public String type = "";
	
	/**
	 * If this node represents a terminal symbol, this is the value of the token.
	 */
	public String value = "";
	
	/**
	 * Branches.
	 */
	public TableMap<String, Node> branches = new TableMap<String, Node>();
	
	private static void throwParseError(String filename, int lineno, int column, String msg)
	{
		throw new ParseError(filename + ":" + new String(lineno) + ":" + new String(column) + ": error: " + msg);
	};
	
	private static int matchTermList(Node node, Grammar grammar, IList<Term> terms, IList<Token> tokens, int index)
	{
		Iterator<Term> it;
		for (it=terms.iterate(); !it.end(); it.next())
		{
			if (index == tokens.size())
			{
				throwParseError(tokens[index-1].filename, tokens[index-1].lineno, tokens[index-1].column,
						"unexpected end of file");
			};
			
			Term term = it.get();
			
			if (term.type == Term.FIXED)
			{
				if (tokens[index].value != term.value)
				{
					throwParseError(tokens[index].filename, tokens[index].lineno, tokens[index].column,
							"expected '" + term.value + ", have '" + tokens[index].value + "'");
				};
				
				index++;
			}
			else
			{
				Node subNode = new Node();
				if (term.name != "")
				{
					node.branches[term.name] = subNode;
				};
				
				index = match(subNode, grammar, term.value, tokens, index);
			};
		};
		
		return index;
	};
	
	private static int match(Node node, Grammar grammar, String symbolName, IList<Token> tokens, int index)
	{
		if (tokens.size() == index)
		{
			throwParseError(tokens[index-1].filename, tokens[index-1].lineno, tokens[index-1].column,
						"unexpected end of file");
		};
		
		if (grammar.terminalSymbols.contains(symbolName))
		{
			if (tokens[index].type == symbolName)
			{
				node.filename = tokens[index].filename;
				node.lineno = tokens[index].lineno;
				node.column = tokens[index].column;
				
				node.type = symbolName;
				node.value = tokens[index].value;
				return index + 1;
			}
			else
			{
				throwParseError(tokens[index].filename, tokens[index].lineno, tokens[index].column,
						"expected " + symbolName + ", have " + tokens[index].value);
			};
		}
		else
		{
			Iterator< ArrayList<Term> > it;
			for (it=grammar.rules[symbolName].formats.iterate(); !it.end(); it.next())
			{
				ArrayList<Term> termList = it.get();
				
				try
				{
					node.branches = new TableMap<String, Node>();
					int newIndex = matchTermList(node, grammar, termList, tokens, index);
					
					node.filename = tokens[index].filename;
					node.lineno = tokens[index].lineno;
					node.column = tokens[index].column;
					
					node.type = symbolName;
					node.value = "";
					
					return newIndex;
				}
				catch (ParseError e)
				{
					continue;
				};
			};
			
			throwParseError(tokens[index].filename, tokens[index].lineno, tokens[index].column,
					"expected " + symbolName + ", have " + tokens[index].value);
		};
	};
	
	/**
	 * Create a parse tree out of a grammar and a list of tokens.
	 */
	public static Node parse(Grammar grammar, String root, IList<Token> tokens)
	{
		Node node = new Node();
		match(node, grammar, root, tokens, 0);
		return node;
	};
	
	/**
	 * Write the XML form of this node (and its children) to the specified output stream.
	 */
	public void xmlDump(ITextOutputStream out)
	{
		xmlDump("", out, "root");
	};
	
	public void xmlDump(String indent, ITextOutputStream out, String tag)
	{
		if (value != "")
		{
			out.writeLine(indent + "<" + tag + " type=\"" + type + "\">" + value + "</" + tag + ">");
		}
		else
		{
			out.writeLine(indent + "<" + tag + " type=\"" + type + "\">");
			
			Iterator< KeyValuePair<String, Node> > it;
			for (it=branches.iterate(); !it.end(); it.next())
			{
				it.get().value.xmlDump(indent+"\t", out, it.get().key);
			};
			
			out.writeLine(indent + "</" + tag + ">");
		};
	};
};
