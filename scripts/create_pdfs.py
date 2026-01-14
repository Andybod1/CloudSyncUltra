#!/usr/bin/env python3
"""
Generate professional PDFs from CloudSync Ultra markdown documents.
"""

from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib.colors import HexColor
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT
import re
import os

# Color scheme matching CloudSync Ultra brand
BRAND_INDIGO = HexColor('#6366F1')
BRAND_VIOLET = HexColor('#8B5CF6')
BRAND_DARK = HexColor('#1E293B')
BRAND_GRAY = HexColor('#64748B')

def create_styles():
    """Create custom styles for the PDF."""
    styles = getSampleStyleSheet()

    # Title style
    styles.add(ParagraphStyle(
        name='DocTitle',
        parent=styles['Title'],
        fontSize=24,
        textColor=BRAND_INDIGO,
        spaceAfter=20,
        alignment=TA_CENTER
    ))

    # Subtitle
    styles.add(ParagraphStyle(
        name='Subtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=BRAND_GRAY,
        spaceAfter=30,
        alignment=TA_CENTER
    ))

    # Section heading (##)
    styles.add(ParagraphStyle(
        name='Heading2Custom',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=BRAND_INDIGO,
        spaceBefore=20,
        spaceAfter=10
    ))

    # Subsection heading (###)
    styles.add(ParagraphStyle(
        name='Heading3Custom',
        parent=styles['Heading3'],
        fontSize=13,
        textColor=BRAND_VIOLET,
        spaceBefore=15,
        spaceAfter=8
    ))

    # Body text
    styles.add(ParagraphStyle(
        name='BodyCustom',
        parent=styles['Normal'],
        fontSize=10,
        textColor=BRAND_DARK,
        spaceAfter=8,
        leading=14
    ))

    # Bullet point
    styles.add(ParagraphStyle(
        name='BulletCustom',
        parent=styles['Normal'],
        fontSize=10,
        textColor=BRAND_DARK,
        leftIndent=20,
        spaceAfter=4,
        bulletIndent=10
    ))

    # Code block
    styles.add(ParagraphStyle(
        name='CodeCustom',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        textColor=HexColor('#374151'),
        backColor=HexColor('#F3F4F6'),
        leftIndent=10,
        rightIndent=10,
        spaceAfter=10,
        spaceBefore=5
    ))

    return styles

def parse_markdown_to_elements(markdown_text, styles):
    """Convert markdown text to reportlab elements."""
    elements = []
    lines = markdown_text.split('\n')
    in_code_block = False
    code_buffer = []
    in_table = False
    table_rows = []

    i = 0
    while i < len(lines):
        line = lines[i]

        # Handle code blocks
        if line.strip().startswith('```'):
            if in_code_block:
                # End code block
                code_text = '\n'.join(code_buffer)
                if code_text.strip():
                    # Escape special characters for reportlab
                    code_text = code_text.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                    elements.append(Paragraph(f"<font face='Courier' size='8'>{code_text}</font>", styles['CodeCustom']))
                code_buffer = []
                in_code_block = False
            else:
                in_code_block = True
            i += 1
            continue

        if in_code_block:
            code_buffer.append(line)
            i += 1
            continue

        # Handle tables
        if '|' in line and line.strip().startswith('|'):
            if not in_table:
                in_table = True
                table_rows = []

            # Parse table row
            cells = [cell.strip() for cell in line.split('|')[1:-1]]

            # Skip separator rows (|---|---|)
            if all(set(cell) <= set('-: ') for cell in cells):
                i += 1
                continue

            table_rows.append(cells)
            i += 1
            continue
        elif in_table:
            # End of table
            if table_rows:
                table = Table(table_rows)
                table.setStyle(TableStyle([
                    ('BACKGROUND', (0, 0), (-1, 0), BRAND_INDIGO),
                    ('TEXTCOLOR', (0, 0), (-1, 0), HexColor('#FFFFFF')),
                    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                    ('FONTSIZE', (0, 0), (-1, -1), 9),
                    ('BOTTOMPADDING', (0, 0), (-1, 0), 8),
                    ('TOPPADDING', (0, 0), (-1, -1), 5),
                    ('BACKGROUND', (0, 1), (-1, -1), HexColor('#F8FAFC')),
                    ('GRID', (0, 0), (-1, -1), 0.5, BRAND_GRAY),
                ]))
                elements.append(table)
                elements.append(Spacer(1, 10))
            table_rows = []
            in_table = False

        # Skip empty lines
        if not line.strip():
            elements.append(Spacer(1, 6))
            i += 1
            continue

        # Handle headings
        if line.startswith('# '):
            text = line[2:].strip()
            elements.append(Paragraph(text, styles['DocTitle']))
        elif line.startswith('## '):
            text = line[3:].strip()
            # Remove markdown formatting
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            elements.append(Paragraph(text, styles['Heading2Custom']))
        elif line.startswith('### '):
            text = line[4:].strip()
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            elements.append(Paragraph(text, styles['Heading3Custom']))
        elif line.startswith('#### '):
            text = line[5:].strip()
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            elements.append(Paragraph(f"<b>{text}</b>", styles['BodyCustom']))
        # Handle bullet points
        elif line.strip().startswith('- ') or line.strip().startswith('* '):
            text = line.strip()[2:]
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            text = re.sub(r'\[(.+?)\]\(.+?\)', r'\1', text)  # Remove links
            elements.append(Paragraph(f"<bullet>&bull;</bullet> {text}", styles['BulletCustom']))
        elif re.match(r'^\d+\. ', line.strip()):
            text = re.sub(r'^\d+\. ', '', line.strip())
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            text = re.sub(r'\[(.+?)\]\(.+?\)', r'\1', text)
            elements.append(Paragraph(f"<bullet>&bull;</bullet> {text}", styles['BulletCustom']))
        elif line.strip().startswith('- [ ]'):
            text = line.strip()[6:]
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            elements.append(Paragraph(f"<bullet>[ ]</bullet> {text}", styles['BulletCustom']))
        # Handle horizontal rules
        elif line.strip() == '---':
            elements.append(Spacer(1, 15))
        # Handle blockquotes
        elif line.startswith('> '):
            text = line[2:].strip()
            text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
            elements.append(Paragraph(f"<i>{text}</i>", styles['BodyCustom']))
        # Regular paragraph
        else:
            text = line.strip()
            if text:
                # Convert markdown formatting
                text = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', text)
                text = re.sub(r'\*(.+?)\*', r'<i>\1</i>', text)
                text = re.sub(r'`(.+?)`', r'<font face="Courier">\1</font>', text)
                text = re.sub(r'\[(.+?)\]\(.+?\)', r'\1', text)  # Remove links
                elements.append(Paragraph(text, styles['BodyCustom']))

        i += 1

    return elements

