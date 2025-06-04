from flask import Flask, request, send_file
from docx import Document
import fitz  # PyMuPDF
import tempfile
import re
import os

app = Flask(__name__)

def extract_data_from_pdf(pdf_path):
    text = ""
    with fitz.open(pdf_path) as doc:
        for page in doc:
            text += page.get_text()
    data = {
        "fio": re.search(r"в отношении\s+([А-Яа-яЁё\s\-]+)", text).group(1).strip(),
        "iin": re.search(r"\b\d{12}\b", text).group(0),
        "address": re.search(r"Адрес.*?:\s*(.+)", text).group(1).strip(),
        "number": re.search(r"Зарегистрировано.*?№\s*(\S+)", text).group(1).strip(),
        "sum": re.search(r"взыскать\s+([\d\s]+) тенге", text).group(1).strip(),
        "company": re.search(r"в пользу\s+(.+?)\s+в размере", text).group(1).strip(),
    }
    return data

def fill_template(data):
    doc = Document("ШАБЛОН_GPT_ЧИСТЫЙ.docx")
    for para in doc.paragraphs:
        for key, value in data.items():
            para.text = para.text.replace(f"<<{key}>>", value)
    tmp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".docx")
    doc.save(tmp_file.name)
    return tmp_file.name

@app.route('/generate', methods=['POST'])
def generate():
    if 'file' not in request.files:
        return {'error': 'No file provided'}, 400
    pdf_file = request.files['file']
    with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
        pdf_file.save(tmp.name)
        data = extract_data_from_pdf(tmp.name)
        docx_file = fill_template(data)
        return send_file(docx_file, as_attachment=True, download_name="vozrazhenie.docx")

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=10000)

