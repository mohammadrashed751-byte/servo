import 'package:flutter/material.dart';
import '../network/marketplace_api.dart';

class BookingActionsMenu extends StatefulWidget {
  const BookingActionsMenu({
    super.key,
    required this.id,
    required this.status,
    required this.onChanged,
    this.provider = false,
    this.onReview,
    this.api,
  });
  final String id;
  final String status;
  final bool provider;
  final Future<void> Function() onChanged;
  final Future<void> Function()? onReview;
  final MarketplaceApi? api;
  @override
  State<BookingActionsMenu> createState() => _BookingActionsMenuState();
}

class _BookingActionsMenuState extends State<BookingActionsMenu> {
  bool _busy = false;
  Future<void> _act(String action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (action == 'review') {
        await widget.onReview?.call();
        return;
      }
      String? reason;
      if (action == 'cancel' || action == 'reject') {
        var input = '';
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              action == 'cancel' ? 'Cancel booking?' : 'Reject booking?',
            ),
            content: TextField(
              onChanged: (value) => input = value,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep booking'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        );
        reason = input.trim();
        if (result != true) return;
      }
      await (widget.api ?? MarketplaceApi()).request(
        '${widget.provider ? 'provider/' : ''}bookings/${widget.id}/$action',
        method: 'POST',
        data: reason == null ? null : {'reason': reason},
      );
      await widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = <String, String>{};
    if (widget.provider) {
      if (widget.status == 'pending') options['reject'] = 'Reject booking';
      if (['accepted', 'confirmed'].contains(widget.status)) {
        options['on-the-way'] = 'On the way';
      }
      if (['accepted', 'confirmed', 'on_the_way'].contains(widget.status)) {
        options['start'] = 'Start service';
      }
      if (widget.status == 'in_progress') {
        options['complete'] = 'Complete service';
      }
    } else if (widget.status == 'completed' && widget.onReview != null) {
      options['review'] = 'Write a review';
    }
    if ([
      'pending',
      'accepted',
      'confirmed',
      'on_the_way',
      'in_progress',
    ].contains(widget.status)) {
      options['cancel'] = 'Cancel booking';
    }
    if (options.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      tooltip: 'Booking actions',
      enabled: !_busy,
      onSelected: _act,
      icon: Icon(_busy ? Icons.hourglass_empty : Icons.more_vert),
      itemBuilder: (_) => options.entries
          .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
    );
  }
}
