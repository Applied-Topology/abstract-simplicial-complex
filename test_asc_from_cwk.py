# from ast_tree.ast_tree import ASC_Tree
from asc_tree import asc_tree
    
def main():
    simplicial_complex = asc_tree.ASC_Tree()
    simplicial_complex.add_path(("Cow", "Rabbit"))
    simplicial_complex.add_path(("Cow", "Horse"))
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
    
    print(simplicial_complex.get_paths())


    
if __name__ == "__main__":
    main()