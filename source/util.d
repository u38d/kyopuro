
import std.stdio;
import std.string;
import std.range;
import std.conv;
import std.algorithm;
import std.array;

T[] readArray(T)() {
//	auto a = readln.chomp.split.map!(to!int).array;
	return readln.chomp.split.map!(to!T).array;
}

void writeArray2(T)(in T[][] aa) {
//writefln("[%([%(%s, %)],%|\n %)]", dp);
	writefln("[%([%(%s, %)],%|\n %)]", aa);
}

unittest {
	auto aa = [
		[7, 8, 9],
		[4, 5, 6],
		[1, 2, 3],
		[0,],
	];

	writeArray2!int(aa);
}
