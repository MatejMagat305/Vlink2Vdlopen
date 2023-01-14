module main

fn filter_convert(file_src_old []string) ([]string, []string, []int) { // return rows to convert, not conver and rows index on non convert where is needed remove "C."" 
	mut rows_without_full_convert := []string{cap: file_src_old.len}
	mut rows_with_convert1 := []string{cap: file_src_old.len}
	mut convert2 := []int{cap: file_src_old.len / 7}
	for i := 0; i < file_src_old.len; i++ {
		if is_to_convert1(file_src_old[i]) {
			rows_with_convert1 << file_src_old[i]
		} else {
			if is_to_convert2(file_src_old[i]) {
				convert2 << rows_without_full_convert.len
			}
			rows_without_full_convert << file_src_old[i]
		}
	}
	return rows_with_convert1, rows_without_full_convert, convert2
}

fn is_to_convert1(row string) bool { // check is declaration to reference of C.function
	b1 := row.contains('fn ')
	b2 := row.contains('C.')
	b3 := row.contains('(')
	b4 := row.contains('{')
	return b1 && b2 && b3 && !b4
}

fn is_to_convert2(row string) bool { // check is C.function call?
	b1 := row.contains('fn ')
	b2 := row.contains('C.')
	b3 := row.contains('(')
	//b4 := row.contains('=')
	//b5 := row.contains(':=')
	return !b1 && b2 && b3 // && (b4 || b5)
}
