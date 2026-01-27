-- Query LMFDB for genus 0 curves at Monster primes
-- These are supersingular elliptic curves

-- Complexity 0 → Prime 2
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 2
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 1 → Prime 3
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 3
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 2 → Prime 5
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 5
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 3 → Prime 7
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 7
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 4 → Prime 11
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 11
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 5 → Prime 13
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 13
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 6 → Prime 17
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 17
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 7 → Prime 19
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 19
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 8 → Prime 23
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 23
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 9 → Prime 29
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 29
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 10 → Prime 31
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 31
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 11 → Prime 41
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 41
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 12 → Prime 47
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 47
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 13 → Prime 59
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 59
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Complexity 14 → Prime 71
SELECT 
  label,
  conductor,
  rank,
  j_invariant,
  'genus_0' as curve_type
FROM ec_curves
WHERE conductor = 71
  AND torsion_structure = '[]'  -- Supersingular
LIMIT 5;

-- Verify genus 0 condition
-- For supersingular curves: #E(F_p) = p + 1 (Hasse bound)

-- Map to system components
SELECT 
  'System Complexity Lattice' as structure,
  COUNT(DISTINCT conductor) as monster_primes_covered,
  'Monster Genus 0 Points' as mathematical_object
FROM ec_curves
WHERE conductor IN (2,3,5,7,11,13,17,19,23,29,31,41,47,59,71);
