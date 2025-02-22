import "dart:async";

import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:isar/isar.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";

import "../../../database/models.dart";
import "../../../utils/unique_db_form_validator.dart";
import "../data/acces_zones_repository.dart";
import "allowed_sers_subform.dart";

part "zone_form.freezed.dart";
part "zone_form.gform.dart";

@Rf()
@freezed
class ZoneForm with _$ZoneForm {
  factory ZoneForm({
    @RfControl(
      validators: [
        NumberValidator(
          allowNegatives: false,
        ),
        RequiredValidator(),
      ],
    )
    required String number,
    @RfControl(
      validators: [RequiredValidator()],
    )
    required String location,
    @RfArray() required List<User> allowedUsers,
  }) = _ZoneForm;
}

class ZoneFormDialog extends ConsumerWidget {
  const ZoneFormDialog({
    super.key,
    this.initialData,
  });

  final AccessZone? initialData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ZoneFormFormBuilder(
      initState: (context, formModel) {
        formModel.numberControl.setAsyncValidators([
          UniqueDbFormValidator(
            (number) async {
              return ref
                  .read(accessZonesRepositoryProvider.notifier)
                  .isNumberUnique(int.parse(number));
            },
          ),
        ]);
      },
      model: ZoneForm(
        number: initialData?.number.toString() ?? "",
        location: initialData?.location ?? "",
        allowedUsers: initialData?.zoneAllowedUsers.toList() ?? [],
      ),
      builder: (context, formModel, child) {
        return _FormContent(
          formModel: formModel,
          initialData: initialData,
        );
      },
    );
  }
}

class _FormContent extends ConsumerWidget {
  const _FormContent({
    required this.formModel,
    required this.initialData,
  });

  final ZoneFormForm formModel;
  final AccessZone? initialData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onSubmit() async {
      formModel.form.markAllAsTouched();
      if (formModel.form.valid) {
        unawaited(
          ref.read(accessZonesRepositoryProvider.notifier).putZone(
                AccessZone()
                  ..id = initialData?.id ?? Isar.autoIncrement
                  ..location = formModel.locationControl.value!
                  ..number = int.parse(formModel.numberControl.value!),
                formModel.allowedUsersControl.value
                    ?.whereType<User>()
                    .toIList(),
              ),
        );
        Navigator.of(context).pop();
      }
    }

    void onCancel() {
      Navigator.of(context).pop();
    }

    return AlertDialog(
      title: Text(
        initialData == null ? "Dodaj strefę dostępu" : "Edytuj strefę dostępu",
      ),
      scrollable: true,
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 24,
          children: [
            ReactiveTextField<String>(
              formControl: formModel.numberControl,
              validationMessages: {
                ValidationMessage.required: (_) =>
                    "Numer strefy nie może być pusty",
                ValidationMessage.number: (_) =>
                    "Numer strefy musi być dodatnią liczbą",
                MyValidationMessage.unique: (_) =>
                    "Numer strefy musi być unikalny",
              },
              decoration: const InputDecoration(
                labelText: "Numer strefy",
                hintText: "np. 1123",
              ),
            ),
            ReactiveTextField<String>(
              formControl: formModel.locationControl,
              validationMessages: {
                ValidationMessage.required: (_) =>
                    "Opis miejsca strefy nie może być puste",
              },
              decoration: const InputDecoration(
                labelText: "Lokalizacja/Nazwa",
                hintText: "np. Biuro 1",
              ),
              keyboardType: TextInputType.name,
            ),
            AllowedUsersSubform(formModel: formModel),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text("Anuluj"),
        ),
        SubmitButton(onSubmit: onSubmit),
      ],
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key, required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ReactiveZoneFormFormConsumer(
      builder: (context, formModel, child) {
        return ElevatedButton(
          onPressed: formModel.form.valid ? onSubmit : null,
          child: const Text("Zapisz"),
        );
      },
    );
  }
}
