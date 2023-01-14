module main

import os

fn main() {
	if os.args.len < 1 {
		panic('Please provide file, dictionary or multiple files ')
	}
	mut paths := os.args[1..].clone()
	for paths.len > 0 { // walk args
		path := paths.pop()
		// println('path: ' + path)
		if os.is_dir(path) {
			paths << os.walk_ext(path, '.v')
			continue
		}
		if path.ends_with('.v') {
			file_src_old := os.read_lines(path) or {
				eprintln('${err}')
				continue
			}
			file_name := os.file_name(path)
			convert(file_src_old, file_name)
		}
	}
}
