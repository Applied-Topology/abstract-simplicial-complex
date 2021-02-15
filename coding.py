from pprint import pprint

def main():
    vertices = ['Cow', 'Rabbit', 'Horse', 'Dog', 'Fish', 'Dolphin', 'Oyster', 'Broccoli', 'Fern', 'Onion', 'Apple']
    edges_a = [{'Cow', 'Rabbit'}, {'Cow', 'Horse'}, {'Cow', 'Dog'}, {'Rabbit', 'Horse'}, {'Rabbit', 'Dog'}, {'Horse', 'Dog'}, {'Fish', 'Dolphin'}, {'Fish', 'Oyster'}, {'Dolphin', 'Oyster'}, {'Broccoli', 'Fern'}, {'Broccoli', 'Onion'}, {'Broccoli', 'Apple'}, {'Fern', 'Onion'}, {'Fern', 'Apple'}, {'Onion', 'Apple'}, {'Cow', 'Rabbit', 'Horse'}, {'Cow', 'Rabbit', 'Dog'}, {'Cow', 'Horse', 'Dog'}, {'Rabbit', 'Horse', 'Dog'}, {'Fish', 'Dolphin', 'Oyster'}, {'Broccoli', 'Fern', 'Onion'}, {'Broccoli', 'Fern', 'Apple'}, {'Broccoli', 'Onion', 'Apple'}, {'Fern', 'Onion', 'Apple'}]
    edges_b = [{'Cow','Rabbit'},{'Cow','Fish'},{'Cow','Oyster'},{'Cow','Oyster'},{'Cow','Broccoli'},{'Cow','Onion'},{'Cow','Apple'},{'Rabbit','Fish'},{'Rabbit','Oyster'},{'Rabbit','Broccoli'},{'Rabbit','Onion'},{'Rabbit','Apple'},{'Fish','Oyster'},{'Fish','Broccoli'},{'Fish','Onion'},{'Fish','Apple'},{'Oyster','Broccoli'},{'Oyster','Onion'},{'Oyster','Apple'},{'Broccoli','Onion'},{'Broccoli','Apple'},{'Onion','Apple'},{'Horse','Dog'},{'Horse','Dolphin'},{'Horse','Fern'},{'Dog','Dolphin'},{'Dog','Fern'},{'Dolphin','Fern'},{'Cow','Broccoli','Apple'},{'Cow','Onion','Apple'},{'Rabbit','Broccoli','Apple'},{'Rabbit','Onion','Apple'},{'Fish','Broccoli','Apple'},{'Fish','Onion','Apple'},{'Oyster','Broccoli','Apple'},{'Oyster','Onion','Apple'}]
    adjacency_list_a = dict(zip(vertices, [[] for _ in range(len(vertices))]))
    adjacency_list_b = dict(zip(vertices, [[] for _ in range(len(vertices))]))

    for e in edges_a:
        for vtx in e:
            adjacency_list_a[vtx].append(e)
    for e in edges_b:
        for vtx in e:
            adjacency_list_b[vtx].append(e)
    pprint(adjacency_list_a)


if __name__ == "__main__":
    main()


