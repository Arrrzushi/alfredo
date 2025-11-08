import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onTap;
  final bool enabled;
  final Function(String)? onChanged;
  final bool showPrefixIcon;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onTap,
    this.enabled = true,
    this.onChanged,
    this.showPrefixIcon = true,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {});
      if (widget.onChanged != null) {
        widget.onChanged!(widget.controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled,
        onTap: widget.onTap,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
        decoration: InputDecoration(
          hintText: 'Search recipes, ingredients, or ask Alfredo...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.gray500,
              ),
          prefixIcon: widget.showPrefixIcon && widget.controller.text.isEmpty
              ? Icon(
                  Icons.search_rounded,
                  color: AppTheme.gray600,
                )
              : null,
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.gray600,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                  },
                )
              : Icon(
                  Icons.mic_rounded,
                  color: AppTheme.primaryOrange,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
