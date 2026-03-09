import sys
import pypdf

reader = pypdf.PdfReader(r'c:\Users\WINDOWS\Desktop\iyad\itc challenges\Provix\DispatchDZ_README.pdf')
text = ""
for page in reader.pages:
    text += page.extract_text() + "\n"

with open(r'c:\Users\WINDOWS\Desktop\iyad\itc challenges\Provix\pdf_text.txt', 'w', encoding='utf-8') as f:
    f.write(text)
