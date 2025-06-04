// lib/pages/subscription_page.dart (Revised to use the model)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp.now()
import 'package:congress_app/services/firestore_service.dart'; // Import your service
import 'package:congress_app/models/subscription.dart'; // Import your Subscription model
import 'package:intl/intl.dart';
import 'package:congress_app/widgets/CustomAppBar.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService(); // Instantiate your service

  bool _isSubmitting = false; // To disable button during submission

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true; // Show loading state
      });

      try {
        final String email = _emailController.text.trim(); // Trim whitespace

        // First, check if email already exists
        bool exists = await _firestoreService.doesEmailExistInSubscriptions(email);
        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This email is already subscribed!')),
          );
          return; // Stop execution
        }

        // Create an instance of your Subscription model
        final newSubscription = Subscription(
          email: email,
          subscribedAt: Timestamp.now(), // Set the current timestamp
        );

        // Use your FirestoreService to add the subscription
        await _firestoreService.addSubscription(newSubscription);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully subscribed with ${newSubscription.email}!')),
        );
        _emailController.clear(); // Clear the input field
      } catch (e) {
        print('Error subscribing: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to subscribe. Please try again.')),
        );
      } finally {
        setState(() {
          _isSubmitting = false; // Hide loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()); // Changed 'EEEE, MMMM d,YYYY' to 'EEEE, MMMM d, yyyy' for correct year formatting
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar( // Use your custom AppBar
        formattedDate: formattedDateTime, // Pass the formatted date
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join our newsletter for the latest updates!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm, // Disable button while submitting
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white) // Show spinner
                      : const Text('Subscribe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}