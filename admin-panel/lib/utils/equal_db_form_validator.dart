import "package:reactive_forms/reactive_forms.dart";

class EqualValidationMessage {
  static const equal = "equal";
}

class EqualDbFormValidator extends Validator<dynamic> {
  final AbstractControl<dynamic> otherControl;

  EqualDbFormValidator(this.otherControl);

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final otherValue = otherControl.value;
    final controlValue = control.value;

    if (otherValue != controlValue) {
      return {EqualValidationMessage.equal: true};
    }

    return null;
  }
}
