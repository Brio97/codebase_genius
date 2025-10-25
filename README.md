# 🧠 Codebase Genius

**AI-Powered Multi-Agent Code Documentation System built in Jaclang**

Codebase Genius automatically analyzes source code repositories, maps their structure, and generates intelligent, human-readable documentation — all powered by **Jaclang** agents.

---

## 🚀 Overview

This project demonstrates how Jaclang can be used to build an **AI-powered multi-agent system** with a backend and frontend running natively in `.jac` files.

- 🤖 Multi-agent AI design (RepoMapper • CodeAnalyzer • DocGen)
- 🧠 Automatic Markdown documentation generation
- ⚙️ FastAPI-style backend (via Jac runtime)
- 🎨 Streamlit-powered frontend interface
- 💾 Local database persistence (no external DB required)

---

## 🧩 Architecture

| Component | Description |
|------------|--------------|
| **backend.jac** | Provides REST endpoints and orchestrates AI agents for repo analysis and documentation generation. |
| **frontend.jac** | Streamlit-based interface for interacting with the backend and visualizing generated documentation. |
| **LocalDB** | Used for persistence and caching when `DATABASE_HOST` is not available. |

---

## 🛠️ Setup Instructions

### 1️⃣ Environment Setup

```bash
# Create a virtual environment
python -m venv jac-env
source jac-env/bin/activate

# Install dependencies
pip install jaclang streamlit requests
```

### 2️⃣ Run the Backend

```bash
jac serve backend.jac
```

The backend will start on  
👉 `http://localhost:8000`

### 3️⃣ Run the Frontend

```bash
jac streamlit frontend.jac
```

The UI will be available on  
👉 `http://localhost:8501`

---

## 🧠 How It Works

1. User enters a GitHub repository URL in the frontend.  
2. Backend clones the repository locally.  
3. AI agents analyze source code (functions, classes, structure).  
4. Generated Markdown documentation is returned and displayed in the UI.  

---

## 🧾 Example Output

```markdown
# Auto-Generated Documentation

This is an AI-generated doc.

- Repository: flask
- Functions: 23
- Classes: 7
```

---

## 🧑‍💻 For Developers

- **Language:** Jaclang  
- **Frontend:** Streamlit  
- **Backend:** FastAPI (Jac runtime)  
- **AI Agents:** Custom multi-agent logic for code mapping and documentation

---

## ⚖️ License

MIT License © 2025 — Brio97
