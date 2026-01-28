// parquet_ffi.rs - Native Rust FFI for SWI-Prolog to read parquet

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// FFI: Read parquet file and return row count
#[no_mangle]
pub extern "C" fn parquet_row_count(path: *const c_char) -> i64 {
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = c_str.to_str().unwrap_or("");
    
    // For now, read CSV version
    let csv_path = path_str.replace(".parquet", ".csv");
    
    match std::fs::read_to_string(&csv_path) {
        Ok(content) => content.lines().count() as i64 - 1, // Subtract header
        Err(_) => -1,
    }
}

/// FFI: Get row from parquet by index
#[no_mangle]
pub extern "C" fn parquet_get_row(path: *const c_char, row_idx: i64) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(path) };
    let path_str = c_str.to_str().unwrap_or("");
    
    let csv_path = path_str.replace(".parquet", ".csv");
    
    match std::fs::read_to_string(&csv_path) {
        Ok(content) => {
            let lines: Vec<&str> = content.lines().collect();
            if row_idx >= 0 && (row_idx as usize) < lines.len() - 1 {
                let row = lines[row_idx as usize + 1]; // Skip header
                CString::new(row).unwrap().into_raw()
            } else {
                CString::new("").unwrap().into_raw()
            }
        }
        Err(_) => CString::new("").unwrap().into_raw(),
    }
}

/// FFI: Free string allocated by Rust
#[no_mangle]
pub extern "C" fn parquet_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe { CString::from_raw(s) };
    }
}

/// FFI: Query parquet with column filter
#[no_mangle]
pub extern "C" fn parquet_query(
    path: *const c_char,
    column: *const c_char,
    value: *const c_char,
) -> *mut c_char {
    let path_str = unsafe { CStr::from_ptr(path).to_str().unwrap_or("") };
    let col_str = unsafe { CStr::from_ptr(column).to_str().unwrap_or("") };
    let val_str = unsafe { CStr::from_ptr(value).to_str().unwrap_or("") };
    
    let csv_path = path_str.replace(".parquet", ".csv");
    
    match std::fs::read_to_string(&csv_path) {
        Ok(content) => {
            let mut results = Vec::new();
            let lines: Vec<&str> = content.lines().collect();
            
            if lines.is_empty() {
                return CString::new("").unwrap().into_raw();
            }
            
            let header = lines[0];
            let columns: Vec<&str> = header.split(',').collect();
            
            if let Some(col_idx) = columns.iter().position(|&c| c == col_str) {
                for line in &lines[1..] {
                    let fields: Vec<&str> = line.split(',').collect();
                    if col_idx < fields.len() && fields[col_idx].contains(val_str) {
                        results.push(*line);
                    }
                }
            }
            
            let result = results.join("\n");
            CString::new(result).unwrap().into_raw()
        }
        Err(_) => CString::new("").unwrap().into_raw(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::ffi::CString;

    #[test]
    fn test_row_count() {
        let path = CString::new("generated/godel_lattice.parquet").unwrap();
        let count = parquet_row_count(path.as_ptr());
        assert!(count > 0);
    }
}
