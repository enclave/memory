module external

#include <Tlhelp32.h>

__global ( g_process Process )

const (
	// MAX_MODULE_NAME32 + 1
	sz_module_length = 256
	max_path         = 260
)

[typedef]
struct C.PROCESSENTRY32W {
	dwSize              size_t
	cntUsage            u32
	th32ProcessID       u32
	th32DefaultHeapID   C.ULONG_PTR
	cntThreads          u32
	th32ParentProcessID u32
	pcPriClassBase      int
	dwFlags             u32
	szExeFile           [260]C.WCHAR
}

[typedef]
struct C.MODULEENTRY32W {
	dwSize        size_t
	th32ModuleID  u32
	th32ProcessID u32
	GlblcntUsage  u32
	ProccntUsage  u32
	modBaseAddr   &byte
	modBaseSize   size_t
	hModule       voidptr
	szModule      [256]u16
	szExePath     [260]u16
}

pub struct Process {
pub:
	handle voidptr
}

[windows_stdcall]
fn C.CreateToolhelp32Snapshot(dwFlags u32, th32ProcessID u32) voidptr
fn C.OpenProcess(dwDesiredAccess u32, bInheritHandle int, dwProcessId u32) voidptr
fn C.Process32FirstW(hSnapshot voidptr, lppe voidptr) int
fn C.Process32NextW(hSnapshot voidptr, lppe voidptr) int

// Take a snapshot of all processes in the system
pub fn get_process_list() voidptr {
	// Take a snapshot of all processes, and obtain an open handle to the snapshot
	th32 := C.CreateToolhelp32Snapshot(C.TH32CS_SNAPPROCESS, 0)

	if th32 == C.INVALID_HANDLE_VALUE {
		eprintln('CreateToolhelp32Snapshot() failed')
	}

	return th32
}

// Find a running process by its name
pub fn find_process_id(name string) u32 {
	th32 := get_process_list()

	pe32 := C.PROCESSENTRY32W{
		dwSize: size_t(sizeof(C.PROCESSENTRY32W))
	}

	// Retrieve information of the first process taken in the snapshot
	if C.Process32FirstW(th32, &pe32) != 0 {
		// Enumerate all other processes from the taken snapshot
		for C.Process32NextW(th32, &pe32) != 0 {
			process_name := unsafe { string_from_wide(&u16(&pe32.szExeFile[0])) }

			// Check if enumerated process name matches the specified process name
			if process_name == name {
				// Destroy the snapshot as it not needed anymore
				C.CloseHandle(th32)
				return pe32.th32ProcessID
			}
		}
	} else {
		eprintln('Process32FirstW() failed')
		return 0
	}

	eprintln('$name is not running')
	return 0
}

// Obtain an open handle to a process
pub fn open_process_handle(id u32) voidptr {
	handle := C.OpenProcess(C.PROCESS_ALL_ACCESS, 0, id)

	if handle == 0 {
		eprintln('OpenProcess() failed')
		return voidptr(0)
	}

	println('OpenProcess() successful')
	return handle
}

pub fn attach_process(name string) {
	id := find_process_id(name)

	g_process = Process{
		handle: open_process_handle(id)
	}
}