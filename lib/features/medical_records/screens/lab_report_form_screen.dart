import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LabReportFormScreen extends ConsumerStatefulWidget {
  final String? profileId;

  const LabReportFormScreen({super.key, this.profileId});

  @override
  ConsumerState<LabReportFormScreen> createState() => _LabReportFormScreenState();
}

class _LabReportFormScreenState extends ConsumerState<LabReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _testNameController = TextEditingController();
  final _resultsController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Lab Report'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lab report form - T058 placeholder')),
              );
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Report Title *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.science),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _testNameController,
              decoration: const InputDecoration(
                labelText: 'Test Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resultsController,
              decoration: const InputDecoration(
                labelText: 'Results',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}