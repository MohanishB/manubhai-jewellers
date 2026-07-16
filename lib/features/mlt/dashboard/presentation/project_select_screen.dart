import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_event.dart';
import '../../../auth/bloc/auth_state.dart';

class ProjectSelectScreen extends StatelessWidget {
  const ProjectSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final auth = authState;

    final projects = <_ProjectTileVm>[
      _ProjectTileVm(
        title: 'Golden Eye',
        subtitle: '',
        onTap: () => context.go('/mjt'),
      ),
      _ProjectTileVm(
        title: 'Solitaire',
        subtitle: '',
        onTap: () => context.go('/solitaire/step1'),
      ),
      _ProjectTileVm(
        title: 'Solishift - LG',
        subtitle: '',
        onTap: () => context.go('/solishift-lg'),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(
                children: [
                  Image.asset(
                    'assets/images/mj_logo_blue_text.png',
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),
                  Text(
                    'Welcome, ${auth.user.firstName}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 16),
                  InkWell(
                    onTap: () => context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested()),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Select Project',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),

              // ✅ Responsive square grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // You can tweak these
                    const minTileWidth = 160.0;

                    final crossAxisCount = (constraints.maxWidth / minTileWidth)
                        .floor()
                        .clamp(2, 4);

                    // Rectangular tiles
                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      itemCount: projects.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300, // smaller card width
                        mainAxisExtent: 160, // fixed card height
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final p = projects[index];
                        return ProjectTile(
                          title: p.title,
                          subtitle: p.subtitle,
                          onTap: p.onTap,
                        );
                      },
                    );

                    // Square tiles
                    // return GridView.builder(
                    //   itemCount: projects.length,
                    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: crossAxisCount,
                    //     crossAxisSpacing: 14,
                    //     mainAxisSpacing: 14,
                    //     childAspectRatio: 1, // ✅ square tiles
                    //   ),
                    //   itemBuilder: (context, index) {
                    //     final p = projects[index];
                    //     return ProjectTile(
                    //       title: p.title,
                    //       subtitle: p.subtitle,
                    //       onTap: p.onTap,
                    //     );
                    //   },
                    // );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectTileVm {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _ProjectTileVm({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

// Square tile 
// class _ProjectTile extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final VoidCallback onTap;

//   const _ProjectTile({
//     required this.title,
//     required this.subtitle,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const blue = Color(0xFF1E5AA8);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: const Color(0xFFE0E0E0)),
//           borderRadius: BorderRadius.circular(14),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x14000000),
//               blurRadius: 10,
//               offset: Offset(0, 4),
//             )
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // icon
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE9EEF6),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Icon(Icons.grid_view_rounded, color: blue),
//             ),

//             const SizedBox(height: 12),

//             // title
//             Text(
//               title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
//             ),
//             const SizedBox(height: 6),

//             // subtitle (prevent overflow)
//             Expanded(
//               child: Text(
//                 subtitle,
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//                 style: const TextStyle(color: Colors.black54, height: 1.2),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // bottom "Open →" (stays inside tile)
//             Row(
//               children: const [
//                 Text(
//                   'Open',
//                   style: TextStyle(
//                     color: blue,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(width: 6),
//                 Icon(Icons.arrow_forward, size: 18, color: blue),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// Rectangular tile
class ProjectTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProjectTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color blue = Color(0xFF1E5AA8);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 220, // Fixed rectangular height
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EEF6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: blue,
              ),
            ),

            const SizedBox(height: 12),

            /// Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            /// Subtitle
            Expanded(
              child: Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ),

            const SizedBox(height: 8),

            /// Bottom Action
            const Row(
              children: [
                Text(
                  'Open',
                  style: TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  size: 20,
                  color: blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}