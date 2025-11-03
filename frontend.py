"""
Codebase Genius - Frontend
Simple Streamlit UI for documentation generation
"""

import streamlit as st
import requests
from pathlib import Path
import os

# Configuration
INSTANCE_URL = "http://localhost:8000"
TEST_EMAIL = "guest@mail.com"
TEST_PASSWORD = "guest"

def get_auth_token():
    """Logs in or registers a user and returns an auth token."""
    
    response = requests.post(
        f"{INSTANCE_URL}/user/login",
        json={"email": TEST_EMAIL, "password": TEST_PASSWORD}
    )

    if response.status_code != 200:
        # Try registering the user if login fails
        response = requests.post(
            f"{INSTANCE_URL}/user/register",
            json={
                "email": TEST_EMAIL,
                "password": TEST_PASSWORD
            }
        )
        
        if response.status_code == 200:
            # Now login again
            response = requests.post(
                f"{INSTANCE_URL}/user/login",
                json={"email": TEST_EMAIL, "password": TEST_PASSWORD}
            )
    
    if response.status_code == 200:
        return response.json().get("token", "")
    
    return ""

def bootstrap_frontend(token):
    st.set_page_config(
        page_title="Codebase Genius - AI Documentation",
        page_icon="🧠",
        layout="wide"
    )

    st.title("🧠 Codebase Genius")
    st.markdown("**AI-Powered Multi-Agent Code Documentation System**")

    # Initialize session state
    if "results" not in st.session_state:
        st.session_state.results = []
    if "loading" not in st.session_state:
        st.session_state.loading = False

    # Main input
    st.markdown("### 📁 Generate Documentation")
    
    col1, col2 = st.columns([3, 1])
    
    with col1:
        repo_url = st.text_input(
            "GitHub Repository URL:",
            placeholder="https://github.com/username/repository",
            help="Enter a public GitHub repository URL"
        )
    
    with col2:
        st.write("")
        generate_btn = st.button("🚀 Generate Docs")

    # Example repositories
    with st.expander("💡 Try These Examples"):
        if st.button("📦 Flask (Python Web Framework)"):
            st.session_state.example_url = "https://github.com/pallets/flask"
            st.rerun()
        if st.button("📦 Requests (HTTP Library)"):
            st.session_state.example_url = "https://github.com/psf/requests"
            st.rerun()
    
    # Use example URL if set
    if "example_url" in st.session_state:
        repo_url = st.session_state.example_url
        del st.session_state.example_url

    # Process button
    if generate_btn:
        if repo_url.strip():
            st.session_state.loading = True
            st.rerun()
        else:
            st.warning("⚠️ Please enter a repository URL!")

    # Loading state
    if st.session_state.loading:
        with st.spinner("🧠 AI Agents are working..."):
            progress_text = st.empty()
            progress_bar = st.progress(0)

            progress_text.text("📥 Stage 1/3: Cloning and mapping repository...")
            progress_bar.progress(33)

            response = requests.post(
                f"{INSTANCE_URL}/walker/generate_docs",
                json={"repo_url": repo_url},
                headers={"Authorization": f"Bearer {token}"}
            )

            progress_text.text("🔍 Stage 2/3: Analyzing code...")
            progress_bar.progress(66)

            if response.status_code == 200:
                result = response.json()
                reports = result.get("reports", [{}])

                if reports:
                    doc_result = reports[0]
                    progress_text.text("📝 Stage 3/3: Generating documentation...")
                    progress_bar.progress(100)

                    st.session_state.results.insert(0, doc_result)
                    st.session_state.loading = False
                    st.success("✅ Documentation generated successfully!")
                    st.balloons()
                    st.rerun()
            else:
                st.error(f"❌ Error: {response.text}")
                st.session_state.loading = False

    # Display results
    if st.session_state.results:
        st.markdown("---")
        st.markdown("## 📚 Generated Documentation")

        for i, result in enumerate(st.session_state.results):
            with st.expander(f"📄 {result.get('repo_name', 'Unknown')} - Result {i+1}", expanded=(i==0)):
                
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    st.metric("Status", "✅ Success" if result.get("status") == "success" else "❌ Failed")
                with col2:
                    st.metric("Symbols", result.get("symbols_count", 0))
                with col3:
                    st.metric("Files", len(result.get("files", [])))
                
                st.markdown("### 📁 Output")
                output_path = result.get("output_path")
                if output_path:
                    st.code(output_path)
                    
                    doc_path = Path(output_path)
                    if doc_path.exists():
                        content = doc_path.read_text()
                        st.markdown("### 📖 Preview")
                        st.markdown(content[:1000] + "\n\n... (truncated)")
                        
                        st.download_button(
                            "⬇️ Download Full Documentation",
                            data=content,
                            file_name=f"{result.get('repo_name')}_docs.md",
                            mime="text/markdown"
                        )
                    else:
                        st.warning("Preview file not found on disk.")

        if st.button("🗑️ Clear History"):
            st.session_state.results = []
            st.rerun()

    # Footer
    st.markdown("---")
    st.markdown("**Powered by:** 🗺️ RepoMapper • 🔍 CodeAnalyzer • 📝 DocGenie")

if __name__ == "__main__":
    try:
        auth_token = get_auth_token()
        if auth_token:
            bootstrap_frontend(auth_token)
        else:
            st.error("❌ Failed to authenticate. Please check server is running.")
    except requests.exceptions.RequestException as e:
        st.error(f"Could not connect to Jaclang server at {INSTANCE_URL}. Error: {e}")
    except Exception as e:
        st.error(f"An unexpected error occurred: {e}")