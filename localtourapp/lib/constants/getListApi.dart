enum SortBy {
  suggested,
  created_by,
  distance,
  rating,
}

enum SortOrder {
  asc,
}

String sortByToString(SortBy sortBy) {
  return sortBy.toString().split('.').last;
}

String sortOrderToString(SortOrder sortOrder) {
  return sortOrder.toString().split('.').last;
}

SortBy stringToSortBy(String value) {
  return SortBy.values.firstWhere((e) => e.toString().split('.').last == value);
}

SortOrder stringToSortOrder(String value) {
  return SortOrder.values
      .firstWhere((e) => e.toString().split('.').last == value);
}
