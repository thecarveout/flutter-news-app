import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure these are imported
import 'package:cloud_firestore/cloud_firestore.dart'; // Make sure these are imported

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final QuillController _controller = QuillController.basic();
  final TextEditingController _nameController = TextEditingController(); // For the 'name' field

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _savePost() async {
    // Get the content from the Quill editor in Delta format (JSON array)
    final List<Map<String, dynamic>> quillDeltaContent = _controller.document.toDelta().toJson();

    // Get the post name from a hypothetical text field
    final String postName = _nameController.text;

    if (postName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a post name.')),
      );
      return;
    }

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'name': postName, // Use 'name' field as per your structure
        'content': quillDeltaContent, // Saves the entire Quill Delta JSON array
        'created_on': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post saved successfully!')),
      );
      // Optionally clear the editor and name field or navigate back
      _controller.clear();
      _nameController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save post: $error')),
      );
      print('Firestore save error: $error'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePost,
            tooltip: 'Save Post',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Post Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          QuillToolbar.basic(controller: _controller),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}