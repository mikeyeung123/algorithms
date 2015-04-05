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
    case Red, Black, DoubleBlack
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
    
    func sibling() -> Node? {
        return parent?.children![oppositeDirection(childType!).rawValue]
    }
    
    func switchColor() {
        assert(color != .DoubleBlack, "Cannot switch DoubleBlack")
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
        } else {
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
    
    private func successor(node: Node<T>) -> Node<T> {
        assert(node.children != nil && node.children![1].value != nil, "successor() must be called on node with right non-leaf child")
        var iter = node.children![1]
        while iter.children![0].value != nil {
            iter = iter.children![0]
        }
        return iter
    }
    
    private func resolveDoubleBlack(node: Node<T>) {
        if node.parent == nil {
            node.color = .Black
        } else if node.color == .DoubleBlack {
            let parent = node.parent!
            let sibling = node.sibling()!
            if sibling.color == .Black {
                let redChildren = sibling.children!.filter{$0.color == .Red}
                if redChildren.count > 0 {
                    let sameDirectionChildren = redChildren.filter{$0.childType == sibling.childType}
                    let differentDirectionChildren = redChildren.filter{$0.childType != sibling.childType}
                    if sameDirectionChildren.count == 1 {
                        rotate(parent, direction: node.childType!)
                        sameDirectionChildren[0].color = .Black
                        node.color = .Black
                    } else {
                        rotate(sibling, direction: sibling.childType!)
                        rotate(parent, direction: node.childType!)
                        differentDirectionChildren[0].color = .Black
                        node.color = .Black
                    }
                } else {
                    sibling.color = .Red
                    node.color = .Black
                    if parent.color == .Red {
                        parent.color = .Black
                    } else {
                        parent.color = .DoubleBlack
                        resolveDoubleBlack(parent)
                    }
                }
            } else {
                rotate(parent, direction: node.childType!)
                sibling.color = .Black
                node.color = .Black
                node.sibling()!.color = .Red
            }
        }
    }
    
    private func delete(node: Node<T>) {
        assert(node.value != nil, "Cannot delete dummy node")
        let children = node.children!.filter{$0.value != nil}
        if children.count == 0 {
            if node.parent == nil {
                root = nil
            } else if node.color == .Red {
                node.value = nil
                node.color = .Black
                node.children = nil
            } else {
                node.value = nil
                node.color = .DoubleBlack
                node.children = nil
                resolveDoubleBlack(node)
            }
        } else if children.count == 1 {
            assert(children[0].color == .Red, "If only child isn't red, violates red-black tree properties, probably from a bug in insert()")
            children[0].color == .Black
            children[0].parent = node.parent
            if node.parent == nil {
                root = children[0]
            } else {
                node.parent!.children![node.childType!.rawValue] = children[0]
            }
        } else {
            let s = successor(node)
            node.value = s.value
            delete(s)
        }
    }
    
    // If value exists, delete it
    func delete(value: T) {
        let result = search(value: value, node: root)
        if result.found {
            delete(result.node!)
        }
    }
}
