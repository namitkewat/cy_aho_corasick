import cy_aho_corasick as cy_aho

# print(dir(cyAhoCorasick))

t = cy_aho.Trie(remove_overlaps=True)
t.insert(b"sugar")
print(t.parse_text(b"sugarcane sugarcane sugar canesugar"))
print(t.parse_text_values(b"sugarcane sugarcane sugar canesugar"))
