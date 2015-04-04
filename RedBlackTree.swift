/*
    Red-black tree with search, insert, and delete. Requires BinarySearchTree.swift in the same target.
    3 April 2015
    Mike Yeung
*/

private enum Color {
    case Red, Black
}

private enum ChildType: Int {
    case Left, Right, Root
}

private class Node<T> {
    var value: T?
    var color: Color
    weak var parent: Node?
    var childType: ChildType
    var children: [Node]
    init(value: T?, color: Color, parent: Node?, childType: ChildType) {
        assert(!(value == nil && color == .Red), "Dummy nodes must be black")
        self.value = value
        self.color = color
        self.parent = parent
        self.childType = childType
        children = [Node]()
        for child in 0...1 {
            children.append(Node(value: nil, color: .Black, parent: self, childType: ChildType(rawValue: child)!))
        }
    }
}

