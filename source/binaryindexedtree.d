
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

	T get(size_t index) { // [0..index]の全要素の計算
		T result = E;

		for (auto i = cast(long)index + 1;i > 0;i -= i & -i) {
			result = F(result, nodeList[i - 1]);
		}

		return result;
	}

	void add(size_t index, T value) { // F(tree[index], value)を追加
		for (auto i = cast(long)index + 1;i <= nodeList.length;i += i & -i) {
			nodeList[i - 1] = F(nodeList[i - 1], value);
		}
	}

	void set(size_t index, T value) {
		auto x = RevF(get(index), get(index - 1));
		x = RevF(value, x);
		add(index, x);
	}
}


unittest {
	import std.algorithm;
	import std.stdio;

	{
		// add
		auto a = [1, 9, 8, 4, 3, 2, 5];
		auto tree = BinaryIndexedTree!(int, (int a, int b) => a + b, (int a, int b) => a - b, 0)(a);

		auto b = [8, 4, 3, 0, 6, 3, 0];
		foreach (i;0..min(a.length, b.length)) {
			if (b[i] != 0) {
				a[i] = b[i];
				tree.set(i, a[i]);
			}
		}


		foreach (i;0..a.length - 1) {
			// writeln(a[0..i + 1].sum, " : ", tree.get(i));
			assert(a[0..i + 1].sum == tree.get(i));
		}
	}
	{
		// xor
		auto a = [1, 9, 8, 4, 3, 2, 5];
		auto tree = BinaryIndexedTree!(int, (int a, int b) => a ^ b, (int a, int b) => a ^ b, 0)(a);

		auto b = [8, 4, 3, 0, 6, 3, 0];
		foreach (i;0..min(a.length, b.length)) {
			if (b[i] != 0) {
				a[i] = b[i];
				tree.set(i, a[i]);
			}
		}


		foreach (i;0..a.length - 1) {
			assert(a[0..i + 1].reduce!"a ^ b" == tree.get(i));
		}
	}
}
