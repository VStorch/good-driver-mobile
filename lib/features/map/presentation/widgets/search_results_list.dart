import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/place.dart';
import '../viewmodels/map_viewmodel.dart';

class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    if (vm.state == MapState.searching && vm.searchResults.isEmpty) {
      return _ResultsContainer(
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFF4CAF50),
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    if (vm.searchResults.isEmpty) return const SizedBox.shrink();

    return _ResultsContainer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: vm.searchResults.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade100,
          indent: 56,
        ),
        itemBuilder: (context, index) {
          final place = vm.searchResults[index];
          return _PlaceTile(place: place);
        },
      ),
    );
  }
}

class _ResultsContainer extends StatelessWidget {
  final Widget child;
  const _ResultsContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final Place place;
  const _PlaceTile({required this.place});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<MapViewModel>().selectPlace(place);
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.shortName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (place.city != null || place.state != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [place.city, place.state, place.country]
                          .where((s) => s != null && s.isNotEmpty)
                          .join(', '),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}