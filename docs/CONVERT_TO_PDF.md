# 📄 PDF-Erstellung - Anleitung

Die kombinierte Markdown-Datei wurde erstellt: **`Kubernetes-Deployment-Blueprint-Combined.md`**

## 🚀 Schnellste Methode: VS Code Extension

1. **VS Code öffnen**
2. **Extension installieren:** "Markdown PDF" (von yzane)
3. **Datei öffnen:** `Kubernetes-Deployment-Blueprint-Combined.md`
4. **Rechtsklick** → "Markdown PDF: Export (pdf)"
5. **Fertig!** ✅

---

## 🔧 Alternative Methoden

### **Option 1: Pandoc (empfohlen)**

```powershell
# Pandoc installieren: https://pandoc.org/installing.html
# Dann:
cd docs
pandoc Kubernetes-Deployment-Blueprint-Combined.md -o Kubernetes-Deployment-Blueprint.pdf --toc --toc-depth=3
```

### **Option 2: Online Converter**

1. Gehe zu: https://www.markdowntopdf.com/
2. Lade `Kubernetes-Deployment-Blueprint-Combined.md` hoch
3. Klicke "Convert"
4. Lade PDF herunter

### **Option 3: Python Script (falls markdown-pdf installiert)**

```powershell
pip install markdown-pdf
python create_pdf_simple.py
```

### **Option 4: Chrome/Edge (Manuell)**

1. Öffne `Kubernetes-Deployment-Blueprint-Combined.md` in VS Code
2. Rechtsklick → "Open Preview"
3. Drucken (STRG+P)
4. Ziel: "Als PDF speichern"
5. Speichern

---

## 📝 Dateien im docs/ Ordner

- ✅ `Kubernetes-Deployment-Blueprint-Combined.md` - Alle Dokumente kombiniert
- ⚠️ `Kubernetes-Deployment-Blueprint.pdf` - Wird nach Konvertierung hier erstellt

---

**Empfohlen:** VS Code Extension "Markdown PDF" (am einfachsten!)
