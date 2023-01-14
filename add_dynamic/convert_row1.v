module main

fn convert_row_to_shared_rows(row string) []string {
	fn_name, fn_args, fn_return := find_fn_name_args_return_type(row)
	mut result := []string{cap: 7}
	result << '	type ${fn_name}_type = fn ${fn_args}'
	result << '	fn ${fn_name}${fn_args} ${fn_return} {'
	result << '		library := dl_get_opened() or {return bug}'
	result << '		defer{my_dl_close(library)}'
	result << '		f := dl.sym_opt(library, \'${fn_name}\') or {return bug2}'
	result << '		return (${fn_name}_type(f))${fn_args}'
	result << '	}'
	return result
}

fn add_v_type(row string) []string {
	mut result := []string{cap: 2}
	result << '	${row}'
	fn_name := find_fn_name(row)
	result << '	type ${fn_name} = C.${fn_name}'
	return result
}

[inline]
fn find_fn_name_args_return_type(row string) (string, string, string) {
	witout_c := row.split('C.')
	without_return_return := witout_c[1].split(')')
	name_args := without_return_return[0].split('(')
	return name_args[0], '(${name_args[1]})', without_return_return[1]
}

[inline]
fn find_fn_name(row string) string {
	without_return_return := row.split('C.')
	name_args := without_return_return[1].split('(')
	return name_args[0]
}
