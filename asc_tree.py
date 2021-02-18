import networkx as nx
from networkx.drawing.nx_agraph import write_dot, graphviz_layout
import matplotlib.pyplot as plt
from copy import deepcopy

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
                
            # add to root:
            if name not in self.root.children:
                self.root.children[name] = deepcopy(new_node)
                
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
    
    def get_edges(self):
        stack = []
        stack.append(self.root)
        
        visited = [stack[0]]
        
        edges = []
        while stack:
            cur_node = stack.pop()
            for child in cur_node.children.values():
                edges.append([cur_node, child])
                stack.append(child)
                visited.append(child)
        
        return visited, edges
    
    def build_networkx_graph(self, name='nx_test.png'):
        nodes, edges = self.get_edges()
        
        G = nx.DiGraph()
        
        G.add_nodes_from(
            [id(node) for node in nodes],
            data = [node.name for node in nodes]
        )
        
        G.add_edges_from(
            [(id(x), id(y)) for x,y in edges]
        )
        
        labels = {id(node): node.name for node in nodes}
        
        write_dot(G,'test.dot')

        plt.title('draw_networkx')
        pos =graphviz_layout(G, prog='dot')

        nx.draw(
            G, pos, with_labels=True, arrows=True,
            labels=labels, alpha= 0.5, font_size=5.7,
            node_size=420, node_color="#e6e6ff"
        )
        plt.savefig(name)

    
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