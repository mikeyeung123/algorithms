# Algorithms

My implementation of selected algorithms discussed in Tufts Comp 160 in Spring 2015.

---

## Binary Search Tree

**File:** BinarySearchTree.swift

**Last updated:** 3 April 2015

**Description:** Each node has at most two children. All elements in the left subtree of a node are smaller than it, and all elements in the right are bigger.

**Complexity:**

|          |Average     |Worst case|
|----------|------------|----------|
|**Space** |*O*(*n*)    |*O*(*n*)  |
|**Search**|*O*(log *n*)|*O*(*n*)  |
|**Insert**|*O*(log *n*)|*O*(*n*)  |
|**Delete**|*O*(log *n*)|*O*(*n*)  |

**Types:** Value types must conform to `Comparable` (`<` and `==` must be implemented). Most built-in numeric types like `Int` are comparable.

**Public properties:** None

**Public functions:**
- `search(value)` searches tree for value and returns whether it is found
- `insert(value)` searches for value and inserts it if it doesn’t exist
- `delete(value)` searches for value and deletes it if it exists

## Longest Common Subsequence

**File:** LongestCommonSubsequence.swift

**Last updated:** 8 April 2015

**Description:** An efficient algorithm using dynamic programming to find the longest common subsequence (LCS) in 2 sequences. LCSs do not have to be contiguous.

**Complexity:** *m* and *n* are lengths of first and second sequence:

|         |Worst case|
|---------|----------|
|**Space**|*O*(*mn*) |
|**Time** |*O*(*mn*) |

**Types:** Value types must conform to `Hashable` (`==` and calculated `hashValue` must be implemented). Most built-in types like `Int` and `String` are hashable.

**Public properties:** None

**Public functions:**
- `LCS(first, second)` calculates and returns all LCSs in an array

---

More to come!