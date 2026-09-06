import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const double kWideBreakpoint = 600;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.blue),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({required this.isDark, required this.onDarkChanged, super.key});
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Academic Overview'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 4),
              Semantics(
                label: 'Mode gelap',
                toggled: isDark,
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Semantics(
            label: 'Profil mahasiswa, Dewi Chalissa Rania, NIM 244107020023, semester 5',
            container: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Row(
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dewi Chalissa Rania',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Mahasiswa | Semester 5',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'NIM: 244107020023',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= kWideBreakpoint ? 2 : 1;
                return GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.6,
                  children: const [
                    InfoCard(title: 'Assignments', value: '8'),
                    InfoCard(title: 'Attendance', value: '92%'),
                    InfoCard(title: 'Study Status', value: 'Active'),
                    InfoCard(title: 'Current week', value: '02'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: '$title: $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}