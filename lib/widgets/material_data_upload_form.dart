import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';

//This is the material widget used to input text data in the Dashboard Screen editing or creating form
// ignore: must_be_immutable
class MaterialDataUploadForm extends StatefulWidget {
  MaterialDataUploadForm(
      {super.key,
      required this.name,
      required this.setName,
      required this.county,
      required this.setCounty,
      required this.description,
      required this.setDescription,
      required this.routesInfo,
      required this.setRoutesInfo,
      required this.androidMapLink,
      required this.setandroidMapLink,
      required this.iosMapLink,
      required this.setIosMapLink,
      required this.partialSubmitForm,
      required this.isEdit});
  final String name;
  final void Function(String) setName;
  String county;
  final void Function(String) setCounty;
  final String description;
  final void Function(String) setDescription;
  final String routesInfo;
  final void Function(String) setRoutesInfo;
  final String androidMapLink;
  final void Function(String) setandroidMapLink;
  final String iosMapLink;
  final void Function(String) setIosMapLink;
  final Future<void> Function() partialSubmitForm;
  final bool isEdit;

  @override
  State<MaterialDataUploadForm> createState() => _MaterialDataUploadFormState();
}

class _MaterialDataUploadFormState extends State<MaterialDataUploadForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          readOnly: widget.isEdit,
          initialValue: widget.name,
          decoration: const InputDecoration(labelText: 'Spot Name:'),
          validator: ValidationBuilder()
              .minLength(3, 'The name should be at least 3 characters long')
              .maxLength(30, 'The name should be at most 30 characters long')
              .build(),
          onSaved: (newValue) {
            widget.setName(newValue!);
          },
        ),
        DropdownButtonFormField(
          value: widget.county,
          items: const [
            DropdownMenuItem(value: 'Cluj', child: Text('Cluj')),
            DropdownMenuItem(value: 'Sălaj', child: Text('Sălaj')),
            DropdownMenuItem(value: 'Bihor', child: Text('Bihor')),
          ],
          onChanged: (value) {
            setState(() {
              widget.county = value!;
            });
          },
          onSaved: (newValue) {
            widget.setCounty(newValue!);
          },
        ),
        TextFormField(
          initialValue: widget.description,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(labelText: 'Spot Description:'),
          validator: ValidationBuilder().build(),
          onSaved: (newValue) {
            widget.setDescription(newValue!);
          },
        ),
        TextFormField(
          initialValue: widget.routesInfo,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Routes Info:'),
          validator: ValidationBuilder().build(),
          onSaved: (newValue) {
            widget.setRoutesInfo(newValue!);
          },
        ),
        TextFormField(
          initialValue: widget.androidMapLink,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
              labelText: 'Link for android GoogleMaps or browser:'),
          validator: ValidationBuilder().url().build(),
          onSaved: (newValue) {
            widget.setandroidMapLink(newValue!);
          },
        ),
        TextFormField(
          initialValue: widget.iosMapLink,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
              labelText: 'Link for iOS AppleMaps or browser:'),
          validator: ValidationBuilder().url().build(),
          onSaved: (newValue) {
            widget.setIosMapLink(newValue!);
          },
        ),
        const SizedBox(
          height: 25,
        ),
        ElevatedButton(
          onPressed: widget.partialSubmitForm,
          child: const Text('Submit information and start uploading images'),
        ),
      ],
    );
  }
}
