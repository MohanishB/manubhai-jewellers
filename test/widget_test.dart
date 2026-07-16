// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:manubhaimlt/app/app.dart';

// import 'package:manubhaimlt/main.dart';

// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MJMLTApp());

//     // Verify that our counter starts at 0.
//     // expect(find.text('0'), findsOneWidget);
//     // expect(find.text('1'), findsNothing);

//     // // Tap the '+' icon and trigger a frame.
//     // await tester.tap(find.byIcon(Icons.add));
//     // await tester.pump();

//     // // Verify that our counter has incremented.
//     // expect(find.text('0'), findsNothing);
//     // expect(find.text('1'), findsOneWidget);
//   });
// }

///////////=============///////////////

// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:manubhaimlt/app/app.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';

// void main() {
//   testWidgets('App builds', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       BlocProvider(
//         create: (_) => AuthBloc()..add(const AuthAppStarted()),
//         child: const MJMLTApp(),
//       ),
//     );

//     await tester.pump();
//     expect(tester.takeException(), isNull);
//   });
// }

///////////=============///////////////
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:manubhaimlt/app/app.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
// import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
// import 'package:manubhaimlt/features/auth/data/repositories/auth_repository.dart';

// void main() {
//   testWidgets('App builds', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       BlocProvider(
//         create: (_) => AuthBloc(
//           AuthRepository(
//             baseUrl: 'https://vitazreportingservices.com/mlt_app_webservices',
//           ),
//         )..add(const AuthAppStarted()),
//         child: const MJMLTApp(),
//       ),
//     );

//     await tester.pump();
//     expect(tester.takeException(), isNull);
//   });
// }

//==============================================================//

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:manubhaimlt/app/app.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/data/repositories/auth_repository.dart';
import 'package:manubhaimlt/features/auth/data/repositories/firebase_log_repository.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    final authRepository =
        AuthRepository(baseUrl: 'https://vitazreportingservices.com/mlt_app_webservices');
    final firebaseLogRepository = CSEFirebaseLogRepository(baseUrl: 'https://vitazreportingservices.com/mlt_app_webservices');

    await tester.pumpWidget(
      BlocProvider(
          create: (_) => AuthBloc(
            repository: authRepository,
            firebaseLogRepo: firebaseLogRepository,
          )..add(const AuthAppStarted()),
        ),
      // BlocProvider(
      //   create: (_) => AuthBloc(repository: authRepository)..add(const AuthAppStarted()),
      //   child: const MJMLTApp(),
      // ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
