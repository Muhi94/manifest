#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Simple script to combine all Markdown files and convert to PDF.
Uses markdown-pdf library (simpler than weasyprint on Windows).
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
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                combined.append(f"\n\n# {'='*80}\n")
                combined.append(f"# {filename}\n")
                combined.append(f"# {'='*80}\n\n")
                combined.append(content)
                combined.append("\n\n\\newpage\n\n")
            except Exception as e:
                print(f"Error reading {filename}: {e}")
        else:
            print(f"Warning: {filename} not found, skipping...")
    
    return "\n".join(combined)

def main():
    """Main function."""
    docs_dir = Path(__file__).parent
    output_pdf = docs_dir / "Kubernetes-Deployment-Blueprint.pdf"
    combined_md = docs_dir / "Kubernetes-Deployment-Blueprint-Combined.md"
    
    print("Combining all Markdown files...")
    combined_content = combine_markdown_files(docs_dir)
    
    # Save combined markdown first
    print(f"\nSaving combined Markdown: {combined_md}")
    with open(combined_md, 'w', encoding='utf-8') as f:
        f.write(combined_content)
    
    # Try to convert to PDF using markdown-pdf
    print(f"\nAttempting to convert to PDF...")
    
    try:
        import markdown_pdf
        print("Using markdown-pdf library...")
        markdown_pdf.convert(combined_md, output_pdf)
        
        if output_pdf.exists():
            size_mb = output_pdf.stat().st_size / 1024 / 1024
            print(f"\nPDF created successfully!")
            print(f"Location: {output_pdf}")
            print(f"Size: {size_mb:.2f} MB")
        else:
            raise Exception("PDF file was not created")
            
    except ImportError:
        print("\nmarkdown-pdf not installed.")
        print("Installing markdown-pdf...")
        os.system(f"{sys.executable} -m pip install markdown-pdf --quiet")
        try:
            import markdown_pdf
            markdown_pdf.convert(combined_md, output_pdf)
            if output_pdf.exists():
                size_mb = output_pdf.stat().st_size / 1024 / 1024
                print(f"\nPDF created successfully!")
                print(f"Location: {output_pdf}")
                print(f"Size: {size_mb:.2f} MB")
            else:
                raise Exception("PDF file was not created")
        except Exception as e:
            print(f"\nError: {e}")
            print("\nAlternative options:")
            print("1. Install pandoc: https://pandoc.org/installing.html")
            print(f"   Then run: pandoc {combined_md} -o {output_pdf}")
            print("2. Use online converter: https://www.markdowntopdf.com/")
            print("3. Use VS Code extension: 'Markdown PDF'")
            print(f"\nCombined Markdown file ready: {combined_md}")
    except Exception as e:
        print(f"\nError creating PDF: {e}")
        print("\nAlternative options:")
        print("1. Install pandoc: https://pandoc.org/installing.html")
        print(f"   Then run: pandoc {combined_md} -o {output_pdf}")
        print("2. Use online converter: https://www.markdowntopdf.com/")
        print("3. Use VS Code extension: 'Markdown PDF'")
        print(f"\nCombined Markdown file ready: {combined_md}")

if __name__ == "__main__":
    main()
