import 'package:flutter/material.dart';
import 'partner_service.dart';

class PartnerScreen extends StatefulWidget {
  const PartnerScreen({super.key});

  @override
  State<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends State<PartnerScreen> {
  final TextEditingController _emailController = TextEditingController();
  final PartnerService _partnerService = PartnerService();
  String? _partnerEmail;

  @override
  void initState() {
    super.initState();
    _loadPartner();
  }

  Future<void> _loadPartner() async {
    final email = await _partnerService.getPartnerEmail();
    setState(() {
      _partnerEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Partner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_partnerEmail != null)
              Text('Partner linked: $_partnerEmail'),
            if (_partnerEmail == null) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Partner Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  await _partnerService.linkPartnerByEmail(_emailController.text);
                  await _loadPartner();
                  Navigator.pushReplacementNamed(context, '/preferences');
                },
                child: const Text('Link'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
