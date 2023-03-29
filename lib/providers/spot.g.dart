// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Spot _$SpotFromJson(Map<String, dynamic> json) => Spot(
      id: json['id'] as String?,
      name: json['name'] as String,
      county: json['county'] as String,
      description: json['description'] as String?,
      descriptionImage: json['descriptionImage'] as String?,
      routes:
          (json['routes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      routesInfo: json['routesInfo'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      androidMapLink: json['androidMapLink'] as String?,
      iosMapLink: json['iosMapLink'] as String?,
    );

Map<String, dynamic> _$SpotToJson(Spot instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'county': instance.county,
      'description': instance.description,
      'descriptionImage': instance.descriptionImage,
      'routes': instance.routes,
      'routesInfo': instance.routesInfo,
      'images': instance.images,
      'androidMapLink': instance.androidMapLink,
      'iosMapLink': instance.iosMapLink,
    };
