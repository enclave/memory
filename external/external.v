module external

[windows_stdcall]
fn C.ReadProcessMemory(hProcess voidptr, lpBaseAddress voidptr, lpBuffer voidptr, nSize size_t, lpNumberOfBytesRead &size_t) int
fn C.WriteProcessMemory(hProcess voidptr, lpBaseAddress voidptr, lpBuffer voidptr, nSize size_t, lpNumberOfBytesWritten &size_t) int

// Reads data from a specified address
[unsafe]
pub fn (p Process) read<T>(address voidptr) T {
	mut data := T{}
	mut bytes_read := size_t(0)

	unsafe { C.ReadProcessMemory(p.handle, address, &data, sizeof(T), &bytes_read) }

	if size_t(sizeof(T)) != bytes_read {
		eprintln('ReadProcessMemory() failed')
	}

	return data
}

// Writes data to a specified address
[unsafe]
pub fn (p Process) write<T>(address voidptr, data T) bool {
	mut bytes_written := size_t(0)

	unsafe { C.WriteProcessMemory(p.handle, address, &data, sizeof(T), &bytes_written) }

	if size_t(sizeof(T)) != bytes_written {
		eprintln('WriteProcessMemory() failed')
		return false
	}

	return true
}