module onsdata.table;

import std.stdio;
import std.string;
import std.conv;

import onsdata;

class Table(T) {
	Row!T[] rows;
	private string[] _columns;
	size_t[string] colIndex;
	
	this() {
	}
	this(size_t aWidth) {
		width = aWidth;
	}
	this(size_t aWidth, size_t aHeight) {
		this(aWidth);
		height = aHeight;
	}
	this(size_t aHeight, string[] someColumns) {
		this(someColumns.length, aHeight);
		columns = someColumns;
	}
	this(S)(Table!S source, bool copy = false) {
		columns = source.columns;
		height = source.height;
		foreach(i, row; source.rows) {
			if (row) rows[i] = newRow;
			if (copy) {
				foreach(j, c; row.cells) rows[i][j] = to!T(c);
			}
		}
	}
	
	@property string[] columns() { return _columns; }
	@property void columns(string[] values) { 
		_columns = values;
		width(_columns.length);
		foreach(i, col; columns) colIndex[col] = i;
	}
	
	@property void width(size_t aWidth) { _columns.length = aWidth; foreach(row; rows) if (row) row.width = width;  }
	@property size_t width() { return _columns.length; }
	@property size_t height() { return rows.length; }
	@property void height(size_t aHeight) { rows.length = aHeight; }
	
	size_t count() {
		size_t counter = 0;
		foreach(row; rows) if (row) counter++;
		return counter;
	}
	auto newRow() {
		Row!T result = new Row!T();
		result.width = width;
		return result;
	}
	auto newRow(T value) {
		auto row = newRow;
		row.value(value);
		return row;
	}
	auto newRow(T[] values) {
		auto row = newRow;
		foreach(i, value; values) row[i] = value;
		return row;
	}
	void add(Row!T row) { row.length = width; rows ~= row; }
	
	auto firstRow() {
		foreach(i, row; rows) if (row) return row;
		return null;
	}
	size_t firstIndex() {
		foreach(i, row; rows) if (row) return i;
		return size_t.max;
	}
	
	void opIndexAssign(Row!T row, size_t i) {
		if (i < height) rows[i] = row;
	}
	auto opIndex(size_t i) {
		if (i < height) return rows[i];
		return newRow; // blää
	}
	size_t opIndex(string col) {
		return colIndex[col];
	}
	
	void min(T)(size_t target, size_t[] cols) { foreach(row; rows) if (row) row.min(target, cols); }
	T min(T)(size_t col, size_t start, size_t end) {
		bool first = false;
		T result = 0;
		foreach(row; rows) {
			if (row) {
				if (!first) {
					result = row[col];
					first = true;
				}
				else {
					if (result > row[col]) result = row[col];
				}
			}
		}
		return result;
	}
	
	void avg(size_t target, size_t[] cols) { foreach(row; rows) if (row) row.avg(target, cols); }
	T avg(size_t col, size_t start, size_t end) {
		size_t counter = 0;
		T result = 0;
		foreach(i; start..end) if (auto row = this[i]) {
			counter++;
			result += row[col];
		}
		if (counter) return to!T(result/counter);
		return 0;
	}
	
	void max(T)(size_t target, size_t[] cols, size_t start = 0, size_t end = 0) { 
		auto e = (end == 0 ? height : end);
		foreach(i; start..end) if (auto row = this[i]) row.max(target, cols); }
	T max(T)(size_t col, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		bool first = false;
		T result = 0;
		foreach(i; start..end) if (auto row = this[i]) {
			if (!first) {
				result = row[col];
				first = true;
			}
			else {
				if (result < row[col]) result = row[col];
			}
		}
		return result;
	}
	
	void sum(size_t target, size_t[] cols) { foreach(row; rows) if (row) row.sum(target, cols); }
	/++
	 Sum - Calculating sum of columns in a row
	 +/
	S sum(S = double)(size_t col, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		int counter = 0; double result = 0;
		if (end > height) end = height;
		foreach(i; start..e) if (auto row = this[i]) { 
			counter++; result += row[col]; }
		return to!S((counter) ? result/counter : 0);
	}
	//	bool sum(T)(T[][] table, size_t target, size_t[] colInds, size_t start = 0, size_t end = size_t.max) { 
	//		if (table.length == 0) return false;
	//		if (colInds.length == 0) return false;
	//		
	//		if (end > table.length) end = table.length;
	//		auto rlen = table[0].length-1; // max Value for colInds
	//		if (target > rlen) return false;
	//		foreach(cIndex; colInds) if (cIndex > rlen) return false;
	//		
	//		double sum = row[cols[0]];
	//		foreach(i; start..end) if (auto row = table[i]) {
	//			if (cols.length > 1) foreach(col; cols[1..$]) sum += row[col];
	//			row[target] = check!T(sum/cols.length);
	//		}
	//		return true;
	//	}
	
	void delta(string target, string[2] cols, size_t start = 0, size_t end = 0) { delta(this[target], cols, start, end); }
	void delta(size_t target, string[2] cols, size_t start = 0, size_t end = 0) { delta(target, [this[cols[0]], this[cols[1]]], start, end); }
	void delta(string target, size_t[2] cols, size_t start = 0, size_t end = 0) { delta(this[target], cols, start, end); }
	void delta(size_t target, size_t[2] cols, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		foreach(i; start..e) if (auto row = this[i]) row.delta(target, cols); }
	
	S inc(S = double)(size_t col, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		int counter = 0; int x = 0; bool foundFirst = false;
		foreach(i; start..e) if (auto row = this[i]) {
			if (i == 0) continue;
			
			if ((rows[i-1]) && (foundFirst)) {
				double delta = row[col] - rows[i-1][col];
				if (delta > 0) x++;
				counter++;
			}
			else foundFirst = true;
		}
		if (counter) return to!S(x/counter);
		return 0;
	}
	
	// -- getDec
	S dec(S = double)(size_t col, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		int counter = 0; int x = 0; bool foundFirst = false;
		foreach(i; start..e) if (auto row = this[i]) {
			if (i == 0) continue;
			
			if ((foundFirst) && (this[i-1])) {
				double delta = row[col] - this[i-1][col];
				if (delta < 0) x++;
				counter++;
			}
			else foundFirst = true;
		}
		if (counter) return x/counter;
		return 0;
	}
	
	Table!T copy() { return new Table!T(this); }
	override string toString() {
		string result;
		result ~= "width:%s\theight:%s\n".format(width, height);
		foreach(i, row; rows) if (row) result ~= "%s:\t%s\n".format(i, row.toString);
		return result;
	}
	
	T[string][] changedRows(Table!T originalTable) {
		T[string][] results; results.length = height; 
		foreach(i, row; rows) if (row) results[i] = changedCells(i, originalTable);
		return results;
	}
	
	T[string][] changedRows(T originalValue) {
		T[string][] results; results.length = height; 
		foreach(i, row; rows) if (row) results[i] = changedCells(i, originalValue);
		return results;
	}
	
	T[string] changedCells(size_t i, Table!T originalTable) {
		T[string] result;
		if (auto row = rows[i]) {
			if (auto oRow = originalTable[i]) { 
				foreach(k, v; colIndex) {	
					if (row[v] != oRow[v]) result[k] = row[v];
				}
			}
		}
		return result;
	}
	T[string] changedCells(size_t i, T originalValue) {
		T[string] result;
		if (auto row = rows[i]) { 
			foreach(k, v; colIndex) {	
				if (row[v] != originalValue) result[k] = row[v];
			}
		}
		return result;
	}
	
}

// -- getInc
double getInc(T)(T[][] table, size_t col){
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