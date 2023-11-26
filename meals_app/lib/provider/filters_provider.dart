import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Filter { glutenFree, lactoseFree, vegetarian, vegan }

class FiltersScreenNotifier extends StateNotifier<Map<Filter, bool>> {
  FiltersScreenNotifier()
      : super({
          Filter.glutenFree: false,
          Filter.lactoseFree: false,
          Filter.vegetarian: false,
          Filter.vegan: false,
        });
  void setAllFilters(Map<Filter, bool> selectedFilters) {
    state = selectedFilters;
  }

  void setFilter(Filter filter, bool isActive) {
    state = {
      ...state,
      filter: isActive,
    };
  }
}

final filtersProvider =
    StateNotifierProvider<FiltersScreenNotifier, Map<Filter, bool>>(
  (ref) => FiltersScreenNotifier(),
);
