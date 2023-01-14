module main

fn convert_row_to_shared_rows(row string) []string { // create dlopen function
	fn_name, fn_args, fn_return := find_fn_name_args_return_type(row)
	clear_variable := get_clear_variable(fn_args)
	mut result := []string{cap: 7}
	result << '	type ${fn_name}_type = fn ${fn_args} ${fn_return}'
	result << '	fn ${fn_name}${fn_args} ${fn_return} {'
	result << '		library := dl_get_opened() or {return bug}'
	result << '		defer{my_dl_close(library)}'
	result << '		f := dl.sym_opt(library, \'${fn_name}\') or {return bug2}'
	result << '		return (${fn_name}_type(f))${clear_variable}'
	result << '	}'
	return result
}

fn get_clear_variable(args string) string { // remove type from args
	if args == "()"{
		return args
	}
	args0 := args.replace("(", "").replace(")", "")
	args_array := args0.split(',')
	//println(args_array)
	mut variable := []string{cap:args_array.len}
	for i := 0; i < args_array.len; i++ {
		empty_arg_type := args_array[i].split(" ")
		mut arg_type := []string{cap:2}
		//println(empty_arg_type)
		for j := 0; j < empty_arg_type.len; j++ {
			//println(j)
			if empty_arg_type[j] != "" {
				arg_type << empty_arg_type[j]
			}
		}		
		variable << arg_type[0]
	}
	return '(${variable.join(", ")})'
}

fn add_v_type(row string) []string { // cast V type to C 
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
