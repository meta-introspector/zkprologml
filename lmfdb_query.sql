# LMFDB Query for Monster-indexed search
# Primes: [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]
# Chords: 24
# Conductor range: 1-71

SELECT label, conductor, degree, coefficients
FROM lfunctions
WHERE conductor IN (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71)
ORDER BY conductor;
