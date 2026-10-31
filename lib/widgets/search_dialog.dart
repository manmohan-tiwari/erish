import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../core/widgets/erish_image.dart';
import '../models/product.dart';

class SearchDialog {
  static void show(
    BuildContext context,
    List<Product> products,
    Function(Product) onProductSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return _SearchDialogWidget(
          products: products,
          onProductSelected: onProductSelected,
        );
      },
    );
  }
}

class _SearchDialogWidget extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;

  const _SearchDialogWidget({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_SearchDialogWidget> createState() => _SearchDialogWidgetState();
}

class _SearchDialogWidgetState extends State<_SearchDialogWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.products;
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.products;
      } else {
        _filtered = widget.products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  (p.description?.toLowerCase().contains(q) ?? false) ||
                  p.tag.toLowerCase().contains(q),
            )
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.ivory,
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 80, left: 20, right: 20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search input
              Row(
                children: [
                  const Icon(Icons.search, color: AppTheme.ink),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Search for prints, styles, dresses...',
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.tenorSans(
                        fontSize: 18,
                        letterSpacing: 0.5,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppTheme.ink, thickness: 1.5),
              const SizedBox(height: 12),

              // Search results list
              Flexible(
                child: _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36.0),
                        child: Text(
                          'No prints found matching your query.',
                          style: GoogleFonts.tenorSans(
                            color: AppTheme.mutedText,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: _filtered.length,
                        separatorBuilder: (_, index) =>
                            const Divider(color: Colors.black12, height: 16),
                        itemBuilder: (context, index) {
                          final p = _filtered[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ErishImage(
                              imagePath: p.image,
                              width: 46,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            title: Text(
                              p.name,
                              style: GoogleFonts.cinzel(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            subtitle: Text(
                              p.priceFormatted,
                              style: GoogleFonts.tenorSans(
                                color: AppTheme.pink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: AppTheme.ink,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              widget.onProductSelected(p);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
