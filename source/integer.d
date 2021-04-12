
import std.algorithm;

T gcd(T)(T a, T b) {
	if (b == 0) {
		return a;
	}
	return gcd(b, a % b);
}

unittest {
	assert(gcd(17, 23) == 1);
	assert(gcd(36, 48) == 12);
}

long extgcd(long a, long b, ref long x, ref long y) {
	if (b == 0) {
		x = 1;
		y = 0;
		return a;
	} else {
		auto d = extgcd(b, a % b, y, x);
		y -= (a / b) * x;
		return d;
	}
}

/*

pow x 0 = 1
pow x 1 = x
pow x n = if n mod 2 == 0 then p2 else p2plus
  where
    p2 = (pow x (n / 2)) * (pow x (n / 2))
		p2plus = p2 * x

*/
long powmod(long x, long n, long mod) {
	long r = 1;

	while (n > 0) {
		if (n & 0x01) {
			r = r * x % mod;
		}
		x = x * x % mod;

		n >>= 1;
	}

	return r;
}

unittest {
	assert(powmod(2, 16, 10) == 6);
}

T modinv(T)(T a, T m) {
	assert(gcd(a, m) == 1);

	T b = m, u = 1, v = 0;

	while (b != 0) {
		auto t = a / b;
		a -= t * b;
		swap(a, b);
		u -= t * v;
		swap(u, v);
	}
	u %= m;
	if (u < 0) {
		u += m;
	}
	return u;
}

unittest {

	void test(long n, long m, long mod) {
		assert((n * modinv(m, mod) % mod) == n / m);
	}

	test(2, 2, 7);
	test(4, 2, 7);

	test(3, 3, 11);
	test(6, 3, 11);
}

// Integer (mod N)
struct IntWithMod(T, T Mod) {
	alias thisT = IntWithMod!(T, Mod); // 自分を表すタイプ

	T value;

	this(T value) {
		this.value = value % Mod;
	}

	this(const thisT r) {
		value = r.value;
	}

	bool opEqual(const thisT r) const {
		return value == r.value;
	}

	auto opAssign(T value) {
		this.value = value % Mod;
		return this;
	}

	auto opAssign(const thisT r) {
		value = r.value;
		return this;
	}

	ref opOpAssign(string op)(const thisT r) if (op == "+" || op == "-" || op == "*") {
		opOpAssign!(op)(r.value);
	}

	ref opOpAssign(string op)(const T r) if (op == "+" || op == "-" || op == "*") {
		mixin("value " ~ op ~ "= r;");
		value %= Mod;
		if (value < 0) {
			value += Mod;
		}
		return this;
	}

	auto opBinary(string op)(const thisT r) const if (op == "+" || op == "-" || op == "*") {
		thisT t = this;

		mixin("t " ~ op ~ "= r.value;");

		return t;
	}

	auto opEquals(const thisT r) {
		return value == r.value;
	}

	auto opEquals(const T r) {
		auto s = r % Mod;
		if (s < 0) {
			s += Mod;
		}
		return value == s;
	}

	auto inv() @property const {
		return modinv(value, Mod);
	}
}

unittest {
	enum Mod = 13;
	int a = 25, b = 33, c = 11;

	auto am = IntWithMod!(int, Mod)(a);
	auto bm = IntWithMod!(int, Mod)(b);
	auto cm = IntWithMod!(int, Mod)(c);

	assert(am + bm == a + b);
	assert(cm - am == c - a);
	assert(am * cm == a * c);
}
