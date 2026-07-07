import 'package:flutter/material.dart';
import '../tema/colores_tema.dart';

/// Reusable pagination bar with page buttons.
/// 
/// Renders: « < 1 2 3 ... 10 > » plus item count.
class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final ValueChanged<int> onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.totalItems = 0,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1 && totalItems <= 10) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (totalItems > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$totalItems registros',
                style: const TextStyle(
                  color: HotelPMSColors.textoSecundario,
                  fontSize: 12,
                ),
              ),
            ),
          _PageButton(
            icon: Icons.first_page,
            onPressed: currentPage > 0 ? () => onPageChanged(0) : null,
          ),
          const SizedBox(width: 4),
          _PageButton(
            icon: Icons.chevron_left,
            onPressed: currentPage > 0
                ? () => onPageChanged(currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          ..._buildPageNumbers(),
          const SizedBox(width: 8),
          _PageButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(currentPage + 1)
                : null,
          ),
          const SizedBox(width: 4),
          _PageButton(
            icon: Icons.last_page,
            onPressed: currentPage < totalPages - 1
                ? () => onPageChanged(totalPages - 1)
                : null,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    const int maxVisible = 5;
    List<Widget> buttons = [];

    // When totalPages fits within maxVisible, show all pages directly
    // to avoid clamp(lower > upper) crashes for small page counts.
    if (totalPages <= maxVisible) {
      for (int i = 0; i < totalPages; i++) {
        buttons.add(_PageNumber(
          number: i,
          isActive: i == currentPage,
          onTap: () => onPageChanged(i),
        ));
      }
      return buttons;
    }

    int start = (currentPage - 2).clamp(0, totalPages - maxVisible);
    int end = (start + maxVisible).clamp(0, totalPages);

    if (end - start < maxVisible && start > 0) {
      start = (end - maxVisible).clamp(0, totalPages);
    }

    if (start > 0) {
      buttons.add(_PageNumber(
        number: 0,
        isActive: false,
        onTap: () => onPageChanged(0),
      ));
      if (start > 1) {
        buttons.add(const _Ellipsis());
      }
    }

    for (int i = start; i < end; i++) {
      buttons.add(_PageNumber(
        number: i,
        isActive: i == currentPage,
        onTap: () => onPageChanged(i),
      ));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        buttons.add(const _Ellipsis());
      }
      buttons.add(_PageNumber(
        number: totalPages - 1,
        isActive: false,
        onTap: () => onPageChanged(totalPages - 1),
      ));
    }

    return buttons;
  }
}

class _PageButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PageButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        color: onPressed != null
            ? HotelPMSColors.textoPrincipal
            : HotelPMSColors.textoSecundario.withValues(alpha: 0.3),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: HotelPMSColors.fondoInput,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final int number;
  final bool isActive;
  final VoidCallback onTap;

  const _PageNumber({
    required this.number,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: isActive ? HotelPMSColors.naranjaAcento : HotelPMSColors.fondoInput,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: isActive ? null : onTap,
            child: Center(
              child: Text(
                '${number + 1}',
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : HotelPMSColors.textoPrincipal,
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: HotelPMSColors.textoSecundario,
          fontSize: 13,
        ),
      ),
    );
  }
}
