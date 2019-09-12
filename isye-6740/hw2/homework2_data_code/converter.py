
with open("polblogs.gml", "r") as f, \
     open("nodes.txt", "w") as fn, \
     open("edges.txt", "w") as fe:
    lines = list(f)
    i = 0
    while i < len(lines):
        if "node" in lines[i]:
            id    = lines[i+1].strip("\n").split(" ")[5]
            label = lines[i+2].strip("\n").split(" ")[5]
            value = lines[i+3].strip("\n").split(" ")[5]
            sourc = lines[i+4].strip("\n").split(" ")[5]
            i    += 6 
            fn.write("\t".join([id, label, value, sourc]) + "\n")
        elif "edge" in lines[i]:
            src   = lines[i+1].strip("\n").split(" ")[5]
            trg   = lines[i+2].strip("\n").split(" ")[5]
            i    += 4
            fe.write("\t".join([src, trg]) + "\n")
        else:
            i += 1