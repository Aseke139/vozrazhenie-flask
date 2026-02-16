import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_task_manager/main.dart';

void main() {
  testWidgets('app starts with Blocks title', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    expect(find.text('Blocks'), findsOneWidget);
  });
}
