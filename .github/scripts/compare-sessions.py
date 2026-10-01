import re
import sys
from bs4 import BeautifulSoup

def extract_cells(html_path):
    with open(html_path, "r", encoding="utf-8") as f:
        soup = BeautifulSoup(f.read(), "html.parser")
    cells = soup.find_all("div", class_="cell")
    extracted = []
    for i, c in enumerate(cells):
        code_pre = c.find("div", class_="sourceCode")
        code = code_pre.get_text().strip() if code_pre else ""
        outputs = [o.get_text().strip() for o in c.find_all("div", class_="cell-output")]
        extracted.append({
            "index": i,
            "code": code,
            "first_line": code.split("\n")[0] if code else "No source",
            "output": "\n---\n".join(outputs)
        })
    return extracted

def compare_html(baseline_path, new_path):
    base_cells = extract_cells(baseline_path)
    new_cells = extract_cells(new_path)
    
    print(f"=== COMPARING SESSION 29: BASELINE vs R 4.6.1 RE-RENDER ===")
    print(f"Baseline cells: {len(base_cells)} | New cells: {len(new_cells)}\n")
    
    # 1. Compare Package Versions (Cell 32: sessionInfo)
    print("--- 1. Package & Environment Versions (sessionInfo) ---")
    base_info = base_cells[-1]["output"]
    new_info = new_cells[-1]["output"]
    
    def get_version(text, pkg):
        m = re.search(rf"\b{pkg}_([0-9\.\-]+)", text)
        return m.group(1) if m else "N/A"
    
    key_pkgs = ["lme4", "Matrix", "lmerTest", "DHARMa", "performance", "parameters", "see", 
                "influence.ME", "trouBBlme4SolveR", "dfoptim", "ordinal", "emmeans", "languageR"]
    
    print(f"{'Package':<20} {'Baseline':<15} {'New (R 4.6.1)':<15} {'Changed?'}")
    print("-" * 60)
    for p in key_pkgs:
        v1 = get_version(base_info, p)
        v2 = get_version(new_info, p)
        changed = "YES" if v1 != v2 else "No"
        print(f"{p:<20} {v1:<15} {v2:<15} {changed}")
    print()

    # 2. Compare Numerical Outputs across all cells
    print("--- 2. Cell-by-Cell Output Diff ---")
    diff_count = 0
    for i in range(min(len(base_cells), len(new_cells))):
        b_out = base_cells[i]["output"].strip()
        n_out = new_cells[i]["output"].strip()
        
        # normalize whitespace
        b_norm = re.sub(r"\s+", " ", b_out)
        n_norm = re.sub(r"\s+", " ", n_out)
        
        if b_norm != n_norm:
            diff_count += 1
            print(f"[Cell {i:02d}] {base_cells[i]['first_line'][:50]}")
            print(f"  -> Outputs differ!")
            # show short diff snippet
            b_sample = b_out[:120].replace("\n", " ")
            n_sample = n_out[:120].replace("\n", " ")
            print(f"     Baseline: {b_sample}...")
            print(f"     New:      {n_sample}...")
            print()
    
    if diff_count == 0:
        print("[OK] All computational outputs match exactly!")
    else:
        print(f"Summary: {diff_count} cell(s) had output differences.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python compare_sessions.py <baseline.html> <new.html>")
        sys.exit(1)
    compare_html(sys.argv[1], sys.argv[2])