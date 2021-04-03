
struct SegmentTree(T, alias F, T E) {
	T[] nodeList;
	size_t lowerOffset;

	this(T[] a) {
		size_t len = 1;
		while (len < a.length) {
			len <<= 1;
		}
		lowerOffset = len - 1;

		nodeList = new T[len * 2 - 1];
		nodeList[lowerOffset..lowerOffset + a.length] = a[];
		nodeList[lowerOffset + a.length..$] = E;

		foreach_reverse (i;0..lowerOffset) {
			nodeList[i] = F(nodeList[i * 2 + 1], nodeList[i * 2 + 2]);
		}
	}

	void update(size_t index, T value) {
		auto current = lowerOffset + index;

		nodeList[current] = value;

		do {
			current = (current - 1) / 2;
			nodeList[current] = F(nodeList[current * 2 + 1], nodeList[current * 2 + 2]);
		} while (current > 0);
	}

	T get(size_t a, size_t b) {
		T get_(size_t index, size_t l, size_t r) {
			if (r <= a || b <= l) {
				// 要求区間と対象区間が交わらない
				return E;
			}

			if (a <= l && r <= b) {
				//要求区間が対象区間を覆っているので、再帰は不要
				return nodeList[index];
			}

			auto valueL = get_(2 * index + 1, l, (l + r) / 2);
			auto valueR = get_(2 * index + 2, (l + r) / 2, r);
			return F(valueL, valueR);
		}

		return get_(0, 0, lowerOffset + 1);
	}
}

unittest {
	import std.algorithm;

	auto a = [1, 9, 8, 4, 3, 2, 5];
	auto seg = SegmentTree!(int, (int a, int b) => min(a, b), int.max)(a);

	auto b = [8, 4, 3, 0, 6, 3, 0];
	foreach (i;0..min(a.length, b.length)) {
		if (b[i] != 0) {
			a[i] = b[i];
			seg.update(i, b[i]);
		}
	}

	foreach (i;1..a.length) {
		foreach (j;i + 1..a.length + 1) {
			assert(a[i..j].reduce!min == seg.get(i, j));
		}
	}
}
