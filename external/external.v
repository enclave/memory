module external

__global ( g_external External )

[windows_stdcall]
fn C.ReadProcessMemory(hProcess voidptr, lpBaseAddress voidptr, lpBuffer voidptr, nSize size_t, lpNumberOfBytesRead voidptr) int
fn C.VirtualProtectEx(hProcess voidptr, lpAddress voidptr, dwSize size_t, flNewProtect u32, lpflOldProtect voidptr) int
fn C.WriteProcessMemory(hProcess voidptr, lpBaseAddress voidptr, lpBuffer voidptr, nSize size_t, lpNumberOfBytesRead voidptr) int

pub struct External {
pub:
	handle voidptr
}

// Reads data from a specified address
[unsafe]
pub fn read<T>(address voidptr) T {
	mut data := T{}
	mut bytes_read := u32(0)

	unsafe { C.ReadProcessMemory(g_external.handle, address, &data, sizeof(T), &bytes_read) }

	if sizeof(T) != bytes_read {
		$if debug {
			panic('read() failed')
		}
	}
	return data
}

// Writes data to a specified address
[unsafe]
pub fn write<T>(address voidptr, data T) bool {
	mut bytes_written := u32(0)

	unsafe { C.WriteProcessMemory(g_external.handle, address, &data, sizeof(T), &bytes_written) }

	if sizeof(T) == bytes_written {
		return true
	} else {
		$if debug {
			panic('write() failed')
		}
		return false
	}
}
