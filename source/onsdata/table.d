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
	size_t lastIndex() {
		foreach_reverse(i, row; rows) if (row) return i;
		return 0;
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
	
	void min(size_t target, size_t[] cols) { foreach(row; rows) if (row) row.min(target, cols); }
	T min(size_t col, size_t start, size_t end) {
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
	
	void max(size_t target, size_t[] cols, size_t start = 0, size_t end = 0) { 
		auto e = (end == 0 ? height : end);
		foreach(i; start..end) if (auto row = this[i]) row.max(target, cols); }
	T max(size_t col, size_t start = 0, size_t end = 0) {
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
	
	// -- dec
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
	
	// -- div
	S div(S = double)(size_t col, size_t start = 0, size_t end = 0) {
		auto e = (end == 0 ? height : end);
		T[] values; 
		foreach(i; start..e) if (auto row = this[i]) {
			if (auto row2 = this[i-1]) {
				values ~= row2[col] - row[col];
			}
		}
		if (values) {
			S result = 0;
			foreach(value; values) result += value;
			return result/values.length;
		}
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
