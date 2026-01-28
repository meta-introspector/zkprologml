# HuggingFace Space for zkPrologML llm.txt

import gradio as gr
import requests

def get_llm_txt():
    """Get full llm.txt content"""
    # In production, this would fetch from the dataset
    # https://huggingface.co/datasets/introspector/llm.txt
    with open('generated/llm.txt', 'r') as f:
        return f.read()

def get_chunk(chunk_id):
    """Get specific chunk"""
    try:
        with open(f'generated/llm_chunk_{chunk_id}.txt', 'r') as f:
            return f.read()
    except:
        return f"Chunk {chunk_id} not found"

def list_chunks():
    """List all available chunks"""
    import os
    chunks = [f for f in os.listdir('generated') if f.startswith('llm_chunk')]
    return "\n".join(sorted(chunks))

# Gradio interface
with gr.Blocks(title="zkPrologML - LLM.txt for NotebookLM") as demo:
    gr.Markdown("# zkPrologML - LLM.txt Generator")
    gr.Markdown("> Zero-Knowledge Prolog Meta-Language documentation for NotebookLM")
    
    with gr.Tab("Full Content"):
        full_btn = gr.Button("Get llm.txt")
        full_output = gr.Textbox(label="Content", lines=20)
        full_btn.click(get_llm_txt, outputs=full_output)
    
    with gr.Tab("Chunks"):
        chunk_id = gr.Number(label="Chunk ID", value=0)
        chunk_btn = gr.Button("Get Chunk")
        chunk_output = gr.Textbox(label="Chunk Content", lines=20)
        chunk_btn.click(get_chunk, inputs=chunk_id, outputs=chunk_output)
    
    with gr.Tab("List"):
        list_btn = gr.Button("List All Chunks")
        list_output = gr.Textbox(label="Available Chunks", lines=10)
        list_btn.click(list_chunks, outputs=list_output)
    
    gr.Markdown("""
    ## Usage
    
    1. **Full Content**: Get complete llm.txt for NotebookLM
    2. **Chunks**: Get individual 8KB chunks
    3. **List**: See all available chunks
    
    ## Integration
    
    ```python
    # Download for NotebookLM
    import requests
    content = requests.get('https://huggingface.co/spaces/introspector/meta-meme/llm.txt').text
    ```
    
    ## Dataset
    
    Chunks stored at: https://huggingface.co/datasets/introspector/llm.txt
    """)

if __name__ == "__main__":
    demo.launch()
