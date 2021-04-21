module internal

[windows_stdcall]
fn C.VirtualProtect(lpAddress voidptr, dwSize size_t, flNewProtect u32, lpflOldProtect &u32) int

// Reads data from a specified address
[unsafe]
pub fn read<T>(address voidptr) T {
	return unsafe { (*(&T(address))) }
}

// Writes data to a specified address
[unsafe]
pub fn write<T>(address voidptr, data T) bool {
	mut old_protection := u32(0)

	// Change page protection to enable execute, read-only or read/write access
	if C.VirtualProtect(address, sizeof(T), C.PAGE_EXECUTE_READWRITE, &old_protection) == 0 {
		eprintln('VirtualProtect() failed')
		return false
	}

	unsafe {
		(*(&T(address))) = data
	}
	// Restore page protection
	if C.VirtualProtect(address, sizeof(T), old_protection, &old_protection) == 0 {
		eprintln('VirtualProtect() failed #2')
		return false
	}

	return true
}