% Emoji patterns from audiocraft

emoji_prime('🔢', 2).
emoji_prime('⚡', 3).
emoji_prime('📦', 5).
emoji_prime('🔀', 7).
emoji_prime('🎯', 11).
emoji_prime('👉', 13).
emoji_prime('🏗️', 17).
emoji_prime('📊', 19).
emoji_prime('💾', 23).
emoji_prime('⚙️', 29).
emoji_prime('📤', 31).
emoji_prime('🔄', 37).
emoji_prime('🤖', 41).
emoji_prime('🔐', 43).
emoji_prime('🌐', 47).
emoji_prime('🧬', 53).
emoji_prime('🎨', 59).
emoji_prime('🔬', 61).
emoji_prime('🌌', 67).
emoji_prime('♾️', 71).

% Get all emojis
all_emojis(Emojis) :- findall(E, emoji_prime(E, _), Emojis).

% Get prime for emoji
emoji_to_prime(Emoji, Prime) :- emoji_prime(Emoji, Prime).
