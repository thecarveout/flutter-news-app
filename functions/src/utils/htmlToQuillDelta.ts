// functions/src/utils/htmlToQuillDelta.ts

import { JSDOM } from "jsdom";
// You'll need to install this if you haven't: npm install jsdom @types/jsdom

/**
 * Converts an HTML string into a simplified Quill Delta operations array.
 * Note: This is a basic converter and may not handle all complex HTML structures.
 *
 * @param {string} html - The HTML string to convert.
 * @return {{ ops: any[] }} An object containing the Quill Delta operations array.
 */
export function htmlToQuillDelta(html: string): { ops: any[] } {
  const dom = new JSDOM(html);
  const doc = dom.window.document;
  const ops: any[] = [];

  /**
     * Recursively processes a DOM node to extract text and apply formatting,
     * pushing the resulting Quill Delta operations to the `ops` array.
     *
     * @param {Node} node - The DOM node to process.
     * @return {void}
     */
  function processNode(node: Node): void {
    if (node.nodeType === dom.window.Node.TEXT_NODE) {
      if (node.textContent) {
        ops.push({ insert: node.textContent });
      }
    } else if (node.nodeType === dom.window.Node.ELEMENT_NODE) {
      const element = node as Element;
      let textContent = "";
      const attributes: { [key: string]: any } = {};

      switch (element.tagName.toLowerCase()) {
      case "p":
        textContent = element.textContent || "";
        if (textContent) {
          ops.push({ insert: textContent });
        }
        ops.push({ insert: "\n" });
        break;
      case "br":
        ops.push({ insert: "\n" });
        break;
      case "b":
      case "strong":
        attributes.bold = true;
        textContent = element.textContent || "";
        if (textContent) {
          ops.push({ insert: textContent, attributes: attributes });
        }
        break;
      case "i":
      case "em":
        attributes.italic = true;
        textContent = element.textContent || "";
        if (textContent) {
          ops.push({ insert: textContent, attributes: attributes });
        }
        break;
      case "u":
        attributes.underline = true;
        textContent = element.textContent || "";
        if (textContent) {
          ops.push({ insert: textContent, attributes: attributes });
        }
        break;
      case "a":
        attributes.link = element.getAttribute("href");
        textContent = element.textContent || "";
        if (attributes.link && textContent) {
          ops.push({ insert: textContent, attributes: attributes });
        }
        break;
      case "ul":
        Array.from(element.children).forEach((li) => {
          if (li.tagName.toLowerCase() === "li") {
            processNode(li);
          }
        });
        break;
      case "li":
        Array.from(element.childNodes).forEach((child) => processNode(child));
        ops.push({ insert: "\n", attributes: { list: "bullet" } });
        break;
      case "h1":
      case "h2":
      case "h3":
      case "h4":
      case "h5":
      case "h6":
        textContent = element.textContent || "";
        if (textContent) {
          ops.push({ insert: textContent });
        }
        ops.push({ insert: "\n", attributes: { header: parseInt(element.tagName.charAt(1)) } });
        break;
      default:
        Array.from(element.childNodes).forEach((child) => processNode(child));
        break;
      }
    }
  }

  Array.from(doc.body.childNodes).forEach((node) => processNode(node));

  return { ops: ops };
}
