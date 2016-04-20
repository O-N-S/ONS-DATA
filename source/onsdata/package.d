module onsdata;

public import std.traits;

public import onsdata.cell;
public import onsdata.row;
public import onsdata.rows;
public import onsdata.table;

alias BASE = double;
alias NORM = int;

enum Ops {
	GV, 
	LV, 
	GC, 
	LC
}

bool inside(T)(size_t col, T[] row) {
	if (col > row.length-1) return false;
	return true;
}
void set(T, S)(T[] row, size_t col, S value) {
	if (col > row.length-1) return;
	row[col] = checkFor!T(value);
}

void set(T, S)(T[][] rows, size_t index, size_t col, S value) {
	if (!isIn(index, rows)) return;
	rows[index].set(col, value);
}
void set(T, S, G)(T[][G] rows, G group, size_t col, S value) {
	if (group !in rows) return;
	rows[group].set(col, value);
}

void set(T, S, G, C)(T[][G][C] rows, C category, G group, size_t col, S value) {
	if (category !in rows) return;
	rows[category].set(group, col, value);
}

bool isIn(T)(T value, T[] values) {
	foreach(v; values) if (value == v) return true;
	return false;
}
size_t[T] indexing(T)(T[] values) {
	size_t[T] results;
	foreach(i, v; values) results[v] = i;
	return results;
}