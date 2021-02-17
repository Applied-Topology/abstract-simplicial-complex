class Node:
    
    def __init__(self, name, children=dict()):
        self.name = name
        self.children = children
        
    def __eq__(self, other):
        if isinstance(other, Node):
            return self.name == other.name
        return False
    
    def __repr__(self):
        return f"{self.name} : {self.children}"

class ASC_Tree:
    
    def __init__(self,):
        self.root = Node("ROOT", dict())
        self.path_cache = []
    
    def add_path(self, face):
        """
        we encode faces as unique paths in a tree. 
        Note for this to be possible there are duplicate
        nodes in the tree and potentially duplicate subtrees
        """
        
        cur_parent = self.root
        
        for name in face:
            
            if name not in cur_parent.children:
                new_node = Node(name, dict())
                cur_parent.children[name] = new_node
            else:
                new_node = cur_parent.children[name] 
            
            cur_parent = new_node
    
    def search(self, cur_node, visited =[]):

        if cur_node.name != "ROOT": visited.append(cur_node)
        for node in cur_node.children.values():
            if node not in visited:
                self.search( node, visited.copy())
        if visited: self.path_cache.append(visited)
    
    def get_paths(self):
            
        self.search(self.root)
        path_list = [
            list(map(lambda x:x.name, x)) for x in self.path_cache
        ]
        self.path_cache = []
        return path_list

    
if __name__ == "__main__":
    simplicial_complex = ASC_Tree()
    
    vertices = list((Node(name = "Cow"),
                     Node(name = "Rabbit"),
                     Node(name = "Horse"),
                     Node(name = "Dog")))

    simplicial_complex.add_path(("Cow", "Rabbit"))
    simplicial_complex.add_path(("Cow", "Horse"))
    simplicial_complex.add_path(("Rabbit", "Horse"))
    simplicial_complex.add_path(("Horse", "Rabbit"))

    simplicial_complex.add_path(("Cow", "Rabbit", "Horse"))