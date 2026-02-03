#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to combine all Markdown files in docs/ folder into a single PDF.
"""

import os
import sys
from pathlib import Path
from datetime import datetime

# Fix Windows console encoding
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

try:
    import markdown
    from markdown.extensions import codehilite, tables, toc
    from weasyprint import HTML, CSS
except ImportError:
    print("Installing required packages...")
    os.system(f"{sys.executable} -m pip install markdown weasyprint markdown-extensions --quiet")
    import markdown
    from markdown.extensions import codehilite, tables, toc
    from weasyprint import HTML, CSS

def get_doc_order():
    """Return files in the correct reading order."""
    return [
        "GETTING-STARTED.md",
        "DOCUMENTATION-INDEX.md",
        "QUICK-START-GUIDE.md",
        "DEPLOYMENT-BLUEPRINT.md",
        "YAML-EXAMPLES.md",
        "ARCHITECTURE.md",
    ]

def read_markdown_file(filepath):
    """Read a markdown file and return its content."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return f"\n\n# Error reading {filepath}\n\n{e}\n\n"

def combine_markdown_files(docs_dir):
    """Combine all markdown files into one."""
    combined = []
    combined.append("# Kubernetes Deployment Blueprint - Komplette Dokumentation\n\n")
    combined.append(f"*Generiert am: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n\n")
    combined.append("---\n\n")
    
    doc_order = get_doc_order()
    
    for filename in doc_order:
        filepath = Path(docs_dir) / filename
        if filepath.exists():
            print(f"Adding: {filename}")
            content = read_markdown_file(filepath)
            combined.append(f"\n\n# {'='*80}\n")
            combined.append(f"# {filename}\n")
            combined.append(f"# {'='*80}\n\n")
            combined.append(content)
            combined.append("\n\n\\newpage\n\n")
        else:
            print(f"Warning: {filename} not found, skipping...")
    
    return "\n".join(combined)

def markdown_to_pdf(markdown_content, output_path):
    """Convert markdown to PDF."""
    print("Converting Markdown to HTML...")
    
    # Configure markdown extensions
    md = markdown.Markdown(
        extensions=[
            'codehilite',
            'tables',
            'toc',
            'fenced_code',
            'nl2br',
        ]
    )
    
    # Convert markdown to HTML
    html_content = md.convert(markdown_content)
    
    # Add CSS styling
    html_template = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            @page {{
                size: A4;
                margin: 2cm;
            }}
            body {{
                font-family: 'Segoe UI', Arial, sans-serif;
                line-height: 1.6;
                color: #333;
            }}
            h1 {{
                color: #2c3e50;
                border-bottom: 3px solid #3498db;
                padding-bottom: 10px;
                page-break-after: avoid;
            }}
            h2 {{
                color: #34495e;
                border-bottom: 2px solid #ecf0f1;
                padding-bottom: 5px;
                page-break-after: avoid;
            }}
            h3 {{
                color: #555;
                page-break-after: avoid;
            }}
            code {{
                background-color: #f4f4f4;
                padding: 2px 6px;
                border-radius: 3px;
                font-family: 'Consolas', 'Monaco', monospace;
                font-size: 0.9em;
            }}
            pre {{
                background-color: #f4f4f4;
                padding: 15px;
                border-radius: 5px;
                overflow-x: auto;
                page-break-inside: avoid;
            }}
            pre code {{
                background-color: transparent;
                padding: 0;
            }}
            table {{
                border-collapse: collapse;
                width: 100%;
                margin: 20px 0;
                page-break-inside: avoid;
            }}
            th, td {{
                border: 1px solid #ddd;
                padding: 12px;
                text-align: left;
            }}
            th {{
                background-color: #3498db;
                color: white;
            }}
            tr:nth-child(even) {{
                background-color: #f2f2f2;
            }}
            blockquote {{
                border-left: 4px solid #3498db;
                margin: 20px 0;
                padding-left: 20px;
                color: #666;
            }}
            .newpage {{
                page-break-before: always;
            }}
        </style>
    </head>
    <body>
        {html_content}
    </body>
    </html>
    """
    
    print("Converting HTML to PDF...")
    HTML(string=html_template).write_pdf(output_path)
    print(f"✅ PDF created: {output_path}")

def main():
    """Main function."""
    docs_dir = Path(__file__).parent
    output_pdf = docs_dir / "Kubernetes-Deployment-Blueprint.pdf"
    
    print("Combining all Markdown files...")
    combined_md = combine_markdown_files(docs_dir)
    
    print(f"\nCreating PDF: {output_pdf}")
    try:
        markdown_to_pdf(combined_md, output_pdf)
        print(f"\nDone! PDF saved to: {output_pdf}")
        print(f"File size: {output_pdf.stat().st_size / 1024 / 1024:.2f} MB")
    except Exception as e:
        print(f"\nError creating PDF: {e}")
        print("\nTrying alternative method...")
        # Fallback: Save as combined markdown
        combined_md_path = docs_dir / "Kubernetes-Deployment-Blueprint-Combined.md"
        with open(combined_md_path, 'w', encoding='utf-8') as f:
            f.write(combined_md)
        print(f"Saved combined Markdown to: {combined_md_path}")
        print("You can convert it to PDF using an online tool or pandoc:")
        print(f"  pandoc {combined_md_path} -o {output_pdf}")
        sys.exit(1)

if __name__ == "__main__":
    main()
