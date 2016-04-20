module onsdata.rows;

import std.conv;
import onsdata;

oid min(T)(Row!T[] rows, size_t target, size_t[] cols) {
	foreach(row; rows) row.min(target, cols);
}
void avg(T)(Row!T[] rows, size_t target, size_t[] cols) {
	foreach(row; rows) row.avg(target, cols);
}
S avg(S = double, T)(Row!T[] rows, size_t target) {
	size_t counter = 0;
	double sum = 0;
	foreach(row; rows) if (row) {
		counter++;
		sum += row[target];
	}
	if (counter) return to!S(sum/counter);
	return 0;
}
void max(T)(Row!T[] rows, size_t target, size_t[] cols) {
	foreach(row; rows) row.max(target, cols);
}
void sum(T)(Row!T[] rows, size_t target, size_t[] cols) {
	foreach(row; rows) row.sum(target, cols);
}
void delta(T)(Row!T[] rows, size_t target, size_t[2] cols) {
	foreach(row; rows) row.delta(target, cols);
}

T min(T)(Row!T[] rows, size_t col) if (isNumeric!T) {
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

T max(T)(Row!T[] rows, size_t col) if (isNumeric!T) {
	bool first = false;
	T result = 0;
	foreach(row; rows) {
		if (row) {
			if (!first) {
				result = row[col];
				first = true;
			}
			else {
				if (result < row[col]) result = row[col];
			}
		}
	}
	return result;
}

void delta(T)(Row!T[] rows, size_t target, size_t[2] cols) { table.delta(target, cols[0], cols[1]); }
void delta(T)(Row!T[] rows, size_t target, size_t left, size_t right) { 
	foreach(row; table) if (row) {
		if (!target.inside(row)) return;
		if (!left.inside(row)) return;
		if (!right.inside(row)) return;
		
		row[target] = row[right] - row[left];
	}
}

double inc(T)(Row!T[] rows, size_t col) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i, row; rows) if (row) {
		if (i == 0) continue;
		
		if ((foundFirst) && (rows[i-1])) {
			double delta = row[col] - rows[i-1][col];
			if (delta > 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}
double dec(T)(Row!T[] rows, size_t col) {
	int counter = 0; int x = 0; bool foundFirst = false;
	foreach(i, row; rows) if (row) {
		if (i == 0) continue;
		
		if ((foundFirst) && (rows[i-1])) {
			double delta = row[col] - rows[i-1][col];
			if (delta < 0) x++;
			counter++;
		}
		else foundFirst = true;
	}
	if (counter) return x/counter;
	return 0;
}

S sum(S = double, T)(size_t col) { 
	double result = 0;
	foreach(row; rows) if (row) result += row[col];
	return to!S(result);
}
S sum(S = double, T)(Row!T rows, size_t col, size_t start = 0, size_t end = size_t.max) {
	int counter = 0; double sum = 0;
	if (end > rows.length) end = rows.length;
	foreach(i; start..end) if (auto row = table[i]) { counter++; sum += row[col]; }
	return To!S((counter) ? sum/counter : 0);
}

