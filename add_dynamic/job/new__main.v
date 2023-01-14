module main

import vsl.vcl
import time

const kernel_source = '
__kernel void addOne(__global float* data) {
    const int i = get_global_id(0);
    data[i] += 1;
}'

const how_many = 4096 * 16

fn main() {
	mut devices := vcl.get_devices(vcl.DeviceType.cpu)?
	println('Devices: ${devices}')
	mut threads := []thread{}
	mut device := vcl.get_default_device()?
	threads << spawn d(mut device)
	mut data := []f32{len: how_many, init: it}
	for i in 1 .. 16 {
		threads << spawn fn (i int, mut data []f32) {
			for j := 0; j < how_many / 16; j++ {
				data[i * how_many / 16 + j] += 1
			}
		}(i, mut &data)
	}
	threads.wait()
	println('${data[(how_many - 16)..]}')
	time.sleep(10000000)
}

fn d(mut device vcl.Device) {
	// println('Device: ${device},0')	
	mut v := device.vector[f32](how_many) or { return }
	// println('Device: ${device},1')	
	defer {
		v.release() or { panic(err) }
	}
	data := []f32{len: how_many, init: 1}
	err := <-v.load(data)
	if err !is none {
		panic(err)
	}
	device.add_program(kernel_source) or {
		println('Device: ${device},${err}')
		return
	}
	// println('Device: ${device},2')	
	k := device.kernel('addOne') or { return }
	// println('Device: ${device},3')	
	kernel_err := <-k.global(how_many).local(1).run(v) // run kernel (global work size 16 and local work size 1)
	if kernel_err !is none {
		panic(kernel_err)
	}
	next_data := v.data() or { return }
	println('\n\nUpdated vector data: ${next_data[(how_many - 16)..]}, Device: ${device}') // prints out [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
}

