import 'package:flutter/cupertino.dart';
import 'package:form_validator/form_validator.dart';

//This is the cupertino widget used to input text data in the Dashboard Screen editing or creating form
// ignore: must_be_immutable
class CupertinoDataUploadForm extends StatefulWidget {
  CupertinoDataUploadForm(
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
  State<CupertinoDataUploadForm> createState() =>
      _CupertinoDataUploadFormState();
}

class _CupertinoDataUploadFormState extends State<CupertinoDataUploadForm> {
  List<String> countiesCupertino = ['Cluj', 'Sălaj', 'Bihor'];

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoTextFormFieldRow(
          readOnly: widget.isEdit,
          initialValue: widget.name,
          prefix: const Text('Spot Name:'),
          placeholder: '',
          validator: ValidationBuilder()
              .minLength(3, 'The name should be at least 3 characters long')
              .maxLength(30, 'The name should be at most 30 characters long')
              .build(),
          onSaved: (newValue) {
            widget.setName(newValue!);
          },
        ),
        Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            const Text('Select a county:'),
            CupertinoButton(
              onPressed: () {
                _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: 32,
                    // This is called when selected item is changed.
                    onSelectedItemChanged: (int selectedItem) {
                      setState(() {
                        widget.county = countiesCupertino[selectedItem];
                      });
                      widget.setCounty(widget.county);
                    },
                    children: List<Widget>.generate(countiesCupertino.length,
                        (int index) {
                      return Center(
                        child: Text(
                          countiesCupertino[index],
                        ),
                      );
                    }),
                  ),
                );
              },
              child: Text(widget.county),
            )
          ],
        ),
        CupertinoTextFormFieldRow(
          initialValue: widget.description,
          prefix: const Text('Spot Description:'),
          placeholder: '',
          minLines: 3,
          maxLines: 5,
          validator: ValidationBuilder().build(),
          onSaved: (newValue) {
            widget.setDescription(newValue!);
          },
        ),
        CupertinoTextFormFieldRow(
          initialValue: widget.routesInfo,
          prefix: const Text('Routes Info:'),
          placeholder: '',
          minLines: 2,
          maxLines: 3,
          validator: ValidationBuilder().build(),
          onSaved: (newValue) {
            widget.setRoutesInfo(newValue!);
          },
        ),
        CupertinoTextFormFieldRow(
          initialValue: widget.androidMapLink,
          prefix: const Text('Link Android:'),
          placeholder: '',
          minLines: 2,
          maxLines: 3,
          validator: ValidationBuilder().url().build(),
          onSaved: (newValue) {
            widget.setandroidMapLink(newValue!);
          },
        ),
        CupertinoTextFormFieldRow(
          initialValue: widget.iosMapLink,
          prefix: const Text('Link IOS:'),
          placeholder: '',
          minLines: 2,
          maxLines: 3,
          validator: ValidationBuilder().url().build(),
          onSaved: (newValue) {
            widget.setIosMapLink(newValue!);
          },
        ),
        const SizedBox(
          height: 25,
        ),
        CupertinoButton.filled(
          onPressed: widget.partialSubmitForm,
          child: const Text('Submit information and start uploading images'),
        ),
      ],
    );
  }
}
