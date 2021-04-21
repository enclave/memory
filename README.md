# memory

A module to facilitate memory manipulation of a process internally and externally.

## Installation

Clone the repository.

```bash
git clone https://github.com/enclave/memory ~/.vmodules/memory
```


## Usage

### External

```v
import memory.external

// Obtain an open handle to a process
fn obtain_process() {
	mut process := external.Process{}
	process.attach_process('placeholder.exe')
}

// Demonstrate external memory manipulation of a process
fn (p Process) read_and_write() {
	str := 'Hey'
	unsafe { p.write<string>(&str, 'Bye') }
	read_str := unsafe { p.read<string>(&str) }
	// [Output] str: Bye, read_str: Bye
	println('str: $str, read_str: $read_str')
}
```

### Internal

```v
import memory.internal

// Demonstrate internal memory manipulation of a process
fn read_and_write() {
	boolean := true
	unsafe { internal.write<bool>(&boolean, false) }
	read_boolean := unsafe { internal.read<bool>(&boolean) }
	// [Output] boolean: false, read_boolean: false
	println('boolean: $boolean, read_boolean: $read_boolean')
}
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)