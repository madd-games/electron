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
import elec.util.IList;
import elec.io.TextFileOutput;

import edk.parse.Grammar;
import edk.parse.Node;
import edk.parse.Token;
import edk.parse.Node;
import edk.parse.Lexer;

public class Main
{
	private static String elecGrammar = "
@identifier
@char
@float
@dec-int
@hex-int
@oct-int
@string
@operator

<int-literal> ::= <dec-int value> | <hex-int value> | <oct-int value>
<float-literal> ::= <float value>
<str-literal> ::= <string value>
<true> ::= 'true'
<false> ::= 'false'
<bool-literal> ::= <true value> | <false value>
<this> ::= 'this'
<null> ::= 'null'
<path> ::= <identifier id> '.' <path next> | <identifier id>
<brackets> ::= '(' <expression expr> ')'
<primary-expr> ::= <brackets expr> | <int-literal expr> | <str-literal expr> | <bool-literal expr> | <this expr> | <null expr> | <path expr> | <float expr>
<pre-inc> ::= '++' <primary-expr sub>
<post-inc> ::= <primary-expr sub> '++'
<pre-dec> ::= '--' <primary-expr sub>
<post-dec> ::= <primary-expr sub> '--'
<incdec-expr> ::= <pre-inc expr> | <post-inc expr> | <pre-dec expr> | <post-dec expr> | <primary-expr expr>
<generic-arg-expr> ::= <type-name type> ',' <generic-arg-expr next> | <type-name type>
<generic-arg-list> ::= '<' <generic-arg-expr head> '>'
<type-name> ::= <primitive prim> | <path path> <generic-arg-list generic-args> | <path path>
<argument-list> ::= <expression value> ',' <argument-list next> | <expression value>
<new-expr> ::= 'new' <type-name class-name> '(' <argument-list args> ')' | 'new' <type-name class-name> '(' ')'
<func-expr> ::= <incdec-expr sub> '(' <argument-list args> ')' | <incdev-expr sub> '(' ')'
<call-expr> ::= <new-expr expr> | <func-expr expr> | <incdec-expr expr>
<logical-not> ::= '!' <call-expr sub>
<bitwise-not> ::= '~' <call-expr sub>
<unary-expr> ::= <logical-not expr> | <bitwise-not expr> | <call-expr expr>
<cast-expr> ::= '(' <type-name dest-type> ')' <unary-expr sub>
<secondary-expr> ::= <cast-expr expr> | <unary-expr expr>
<mul-op> ::= '*'
<div-op> ::= '/'
<mod-op> ::= '%'
<muldiv-op> ::= <mul-op op> | <div-op op> | <mod-op op>
<muldiv-expr> ::= <secondary-expr left> <muldiv-op op> <muldiv-expr right> | <secondary-expr expr>
<add-op> ::= '+'
<sub-op> ::= '-'
<addsub-op> ::= <add-op op> | <sub-op op>
<addsub-expr> ::= <muldiv-expr left> <addsub-op op> <addsub-expr right> | <muldiv-expr expr>
<shl-op> ::= '<<'
<shr-op> ::= '>>'
<shift-op> ::= <shl-op op> | <shr-op op>
<shift-expr> ::= <addsub-expr value> <shift-op op> <shift-expr count> | <addsub-expr expr>
<instanceof-expr> ::= <shift-expr sub> 'instanceof' <type-name class-name> | <shift-expr expr>
<smaller-expr> ::= <instanceof-expr left> '<' <instanceof-expr right>
<larger-expr> ::= <instanceof-expr left> '>' <instanceof-expr right>
<smaller-equal-expr> ::= <instanceof-expr left> '<=' <instanceof-expr right>
<larger-equal-expr> ::= <instanceof-expr left> '>=' <instanceof-expr right>
<equal-expr> ::= <instanceof-expr left> '==' <instanceof-expr right>
<not-equal-expr> ::= <instanceof-expr left> '!=' <instanceof-expr right>
<compare-expr> ::= <smaller-expr expr> | <larger-expr expr> | <smaller-equal-expr expr> | <larger-equal-expr expr> | <equal-expr expr> | <not-equal-expr expr> | <instanceof-expr expr>
<bitwise-or-op> ::= '|'
<bitwise-and-op> ::= '&'
<bitwise-xor-op> ::= '^'
<bitwise-op> ::= <bitwise-or-op op> | <bitwise-and-op op> | <bitwise-xor-op op>
<bitwise-expr> ::= <compare-expr left> <bitwise-op op> <bitwise-expr right> | <compare-expr expr>
<logical-or-op> ::= '||'
<logical-and-op> ::= '&&'
<logical-op> ::= <logical-or-op op> | <logical-and-op op>
<logical-expr> ::= <bitwise-expr left> <logical-op op> <logical-expr right> | <bitwise-expr expr>
<simple-assign-op> ::= '='
<add-assign-op> ::= '+='
<sub-assign-op> ::= '-='
<mul-assign-op> ::= '*='
<div-assign-op> ::= '/='
<mod-assign-op> ::= '%='
<bitwise-and-assign-op> ::= '&='
<bitwise-or-assign-op> ::= '|='
<bitwise-xor-assign-op> ::= '^='
<logical-and-assign-op> ::= '&&='
<logical-or-assign-op> ::= '||='
<shl-assign-op> ::= '<<='
<shr-assign-op> ::= '>>='
<assign-op> ::= <simple-assign-op op> | <add-assign-op op> | <sub-assign-op op> | <mul-assign-op op> | <div-assign-op op> | <mod-assign-op op> | <bitwise-and-assign-op op> | <bitwise-or-assign-op op> | <bitwise-xor-assign-op op> | <logical-and-assign-op op> | <logical-or-assign-op op> | <shl-assign-op op> | <shr-assign-op op>
<assign-expr> ::= <logical-expr left> <assign-op op> <assign-expr right> | <logical-expr expr>
<expression> ::= <assign-expr expr>
		";

	public static void main()
	{
		Grammar grammar = new Grammar(elecGrammar);
		
		Lexer lexer = new Lexer("test", "x = y = power(5 * 7, a + 4)");
		IList<Token> tokens = lexer.getList();
		
		Node tree = Node.parse(grammar, "expression", tokens);
		TextFileOutput out = new TextFileOutput("test.xml");
		tree.xmlDump(out);
		out.close();
	};
};
