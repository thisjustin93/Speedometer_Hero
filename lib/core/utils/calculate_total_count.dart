// Helper method to calculate the total count of products in a category
int calculateTotalCount(List<Map<String, dynamic>> products) {
  int totalCount = 0;
  for (final product in products) {
    totalCount += product['count'] as int;
  }
  return totalCount;
}
