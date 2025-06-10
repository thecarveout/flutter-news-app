// functions/src/index.ts

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { htmlToQuillDelta } from "./utils/htmlToQuillDelta";

admin.initializeApp(); // Initialize Firebase Admin SDK

// Define the Cloud Function using Firebase Functions v2 syntax
// Listens for writes (create, update, delete) to documents in the 'blog' collection
export const convertHtmlToQuillDelta = functions.firestore
  .onDocumentWritten("blog/{articleId}", async (event) => { // v2 passes an 'event' object
    const articleId = event.params.articleId; // Document ID from URL wildcard
    const articleRef = admin.firestore().collection("blog").doc(articleId);

    // Get the data AFTER the write operation (the latest state of the document)
    const afterData = event.data?.after.data(); // Access data from event.data.after

    // --- UPDATED LOGIC FOR ARRAY 'content' FIELD ---
    // If no data (e.g., document was deleted),
    // or 'content' is not an array,
    // or the array is empty,
    // or the first element's 'value' property is not a string, exit early.
    if (
      !afterData ||
      !Array.isArray(afterData.content) ||
      afterData.content.length === 0 ||
      typeof afterData.content[0].value !== "string"
    ) {
      console.log("No valid 'content' array found or document deleted. Exiting function.");
      return null;
    }

    // Access the HTML content from the 'value' property of the first element in the 'content' array
    const currentHtmlContent: string = afterData.content[0].value;
    // --- END UPDATED LOGIC ---

    // The 'content_delta' might not exist yet, so it can be undefined
    const currentQuillDelta: string | undefined = afterData.content_delta; // This line is correct for output

    // --- Idempotency Check ---
    // Prevents infinite loops if the function's own update triggers it again
    // Or if the HTML content hasn't changed and the delta is already there.
    try {
      const generatedDeltaOps = htmlToQuillDelta(currentHtmlContent).ops;
      // Change the comparison to use the correct field from afterData for idempotency check
      if (currentQuillDelta && JSON.stringify(generatedDeltaOps) === currentQuillDelta) {
        console.log("HTML 'content' did not change and 'content_delta' is up-to-date. Exiting."); // Updated log
        return null;
      }
    } catch (error: unknown) { // Type 'error' as unknown for safety
      // If the conversion for the check fails, log a warning but proceed to main conversion
      console.warn("Temporary conversion check failed, proceeding to main conversion:", (error instanceof Error) ? error.message : String(error));
    }

    console.log(`Processing article ${articleId} for HTML to Quill Delta conversion.`);

    let quillDeltaJsonString: string;
    try {
      // Perform the main conversion from HTML (or Markdown) to Quill Delta
      const delta = htmlToQuillDelta(currentHtmlContent);
      quillDeltaJsonString = JSON.stringify(delta.ops); // Convert Delta ops to string
      console.log("Conversion successful.");
    } catch (error: unknown) { // Type 'error' as unknown
      console.error("Error converting HTML to Quill Delta:", (error instanceof Error) ? error.message : String(error));
      // Save an error message to Firestore for debugging in the CMS
      await articleRef.update({ conversionError: `Failed to convert: ${ (error instanceof Error) ? error.message : String(error) }` });
      return null; // Stop execution if conversion fails
    }

    // Update the document with the new content_delta field
    try {
      await articleRef.set({
        content_delta: quillDeltaJsonString, // This field name 'content_delta' is correct based on your code
      }, { merge: true }); // Use merge: true to only update this field
      console.log(`Updated article ${articleId} with content_delta.`);
    } catch (error: unknown) { // Type 'error' as unknown
      console.error(`Error writing content_delta for article ${articleId}:`, (error instanceof Error) ? error.message : String(error));
    }

    return null; // Cloud Functions should return null or a Promise
  });
