import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/l10n/app_localizations.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_cancel_button.dart';
import 'package:weeklet/presentation/screens/categories/widgets/category_form_footer_view/category_form_footer_view.dart';

void main() {
  Future<void> pumpFooter(WidgetTester tester, double bottomInset) async {
    final controller = TextEditingController();
    final notifier = ValueNotifier<CategoryIcon?>(null);
    addTearDown(controller.dispose);
    addTearDown(notifier.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            viewPadding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: child!,
        ),
        home: Scaffold(
          bottomNavigationBar: CategoryFormFooterView(
            isLoading: false,
            onSave: () {},
            onCancel: () {},
            nameController: controller,
            selectedIconNotifier: notifier,
          ),
        ),
      ),
    );
  }

  double gapBelowCancel(WidgetTester tester) {
    final surfaceHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    final cancelBottom = tester
        .getBottomLeft(find.byType(CategoryFormCancelButton))
        .dy;
    return surfaceHeight - cancelBottom;
  }

  testWidgets('footer clears the system bottom inset', (tester) async {
    await pumpFooter(tester, 34);
    expect(gapBelowCancel(tester), 12 + 8 + 34);
  });

  testWidgets('footer keeps base padding with no system inset', (tester) async {
    await pumpFooter(tester, 0);
    expect(gapBelowCancel(tester), 12 + 8);
  });
}
