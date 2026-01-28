-- Emoji patterns from audiocraft

def emojiPatterns : List String := [
  "🔢",
  "⚡",
  "📦",
  "🔀",
  "🎯",
  "👉",
  "🏗️",
  "📊",
  "💾",
  "⚙️",
  "📤",
  "🔄",
  "🤖",
  "🔐",
  "🌐",
  "🧬",
  "🎨",
  "🔬",
  "🌌",
  "♾️",
]

def emojiToPrime : String → Option Nat
  | "🔢" => some 2
  | "⚡" => some 3
  | "📦" => some 5
  | "🔀" => some 7
  | "🎯" => some 11
  | "👉" => some 13
  | "🏗️" => some 17
  | "📊" => some 19
  | "💾" => some 23
  | "⚙️" => some 29
  | "📤" => some 31
  | "🔄" => some 37
  | "🤖" => some 41
  | "🔐" => some 43
  | "🌐" => some 47
  | "🧬" => some 53
  | "🎨" => some 59
  | "🔬" => some 61
  | "🌌" => some 67
  | "♾️" => some 71
  | _ => none

theorem emoji_prime_valid (e : String) (p : Nat) :
  emojiToPrime e = some p → Nat.Prime p := by
  intro h
  cases e <;> simp [emojiToPrime] at h
  sorry -- Proof that all mapped values are prime
