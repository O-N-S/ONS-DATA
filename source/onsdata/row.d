module onsdata.row;

import std.stdio;
import onsdata;

/+ +/
T[] newRow(T)(size_t length) {
	T[] result; result.length = length;
	foreach(ref r; result) r = 0;
	return result;
}

/+ +/
T[] copy(T)(T[] row) if (isBasicType!T) {
	T[] result;
	result.length = row.length;
	foreach(i, r; row) result[i] = r;
	return result;
} 

/+ +/
T[][] copy(T)(T[][] rows) if (isBasicType!T) {
	T[][] result;
	result.length = rows.length;
	foreach(i, r; rows) result[i] = copy(r);
	return result;
} 

/+ +/
T[string] changedCells(T)(T[] changedRow, T[] originalRow, size_t[string] colIndex) if (isBasicType!T) {
	T[string] result;
	if ((changedRow) && (originalRow)) { 
		foreach(k, v; colIndex) {	
			if (changedRow[v] != originalRow[v]) result[k] = changedRow[v];
		}
	}
	return result;
}

/+ +/
T[string] changedCells(T)(T[] changedRow, T originalValue, size_t[string] colIndex) if (isBasicType!T) {
	T[string] result;
	if (changedRow) { 
		foreach(k, v; colIndex) {	
			if (changedRow[v] != originalValue) result[k] = changedRow[v];
		}
	}
	return result;
}

/+ +/
bool isIn(T)(T value, T[] values) {
	foreach(v; values) if (v == value) return true;
	return false;
}

/+ +/
bool isNotIn(T)(T value, T[] values) {
	foreach(v; values) if (v == value) return false;
	return true;
}
