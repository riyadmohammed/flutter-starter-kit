import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:dumbdumb_flutter_app/app/view/main_navigation_shell.dart';

// Mock for StatefulNavigationShell
// It needs to be a widget because MainNavigationShell places it in the Scaffold body.
class MockStatefulNavigationShell extends StatelessWidget implements StatefulNavigationShell {
  final int initialIndex;
  int _currentIndex;
  int? lastGoBranchIndexCalled;
  bool? lastGoBranchInitialLocationParam;

  // This is a simple child widget to represent the body.
  // In a real scenario, this would be one of the branch navigators.
  final Widget child;

  MockStatefulNavigationShell({
    super.key,
    this.initialIndex = 0,
    required this.child,
  }) : _currentIndex = initialIndex;

  @override
  int get currentIndex => _currentIndex;

  @override
  void goBranch(int index, {bool initialLocation = false}) {
    _currentIndex = index;
    lastGoBranchIndexCalled = index;
    lastGoBranchInitialLocationParam = initialLocation;
    // In a real app, this would trigger navigation and rebuilds.
    // For testing, we manually update the state and expect the test to pump.
    print('MockStatefulNavigationShell: goBranch called with index $index, initialLocation: $initialLocation. CurrentIndex is now $_currentIndex');
  }

  // Other methods from StatefulNavigationShell that might be called if the widget was more complex
  // or if StatefulNavigationShell had abstract methods that are not directly used by MainNavigationShell
  // but are required by the interface. For now, we are focusing on what MainNavigationShell uses.

  @override
  Widget build(BuildContext context) {
    // Returns the child widget, which simulates the current page/view of the shell.
    // We can use different keys to ensure widget rebuilds if necessary.
    return IndexedStack(
      index: _currentIndex,
      children: [
        Container(key: const ValueKey('mock_child_0')), // Represents view for index 0
        Container(key: const ValueKey('mock_child_1')), // Represents view for index 1
      ],
    );
  }

  // Required by StatefulNavigationShell, but we don't need complex implementations for this mock.
  @override
  List<RouteBase> get routes => [];

  @override
  List<GlobalKey<NavigatorState>> get navigatorKeys => [];

  @override
  State<StatefulNavigationShell> createState() {
    // This is problematic as StatefulNavigationShell is abstract and its state is internal.
    // However, our MainNavigationShell only interacts with the `StatefulNavigationShell` instance directly,
    // not its state object. And since our mock is a StatelessWidget, this won't be called.
    // If it were a StatefulWidget, we'd need a corresponding State object.
    throw UnimplementedError('createState is not used by this StatelessWidget mock');
  }
}

// A helper widget to provide MaterialApp and other necessary ancestors for testing.
Widget testApp(Widget child) {
  return MaterialApp(
    home: child,
  );
}

void main() {
  testWidgets('MainNavigationShell Renders Test', (WidgetTester tester) async {
    final mockShell = MockStatefulNavigationShell(child: Container(key: const ValueKey('mock_child_0')));

    await tester.pumpWidget(testApp(MainNavigationShell(navigationShell: mockShell)));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    // Check if the mock shell's body is rendered
    expect(find.byKey(const ValueKey('mock_child_0')), findsOneWidget);
  });

  testWidgets('BottomNavigationBar Items Test', (WidgetTester tester) async {
    final mockShell = MockStatefulNavigationShell(child: Container());
    await tester.pumpWidget(testApp(MainNavigationShell(navigationShell: mockShell)));

    final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavBar.items.length, 2);

    // Check Home item
    expect(find.widgetWithText(BottomNavigationBar, 'Home'), findsOneWidget); // Checks if 'Home' text is descendant
    expect(find.widgetWithIcon(BottomNavigationBar, Icons.home), findsOneWidget); // Checks if home icon is descendant

    // Check Profile item
    expect(find.widgetWithText(BottomNavigationBar, 'Profile'), findsOneWidget);
    expect(find.widgetWithIcon(BottomNavigationBar, Icons.person), findsOneWidget);

    // More specific check for item properties
    final homeItem = bottomNavBar.items[0];
    expect(homeItem.label, 'Home');
    expect((homeItem.icon as Icon).icon, Icons.home);

    final profileItem = bottomNavBar.items[1];
    expect(profileItem.label, 'Profile');
    expect((profileItem.icon as Icon).icon, Icons.person);
  });

  testWidgets('Navigation Tapping Test', (WidgetTester tester) async {
    final mockShell = MockStatefulNavigationShell(
      initialIndex: 0,
      child: Container(), // Placeholder child
    );

    await tester.pumpWidget(testApp(MainNavigationShell(navigationShell: mockShell)));

    // Initial state check
    expect(mockShell.currentIndex, 0);
    expect(find.byKey(const ValueKey('mock_child_0')), findsOneWidget); // Initial view
    expect(find.byKey(const ValueKey('mock_child_1')), findsNothing);


    // Tap Profile (index 1)
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle(); // pumpAndSettle to allow for animations and state changes

    expect(mockShell.lastGoBranchIndexCalled, 1);
    // MainNavigationShell is a StatelessWidget, its rebuild depends on its parent.
    // In this test setup, testApp/MaterialApp won't rebuild MainNavigationShell just because mockShell's internal state changed.
    // However, BottomNavigationBar.onTap *will* call mockShell.goBranch.
    // And BottomNavigationBar.currentIndex *will* read mockShell.currentIndex.
    // So, to reflect the change in currentIndex in the BottomNavigationBar, we need to make the mock part of the widget tree
    // that *does* rebuild, or trigger a rebuild of MainNavigationShell with the updated mock.
    // A better way for the mock to work is to have it be a StatefulWidget itself, or use a ValueNotifier.

    // Let's re-evaluate the mock. Since MainNavigationShell takes `navigationShell` as a final field,
    // for `BottomNavigationBar.currentIndex` to update, `MainNavigationShell` itself needs to be rebuilt
    // with a `navigationShell` that has an updated `currentIndex`.
    // The current mock updates its internal `_currentIndex` when `goBranch` is called.
    // The `BottomNavigationBar` in `MainNavigationShell` reads `navigationShell.currentIndex` directly.
    // So, if `mockShell` instance is the same, `BottomNavigationBar.currentIndex` will reflect `_currentIndex`.

    expect(mockShell.currentIndex, 1); // Verifying the mock's internal state changed via goBranch
                                       // And that BottomNavigationBar displays this correctly.
    final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavBar.currentIndex, 1);
    // We also need to ensure the body of the scaffold (which is the mockShell itself) reflects this change.
    // Since mockShell rebuilds with an IndexedStack, this should work.
    expect(find.byKey(const ValueKey('mock_child_0')), findsNothing);
    expect(find.byKey(const ValueKey('mock_child_1')), findsOneWidget);


    // Tap Home (index 0)
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    expect(mockShell.lastGoBranchIndexCalled, 0);
    expect(mockShell.currentIndex, 0);
    final updatedBottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(updatedBottomNavBar.currentIndex, 0);
    expect(find.byKey(const ValueKey('mock_child_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('mock_child_1')), findsNothing);
  });
}
