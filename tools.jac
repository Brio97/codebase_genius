"""
Codebase Genius - Utility Tools
"""

import from pathlib { Path }

obj FileParser {
    def extract_symbols(content: str, file_path: str) -> list {
        lines = content.split("\n");
        symbols = [];
        
        for i in range(len(lines)) {
            line = lines[i].strip();
            
            if line.startswith("def ") or line.startswith("can ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("(")[0];
                    symbols.append({"name": name, "type": "function", "file": file_path, "line": i+1});
                }
            }
            elif line.startswith("class ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("(")[0].split(":")[0].strip();
                    symbols.append({"name": name, "type": "class", "file": file_path, "line": i+1});
                }
            }
            elif line.startswith("node ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "node", "file": file_path, "line": i+1});
                }
            }
            elif line.startswith("walker ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "walker", "file": file_path, "line": i+1});
                }
            }
            elif line.startswith("edge ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip().rstrip(";");
                    symbols.append({"name": name, "type": "edge", "file": file_path, "line": i+1});
                }
            }
            elif line.startswith("obj ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "obj", "file": file_path, "line": i+1});
                }
            }
        }
        
        return symbols;
    }
}

obj ReadmeProcessor {
    def process(repo_path: str) -> str {
        for readme_name in ["README.md", "readme.md", "README.rst", "README.txt", "README"] {
            readme_path = repo_path + "/" + readme_name;
            p = Path(readme_path);
            if p.exists() {
                content = p.read_text();
                parts = content.split("\n\n");
                summary = parts[0] if len(parts) > 0 else content[:500];
                return summary;
            }
        }
        
        return "No README found";
    }
}