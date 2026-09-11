class PageMeta {
  final int page;
  final int pageSize;
  final int total;

  const PageMeta({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) => PageMeta(
    page: json['page'] as int,
    pageSize: json['pageSize'] as int,
    total: json['total'] as int,
  );

  bool get hasNextPage => page * pageSize < total;
}

class PageResult<T> {
  final List<T> data;
  final PageMeta meta;

  const PageResult({required this.data, required this.meta});

  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawData = json['data'] as List<dynamic>;
    return PageResult(
      data: rawData
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}
