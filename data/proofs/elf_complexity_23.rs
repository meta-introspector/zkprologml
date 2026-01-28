// Proof: All ELF tools have complexity 23

const PARSE_HEADER_COMPLEXITY: u32 = 7;
const READ_SECTIONS_COMPLEXITY: u32 = 11;
const EXTRACT_SYMBOLS_COMPLEXITY: u32 = 5;

const ELF_COMPLEXITY: u32 = 
    PARSE_HEADER_COMPLEXITY + 
    READ_SECTIONS_COMPLEXITY + 
    EXTRACT_SYMBOLS_COMPLEXITY;

#[derive(Debug, Clone, Copy)]
enum ELFTool {
    Goblin,
    Readelf,
    Objdump,
    Nm,
}

impl ELFTool {
    const fn complexity(&self) -> u32 {
        ELF_COMPLEXITY
    }
}

#[test]
fn test_elf_complexity_is_23() {
    assert_eq!(ELF_COMPLEXITY, 23);
}

#[test]
fn test_all_tools_have_complexity_23() {
    assert_eq!(ELFTool::Goblin.complexity(), 23);
    assert_eq!(ELFTool::Readelf.complexity(), 23);
    assert_eq!(ELFTool::Objdump.complexity(), 23);
    assert_eq!(ELFTool::Nm.complexity(), 23);
}
