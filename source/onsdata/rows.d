module onsdata.rows;

import std.conv;
import onsdata;

void min(T)(Row!T[] rows, size_t target, size_t[] cols) {
	foreach(row; rows) row.min(target, cols);
}

/+ avg - returns the average value of columns in rows and write the result in the target col of each row +/
void avg(T)(Row!T[] rows, size_t target, size_t[] cols) { foreach(row; rows) row.avg(target, cols); }
/+ avg - returns the average value of columns in selected rows +/
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
/*
AVG
S avg(S = double, T)(T[][] table, size_t col, size_t start = 0, size_t end = size_t.max) {
	return (end == size_t.max) ? avg(table[start..table.length], col) : avg(table[start..end], col) ;
}
S avg(S = double, T)(T[][] table, size_t col) {
	int counter = 0; double sum = 0;
	foreach(row; table) if (row) { counter++; sum += row[col]; }
	return (counter) ? sum/counter : 0;
}
*/
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