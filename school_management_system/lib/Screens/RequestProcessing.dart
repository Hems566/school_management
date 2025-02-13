import 'package:flutter/material.dart';
import 'package:school_management/Widgets/PageWrapper.dart';

class RequestProcessing extends StatelessWidget {
  final bool approved;
  final String? message;

  const RequestProcessing({
    super.key,
    this.approved = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "Registration Status",
      showDrawer: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              approved ? Icons.check_circle : Icons.access_time,
              color: approved ? Colors.green : Colors.orange,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              approved
                  ? 'Registration Successful!'
                  : 'Your request is being processed',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message ??
                  (approved
                      ? 'Please check your email for login credentials'
                      : 'We will email you once your request is approved'),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
