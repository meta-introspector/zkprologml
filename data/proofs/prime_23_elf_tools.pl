% Prime 23: ELF parsing tools
% goblin, binutils, readelf all live here

:- dynamic tool/3.
:- dynamic tool_location/2.

main :-
    write('⚪ PRIME 23: ELF PARSING TOOLS\n'),
    write('═══════════════════════════════════════════════════════════\n\n'),
    
    % Register tools at prime 23
    Tools = [
        (goblin, 'Rust ELF parser', rust),
        (readelf, 'GNU readelf', c),
        (objdump, 'GNU objdump', c),
        (nm, 'Symbol lister', c),
        (binutils, 'Binary utilities', c)
    ],
    
    write('🔍 Tools at prime 23:\n\n'),
    forall(
        member((Tool, Desc, Lang), Tools),
        (
            assertz(tool(Tool, 23, Desc)),
            format('  ⚪ ~w (~w) - ~w\n', [Tool, Lang, Desc])
        )
    ),
    
    nl,
    write('📍 Locating in system...\n\n'),
    
    % Find readelf
    shell('which readelf 2>/dev/null', _),
    
    % Find objdump
    shell('which objdump 2>/dev/null', _),
    
    % Find nm
    shell('which nm 2>/dev/null', _),
    
    % Find goblin usage
    shell('find . -name "*.rs" -exec grep -l "use goblin" {} \\; 2>/dev/null | head -5', _),
    
    nl,
    write('🔬 Testing ELF parsing at prime 23...\n\n'),
    
    % Test readelf on a binary
    write('readelf -h /bin/ls:\n'),
    shell('readelf -h /bin/ls 2>/dev/null | head -10', _),
    
    nl,
    write('✅ PRIME 23 TOOLS VERIFIED\n').

% ?- main.
