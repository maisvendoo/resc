//-------------------------------------------------------------------
//
//		Results files compiler
//		(c) maisvendoo, 2015/02/04
//
//-------------------------------------------------------------------
module	main;

import	std.stdio;
import	std.getopt;
import	std.file;
import	std.conv;
import	std.string;

struct TCmdLine
{
	string	data_dir;
	bool	is3d;

	this(this)
	{
		this.data_dir	= "./";
		this.is3d		= false; 
	}
}


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
void main(string[] args)
{
	// Parse command line
	TCmdLine	cmd_line;

	getopt(args,
		"data_dir", &cmd_line.data_dir,
		"is3d",		&cmd_line.is3d);

	// Read input data
	string[]	buf;
	int			data_count = 0;

	if (cmd_line.data_dir[$-1] != '/')
		cmd_line.data_dir ~= "/";

	File input = File(cmd_line.data_dir ~ "input", "r");
	File result = File(cmd_line.data_dir ~ "Result", "wt");

	foreach(string line; lines(input))
	{
		if (line == "##\n")
		{
			buf ~= "\n\n";
		}
		else
		{
			if (line[0] == '#')
				result.write(line);
			else
			{
				buf ~= line.dup;
				data_count++;
			}
		}
	}

	input.close();

	string[] raw_data = new string[data_count];

	int thread_id = 0;

	// Read calculation results
	while (exists(cmd_line.data_dir ~ "thread" ~ to!string(thread_id)))
	{
		input = File(cmd_line.data_dir ~ "thread" ~ to!string(thread_id), "r");

		foreach(string line; lines(input))
		{
			int		i = 0;
			string	str = "";

			while (line[i] != ' ')
			{
				str ~= line[i];
				i++;
			}

			int idx = to!int(str);

			raw_data[idx] = line[i..$];
		}

		input.close();
		thread_id++;
	}

	// Concat input and output data
	int i = 0;
	int j = 0;

	while (i < buf.length)
	{
		if (buf[i] != "\n\n")
		{
			int k = 0;
			string str = "";
			str = chomp(buf[i].dup);
			buf[i] = "";
			buf[i] ~= str ~ " " ~ raw_data[j];
			j++;
		}

		i++;
	}

	for(i = 0; i < buf.length; i++)
		result.write(buf[i]);

	result.close();

	result = File(cmd_line.data_dir ~ "Result3d", "wt");

	if (cmd_line.is3d)
	{
		for (i = 0; i < buf.length; i++)
		{
			if (buf[i] == "\n\n")
				result.writeln();
			else
				result.write(buf[i]);
		}
	}

	result.close();
}