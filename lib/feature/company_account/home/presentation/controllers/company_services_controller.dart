import 'package:servo/core/network/marketplace_api.dart';
import 'package:flutter/foundation.dart';
import 'package:servo/core/constants/app_assets.dart';
import '../widgets/company_service_filter.dart';

class CompanyServicePreview {
  const CompanyServicePreview({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.imagePath = AppAssets.authHeader4,
    this.status = CompanyServiceStatus.pending,
    this.description = '',
    this.durationMinutes,
    this.price = 0,
    this.ordersCount = 0,
    this.deliveryDate,
    this.categoryId = 0,
    this.priceType = 'fixed',
  });

  final int categoryId;
  final String priceType;
  final String id;
  final String title;
  final String category;
  final String date;
  final String imagePath;
  final CompanyServiceStatus status;
  final String description;
  final int? durationMinutes;
  final double price;
  final int ordersCount;
  final DateTime? deliveryDate;

  CompanyServicePreview copyWith({
    String? title,
    String? category,
    String? description,
    int? durationMinutes,
    double? price,
  }) => CompanyServicePreview(
    id: id,
    categoryId: categoryId,
    priceType: priceType,
    title: title ?? this.title,
    category: category ?? this.category,
    date: date,
    imagePath: imagePath,
    status: status,
    description: description ?? this.description,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    price: price ?? this.price,
    ordersCount: ordersCount,
    deliveryDate: deliveryDate,
  );
}

class CompanyOrderPreview {
  CompanyOrderPreview(this.data);
  final JsonMap data;
  String get id => '${data['id']}';
  String get status => apiText(data['status']);
  bool get accepted => [
    'accepted',
    'confirmed',
    'on_the_way',
    'in_progress',
    'completed',
  ].contains(status);
  String get name => apiText(apiMap(data['customer'])['name']);
  String get avatarPath => apiText(apiMap(data['customer'])['avatar']);
  String get date => apiText(data['created_at']);
  String get deliveryDate => apiText(data['scheduled_date']);
  int get rating =>
      (apiMap(data['customer'])['rating_avg'] as num?)?.round() ?? 0;
}

class CompanyServicesController extends ChangeNotifier {
  CompanyServicesController({MarketplaceApi? api})
    : _api = api ?? MarketplaceApi();
  final MarketplaceApi _api;
  MarketplaceApi get api => _api;
  bool loading = false;
  String? error;
  bool _disposed = false;
  String companyName = '';
  List<CompanyServicePreview> _services = [];
  List<JsonMap> categories = [];
  final Map<String, List<CompanyOrderPreview>> _orders = {};
  final Set<String> _busy = {};
  bool isBusy(String id) => _busy.contains(id);
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  static CompanyServicePreview parse(JsonMap data) {
    if (data['id'] == null || data['title'] == null) {
      throw const ApiFailure('Invalid service received');
    }
    final category = apiMap(data['category']);
    return CompanyServicePreview(
      id: '${data['id']}',
      title: apiText(data['title']),
      category: apiText(category['name']),
      categoryId:
          (category['id'] as num?)?.toInt() ??
          (data['category_id'] as num?)?.toInt() ??
          0,
      date: apiText(data['created_at']),
      imagePath: apiText(data['thumbnail']).isEmpty
          ? AppAssets.authHeader4
          : apiText(data['thumbnail']),
      status: data['is_active'] == true
          ? CompanyServiceStatus.accepted
          : CompanyServiceStatus.pending,
      description: apiText(data['description']),
      price: double.tryParse('${data['price']}') ?? 0,
      priceType: apiText(data['price_type']),
      durationMinutes: (data['duration_min'] as num?)?.toInt(),
    );
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    _notify();
    try {
      final result = await Future.wait([
        _api.list('provider/services'),
        _api.list('categories'),
        _api.request('me'),
      ]);
      _services = (result[0] as List<JsonMap>).map(parse).toList();
      categories = result[1] as List<JsonMap>;
      companyName = apiText(apiMap(result[2])['name']);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      _notify();
    }
  }

  List<CompanyServicePreview> get services => List.unmodifiable(_services);
  int get activeCount =>
      _services.where((s) => s.status == CompanyServiceStatus.accepted).length;
  List<CompanyOrderPreview> ordersFor(String id) =>
      List.unmodifiable(_orders[id] ?? []);
  bool hasLoadedOrders(String id) => _orders.containsKey(id);
  Future<void> loadOrders(String id) async {
    final data = await _api.list('provider/services/$id/bookings');
    _orders[id] = data.map(CompanyOrderPreview.new).toList();
    _notify();
  }

  Future<void> acceptOrder(String serviceId, String id) async {
    if (isBusy(id)) return;
    _busy.add(id);
    _notify();
    try {
      await _api.request('provider/bookings/$id/accept', method: 'POST');
      await loadOrders(serviceId);
    } finally {
      _busy.remove(id);
      _notify();
    }
  }

  JsonMap _payload(CompanyServicePreview s) {
    final matches = categories.where((c) => apiText(c['name']) == s.category);
    final categoryId = matches.isNotEmpty ? matches.first['id'] : s.categoryId;
    if (categoryId == 0) throw const ApiFailure('Choose a valid category');
    return {
      'category_id': categoryId,
      'title': {'en': s.title},
      'description': s.description,
      'duration_min': s.durationMinutes,
      'price': s.price,
      'price_type': s.priceType.isEmpty ? 'fixed' : s.priceType,
    };
  }

  Future<void> add(CompanyServicePreview service) async {
    await _api.request(
      'provider/services',
      method: 'POST',
      data: _payload(service),
    );
    await load();
  }

  Future<void> update(CompanyServicePreview service) async {
    await _api.request(
      'provider/services/${service.id}',
      method: 'PUT',
      data: _payload(service),
    );
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index != -1) _services[index] = service;
    _notify();
    await load();
  }

  Future<void> delete(String id) async {
    await _api.request('provider/services/$id', method: 'DELETE');
    _services.removeWhere((s) => s.id == id);
    _orders.remove(id);
    _notify();
  }
}
