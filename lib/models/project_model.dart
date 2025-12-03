class Project {
  final String id;
  final String status;
  final String title;
  final Location location;
  final String projectType;
  final String buildingType;
  final String projectPrice;
  final String priceUnit;
  final List<String> coverImageUrls;
  final int totalUnits;
  final String unitPrice;
  final int unitsSold;
  final String publishedAt;

  Project({
    required this.id,
    required this.status,
    required this.title,
    required this.location,
    required this.projectType,
    required this.buildingType,
    required this.projectPrice,
    required this.priceUnit,
    required this.coverImageUrls,
    required this.totalUnits,
    required this.unitPrice,
    required this.unitsSold,
    required this.publishedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'N/A',
      title: json['title'] ?? 'No Title',
      location: Location.fromJson(json['location'] ?? {}),
      projectType: json['projectType'] ?? '',
      buildingType: json['buildingType'] ?? '',
      projectPrice: json['projectPrice'] ?? 'Price on Request',
      priceUnit: json['priceUnit'] ?? '',
      coverImageUrls: List<String>.from(json['coverImageUrls'] ?? []),
      totalUnits: json['totalUnits'] ?? 0,
      unitPrice: json['unitPrice'] ?? 'N/A',
      unitsSold: json['unitsSold'] ?? 0,
      publishedAt: json['published_at'] ?? 'N/A',
    );
  }
}

class Location {
  final String city;
  final String country;

  Location({required this.city, required this.country});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city'] ?? 'Unknown City',
      country: json['country'] ?? 'Unknown Country',
    );
  }
}
