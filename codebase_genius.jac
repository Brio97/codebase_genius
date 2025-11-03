"""
Codebase Genius - Multi-Agent Documentation System
Main declarations
"""

import from byllm.lib { Model }
import from pathlib { Path }
import from tools { FileParser, ReadmeProcessor }
import git;
import os;

glob llm = Model(model_name="gpt-4o-mini");

# Semantic annotations
sem RepoInfo = "GitHub repository information and metadata";
sem CodeFileInfo = "Code file with extracted symbols";
sem Symbol = "Code symbol (function, class, node, walker)";
sem DocOutput = "Generated documentation result";

# Data objects
obj RepoInfo {
    has url: str = "";
    has name: str = "";
    has local_path: str = "";
    has readme_summary: str = "";
    has files: list = [];
}

obj CodeFileInfo {
    has path: str = "";
    has language: str = "";
    has symbols: list = [];
}

obj Symbol {
    has name: str = "";
    has type: str = "";
    has file: str = "";
    has line: int = 0;
}

obj DocOutput {
    has repo_name: str = "";
    has markdown: str = "";
    has output_path: str = "";
    has status: str = "";
}

# Authentication objects
obj User {
    has username: str = "";
    has password: str = "";
}

obj TokenResponse {
    has access_token: str = "";
    has token_type: str = "bearer";
}

# Nodes
node RepoMapper {
    has repo: RepoInfo = RepoInfo();
    has status: str = "pending";
    
    def clone_and_scan();
}

node CodeAnalyzer {
    has file_info: CodeFileInfo = CodeFileInfo();
    has analyzed: bool = False;
    
    def analyze_file(repo_path: str);
}

node DocGenie {
    has output: DocOutput = DocOutput();
    
    def generate_markdown(repo: RepoInfo, all_symbols: list);
}

# Walkers
walker CodeGenius {
    has repo_url: str;
    has repo_info: RepoInfo = RepoInfo();
    has all_symbols: list = [];
    has final_output: DocOutput = DocOutput();
    
    can orchestrate with `root entry;
}

walker generate_docs {
    has repo_url: str;
    has is_public: bool = True;  # Mark as public
    
    can execute with `root entry;
}

walker test_walker {
    can execute with `root entry {
        report {"status": "success", "message": "Walker is accessible"};
    }
}