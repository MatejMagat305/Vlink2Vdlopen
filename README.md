# Vlink2Vdlopen
this is small prototype of tool, which is trying transform V code with link (static or dynamic) to V code with dl open. <br>
# the main idea:
'''
...
fn C.some_fn1(params1) ret1
...
->
...
fn dl_get_opened() !voidptr{
	parts := $if linux||gnu{[]}$else $if windows{[]}$else $if mac||macos{[]}$else $if android{[]}$else{[]}//fix me give locations
	for i := 0; i < paths.len; i++ {
		handle := dl.open_opt(paths[i]) or {continue}
		return handle}
	return error("dl_get_opened")
}
fn my_dl_close(library voidptr){dl.close(library)}

const(
	bug = // fix me
	bug2 = // fix me
)
$if shared_library ? {
type some_fn1_type = fn (params1) ret1
fn some_fn1 (params1) ret1{
		library := dl_get_opened() or {return bug}
		defer{my_dl_close(library)}
		f := dl.sym_opt(library, 'clCreateBuffer') or {return bug2}
		return (some_fn1_type(f))(context ClContext, flags ClMemFlags, size usize, host_ptr voidptr, errcode_ret &int)
}
...
}$else {
fn C.some_fn1(params1) ret1
type some_fn1 = C.some_fn1
...
}
'''
paths of dlopen you have to put manualy because tool can not know it ..., and bugs you have to solve ... for concrete library ... 
