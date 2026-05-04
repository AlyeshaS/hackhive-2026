import 'package:flutter/material.dart';

class ExpandableMatchTile extends StatefulWidget {
  final String title;
  final String description;
  const ExpandableMatchTile({
    required this.title,
    required this.description,
    super.key,
  });

  @override
  State<ExpandableMatchTile> createState() => _ExpandableMatchTileState();
}

class _ExpandableMatchTileState extends State<ExpandableMatchTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: Text(
              widget.description,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}
