"""
Codebase Genius - Multi-Agent Documentation System
Pure Jac implementation for automated codebase documentation
"""

import from byllm.lib { Model }
import from pathlib { Path }
import git;
import os;

glob llm = Model(model_name="gpt-4o-mini");

# ==============================================================================
# DATA OBJECTS
# ==============================================================================

obj RepoInfo {
    has url: str = "";
    has name: str = "";
    has local_path: str = "";
    has readme_summary: str = "";
    has files: list = [];
}
sem RepoInfo = "Repository information and metadata";

obj CodeFileInfo {
    has path: str = "";
    has language: str = "";
    has symbols: list = [];
}
sem CodeFileInfo = "Code file with extracted symbols";

obj Symbol {
    has name: str = "";
    has type: str = "";  # function, class, node, walker
    has file: str = "";
    has line: int = 0;
}
sem Symbol = "Code symbol (function, class, node, walker)";

obj DocOutput {
    has repo_name: str = "";
    has markdown: str = "";
    has output_path: str = "";
    has status: str = "";
}
sem DocOutput = "Generated documentation result";

# ==============================================================================
# LLM-BACKED FUNCTIONS
# ==============================================================================

def summarize_readme(content: str) -> str by llm(method="Reason");
def enhance_documentation(repo: RepoInfo, symbols: list) -> str by llm(method="Reason");

# ==============================================================================
# NODES FOR PIPELINE
# ==============================================================================

node RepoNode {
    has repo: RepoInfo = RepoInfo();
    has status: str = "pending";
    
    def clone_and_scan() {
        print(f"[RepoMapper] Cloning {self.repo.url}...");
        
        # Extract repo name
        repo_name = self.repo.url.rstrip("/").split("/")[-1].replace(".git", "");
        self.repo.name = repo_name;
        
        # Clone to tmp directory
        local_path = f"./tmp_repos/{repo_name}";
        self.repo.local_path = local_path;
        
        if not Path(local_path).exists() {
            git.Repo.clone_from(self.repo.url, local_path, depth=1);
            print(f"[RepoMapper] Cloned to {local_path}");
        } else {
            print(f"[RepoMapper] Repository already exists");
        }
        
        # Scan for code files
        p = Path(local_path);
        ignore_dirs = {".git", "__pycache__", "node_modules", "venv", ".venv", "dist", "build"};
        files = [];
        
        for file in p.rglob("*") {
            if file.is_file() and file.suffix in [".py", ".jac"] {
                # Check if in ignore directory
                in_ignore = any(part in ignore_dirs for part in file.parts);
                
                if not in_ignore {
                    rel_path = str(file.relative_to(p));
                    files.append(rel_path);
                }
            }
        }
        
        self.repo.files = files;
        print(f"[RepoMapper] Found {len(files)} code files");
        
        # Read README
        for readme_name in ["README.md", "readme.md", "README.rst", "README.txt"] {
            readme_path = p / readme_name;
            if readme_path.exists() {
                content = readme_path.read_text();
                # Take first paragraph or first 500 chars
                parts = content.split("\n\n");
                summary = parts[0] if len(parts) > 0 else content[:500];
                self.repo.readme_summary = summary;
                print(f"[RepoMapper] Found README");
                break;
            }
        }
        
        self.status = "mapped";
    }
}

