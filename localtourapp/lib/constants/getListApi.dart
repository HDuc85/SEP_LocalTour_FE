enum SortBy {
  suggested,
  created_by,
  distance,
  rating,
  none
}

enum SortOrder {
  asc,
  desc
}

String sortByToString(SortBy sortBy) {
  if (sortBy == SortBy.none) {
    return '';
  }
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
