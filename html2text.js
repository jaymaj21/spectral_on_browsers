const { JSDOM } = require("jsdom");
const fs = require("fs");
const path = require("path");

// Recursive directory traversal
function walkDir(dir, callback) {
    fs.readdirSync(dir, { withFileTypes: true }).forEach((dirent) => {
        const fullPath = path.join(dir, dirent.name);
        if (dirent.isDirectory()) {
            walkDir(fullPath, callback);
        } else {
            callback(fullPath);
        }
    });
}

// Extract text from HTML file
function extractFromHtml(htmlFilePath, outputFilePath) {
    const htmlContent = fs.readFileSync(htmlFilePath, "utf8");
    const dom = new JSDOM(htmlContent);
    const document = dom.window.document;

    const editorDiv = document.querySelector("#editor");

    if (editorDiv) {
        let extractedText = extractTextWithLineBreaks(editorDiv);
        extractedText = cleanInvisibleChars(extractedText);

        fs.writeFileSync(outputFilePath, extractedText, "utf8");
        console.log(`Extracted to ${outputFilePath}`);
    } else {
        console.log(`No div found in ${htmlFilePath}`);
    }
}

function extractTextWithLineBreaks(node) {
    let text = '';

    node.childNodes.forEach(child => {
        if (child.nodeType === child.ownerDocument.defaultView.Node.TEXT_NODE) {
            text += child.textContent;
        } else if (child.nodeType === child.ownerDocument.defaultView.Node.ELEMENT_NODE) {
            const tag = child.tagName.toUpperCase();

            if (tag === 'BR') {
                text += '\n';
            } else if (['P', 'DIV', 'LI', 'H1', 'H2', 'H3', 'H4', 'H5', 'H6'].includes(tag)) {
                text += extractTextWithLineBreaks(child) + '\n';
            } else if (tag === 'TR') {
                // Remove any trailing tab before appending newline for table row
                let rowText = extractTextWithLineBreaks(child).replace(/\t+$/, '');
                text += rowText + '\n';
            } else if (tag === 'TD' || tag === 'TH') {
                text += extractTextWithLineBreaks(child) + '\t';
            } else {
                text += extractTextWithLineBreaks(child);
            }
        }
    });

    return text;
}



function cleanInvisibleChars(text) {
    return text.replace(/[\u200B-\u200D\uFEFF\u00A0]/g, ' ')
               .replace(/\r\n|\r/g, '\n')
               .replace(/[ \t]+\n/g, '\n')
               .replace(/\n{3,}/g, '\n\n')
               .trim();
}

// Main
if (process.argv.length === 4) {
    const inputFile = process.argv[2];
    const outputFile = process.argv[3];
    extractFromHtml(inputFile, outputFile);
} else {
    const inputDir = process.argv[2] || '.';

    walkDir(inputDir, (filePath) => {
        const match = filePath.match(/(.+)\.(\w+)\.html$/);
        if (match) {
            const outputFilePath = `${match[1]}.${match[2]}`;
            extractFromHtml(filePath, outputFilePath);
        }
    });
}
