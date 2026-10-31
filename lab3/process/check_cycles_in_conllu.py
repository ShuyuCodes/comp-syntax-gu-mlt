# check_cycles_in_conllu.py
from collections import defaultdict

def read_conllu(file_path):
    with open(file_path, encoding="utf-8") as f:
        content = f.read().strip()
    sentences = content.split("\n\n")
    parsed_sentences = []
    for sent in sentences:
        tokens = []
        for line in sent.splitlines():
            if line.startswith("#") or line.strip() == "":
                continue
            parts = line.split("\t")
            if "-" in parts[0] or "." in parts[0]:
                continue  # skip multiword or empty nodes
            tokens.append((int(parts[0]), int(parts[6])))  # ID, HEAD
        parsed_sentences.append(tokens)
    return parsed_sentences

def has_cycle(tokens):
    graph = defaultdict(list)
    for child, head in tokens:
        if head != 0:  # root node
            graph[head].append(child)

    visited = set()
    def dfs(node, ancestors):
        if node in ancestors:
            return True  # cycle detected
        ancestors.add(node)
        for child in graph.get(node, []):
            if dfs(child, ancestors):
                return True
        ancestors.remove(node)
        return False

    for node, _ in tokens:
        if dfs(node, set()):
            return True
    return False

# ==== 使用 ====
if __name__ == "__main__":
    path = "se-source-std.conllu"  # 替换成你的路径
    sentences = read_conllu(path)
    for i, sent in enumerate(sentences):
        if has_cycle(sent):
            print(f"❌ 第 {i+1} 句有循环依存结构！")
    print("✅ 检查完毕")
