import 'package:flutter/material.dart';
import 'package:tasky/core/services/ai_service.dart';

class SmartQuickAddBar extends StatefulWidget {
  final Function(SmartTaskParseResult result) onParsed;

  const SmartQuickAddBar({super.key, required this.onParsed});

  @override
  State<SmartQuickAddBar> createState() => _SmartQuickAddBarState();
}

class _SmartQuickAddBarState extends State<SmartQuickAddBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;

  void _parse() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final result = AIService().parseNaturalLanguageTask(text);
    widget.onParsed(result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✨ Auto-filled: "${result.title}"'
          '${result.categoryId != null ? ' • #${result.categoryId}' : ''}'
          '${result.priority == 'high' ? ' • High Priority' : ''}',
        ),
        backgroundColor: const Color(0xFF15B86C),
        behavior: SnackBarBehavior.floating,
      ),
    );

    _controller.clear();
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF15B86C).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15B86C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('✨', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Smart Natural Language Auto-Fill',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15B86C),
                          ),
                        ),
                        Text(
                          'Type e.g. "Prepare slides tomorrow high #Work"',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF15B86C),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onSubmitted: (_) => _parse(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Type task details naturally...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _parse,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Parse',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
