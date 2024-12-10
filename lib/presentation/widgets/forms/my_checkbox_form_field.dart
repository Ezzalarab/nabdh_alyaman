import 'package:flutter/material.dart';

class MyCheckboxFormField extends FormField<bool> {
  MyCheckboxFormField({
    super.key,
    required Widget title,
    required FormFieldSetter<bool> super.onSaved,
    super.validator,
    bool super.initialValue = false,
    bool autovalidate = false,
  }) : super(
          builder: (FormFieldState<bool> state) {
            return CheckboxListTile(
              dense: state.hasError,
              title: title,
              value: state.value,
              onChanged: state.didChange,
              subtitle: state.hasError
                  ? Builder(
                      builder: (BuildContext context) => Text(
                        state.errorText?.toString() ?? "",
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    )
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
}
