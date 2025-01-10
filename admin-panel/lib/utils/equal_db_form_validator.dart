import "package:reactive_forms/reactive_forms.dart";

class NotEqualValidationMessage {
  static const notEqual = "notEqual";
}

class EqualAsOtherFormValidator extends Validator<dynamic> {
  final AbstractControl<dynamic> otherControl;

  EqualAsOtherFormValidator(this.otherControl);

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final otherValue = otherControl.value;
    final thisValue = control.value;

    if (otherValue != thisValue) {
      return {
        NotEqualValidationMessage.notEqual: false, // validation failed
      };
    }

    return null;
  }
}
