import 'package:flutter/material.dart';
import '../controllers/project_controller.dart';
import '../models/project_model.dart';
import 'widgets/project_card.dart';
import 'sensor_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> futureProjects;
  final ProjectController _controller = ProjectController();

  @override
  void initState() {
    super.initState();
    futureProjects = _controller.fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Project>>(
        future: futureProjects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100, top: 8, left: 8, right: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ProjectCard(project: snapshot.data![index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SensorScreen()),
          );
        },
        icon: const Icon(Icons.sensors),
        label: const Text('View Sensors'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
