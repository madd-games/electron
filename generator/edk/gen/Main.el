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

import elec.rt.System;
import elec.io.*;
import elec.rt.Exception;

import edk.gen.EIR;
import edk.gen.Generator;
import edk.gen.Generator_x86_64;

public class Main
{
	private static String progName;
	private static String sourceFileName;
	private static String outFileName;
	private static String arch = "x86_64";
	
	private static TextFileOutput outfile;
	
	private static void usage()
	{
		System.stderr.writeLine("USAGE:\t" + progName + " [options...]");
		System.stderr.writeLine("Parses an Electron Intermediate Representation (EIR) file specified by the -s");
		System.stderr.writeLine("option and outputs native assembly in a file named with the -o option.");
		System.stderr.writeLine("");
		
		System.stderr.writeLine("-s <source-file>");
		System.stderr.writeLine("\tSpecifies the EIR source file.");
		System.stderr.writeLine("-o <output-file>");
		System.stderr.writeLine("\tSpecifies the file to write assembly to.");
		System.stderr.writeLine("-a <architecure>");
		System.stderr.writeLine("\tSpecifies which architecture to generate for.");
	};
	
	private static Generator loadGenerator()
	{
		if (arch == "x86_64")
		{
			return new Generator_x86_64();
		}
		else
		{
			System.stderr.writeLine(progName + ": unsupported architecture: " + arch);
			System.exit(1);
		};
	};
	
	public static void main()
	{
		progName = System.args[0];
		
		if (System.args.size == 1)
		{
			usage();
			return;
		};
		
		int i;
		for (i=1; i<System.args.size; i+=2)
		{
			String key = System.args[i];
			String value = System.args[i+1];
			
			if (key == "-s")
			{
				sourceFileName = value;
			}
			else if (key == "-o")
			{
				outFileName = value;
			}
			else if (key == "-a")
			{
				arch = value;
			}
			else
			{
				System.stderr.writeLine(progName + ": unknown command-line option: " + key);
				System.stderr.writeLine("Run '" + progName + "' without argument for more info.");
				return;
			};
		};
		
		if (!(sourceFileName instanceof Object))
		{
			System.stderr.writeLine(progName + ": no source file (-s) specified");
			System.stderr.writeLine("Run '" + progName + "' without argument for more info.");
			return;
		};
		
		if (!(outFileName instanceof Object))
		{
			System.stderr.writeLine(progName + ": no output file (-o) specified");
			System.stderr.writeLine("Run '" + progName + "' without argument for more info.");
			return;
		};
		
		try
		{
			outfile = new TextFileOutput(outFileName);
		}
		catch (IOError e)
		{
			System.stderr.writeLine(progName + ": failed to open '" + outFileName + "' for write: " + e.getMessage());
		};
		
		// the constructor of EIR simply opens the source file, ready to parse
		EIR eir;
		try
		{
			eir = new EIR(sourceFileName);
		}
		catch (Exception e)
		{
			System.stderr.writeLine(progName + ": failed to open source file: " + e.getMessage());
		};
		
		// parse the file. This does not throw exceptions, but it does print error messages to the console,
		// and exits with status 1 if the parsing failed.
		eir.parse();
		
		// now generate the assembly
		Generator gen = loadGenerator();
		gen.generate(eir, outfile);
		outfile.close();
	};
};
