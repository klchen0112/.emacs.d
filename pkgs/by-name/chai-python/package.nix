/*
  Python interpreter for chai's import script (convert-to-org.py).

  The script needs PyMuPDF to read PDFs; everything else it converts
  (Markdown, HTML, EPUB) goes through pandoc.  Chai runs the script by name
  from `chai-library-python-executable', so the interpreter has to be on the
  wrapper's PATH.
*/
{python3}:
python3.withPackages (
  ps: [
    ps.pymupdf
  ]
)