node AnalysisNode {
    has file_info: CodeFileInfo = CodeFileInfo();
    has analyzed: bool = False;
    
    def analyze_file(repo_path: str) {
        print(f"[CodeAnalyzer] Analyzing {self.file_info.path}...");
        
        full_path = Path(repo_path) / self.file_info.path;
        if not full_path.exists() {
            return;
        }
        
        content = full_path.read_text();
        lines = content.split("\n");
        symbols = [];
        
        for i in range(len(lines)) {
            line = lines[i].strip();
            
            # Extract functions
            if line.startswith("def ") or line.startswith("can ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("(")[0];
                    sym = Symbol(name=name, type="function", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
            # Extract classes
            elif line.startswith("class ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("(")[0].split(":")[0].strip();
                    sym = Symbol(name=name, type="class", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
            # Extract nodes
            elif line.startswith("node ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    sym = Symbol(name=name, type="node", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
            # Extract walkers
            elif line.startswith("walker ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    sym = Symbol(name=name, type="walker", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
            # Extract edges
            elif line.startswith("edge ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip().rstrip(";");
                    sym = Symbol(name=name, type="edge", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
            # Extract objects
            elif line.startswith("obj ") {
                parts = line.split();
                if len(parts) > 1 {
                    name = parts[1].split("{")[0].strip();
                    sym = Symbol(name=name, type="obj", file=self.file_info.path, line=i+1);
                    symbols.append(sym);
                }
            }
        }
        
        self.file_info.symbols = symbols;
        self.analyzed = True;
        print(f"[CodeAnalyzer] Found {len(symbols)} symbols in {self.file_info.path}");
    }
}

node DocNode {
    has output: DocOutput = DocOutput();
    
    def generate_markdown(repo: RepoInfo, all_symbols: list) {
        print(f"[DocGenie] Generating documentation for {repo.name}...");
        
        # Build markdown using string concatenation
        md = "# " + repo.name + " Documentation\n\n";
        md = md + "Automated documentation\n\n";
        
        # Overview
        md = md + "## Overview\n\n";
        if repo.readme_summary {
            md = md + repo.readme_summary + "\n\n";
        } else {
            md = md + "Automated documentation for this codebase.\n\n";
        }
        
        # Repository Structure  
        md = md + "## Repository Structure\n\n";
        md = md + "Total Files: " + str(len(repo.files)) + "\n\n";
        md = md + "```\n";
        for file_path in repo.files[:20] {
            md = md + file_path + "\n";
        }
        if len(repo.files) > 20 {
            md = md + "... and " + str(len(repo.files) - 20) + " more files\n";
        }
        md = md + "```\n\n";
        
        # Components
        md = md + "## Code Components\n\n";
        
        # Group symbols
        file_symbols = {};
        for sym in all_symbols {
            if sym.file not in file_symbols {
                file_symbols[sym.file] = [];
            }
            file_symbols[sym.file].append(sym);
        }
        
        for file_path in sorted(file_symbols.keys()) {
            md = md + "### " + file_path + "\n\n";
            syms = file_symbols[file_path];
            
            for sym in syms {
                md = md + "- " + sym.name + " (" + sym.type + ") - Line " + str(sym.line) + "\n";
            }
            md = md + "\n";
        }
        
        # Diagram
        md = md + "## Architecture Diagram\n\n";
        md = md + "```mermaid\n";
        md = md + "classDiagram\n";
        
        for sym in all_symbols[:30] {
            if sym.type in ["class", "node", "walker", "obj"] {
                md = md + "    class " + sym.name + "\n";
            }
        }
        
        md = md + "```\n\n";
        
        # Installation
        md = md + "## Installation\n\n";
        md = md + "```bash\n";
        md = md + "git clone " + repo.url + "\n";
        md = md + "cd " + repo.name + "\n";
        md = md + "pip install -r requirements.txt\n";
        md = md + "```\n\n";
        
        # Save to file
        output_dir = Path("./outputs") / repo.name;
        output_dir.mkdir(parents=True, exist_ok=True);
        doc_path = output_dir / "documentation.md";
        doc_path.write_text(md);
        
        self.output.repo_name = repo.name;
        self.output.markdown = md;
        self.output.output_path = str(doc_path);
        self.output.status = "success";
        
        print(f"[DocGenie] Documentation saved to {doc_path}");
    }
}

# ==============================================================================
# WALKER: MAIN PIPELINE
# ==============================================================================

walker CodeGeniusPipeline {
    has repo_url: str;
    has repo_info: RepoInfo = RepoInfo();
    has all_symbols: list = [];
    has final_output: DocOutput = DocOutput();
    
    can start with `root entry {
        print("="*60);
        print("🧠 Codebase Genius - Multi-Agent Documentation System");
        print("="*60);
        print(f"Repository: {self.repo_url}");
        print("");
        
        # Create pipeline nodes
        repo_node = RepoNode();
        repo_node.repo.url = self.repo_url;
        
        # Step 1: Clone and map repository
        repo_node.clone_and_scan();
        self.repo_info = repo_node.repo;
        
        # Step 2: Analyze files - create analysis nodes
        analysis_nodes = [];
        for file_path in self.repo_info.files {
            analysis_node = AnalysisNode();
            analysis_node.file_info.path = file_path;
            analysis_node.file_info.language = "python" if file_path.endswith(".py") else "jac";
            analysis_node.analyze_file(self.repo_info.local_path);
            analysis_nodes.append(analysis_node);
            
            # Collect symbols
            for sym in analysis_node.file_info.symbols {
                self.all_symbols.append(sym);
            }
        }
        
        print(f"\n[Pipeline] Total symbols found: {len(self.all_symbols)}");
        
        # Step 3: Generate documentation
        doc_node = DocNode();
        doc_node.generate_markdown(self.repo_info, self.all_symbols);
        self.final_output = doc_node.output;
        
        print("\n" + "="*60);
        print("✅ Documentation Generation Complete!");
        print(f"📄 Output: {self.final_output.output_path}");
        print("="*60);
    }
}

# ==============================================================================
# API WALKER
# ==============================================================================

walker generate_docs {
    has repo_url: str;
    
    can execute with `root entry {
        print(f"[API] Generating docs for {self.repo_url}");
        
        # Spawn the pipeline
        pipeline = CodeGeniusPipeline(repo_url=self.repo_url) spawn root;
        
        # Return result
        report {
            "status": pipeline.final_output.status,
            "repo_name": pipeline.final_output.repo_name,
            "output_path": pipeline.final_output.output_path,
            "symbols_count": len(pipeline.all_symbols)
        };
    }
}

# ==============================================================================
# ENTRY POINT
# ==============================================================================

with entry {
    # Example usage - change this to your repository
    repo_url = "https://github.com/Brio97/RPG-level-generator";
    
    pipeline = CodeGeniusPipeline(repo_url=repo_url) spawn root;
}