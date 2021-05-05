
//	auto a = readln.chomp.split(' ').map!(to!int).array;
import std.container;
import std.range;
import std.algorithm;
import std.array;
import std.string;
import std.conv;
import std.stdio;
import std.container;

struct UnionFind {
	int[] d;

	this(size_t n) {
		d = new int[n];
		d[] = -1;
	}

	int find(int x) {
		if (d[x] < 0) return x;
		return d[x] = find(d[x]);
	}

	bool unite(int x, int y) {
		x = find(x);
		y = find(y);
		if (x == y) return false;
		if (d[x] > d[y]) swap(x, y);
		d[x] += d[y];
		d[y] = x;
		return true;
	}

	bool same(int x, int y) {
		return find(x) == find(y);
	}

	int size(int x) {
		return -d[find(x)];
	}
}

unittest {
	auto u = UnionFind(5);

	assert(!u.same(1, 2));
	assert(u.size(0) == 1);

	u.unite(0, 2);
	u.unite(0, 4);
	assert(u.same(2, 4));
	assert(u.size(0) == 3);
	assert(u.size(4) == 3);
	assert(u.find(0) == u.find(4));

	assert(u.find(1) != u.find(2));
}