def create_pdf(markdown_text, output_path, title):
    """Create a PDF from markdown text."""
    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        rightMargin=0.75*inch,
        leftMargin=0.75*inch,
        topMargin=0.75*inch,
        bottomMargin=0.75*inch
    )

    styles = create_styles()
    elements = parse_markdown_to_elements(markdown_text, styles)

    # Add footer info
    elements.append(Spacer(1, 30))
    elements.append(Paragraph(
        f"<i>CloudSync Ultra - {title}</i>",
        styles['Subtitle']
    ))

    doc.build(elements)
    print(f"Created: {output_path}")

def main():
    base_path = '/sessions/trusting-eager-sagan/mnt/Claude'
    output_dir = f'{base_path}/docs/pdfs'

    # Create output directory
    os.makedirs(output_dir, exist_ok=True)

    # Documents to convert
    documents = [
        {
            'input': f'{base_path}/docs/PUBLISHING_GUIDE.md',
            'output': f'{output_dir}/CloudSyncUltra_Publishing_Guide.pdf',
            'title': 'Publishing Guide'
        },
        {
            'input': f'{base_path}/.claude-team/outputs/PRICING_STRATEGY.md',
            'output': f'{output_dir}/CloudSyncUltra_Pricing_Strategy.pdf',
            'title': 'Pricing Strategy'
        },
        {
            'input': f'{base_path}/.claude-team/outputs/APP_ICON_COMPLETE.md',
            'output': f'{output_dir}/CloudSyncUltra_Brand_Design.pdf',
            'title': 'Brand Design & App Icon'
        },
        {
            'input': f'{base_path}/.claude-team/outputs/MARKETING_CHANNELS_REPORT.md',
            'output': f'{output_dir}/CloudSyncUltra_Marketing_Channels.pdf',
            'title': 'Marketing Channels Report'
        },
        {
            'input': f'{base_path}/.claude-team/outputs/MARKETING_LAUNCH_CHECKLIST.md',
            'output': f'{output_dir}/CloudSyncUltra_Launch_Checklist.pdf',
            'title': 'Launch Checklist'
        }
    ]

    for doc in documents:
        try:
            with open(doc['input'], 'r') as f:
                markdown_text = f.read()
            create_pdf(markdown_text, doc['output'], doc['title'])
        except Exception as e:
            print(f"Error creating {doc['output']}: {e}")

    print(f"\nAll PDFs created in: {output_dir}")

if __name__ == '__main__':
    main()
