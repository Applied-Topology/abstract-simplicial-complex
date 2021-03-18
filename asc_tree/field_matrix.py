import numpy as np

class Z2array(np.ndarray):
    """ class overloading a numpy array for addition
    """
    def __new__(cls, input_array):
        obj = np.asarray(input_array).view(cls)
        return obj % 2

    def __array_finalize__(self, obj):
        return None
    
    def __add__(self,x):
        return Z2array(np.array(self) + np.array(x))
    
    def __radd__(self,x):
        return Z2array(np.array(self) + np.array(x))

    def __array__(self):
        """ so that numpy's array() returns values
        """
        return self

if __name__ == "__main__":
    from asc_tree import asc_tree

    simplicial_complex = asc_tree.ASC_Tree()
    simplicial_complex.add_path(("Cow", "Rabbit"))
    simplicial_complex.add_path(("Cow", "Horse"))
    simplicial_complex.add_path(("Cow", "Dog"))
    simplicial_complex.add_path(("Rabbit", "Horse"))
    simplicial_complex.add_path(("Rabbit", "Dog"))
    simplicial_complex.add_path(("Horse", "Dog"))
    simplicial_complex.add_path(("Fish", "Dolphin"))
    simplicial_complex.add_path(("Fish", "Oyster"))
    simplicial_complex.add_path(("Dolphin", "Oyster"))
    simplicial_complex.add_path(("Broccoli", "Fern"))
    simplicial_complex.add_path(("Broccoli", "Onion"))
    simplicial_complex.add_path(("Broccoli", "Apple"))
    simplicial_complex.add_path(("Fern", "Onion"))
    simplicial_complex.add_path(("Fern", "Apple"))
    simplicial_complex.add_path(("Onion", "Apple"))
    simplicial_complex.add_path(("Cow", "Rabbit", "Horse"))
    simplicial_complex.add_path(("Cow", "Rabbit", "Dog"))
    simplicial_complex.add_path(("Cow", "Horse", "Dog"))
    simplicial_complex.add_path(("Rabbit", "Horse", "Dog"))
    simplicial_complex.add_path(("Fish", "Dolphin", "Oyster"))
    simplicial_complex.add_path(("Broccoli", "Fern", "Onion"))
    simplicial_complex.add_path(("Broccoli", "Fern", "Apple"))
    simplicial_complex.add_path(("Broccoli", "Onion", "Apple"))
    simplicial_complex.add_path(("Fern", "Onion", "Apple"))
    
    mat, rows, cols = simplicial_complex.get_boundary_matrix(3)
    
    print(np.linalg.matrix_rank(Z2array(mat))) # returns 9