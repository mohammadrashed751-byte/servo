import 'package:flutter/material.dart';
import '../network/marketplace_api.dart';

class SupportRequestDialog extends StatefulWidget {
  const SupportRequestDialog({super.key});
  @override
  State<SupportRequestDialog> createState() => _SupportRequestDialogState();
}

class _SupportRequestDialogState extends State<SupportRequestDialog> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;
  String? _error;
  @override
  void dispose() {
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending || !_form.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await MarketplaceApi().request(
        'support/contact',
        method: 'POST',
        data: {'subject': _subject.text.trim(), 'body': _body.text.trim()},
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_sending,
    child: AlertDialog(
      title: const Text('Contact Support'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subject,
                enabled: !_sending,
                maxLength: 150,
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a subject' : null,
              ),
              TextFormField(
                controller: _body,
                enabled: !_sending,
                maxLength: 5000,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Message'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a message' : null,
              ),
              if (_error != null) Text(_error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _sending ? null : _send,
          child: Text(_sending ? 'Sending…' : 'Send'),
        ),
      ],
    ),
  );
}

Future<void> showSupportRequest(BuildContext context) async {
  final sent = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const SupportRequestDialog(),
  );
  if (context.mounted && sent == true) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message sent to support')));
  }
}

void showSupportContact(BuildContext context, String title, String value) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SelectableText(value.isEmpty ? 'Not available' : value),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
