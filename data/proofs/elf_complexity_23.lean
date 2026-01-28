-- Proof: All ELF tools have complexity 23
import Mathlib.Data.Nat.Prime.Basic

def parse_header_complexity : Nat := 7
def read_sections_complexity : Nat := 11
def extract_symbols_complexity : Nat := 5

def elf_complexity : Nat :=
  parse_header_complexity + read_sections_complexity + extract_symbols_complexity

theorem elf_complexity_is_23 : elf_complexity = 23 := rfl

theorem elf_complexity_is_prime : Nat.Prime elf_complexity := by
  norm_num

inductive ELFTool where
  | goblin : ELFTool
  | readelf : ELFTool
  | objdump : ELFTool
  | nm : ELFTool

def tool_complexity : ELFTool → Nat
  | _ => elf_complexity

theorem all_elf_tools_complexity_23 (t : ELFTool) :
  tool_complexity t = 23 := by
  cases t <;> rfl
