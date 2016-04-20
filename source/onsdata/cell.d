module onsdata.cell;

import onsdata;

/+ +/
T checkFor(T, S)(S value, T minValue = T.min, T maxValue = T.max) if (isIntegral!S) {
	import std.conv;
	if (value < minValue) return minValue;
	if (value > maxValue) return maxValue;
	return to!T(value);
}
T checkFor(T, S)(S value, T minValue = T.min, T maxValue = T.max) if (isFloatingPoint!S) {
	import std.conv;
	if (value== S.nan) return 0; 
	if (value < minValue) return minValue;
	if (value > maxValue) return maxValue;
	return to!T(value);
}
/+ +/
T toggle(T, S)(S value) if (isBoolean!S) { return !S; }
T toggle(T, S)(S value, T defValue = 1, T zeroValue = 0) if (isNumeric!S) { 
	if (value != zeroValue) return zeroValue;
	return defValue;
}
/+ +/
T min(T)(T[] values...) if (isNumeric(T)) {
	if (values) {
		T result = values[0];
		foreach(value; values) if (result > value) result = value;
		return result;
	}
	return 0;
}
/+ +/
T avg(T)(T[] values...) if (isNumeric(T)) {
	if (values) {
		T result = 0;
		foreach(value; values) result += value;
		return result/values.length;
	}
	return 0;
} 
/+ +/
T max(T)(T[] values...) if (isNumeric(T)) {
	if (values) {
		T result = values[0];
		foreach(value; values) if (result < value) result = value;
		return result;
	}
	return 0;
} 
/+ +/
T sum(T)(T[] values...) if (isNumeric(T)) {
	T result = 0;
	foreach(value; values) result += value;
	return result;
} 
/+ +/
T delta(T)(T left, T right) if (isNumeric(T)) {
	return right-left;
}
/+ +/
T div(T)(T left, T right, T distance) if (isNumeric(T)) {
	if (distance) delta(left, right)/distance;
	return 0;
}