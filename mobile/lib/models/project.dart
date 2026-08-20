import 'plot.dart';
import 'plot_status.dart';
import '../utils/bilingual_helper.dart';

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
  final String googleMap;
  final String projectVideo;

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
    this.googleMap = '',
    this.projectVideo = '',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    List<String> parsedAmenities = [];
    if (json['facilities'] != null) {
      parsedAmenities = (json['facilities'] as List).map((f) => BilingualHelper.get(f)).toList();
    } else if (json['amenities'] != null) {
      parsedAmenities = (json['amenities'] as List).map((a) => BilingualHelper.get(a)).toList();
    }

    return Project(
      id: json['id'] as String,
      name: BilingualHelper.get(json['name']),
      location: BilingualHelper.get(json['location']),
      description: BilingualHelper.get(json['description']),
      coverImage: json['coverImage'] as String? ?? '',
      gallery:
          (json['gallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      priceRange: BilingualHelper.get(json['plotPrice'] ?? json['priceRange']),
      developmentStatus: BilingualHelper.get(json['developmentStatus']),
      amenities: parsedAmenities,
      plotCount: json['plots'] != null ? (json['plots'] as List).length : 0,
      googleMap: json['googleMap'] as String? ?? '',
      projectVideo: json['projectVideo'] as String? ?? '',
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
                    facing: BilingualHelper.get(p['facing']),
                    roadWidth: BilingualHelper.get(p['road'] ?? p['roadWidth']),
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
