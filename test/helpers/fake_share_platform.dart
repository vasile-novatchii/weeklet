import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

/// A settable [SharePlatform] fake that records `share()` calls instead of
/// hitting a real platform channel.
///
/// Extends [SharePlatform] directly (no `MockPlatformInterfaceMixin`) — the
/// default no-arg constructor already calls `super(token: _token)`, which
/// satisfies `PlatformInterface`'s token check.
class FakeSharePlatform extends SharePlatform {
  final List<ShareParams> shareCalls = [];

  /// When true, [share] throws after recording the call.
  bool shouldThrow = false;

  @override
  Future<ShareResult> share(ShareParams params) async {
    shareCalls.add(params);
    if (shouldThrow) throw StateError('share failed');
    return const ShareResult('', ShareResultStatus.dismissed);
  }

  /// Clears recorded calls — call from `setUp` (not just `setUpAll`) when a
  /// test file has more than one `testWidgets` sharing a single instance.
  void reset() {
    shareCalls.clear();
    shouldThrow = false;
  }
}
