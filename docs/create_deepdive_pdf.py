#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Create PDF from Kubernetes Parameters Deep Dive document.
"""

import os
import sys
import subprocess
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
except ImportError:
    print("Installing markdown...")
    os.system(f"{sys.executable} -m pip install markdown --quiet")
    import markdown
    from markdown.extensions import codehilite, tables, toc

def read_markdown_file(filepath):
    """Read a markdown file and return its content."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return f"\n\n# Error reading {filepath}\n\n{e}\n\n"

def markdown_to_html(markdown_content):
    """Convert markdown to HTML."""
    md = markdown.Markdown(
        extensions=[
            'codehilite',
            'tables',
            'toc',
            'fenced_code',
            'nl2br',
        ]
    )
    
    html_content = md.convert(markdown_content)
    
    html_template = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        @media print {{
            @page {{
                size: A4;
                margin: 2cm;
            }}
        }}
        body {{
            font-family: 'Segoe UI', Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
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
            margin-top: 30px;
            page-break-after: avoid;
        }}
        h3 {{
            color: #555;
            margin-top: 20px;
            page-break-after: avoid;
        }}
        h4 {{
            color: #666;
            margin-top: 15px;
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
            font-weight: bold;
        }}
        tr:nth-child(even) {{
            background-color: #f2f2f2;
        }}
        blockquote {{
            border-left: 4px solid #3498db;
            margin: 20px 0;
            padding-left: 20px;
            color: #666;
            font-style: italic;
        }}
        .newpage {{
            page-break-before: always;
        }}
        ul, ol {{
            margin: 10px 0;
            padding-left: 30px;
        }}
        li {{
            margin: 5px 0;
        }}
    </style>
</head>
<body>
    {html_content}
</body>
</html>"""
    
    return html_template

def find_chrome():
    """Find Chrome or Edge executable."""
    possible_paths = [
        r"C:\Program Files\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
        r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
        r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    ]
    
    for path in possible_paths:
        if os.path.exists(path):
            return path
    return None

def html_to_pdf(html_path, pdf_path, chrome_path):
    """Convert HTML to PDF using Chrome/Edge."""
    cmd = [
        chrome_path,
        '--headless',
        '--disable-gpu',
        '--print-to-pdf=' + str(pdf_path),
        'file:///' + str(html_path).replace('\\', '/')
    ]
    
    print(f"Converting HTML to PDF using {os.path.basename(chrome_path)}...")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0 and pdf_path.exists():
        return True
    else:
        print(f"Error: {result.stderr}")
        return False

def main():
    """Main function."""
    docs_dir = Path(__file__).parent
    input_md = docs_dir / "KUBERNETES-PARAMETERS-DEEP-DIVE.md"
    output_pdf = docs_dir / "Kubernetes-Parameters-Deep-Dive.pdf"
    output_html = docs_dir / "Kubernetes-Parameters-Deep-Dive.html"
    
    if not input_md.exists():
        print(f"Error: {input_md} not found!")
        sys.exit(1)
    
    print(f"Reading: {input_md}")
    markdown_content = read_markdown_file(input_md)
    
    # Convert to HTML
    print("Converting to HTML...")
    html_content = markdown_to_html(markdown_content)
    with open(output_html, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"HTML saved: {output_html}")
    
    # Try to convert to PDF using Chrome/Edge
    chrome_path = find_chrome()
    if chrome_path:
        if html_to_pdf(output_html, output_pdf, chrome_path):
            size_mb = output_pdf.stat().st_size / 1024 / 1024
            print(f"\nPDF created successfully!")
            print(f"Location: {output_pdf}")
            print(f"Size: {size_mb:.2f} MB")
        else:
            print(f"\nPDF conversion failed.")
            print(f"HTML file ready: {output_html}")
            print("You can open it in a browser and print to PDF manually.")
    else:
        print("\nChrome/Edge not found.")
        print(f"HTML file ready: {output_html}")
        print("You can:")
        print("1. Open the HTML file in a browser")
        print("2. Press CTRL+P (Print)")
        print("3. Choose 'Save as PDF' as destination")

if __name__ == "__main__":
    main()
