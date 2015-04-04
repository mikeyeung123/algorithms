/*
    Red-black tree with search, insert, and delete
    4 April 2015
    Mike Yeung
*/

private enum Direction: Int {
    case Left, Right
}

private func oppositeDirection(direction: Direction) -> Direction {
    return Direction(rawValue: (direction.rawValue + 1) % 2)!
}

private enum Color: Int {
    case Red, Black
}

// Initializer handles adding dummy nodes
private class Node<T> {
    
    var value: T?
    var color: Color
    weak var parent: Node?
    var childType: Direction?
    var children: [Node]?
    
    init(value: T?, color: Color, parent: Node?, childType: Direction?) {
        assert(!(value == nil && color == .Red), "Dummy nodes must be black")
        assert((parent == nil) == (childType == nil), "If parent is nil, childType must be nil, and vice versa")
        self.value = value
        self.color = color
        self.parent = parent
        self.childType = childType
        if value != nil {
            children = [Node]()
            for direction in 0...1 {
                children!.append(Node(value: nil, color: .Black, parent: self, childType: Direction(rawValue: direction)!))
            }
        }
    }
    
    func switchColor() {
        color = Color(rawValue: (color.rawValue + 1) % 2)!
    }
}

class RedBlackTree<T: Comparable> {
    
    private var root: Node<T>?
    
    private func search(#value: T, node: Node<T>?) -> (found: Bool, node: Node<T>?) {
        if node == nil {
            return (false, nil)
        } else if node!.value == nil {
            return (false, node)
        } else if value == node!.value {
            return (true, node)
        } else {
            var child = 0
            if value > node!.value {
                child = 1
            }
            return search(value: value, node: node!.children![child])
        }
    }
    
    // Returns whether value is found
    func search(value: T) -> Bool {
        return search(value: value, node: root).found
    }
    
    private func rotate(node: Node<T>, direction: Direction) {
        assert(node.value != nil, "Cannot call rotate() on dummy node")
        let parent = node.parent
        let childType = node.childType
        let child = node.children![oppositeDirection(direction).rawValue]
        assert(child.value != nil, "If rotating left, right child must not be dummy node, and vice versa")
        let grandchild = child.children![direction.rawValue]
        node.children![oppositeDirection(direction).rawValue] = grandchild
        grandchild.parent = node
        grandchild.childType = oppositeDirection(grandchild.childType!)
        child.children![direction.rawValue] = node
        node.parent = child
        node.childType = oppositeDirection(direction)
        parent?.children![childType!.rawValue] = child
        child.parent = parent
        child.childType = childType
    }
    
    private func recolorUpwards(var node: Node<T>) {
        if node.parent == nil || node.parent!.color == .Black {
            root!.color == .Black
            return
        }
        var parent = node.parent!
        let grandparent = parent.parent!
        let uncle = grandparent.children![oppositeDirection(parent.childType!).rawValue]
        if uncle.color == .Red {
            parent.switchColor()
            grandparent.switchColor()
            uncle.switchColor()
            recolorUpwards(grandparent)
        } else {
            if node.childType == oppositeDirection(parent.childType!) {
                rotate(parent, direction: parent.childType!)
                swap(&node, &parent)
            }
            rotate(grandparent, direction: oppositeDirection(parent.childType!))
            grandparent.switchColor()
            parent.switchColor()
        }
    }
    
    // If value doesn't exist, insert it
    func insert(value: T) {
        if root == nil {
            root = Node(value: value, color: .Black, parent: nil, childType: nil)
        } else {
            let result = search(value: value, node: root)
            if !result.found {
                let toInsert = Node(value: value, color: .Red, parent: result.node!.parent, childType: result.node!.childType)
                result.node!.parent!.children![result.node!.childType!.rawValue] = toInsert
                recolorUpwards(toInsert)
            }
        }
    }
}
