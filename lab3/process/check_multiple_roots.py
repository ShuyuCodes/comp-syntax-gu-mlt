def check_multiple_roots(conllu_path):
    with open(conllu_path, encoding="utf-8") as f:
        sentence = []
        sent_id = ""
        lineno = 0
        for line in f:
            line = line.strip()
            if line.startswith("# sent_id"):
                sent_id = line.split("=")[-1].strip()
            if line == "":
                roots = [tok for tok in sentence if len(tok) > 6 and tok[6] == "0"]
                if len(roots) > 1:
                    print(f"❌ 多个root出现在句子: {sent_id or '未知ID'}，共 {len(roots)} 个 root")
                sentence = []
            elif not line.startswith("#"):
                parts = line.split("\t")
                sentence.append(parts)
            lineno += 1
    print("✅ 检查完毕。")

# 跑起来：
check_multiple_roots("se-source-std.conllu")