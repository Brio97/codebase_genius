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
            
            if (line.startswith("def ") or line.startswith("can ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("(")[0];
                    symbols.append({"name": name, "type": "function", "file": file_path, "line": i+1});
                }
            }
            elif (line.startswith("class ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("(")[0].split(":")[0].strip();
                    symbols.append({"name": name, "type": "class", "file": file_path, "line": i+1});
                }
            }
            elif (line.startswith("node ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "node", "file": file_path, "line": i+1});
                }
            }
            elif (line.startswith("walker ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "walker", "file": file_path, "line": i+1});
                }
            }
            elif (line.startswith("edge ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("{")[0].strip().rstrip(";");
                    symbols.append({"name": name, "type": "edge", "file": file_path, "line": i+1});
                }
            }
            elif (line.startswith("obj ")) {
                parts = line.split();
                if (len(parts) > 1) {
                    name = parts[1].split("{")[0].strip();
                    symbols.append({"name": name, "type": "obj", "file": file_path, "line": i+1});
                }
            }
        }
        return symbols;
    }
}

obj FileTreeGenerator {
    def generate(root_path: str, ignore_dirs: set) -> str {
        tree_str = "";

        def build_tree(dir_path: Path, prefix: str = "") {
            nonlocal tree_str;

            dirs = [];
            files = [];
            for p in dir_path.iterdir() {
                if p.name not in ignore_dirs {
                    if p.is_dir() {
                        dirs.append(p);
                    } else {
                        files.append(p);
                    }
                }
            }

            # This manual bubble sort uses only basic Jaclang syntax to avoid compiler issues.
            def bubble_sort(lst: list) {
                n = len(lst);
                for i in range(n) {
                    for j in range(0, n-i-1) {
                        if lst[j].name.lower() > lst[j+1].name.lower() {
                            temp = lst[j];
                            lst[j] = lst[j+1];
                            lst[j+1] = temp;
                        }
                    }
                }
            }
            bubble_sort(dirs);
            bubble_sort(files);
            items = dirs + files;

            pointers = ["├── "] * (len(items) - 1) + ["└── "];

            for pair in zip(pointers, items) {
                pointer = pair[0];
                path = pair[1];
                tree_str += prefix + pointer + path.name + "\n";
                if path.is_dir() and path.name not in ignore_dirs {
                    extension = "│   " if pointer == "├── " else "    ";
                    build_tree(path, prefix=prefix + extension);
                }
            }
        }

        tree_str += f"{Path(root_path).name}/\n";
        build_tree(Path(root_path), "");
        return tree_str;
    }
}

obj ReadmeProcessor {
    def process(repo_path: str) -> str {
        for readme_name in ["README.md", "readme.md", "README.rst", "README.txt", "README"] {
            readme_path = Path(repo_path) / readme_name;
            if readme_path.exists() {
                content = readme_path.read_text(encoding='utf-8', errors='ignore');
                parts = content.split("\n\n");
                summary = parts[0] if len(parts) > 0 else content[:500];
                return summary;
            }
        }
        
        return "No README found";
    }
}