
struct BinaryIndexedTree(T, alias F, alias RevF, T E) {
	T[] nodeList;

	this(const(T)[] a) {
		size_t len = 1;
		while (len < a.length) {
			len <<= 1;
		}
		nodeList = new T[len]; // 2^nの長さで確保
		nodeList[0..a.length] = a[];
		nodeList[a.length..$] = E;

		for (size_t i = 2;i <= nodeList.length;i *= 2) {
			for (size_t j = i - 1;j < nodeList.length;j += i) {
				nodeList[j] = F(nodeList[j], nodeList[j - i / 2]);
			}
		}
	}

	T get0to(size_t end) { // [0..end)の計算
		T result = E;

		for (auto i = cast(long)end;i > 0;i -= i & -i) {
			result = F(result, nodeList[i - 1]);
		}
		return result;
	}

	T get(size_t start, size_t end) { // [start..end)の計算
		assert(start <= end);

		if (start == 0) {
			return get0to(end);
		}

		return RevF(get0to(end), get0to(start));
	}

	void add(size_t index, T value) { // F(tree[index], value)を追加
		for (auto i = cast(long)index + 1;i <= nodeList.length;i += i & -i) {
			nodeList[i - 1] = F(nodeList[i - 1], value);
		}
	}

	void set(size_t index, T value) {
		auto x = get(index, index + 1);
		auto d = RevF(value, x);
		add(index, d);
	}
}


unittest {
	import std.algorithm;
	import std.stdio;

	{
		// add
		auto a = [1, 9, 8, 4, 3, 2, 5];
		auto tree = BinaryIndexedTree!(int, (int a, int b) => a + b, (int a, int b) => a - b, 0)(a);

		foreach (i;1..a.length) {
			assert(a[0..i].sum == tree.get(0, i));
		}

		auto b = [8, 4, 3, 0, 6, 3, 0];
		foreach (i;0..min(a.length, b.length)) {
			if (b[i] != 0) {
				a[i] = b[i];
				tree.set(i, a[i]);
			}
		}

		foreach (i;1..a.length) {
			assert(a[0..i].sum == tree.get(0, i));
		}
	}
	{
		// xor
		auto a = [1, 9, 8, 4, 3, 2, 5];
		auto tree = BinaryIndexedTree!(int, (int a, int b) => a ^ b, (int a, int b) => a ^ b, 0)(a);

		foreach (i;1..a.length) {
			assert(a[0..i].reduce!"a ^ b" == tree.get(0, i));
		}

		auto b = [8, 4, 3, 0, 6, 3, 0];
		foreach (i;0..min(a.length, b.length)) {
			if (b[i] != 0) {
				a[i] = b[i];
				tree.set(i, a[i]);
			}
		}


		foreach (i;1..a.length) {
			assert(a[0..i].reduce!"a ^ b" == tree.get(0, i));
		}
	}
}
