import Swift

// idea
// an invariant collection of key-value associations from `k` to `v` where `k`
// is constrained to iterable sum types⁽¹⁾ and construction is contingent
// upon the exhaustive association of all cases.
// ⁽¹⁾ can't constrain against enum, but we can leverage CaseIterable

// mapping a dictionary of this kind could also guarantee unique keys
// (a case's name must be unique)
