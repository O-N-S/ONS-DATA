module onsdata.rows;

import onsdata;

T[string][] changedRows(T)(T[][] changedRows, T[][] originalRows, size_t[string]colIndex) if (isBasicType!T) {
	T[string][] results; results.length = changedRows.length; 
	foreach(i, r; changedRows) results[i] = changedCells(changedRows[i], originalRows[i], colIndex);
	return results;
}

T[string][] changedRows(T)(T[][] changedRows, T originalValue, size_t[string]colIndex) if (isBasicType!T) {
	T[string][] results; results.length = changedRows.length; 
	foreach(i, r; changedRows) results[i] = changedCells(changedRows[i], originalValue, colIndex);
	return results;
}

T[] firstRowInRows(T)(T[][] rows) if (isBasicType!T) {
	foreach(i, row; rows) if (row) return row;
	return null;
}
size_t firstIndexInRows(T)(T[][] rows) if (isBasicType!T) {
	foreach(i, row; rows) if (row) return i;
	return size_t.max;
}
