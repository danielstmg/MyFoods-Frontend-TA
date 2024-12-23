import 'package:flutter/material.dart';
import 'package:recepku/theme/color_palette.dart';

class FormTextFieldWidget extends StatefulWidget {
  final String text;
  final IconData icon;
  final bool isPasswordType;
  final TextEditingController controller;
  final String warningText;

  const FormTextFieldWidget({
    Key? key,
    required this.text,
    required this.icon,
    required this.isPasswordType,
    required this.controller,
    required this.warningText,
  }) : super(key: key);

  @override
  _FormTextFieldWidgetState createState() => _FormTextFieldWidgetState();
}

class _FormTextFieldWidgetState extends State<FormTextFieldWidget> {
  late bool isObscure;

  @override
  void initState() {
    super.initState();
    isObscure = widget.isPasswordType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          obscureText: isObscure,
          enableSuggestions: !isObscure,
          autocorrect: !isObscure,
          cursorColor: Colors.black,
          style: TextStyle(color: Colors.black.withOpacity(0.9)),
          decoration: InputDecoration(
            suffixIcon: widget.isPasswordType
                ? IconButton(
                    icon: Icon(
                      isObscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black.withOpacity(0.9),
                    ),
                    onPressed: () {
                      setState(() {
                        isObscure = !isObscure;
                      });
                    },
                  )
                : null,
            prefixIcon: Icon(
              widget.icon,
              color: Colors.black.withOpacity(0.9),
            ),
            labelText: widget.text,
            labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
            filled: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            fillColor: ColorPalette.shale.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(width: 0, style: BorderStyle.none),
            ),
          ),
          keyboardType: widget.isPasswordType
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
        ),
        if (widget.warningText != "")
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Text(
              widget.warningText,
              style: const TextStyle(color: Colors.red),
            ),
          )
        else
          Container(),
      ],
    );
  }
}
