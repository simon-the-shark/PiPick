import "package:riverpod_annotation/riverpod_annotation.dart";

import "../../../database/models.dart";
import "../../../mqtt_client.dart";
import "../../admin/data/admin_repository.dart";

part "auth_service.g.dart";

@riverpod
class AuthService extends _$AuthService {
  @override
  Admin? build() {
    return null;
  }

  Future<bool> login(String login, String password, String ipNumber) async {
    final repository = ref.watch(adminRepositoryProvider.notifier);
    final admin = await repository.validateAuth(login, password);
    if (admin != null) {
      ref.read(mqttHostProvider.notifier).setIp(ipNumber);
    }
    state = admin;
    return admin != null;
  }

  void logout() {
    state = null;
  }
}
