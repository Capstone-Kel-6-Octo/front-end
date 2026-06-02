class FeatureItem {
  final String name;
  final int priority;

  FeatureItem({
    required this.name,
    required this.priority,
  });

  factory FeatureItem.fromJson(Map<String, dynamic> json) {
    return FeatureItem(
      name: json['name'] ?? '',
      priority: json['priority'] is int ? json['priority'] : int.parse(json['priority'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priority': priority,
    };
  }
}

class HomepageConfig {
  final String persona;
  final List<String> layout;
  final List<FeatureItem> features;
  final List<String> whyThis;
  final String? userName;
  final double? userBalance;

  HomepageConfig({
    required this.persona,
    required this.layout,
    required this.features,
    required this.whyThis,
    this.userName,
    this.userBalance,
  });

  factory HomepageConfig.fromJson(Map<String, dynamic> json, {String? userName, double? userBalance}) {
    final List<dynamic> layoutList = json['layout'] ?? ['header', 'balance', 'features'];
    
    // Map recommendations or features list cleanly
    final List<dynamic> rawFeatures = json['features'] ?? json['recommendations'] ?? [];
    final List<FeatureItem> mappedFeatures = rawFeatures.map((item) {
      if (item is Map) {
        String name = item['menu'] ?? item['name'] ?? '';
        if (name == 'tagihan_dan_isi_ulang') {
          name = 'top up';
        }
        final int priority = item['rank'] is int 
            ? item['rank'] 
            : (item['priority'] is int ? item['priority'] : int.tryParse((item['rank'] ?? item['priority'] ?? '1').toString()) ?? 1);
        return FeatureItem(name: name, priority: priority);
      }
      return FeatureItem(name: '', priority: 1);
    }).toList();

    // Map whyThis or explanation summary cleanly
    final List<dynamic> rawWhyThis = json['why_this'] ?? [];
    final List<String> whyThisList = rawWhyThis.isNotEmpty 
        ? rawWhyThis.map((item) => item.toString()).toList()
        : (json['explanation']?['summary'] != null ? [json['explanation']!['summary'].toString()] : <String>[]);

    return HomepageConfig(
      persona: json['persona'] ?? 'REGULER',
      layout: layoutList.map((item) => item.toString()).toList(),
      features: mappedFeatures,
      whyThis: whyThisList,
      userName: userName,
      userBalance: userBalance,
    );
  }
}
