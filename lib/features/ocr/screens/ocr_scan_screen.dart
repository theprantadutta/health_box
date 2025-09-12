import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ocr_service.dart';

class OCRScanScreen extends ConsumerStatefulWidget {
  final OCRType ocrType;
  final Function(OCRResult)? onScanComplete;

  const OCRScanScreen({
    super.key,
    this.ocrType = OCRType.general,
    this.onScanComplete,
  });

  @override
  ConsumerState<OCRScanScreen> createState() => _OCRScanScreenState();
}

class _OCRScanScreenState extends ConsumerState<OCRScanScreen>
    with TickerProviderStateMixin {
  final OCRService _ocrService = OCRService();
  
  // UI State
  bool _isProcessing = false;
  OCRResult? _scanResult;
  String? _selectedImagePath;
  
  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOCRService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeOCRService() async {
    try {
      await _ocrService.initialize();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize OCR: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        actions: [
          if (_scanResult != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareResult,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isProcessing) {
      return _buildProcessingView();
    }

    if (_scanResult != null) {
      return _buildResultView();
    }

    return _buildScanView();
  }

  Widget _buildScanView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // OCR Type Icon and Title
                _buildOCRTypeHeader(),
                const SizedBox(height: 32),
                
                // Scan Options
                _buildScanOptions(),
                const SizedBox(height: 32),
                
                // Tips
                _buildTips(),
              ],
            ),
          ),
          
          // Preview Image if selected
          if (_selectedImagePath != null) ...[
            _buildImagePreview(),
            const SizedBox(height: 16),
          ],
          
          // Process Button
          if (_selectedImagePath != null)
            _buildProcessButton(),
        ],
      ),
    );
  }

  Widget _buildOCRTypeHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            _getOCRTypeIcon(),
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _getScreenTitle(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getTypeDescription(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScanOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildScanOptionCard(
            icon: Icons.camera_alt,
            title: 'Camera',
            subtitle: 'Take a photo',
            onTap: () => _scanFromSource(OCRSource.camera),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildScanOptionCard(
            icon: Icons.photo_library,
            title: 'Gallery',
            subtitle: 'Choose from photos',
            onTap: () => _scanFromSource(OCRSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildScanOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTips() {
    final tips = _getTips();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tips for better results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < tips.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. '),
                  Expanded(
                    child: Text(
                      tips[i],
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              if (i < tips.length - 1) const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: FileImage(File(_selectedImagePath!)),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _selectedImagePath = null;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _processImage,
        icon: _isProcessing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.document_scanner),
        label: Text(_isProcessing ? 'Processing...' : 'Scan Text'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Icon(
                    Icons.document_scanner,
                    size: 64,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Scanning document...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final result = _scanResult!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success/Error indicator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    result.success ? Icons.check_circle : Icons.error,
                    color: result.success ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.success ? 'Scan Successful' : 'Scan Failed',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (result.error != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            result.error!,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Extracted data (structured)
          if (result.hasStructuredData) ...[
            _buildExtractedDataSection(result.extractedData!),
            const SizedBox(height: 16),
          ],
          
          // Raw text
          if (result.hasText) ...[
            _buildRawTextSection(result.text!),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExtractedDataSection(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extracted Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDataContent(data),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.where((entry) => entry.key != 'rawText').map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is List && key == 'medications') {
          return _buildMedicationsList(value);
        } else if (value is List && key == 'results') {
          return _buildLabResultsList(value);
        } else if (value is String && value.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatFieldName(key),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildMedicationsList(List medications) {
    if (medications.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medications',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        for (final med in medications) ...[
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med['name'] ?? 'Unknown medication',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (med['dosage'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Dosage: ${med['dosage']}'),
                  ],
                  if (med['frequency'] != null) ...[
                    const SizedBox(height: 4),
                    Text('Frequency: ${med['frequency']}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildLabResultsList(List results) {
    if (results.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lab Results',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        for (final result in results) ...[
          Card(
            color: Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result['testName'] ?? 'Unknown test',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result['value'] ?? 'N/A'} ${result['unit'] ?? ''}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (result['referenceRange'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Normal: ${result['referenceRange']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildRawTextSection(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Scanned Text',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _copyToClipboard(text),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _scanAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan Again'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveResult,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.onScanComplete != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onScanComplete!(_scanResult!);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Use This Scan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _scanFromSource(OCRSource source) async {
    setState(() {
      _scanResult = null;
    });

    try {
      if (source == OCRSource.gallery) {
        // For gallery, just select the image without processing
        final result = await _ocrService.scanFromSource(
          source: source,
          type: widget.ocrType,
        );
        
        if (result.success) {
          setState(() {
            _selectedImagePath = null; // We don't have the path from the service
          });
          _processOCRResult(result);
        } else {
          _showErrorSnackBar(result.error ?? 'Failed to scan image');
        }
      } else {
        // For camera, process immediately
        final result = await _ocrService.scanFromSource(
          source: source,
          type: widget.ocrType,
        );
        
        if (result.success) {
          _processOCRResult(result);
        } else {
          _showErrorSnackBar(result.error ?? 'Failed to scan image');
        }
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _processImage() async {
    if (_selectedImagePath == null) return;
    
    setState(() {
      _isProcessing = true;
    });

    _pulseController.repeat(reverse: true);

    try {
      final result = await _ocrService.scanFromFile(
        _selectedImagePath!,
        type: widget.ocrType,
      );
      
      _processOCRResult(result);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      _pulseController.stop();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _processOCRResult(OCRResult result) {
    setState(() {
      _scanResult = result;
      _selectedImagePath = null;
    });
    
    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text scanned successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _scanAgain() {
    setState(() {
      _scanResult = null;
      _selectedImagePath = null;
    });
  }

  void _saveResult() {
    if (_scanResult != null) {
      // In a real app, you'd save to database or share
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Result saved to medical records!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareResult() {
    if (_scanResult?.text != null) {
      // In a real app, you'd use share_plus package
      _copyToClipboard(_scanResult!.text!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard!'),
        ),
      );
    }
  }

  void _copyToClipboard(String text) {
    // In a real app, you'd use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard!'),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getScreenTitle() {
    switch (widget.ocrType) {
      case OCRType.prescription:
        return 'Scan Prescription';
      case OCRType.medicalReport:
        return 'Scan Medical Report';
      case OCRType.labResult:
        return 'Scan Lab Results';
      case OCRType.general:
        return 'Scan Document';
    }
  }

  String _getTypeDescription() {
    switch (widget.ocrType) {
      case OCRType.prescription:
        return 'Scan prescriptions to extract medication information';
      case OCRType.medicalReport:
        return 'Scan medical reports to extract key findings';
      case OCRType.labResult:
        return 'Scan lab results to extract test values';
      case OCRType.general:
        return 'Scan any document to extract text';
    }
  }

  IconData _getOCRTypeIcon() {
    switch (widget.ocrType) {
      case OCRType.prescription:
        return Icons.medication;
      case OCRType.medicalReport:
        return Icons.description;
      case OCRType.labResult:
        return Icons.science;
      case OCRType.general:
        return Icons.document_scanner;
    }
  }

  List<String> _getTips() {
    switch (widget.ocrType) {
      case OCRType.prescription:
        return [
          'Ensure good lighting and avoid shadows',
          'Keep the prescription flat and in focus',
          'Make sure all text is visible and not cut off',
          'Clean the camera lens for better clarity',
        ];
      case OCRType.medicalReport:
        return [
          'Scan the entire report page by page',
          'Ensure text is clearly visible and not blurry',
          'Avoid reflections from glossy paper',
          'Hold the phone steady while taking the photo',
        ];
      case OCRType.labResult:
        return [
          'Focus on the results section',
          'Ensure numbers and units are clearly visible',
          'Scan each page if results span multiple pages',
          'Good lighting is essential for accurate reading',
        ];
      case OCRType.general:
        return [
          'Use good lighting for best results',
          'Keep text straight and in focus',
          'Avoid shadows and reflections',
          'Hold the camera steady',
        ];
    }
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ocrService.dispose();
    super.dispose();
  }
}