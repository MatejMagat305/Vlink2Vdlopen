module main

import os

[inline]
fn convert(file_src_old []string, file_name string) {
	if file_src_old.len < 1 {
		return
	}
	mut file_new := os.open_append(file_name) or {
		eprintln('${err}')
		return
	}
	defer {
		file_new.flush()
		file_new.close()
	}
	rows_with_convert, rows_without_full_convert, convert2 := filter_convert(file_src_old)
	if convert2.len == 0 {
		write_lines_file(mut &file_new, rows_without_full_convert) or {
			eprintln('${err}')
			return
		}
	} else {
		do_convert_fn(mut &file_new, rows_without_full_convert, convert2) or {
			eprintln('${err}')
			return
		}
	}
	if rows_with_convert.len > 0 {
		write_prefix(mut &file_new) or {
			eprintln('${err}')
			return
		}
		write_convert1(mut &file_new, rows_with_convert) or {
			eprintln('${err}')
			return
		}
	}
}

fn do_convert_fn(mut file_new os.File, rows_without_full_convert []string, convert2 []int) ! { // changes C type to V type
	for i := 0; i < rows_without_full_convert.len; i++ {
		row := if i in convert2 {
			rows_without_full_convert[i].replace("C.", "") //.replace(':= C.', ':= ').replace('= C.', '= ')
		} else {
			rows_without_full_convert[i]
		}
		file_new.writeln(row)!
	}
}

[inline]
fn write_prefix(mut file_new os.File) ! { // write some prepare lines
	file_new.writeln('// converted') or { eprintln('${err}') }
	file_new.writeln('fn dl_get_opened() !voidptr{')!
	file_new.writeln('	parts := \$if linux||gnu{[]}\$else \$if windows{[]}\$else \$if mac||macos{[]}\$else \$if android{[]}\$else{[]}//fix me give locations')!
	file_new.writeln('	for i := 0; i < paths.len; i++ {')!
	file_new.writeln('		handle := dl.open_opt(paths[i]) or {continue}')!
	file_new.writeln('		return handle}')!
	file_new.writeln('	return error("dl_get_opened")')!
	file_new.writeln('}')!
	file_new.writeln('fn my_dl_close(library voidptr){dl.close(library)}')!
	file_new.writeln('const(')!
	file_new.writeln('	bug = // fix me')!
	file_new.writeln('	bug2 = // fix me')!
	file_new.writeln(')')!
}

fn write_convert1(mut file_new os.File, rows_with_convert1 []string) ! {// write all rows with conversion
	for i := 0; i < rows_with_convert1.len; i++ { 
		converted_rows := convert_row_to_shared_rows(rows_with_convert1[i])
		write_lines_file(mut &file_new, converted_rows) or { eprintln('${err}') }
	}
}

fn write_lines_file(mut file_new os.File, rows []string) ! { // write all rows without conversion
	for i := 0; i < rows.len; i++ {
		file_new.writeln(rows[i])!
	}
	file_new.writeln('')!
}
