import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'spot.g.dart';

@JsonSerializable()
class Spot extends ChangeNotifier {
  Spot({
    this.id,
    required this.name,
    required this.county,
    this.description,
    this.descriptionImage,
    this.routes,
    this.routesInfo,
    this.images,
    this.androidMapLink,
    this.iosMapLink,
  });

  //  The @JsonKey atribute is required if using int type keys
  // @JsonKey(fromJson: _stringToInt, toJson: _intToString)
  String? id;
  final String name;
  final String county;
  //using nullables because some fields will be optional and in order to avoid errors
  //null values will make it more clear which values are to be used at compile time
  final String? description;
  final String? descriptionImage;
  final List<String>? routes;
  final String? routesInfo;
  final List<String>? images;
  final String? androidMapLink;
  final String? iosMapLink;

  factory Spot.fromJson(Map<String, dynamic> json) => _$SpotFromJson(json);

  Map<String, dynamic> toJson() => _$SpotToJson(this);

  //The next 2 methods are require for serializing int type keys
  // static int _stringToInt(String value) => int.parse(value);
  // static String _intToString(int value) => value.toString();

  //to do setter after implementing dashboard
}
