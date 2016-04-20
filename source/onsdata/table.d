module onsdata.table;

import std.stdio;
import onsdata;

struct Table(T) {
	size_t rowLength;

	T[][] rows;
	private string[] _columns;
	size_t[string] colIndex;

	@property string[] columns() { return _columns; }
	@property void columns(string[] values) { 
		_columns = values;
		foreach(i, col; _columns) colIndex[col] = i;
	}

	@property size_t width() { return _columns.length; }
	@property size_t height() { return rows.length; }

	T[] row() {
		T[] result; result.length = width;
		foreach(ref r; result) r = T.init;
		return result;
	}
	void add(T[] row) { row.length = width; rows ~= row; }

	T[] firstRow() { return firstRowInRows(rows); }
	size_t firstIndex() { return firstIndexInRows(rows); }

	T[] opIndex(size_t i) {
		if (i < height) return rows[i];
		return null;
	}

}

T[][] newTable(T)(size_t width, size_t height) if (isBasicType!T) {
	T[][] result; result.length = height;
	return result;
}
T[][] newTable(T, S)(S[][] table, size_t start = 0, size_t end = size_t.max) if (isBasicType!T) {
	if (end == size_t.max) end = table.length; 
	T[][] result; result.length = table.length; 
	foreach(i; start..end) if (table[i]) result[i] = newRow!T(table[i].length);
	return result;
}

void setDelta(T)(T[][] table, size_t target, string[2] cols, size_t[string] colIndex) { table.setDelta(target, cols[0], cols[1]); }
void setDelta(T)(T[][] table, size_t target, string left, string right, size_t[string] colIndex) { 
	if (left !in colIndex) writeln(left, " not found!");
	if (right !in colIndex) writeln(right, " not found!");

	table.setDelta(target, colIndex[left], colIndex[right]); 
}

void setDelta(T)(T[][] table, size_t target, size_t[2] cols) { table.setDelta(target, cols[0], cols[1]); }
void setDelta(T)(T[][] table, size_t target, size_t left, size_t right) { 
	foreach(row; table) if (row) {
		if (!target.inside(row)) return;
		if (!left.inside(row)) return;
		if (!right.inside(row)) return;
		
		row[target] = row[left] - row[right];
	}
}

// -- getInc
double getInc(T)(T[][] table, size_t col) if (isBasicType!T) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i, row; table) if (row) {
		if (i == 0) continue;

		if ((foundFirst) && (table[i-1])) {
			double delta = row[col] - table[i-1][col];
			if (delta > 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}
double getInc(T)(T[][] table, size_t col, size_t start, size_t end)  if (isBasicType!T) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i; start..end+1) if (table[i]) {
		if (i == 0) continue;
		
		if ((foundFirst) && (table[i-1])) {
			double delta = row[i][col] - table[i-1][col];
			if (delta > 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}

// -- getDec
double getDec(T)(T[][] table, size_t col)  if (isBasicType!T) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i, row; table) if (row) {
		if (i == 0) continue;
		
		if ((foundFirst) && (table[i-1])) {
			double delta = row[col] - table[i-1][col];
			if (delta < 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}
double getDec(T)(T[][] table, size_t col, size_t start, size_t end) if (isBasicType!T) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i; start..end+1) if (table[i]) {
		if (i == 0) continue;
		
		if ((foundFirst) && (table[i-1])) {
			double delta = row[i][col] - table[i-1][col];
			if (delta < 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}
/++
 Sum - Calculating sum of columns in a row
 +/
S sum(S = double, T)(T[][] table, size_t col, size_t start = 0, size_t end = size_t.max) {
	int counter = 0; double sum = 0;
	if (end > table.length) end = table.length;
	foreach(i; start..end) if (auto row = table[i]) { counter++; sum += row[col]; }
	return (counter) ? sum/counter : 0;
}
bool sum(T)(T[][] table, size_t target, size_t[] colInds, size_t start = 0, size_t end = size_t.max) { 
	if (table.length == 0) return false;
	if (colInds.length == 0) return false;

	if (end > table.length) end = table.length;
	auto rlen = table[0].length-1; // max Value for colInds
	if (target > rlen) return false;
	foreach(cIndex; colInds) if (cIndex > rlen) return false;

	double sum = row[cols[0]];
	foreach(i; start..end) if (auto row = table[i]) {
		if (cols.length > 1) foreach(col; cols[1..$]) sum += row[col];
		row[target] = check!T(sum/cols.length);
	}
	return true;
}

// AVG
S avg(S = double, T)(T[][] table, size_t col, size_t start = 0, size_t end = size_t.max) {
	return (end == size_t.max) ? avg(table[start..table.length], col) : avg(table[start..end], col) ;
}
S avg(S = double, T)(T[][] table, size_t col) {
	int counter = 0; double sum = 0;
	foreach(row; table) if (row) { counter++; sum += row[col]; }
	return (counter) ? sum/counter : 0;
}
// AVG
bool Avg(T)(T[][] table, size_t target, size_t[] cols, size_t start = 0, size_t end = size_t.max) { 
	return (end == size_t.max) ? setAvg(table[start..table.length], target, cols) : setAvg(table[start..end], target, cols);
}
bool Avg(T)(T[][] table, size_t target, size_t[] cols) { 
	if (table.length == 0) return false;
	if (cols.length == 0) return false;
	
	auto rlen = table[0].length-1; // max Value
	if (target > rlen) return false;
	foreach(col; cols) if (col > rlen) return false;
	
	double colSum = row[cols[0]];
	foreach(row; table) if (row) {
		if (cols.length > 1) foreach(col; cols[1..$]) colSum += row[col];
		row[target] = check!T(colSum/cols.length);
	}
	return true;
}

size_t count(T)(T[][] table, size_t left, Ops op, T right) if (isBasicType!T)
in {
	assert(((op == op.GC) || (op == op.LC)) && (right >= 0));
}
body {	
	import std.conv;
	size_t result = 0;  size_t rCol;
	if ((op == op.GC) || (op == op.LC)) rCol = to!size_t(right);
	
	foreach(row; table) if (row) {
		final switch(op) {
			case Ops.GC: if (row[left] > row[rCol]) result++; break;
			case Ops.LC: if (row[left] < row[rCol]) result++; break;
			case Ops.GV: if (row[left] > right) result++; break;
			case Ops.LV: if (row[left] < right) result++; break;
		}
	}
	return result;
}

T[][] find(T, S)(T[][] table, size_t left, Ops op, S right) if (isBasicType!T)
in {
	assert(((op == op.GC) || (op == op.LC)) && (right >= 0));
}
body {	
	import std.conv;
	T[][] result;  size_t rCol;
	if ((op == op.GC) || (op == op.LC)) rCol = to!size_t(right);

	foreach(row; table) if (row) {
		final switch(op) {
			case Ops.GC: if (row[left] > row[rCol]) result ~= row; break;
			case Ops.LC: if (row[left] < row[rCol]) result ~= row; break;
			case Ops.GV: if (row[left] > right) result ~= row; break;
			case Ops.LV: if (row[left] < right) result ~= row; break;
		}
	}
	return result;
}