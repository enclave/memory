module external

#include <Tlhelp32.h>

[windows_stdcall]
fn C.CloseHandle(hObject voidptr) int
fn C.CreateToolhelp32Snapshot(dwFlags u32, th32ProcessID u32) voidptr
fn C.OpenProcess(dwDesiredAccess u32, bInheritHandle int, dwProcessId u32) voidptr
fn C.Process32FirstW(hSnapshot voidptr, lppe &C.PROCESSENTRY32W) int
fn C.Process32NextW(hSnapshot voidptr, lppe &C.PROCESSENTRY32W) int

[typedef]
struct C.PROCESSENTRY32W {
	dwSize              u32
	cntUsage            u32
	th32ProcessID       u32
	th32DefaultHeapID   C.ULONG_PTR
	th32ModuleID        u32
	cntThreads          u32
	th32ParentProcessID u32
	pcPriClassBase      int
	dwFlags             u32
	szExeFile           [260]u16
}

pub struct Process {
pub mut:
	handle voidptr
	id     u32
}

// Take a snapshot of all processes in the system
pub fn get_process_snapshot() voidptr {
	// Take a snapshot of all processes, and obtain an open handle to the snapshot
	snapshot_section := C.CreateToolhelp32Snapshot(C.TH32CS_SNAPPROCESS, 0)

	if snapshot_section == u32(C.INVALID_HANDLE_VALUE) {
		eprintln('CreateToolhelp32Snapshot() failed')
	}

	return snapshot_section
}

pub fn initialize_process_entry() C.PROCESSENTRY32W {
	return C.PROCESSENTRY32W{
		dwSize: sizeof(C.PROCESSENTRY32W)
	}
}

// Find a running process by its name
pub fn (mut p Process) find_process_id(name string) u32 {
	process_snapshot := get_process_snapshot()
	process_entry := initialize_process_entry()

	// Retrieve information of the first process taken in the snapshot
	if C.Process32FirstW(process_snapshot, &process_entry) != 0 {
		// Enumerate all other processes from the taken snapshot
		for C.Process32NextW(process_snapshot, &process_entry) != 0 {
			process_name := unsafe { string_from_wide(&u16(&process_entry.szExeFile[0])) }

			// Check if enumerated process name matches the specified process name
			if process_name == name {
				println('$name found')
				// Destroy the snapshot as it not needed anymore
				C.CloseHandle(process_snapshot)
			}
		}
	} else {
		eprintln('Process32FirstW() failed')
	}

	p.id = process_entry.th32ProcessID

	if p.id == 0 {
		eprintln('$name is not running')
	}

	return p.id
}

// Obtain an open handle to a process
pub fn open_process_handle(process_id u32) voidptr {
	process_handle := C.OpenProcess(C.PROCESS_ALL_ACCESS, 0, process_id)

	if process_handle == 0 {
		eprintln('OpenProcess() failed')
	}

	return process_handle
}

pub fn (mut p Process) attach_process(name string) {
	p.handle = open_process_handle(p.find_process_id(name))
}