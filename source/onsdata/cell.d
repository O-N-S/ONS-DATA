module onsdata.cell;

import onsdata;

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

T toggle(T, S)(S value) if (isBoolean!S) { return !S; }
T toggle(T, S)(S value, T defValue = 1, T zeroValue = 0) if (isNumeric!S) { 
	if (value != zeroValue) return zeroValue;
	return defValue;
}