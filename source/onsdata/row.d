module onsdata.row;

import std.stdio;
import std.conv;
import std.string;
import onsdata;

enum RowStatus {
	invalid,
	valid,
	changed
}
class Row(T) {
	RowStatus status = RowStatus.invalid;
	
	this() {}
	this(size_t aLength) { length = aLength; }
	this(Row!T source) {
		this(source.length);
		foreach(i, c; source.cells) cells[i] = c;
	}
	
	T[] cells;
	@property void length(size_t aLength) { cells.length = aLength; }
	@property auto length() { return cells.length; }
	@property void width(size_t aWidth) { length = aWidth; }
	@property auto width() { return length; }
	
	void init(T initValue) { cells[] = initValue; }
	void value(T val) { cells[] = val; }
	
	void opIndexAssign(T value, size_t i) {
		if (i < length) cells[i] = value;
	}
	auto opIndex(size_t i) {
		if (i < length) return cells[i];
		return T.init; // blää
	}
	
	void min(size_t target, size_t[] cols) { if (cols) this[target] = min(cols); }
	T min(size_t[] cols) {
		if (cols.length == 0) return 0;
		
		T result = this[cols[0]];
		foreach(c; cols) if (result > this[c]) result = this[c];
		return result;
	}
	
	void avg(size_t target, size_t[] cols) { if (cols) this[target] = avg(cols); }
	T avg(size_t[] cols) {
		if (cols.length == 0) return 0;
		
		T result = 0;
		foreach(c; cols) result += this[c];
		return to!T(result/length);
	}
	
	void max(size_t target, size_t[] cols) { if (cols) this[target] = max(cols); }
	T max(size_t[] cols) {
		if (cols.length == 0) return 0;
		
		T result = this[cols[0]];
		foreach(c; cols) if (result < this[c]) result = this[c];
		return result;
	}
	
	void sum(size_t target, size_t[] cols) { if (cols) this[target] = sum(cols); }
	T sum(size_t[] cols) {
		if (cols.length == 0) return 0;
		
		T result = 0;
		foreach(c; cols) result += this[c];
		return result;
	}
	
	void delta( size_t target, size_t[2] cols) { this[target] = delta(cols); }
	T delta( size_t[2] cols) { return this[cols[1]] - this[cols[0]]; }
	
	auto copy()  {
		Row!T result = new Row!T(length);
		foreach(i, c; cells) result[i] = c;
		return result;
	} 
	
	override string toString() {
		string[] values;
		foreach(x; cells) values ~= to!string(x);
		return "["~values.join(",\t")~"]";
	}
}
T[] newRow(T)(size_t length) {
	T[] result; result.length = length;
	foreach(ref r; result) r = 0;
	return result;
}

Row!T[] copy(T)(Row!T[] rows) {
	Row!T[] result;
	result.length = rows.length;
	foreach(i, r; rows) result[i] = copy(r);
	return result;
} 

bool isIn(T)(T value, T[] values) {
	foreach(v; values) if (v == value) return true;
	return false;
}
bool isNotIn(T)(T value, T[] values) {
	foreach(v; values) if (v == value) return false;
	return true;
}

