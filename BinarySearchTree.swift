/*
    Binary search tree with search, insert, and delete
    3 April 2015
    Mike Yeung
*/

enum ChildType: Int {
    case Left, Right, Root
}

private class Node<T> {
    var value: T
    weak var parent: Node?
    var childType: ChildType
    var children: [Node?]
    init(value: T, parent: Node?, childType: ChildType) {
        self.value = value
        self.parent = parent
        self.childType = childType
        children = [Node?](count: 2, repeatedValue: nil)
    }
}

class BinarySearchTree<T: Comparable> {
    
    private var root: Node<T>?
    
    private func search(#value: T, node: Node<T>?) -> (found: Bool, node: Node<T>?) {
        if node == nil {
            return (false, nil)
        } else if value == node!.value {
            return (true, node)
        } else {
            var child = 0
            if value > node!.value {
                child = 1
            }
            if node!.children[child] == nil {
                return (false, node)
            } else {
                return search(value: value, node: node!.children[child])
            }
        }
    }
    
    // Returns whether value is found
    func search(value: T) -> Bool {
        return search(value: value, node: root).found
    }
    
    // If value doesn't exist, insert it
    func insert(value: T) {
        if root == nil {
            root = Node(value: value, parent: nil, childType: .Root)
        } else {
            let result = search(value: value, node: root)
            if !result.found {
                var child = 0
                if value > result.node!.value {
                    child = 1
                }
                result.node!.children[child] = Node(value: value, parent: result.node!, childType: ChildType(rawValue: child)!)
            }
        }
    }
    
    private func successor(node: Node<T>) -> Node<T> {
        assert(node.children[1] != nil, "successor() must be called on node with right child")
        var iter = node.children[1]!
        while iter.children[0] != nil {
            iter = iter.children[0]!
        }
        return iter
    }
    
    private func delete(node: Node<T>) {
        let children = node.children.filter{$0 != nil}
        if children.count == 0 {
            if node.childType == .Root {
                root = nil
            } else {
                node.parent!.children[node.childType.rawValue] = nil
            }
        } else if children.count == 1 {
            if node.childType == .Root {
                root = children[0]
                children[0]!.parent = nil
            } else {
                node.parent!.children[node.childType.rawValue] = children[0]
                children[0]!.parent = node.parent!
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
