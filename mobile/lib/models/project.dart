import 'plot.dart';
import 'plot_status.dart';

class Project {
  final String id;
  final String name;
  final String location;
  final String description;
  final String coverImage;
  final List<String> gallery;
  final String priceRange;
  final String developmentStatus;
  final List<String> amenities;
  final int plotCount;
  final List<Plot> plots;

  Project({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.coverImage,
    required this.gallery,
    required this.priceRange,
    required this.developmentStatus,
    required this.amenities,
    required this.plotCount,
    required this.plots,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverImage: json['coverImage'] as String? ?? '',
      gallery:
          (json['gallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      priceRange: json['priceRange'] as String? ?? '',
      developmentStatus: json['developmentStatus'] as String? ?? 'UPCOMING',
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      plotCount: json['plots'] != null ? (json['plots'] as List).length : 0,
      plots: json['plots'] != null
          ? (json['plots'] as List)
                .map(
                  (p) => Plot(
                    id: p['id'],
                    projectId: p['projectId'],
                    plotNumber: p['plotNumber'],
                    sizeInSqFt: p['size'] is String
                        ? (double.tryParse(
                                p['size'].toString().replaceAll(
                                  RegExp(r'[^0-9.]'),
                                  '',
                                ),
                              ) ??
                              0.0)
                        : (p['size'] as num?)?.toDouble() ?? 0.0,
                    dimensions: p['dimensions']?.toString() ?? 'N/A',
                    facing: p['facing']?.toString() ?? 'N/A',
                    roadWidth: p['road']?.toString() ?? 'N/A',
                    status: _parsePlotStatus(p['status']),
                    price: (p['price'] as num?)?.toDouble() ?? 0.0,
                  ),
                )
                .toList()
          : [],
    );
  }

  static PlotStatus _parsePlotStatus(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return PlotStatus.available;
      case 'HOLD':
        return PlotStatus.hold;
      case 'BOOKED_SOLD':
        return PlotStatus.bookedSold;
      default:
        return PlotStatus.available;
    }
  }
}
