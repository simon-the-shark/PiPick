import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

class MyValidationMessage {
  static const unique = "unique";
}

class UniqueDbFormValidator extends AsyncValidator<dynamic> {
  UniqueDbFormValidator(this.uniqueCheck);

  final Future<bool> Function(String) uniqueCheck;

  @override
  Future<Map<String, dynamic>?> validate(
    AbstractControl<dynamic> control,
  ) async {
    final error = {MyValidationMessage.unique: false};

    final isUnique = await uniqueCheck(control.value.toString());
    if (!isUnique) {
      control.markAsTouched();
      return error;
    }

    return null;
  }
}
