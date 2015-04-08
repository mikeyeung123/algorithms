/*
    Algorithm to find longest common (non-)contiguous subsequence
    7 April 2015
    Mike Yeung
*/

private typealias Result = (length: Int, match: Bool)

// Arrays of results are hashed so inserting prevents duplicates

private func ==<T>(lhs: HashableArray<T>, rhs: HashableArray<T>) -> Bool {
    return lhs.array == rhs.array
}

private class HashableArray<T: Hashable>: Hashable {
    var array: [T]
    init(array: [T]) {
        self.array = array
    }
    var hashValue: Int {
        return array.reduce(0) {$0.0 ^ $1.hashValue}
    }
}

private class LCSs<T: Hashable> {
    var sequences = [(HashableArray<T>): Void]()
}

// Returns all matches with the same length as the bottom right elements
private func levelMatches(results: [[Result]], right: Int, bottom: Int) -> [(Int, Int)] {
    
    let length = results[right][bottom].length
    var i = right
    var j = bottom
    var left: Result
    var above: Result
    var matches = [(Int, Int)]()
    
    if results[i][j].match {
        matches.append((i, j))
    }
    
    while i > 0 {
        left = results[i - 1][j]
        if left.length < length {
            break
        }
        i--
        if left.match {
            matches.append((i, j))
        }
    }
    
    while true {
        while j > 0 {
            above = results[i][j - 1]
            if above.length < length {
                break
            }
            j--
            if above.match {
                matches.append((i, j))
            }
        }
        if i >= right {
            break
        }
        i++
        if results[i][j].match {
            matches.append((i, j))
        }
    }
    
    return matches
}

// Recursively traces LCS from bottom right and adds to sequences at end
private func trace<T: Equatable>(a1: [T], results: [[Result]], i: Int, j: Int, var sequenceSoFar: [T], sequences: LCSs<T>) {
    sequenceSoFar.append(a1[i - 1])
    if results[i - 1][j - 1].length == 0 {
        sequences.sequences[HashableArray(array: sequenceSoFar)] = ()
    } else {
        for (x, y) in levelMatches(results, i - 1, j - 1) {
            trace(a1, results, x, y, sequenceSoFar, sequences)
        }
    }
}

func LCS<T: Hashable>(a1: [T], a2: [T]) -> [[T]] {
    
    assert(a1.count > 0 && a2.count > 0, "Sequences must have length > 0")
    
    var results = [[Result]](count: a1.count + 1,
        repeatedValue: [Result](count: a2.count + 1,
            repeatedValue: (0, false)))
    
    for i in 1 ... a1.count {
        for j in 1 ... a2.count {
            if a1[i - 1] == a2[j - 1] {
                results[i][j] = (results[i - 1][j - 1].length + 1, true)
            } else {
                results[i][j] = (max(results[i - 1][j].length, results[i][j - 1].length), false)
            }
        }
    }
    
    let sequences = LCSs<T>()
    for (x, y) in levelMatches(results, a1.count, a2.count) {
        trace(a1, results, x, y, [T](), sequences)
    }
    
    return Array(sequences.sequences.keys).map{$0.array.reverse()}
}
