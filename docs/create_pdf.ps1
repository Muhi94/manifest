# PowerShell Script to combine all Markdown files into PDF
# Requires: pandoc (or will create combined markdown file)

$ErrorActionPreference = "Stop"
$docsDir = $PSScriptRoot
$outputPdf = Join-Path $docsDir "Kubernetes-Deployment-Blueprint.pdf"
$combinedMd = Join-Path $docsDir "Kubernetes-Deployment-Blueprint-Combined.md"

# Define file order
$files = @(
    "GETTING-STARTED.md",
    "DOCUMENTATION-INDEX.md",
    "QUICK-START-GUIDE.md",
    "DEPLOYMENT-BLUEPRINT.md",
    "YAML-EXAMPLES.md",
    "ARCHITECTURE.md"
)

Write-Host "Combining all Markdown files..." -ForegroundColor Cyan

# Create combined markdown
$combined = @"
# Kubernetes Deployment Blueprint - Komplette Dokumentation

*Generiert am: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')*

---

"@

foreach ($file in $files) {
    $filePath = Join-Path $docsDir $file
    if (Test-Path $filePath) {
        Write-Host "Adding: $file" -ForegroundColor Green
        $content = Get-Content $filePath -Raw -Encoding UTF8
        $combined += "`n`n# ================================================================================`n"
        $combined += "# $file`n"
        $combined += "# ================================================================================`n`n"
        $combined += $content
        $combined += "`n`n\\newpage`n`n"
    } else {
        Write-Host "Warning: $file not found, skipping..." -ForegroundColor Yellow
    }
}

# Save combined markdown
$combined | Out-File -FilePath $combinedMd -Encoding UTF8 -NoNewline
Write-Host "`nCombined Markdown saved to: $combinedMd" -ForegroundColor Green

# Try to convert to PDF
$pandocAvailable = Get-Command pandoc -ErrorAction SilentlyContinue

if ($pandocAvailable) {
    Write-Host "`nConverting to PDF using pandoc..." -ForegroundColor Cyan
    try {
        pandoc $combinedMd `
            -o $outputPdf `
            --pdf-engine=wkhtmltopdf `
            --toc `
            --toc-depth=3 `
            --highlight-style=tango `
            -V geometry:margin=2cm `
            -V fontsize=11pt `
            -V documentclass=article
        
        if (Test-Path $outputPdf) {
            $fileSize = (Get-Item $outputPdf).Length / 1MB
            Write-Host "`nPDF created successfully!" -ForegroundColor Green
            Write-Host "Location: $outputPdf" -ForegroundColor Green
            Write-Host "Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
        } else {
            Write-Host "`nPDF creation failed." -ForegroundColor Yellow
            ShowAlternativeMethods
        }
    } catch {
        Write-Host "`nError with pandoc: $_" -ForegroundColor Red
        ShowAlternativeMethods
    }
} else {
    Write-Host "`npandoc not found." -ForegroundColor Yellow
    ShowAlternativeMethods
}

function ShowAlternativeMethods {
    Write-Host "`nAlternative PDF conversion methods:" -ForegroundColor Cyan
    Write-Host "1. Install pandoc: https://pandoc.org/installing.html" -ForegroundColor Yellow
    Write-Host "   Then run: pandoc $combinedMd -o $outputPdf" -ForegroundColor Gray
    Write-Host "2. Use online converter: https://www.markdowntopdf.com/" -ForegroundColor Yellow
    Write-Host "3. Use VS Code extension: 'Markdown PDF'" -ForegroundColor Yellow
    Write-Host "4. Use Python script (if markdown-pdf installed):" -ForegroundColor Yellow
    Write-Host "   pip install markdown-pdf" -ForegroundColor Gray
    Write-Host "   python create_pdf_simple.py" -ForegroundColor Gray
    Write-Host "`nCombined Markdown file ready: $combinedMd" -ForegroundColor Green
    Write-Host "You can convert it manually using one of the methods above." -ForegroundColor Green
}
