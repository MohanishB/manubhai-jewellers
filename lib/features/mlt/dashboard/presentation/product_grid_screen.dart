import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manubhaimlt/core/widgets/mj_scaffold.dart';
import 'package:manubhaimlt/core/widgets/mj_dropdown_field.dart'; // ✅ your dropdown
import 'package:manubhaimlt/features/auth/bloc/auth_bloc.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_event.dart';
import 'package:manubhaimlt/features/auth/bloc/auth_state.dart';

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

enum SortBy { price, carat, age }

class _ProductGridScreenState extends State<ProductGridScreen> {
  // UI: GRID dropdown 5 / 3 / 2
  int _gridChoice = 5;

  // UI: Sort row
  SortBy _sortBy = SortBy.price;

  // Selected filters shown as chips beside menu icon
  final List<String> _chips = [
    'Ring',
    'Mens',
    'Destiny',
    '0.5 - 1.5 Ct',
    '100000-200000',
  ];

  final Set<int> _selectedIds = {};

  late final List<_ProductVm> _products;

  @override
  void initState() {
    super.initState();

    // Static demo product images (replace later with API)
    // final urls = <String>[
    //   'https://images.unsplash.com/photo-1603575448360-153f093fd0ea?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1617038220319-27625c7a6df7?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1600180758895-6c7f21b13f27?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1617038260898-277a0a2e5d18?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1600180759142-3f8d9b63cc1f?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1617038260862-1c52f4fb1514?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1605100804985-4102b60d1a2b?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1600180759188-3a6a5a3b5c8d?auto=format&fit=crop&w=900&q=80',
    //   'https://images.unsplash.com/photo-1617038260947-6c12e7260213?auto=format&fit=crop&w=900&q=80',
    // ];

    final urls = List.generate(
      10,
      (i) => 'https://picsum.photos/seed/${i + 1}/800/800',
    );


    _products = List.generate(
      20,
      (i) => _ProductVm(
        id: i + 1,
        imageUrl: urls[i % urls.length],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state as AuthAuthenticated;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Allow 5/3/2 on tablet, cap on phone
    final gridColumns =
        isTablet ? _gridChoice : (_gridChoice == 5 ? 2 : _gridChoice);

    return MJScaffold(
      username: auth.user.firstName,
      onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
      requestSafeCount: _selectedIds.length,
      receivedSafeCount: 0,
      onRequestedList: () => {},
      onRequestSafe: () => context.go('/safe/request'),
      onReceivedSafe: () => context.go('/safe/received'),
      onCustomerExperience: () => context.go('/feedback'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Hamburger + selected filter chips + GRID dropdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ Selected filter chips (blue theme) beside menu icon
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _chips.map(_chipBlue).toList(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ✅ Grid dropdown (5/3/2) using MJDropdownField
                _gridDropdownInline(),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Products found + Sort row (right)
            Row(
              children: [
                const Text(
                  '100 Products Found',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                _sortRow(),
              ],
            ),

            const SizedBox(height: 10),

            // Grid (images + check mark)
            Expanded(
              child: GridView.builder(
                itemCount: _products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridColumns,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: isTablet ? 1.02 : 0.90,
                ),
                itemBuilder: (context, index) {
                  final p = _products[index];
                  final selected = _selectedIds.contains(p.id);

                  return _productCard(
                    product: p,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(p.id);
                        } else {
                          _selectedIds.add(p.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Blue theme chip with close icon (matches your button blue)
  Widget _chipBlue(String label) {
    const blue = Color(0xFF1E5AA8);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: blue, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: blue,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => setState(() => _chips.remove(label)),
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.close, size: 16, color: blue),
          ),
        ],
      ),
    );
  }

  // ✅ “GRID DROPDOWN 5 /3/ 2” using MJDropdownField
  Widget _gridDropdownInline() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'GRID DROPDOWN',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 105,
          child: MJDropdownField<int>(
            value: _gridChoice,
            hintText: '5 / 3 / 2',
            items: const [
              DropdownMenuItem(value: 5, child: Text('5')),
              DropdownMenuItem(value: 3, child: Text('3')),
              DropdownMenuItem(value: 2, child: Text('2')),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _gridChoice = v);
            },
          ),
        ),
      ],
    );
  }

  // “Sort Price, Carat, Age ???” right side
  Widget _sortRow() {
    Widget item(String text, SortBy value) {
      final selected = _sortBy == value;
      return InkWell(
        onTap: () => setState(() => _sortBy = value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? const Color(0xFF1E5AA8) : Colors.black87,
              decoration:
                  selected ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Sort ', style: TextStyle(fontWeight: FontWeight.w800)),
        item('Price,', SortBy.price),
        item('Carat,', SortBy.carat),
        item('Age ???', SortBy.age),
      ],
    );
  }

  // Product image tile with checkmark bottom-left
  Widget _productCard({
    required _ProductVm product,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white54),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          if (selected)
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E5AA8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductVm {
  final int id;
  final String imageUrl;

  _ProductVm({required this.id, required this.imageUrl});
}
