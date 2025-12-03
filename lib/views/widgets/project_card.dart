import 'package:flutter/material.dart';
import '../../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (project.coverImageUrls.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: project.coverImageUrls.length,
                itemBuilder: (context, index) {
                  String imageUrl = project.coverImageUrls[index];
                  

                  if (imageUrl.startsWith('/')) {

                    final parts = imageUrl.split('/');
                    final encodedParts = parts.map((part) {

                      if (part.isEmpty || part == 'public') return part;
                      return Uri.encodeComponent(part);
                    }).join('/');
                    imageUrl = 'https://www.propstake.ai$encodedParts';
                  } else {

                    try {
                      final uri = Uri.parse(imageUrl);
                      imageUrl = uri.toString();
                    } catch (e) {
                      // Error parsing URL
                    }
                  }
                  
                  // Loading image

                  
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 250,
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      'Image failed to load',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      imageUrl,
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${index + 1}/${project.coverImageUrls.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.status,
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${project.location.city}, ${project.location.country}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700]
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                

                Text(
                  project.projectPrice,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold
                  ),
                ),
                
                const SizedBox(height: 16),
                

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(context, 'Total Units', '${project.totalUnits}'),
                    _buildInfoItem(context, 'Units Sold', '${project.unitsSold}'),
                    _buildInfoItem(
                      context,
                      'Unit Price',
                      '${project.priceUnit} ${project.unitPrice}'
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (project.projectType.isNotEmpty)
                      Chip(
                        label: Text(project.projectType),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    if (project.buildingType.isNotEmpty)
                      Chip(
                        label: Text(project.buildingType),
                        backgroundColor: Colors.orange.shade50,
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Project ID', project.id),
                      const SizedBox(height: 8),
                      _buildDetailRow('Published', _formatDate(project.publishedAt)),
                      const SizedBox(height: 8),
                      _buildDetailRow('Total Images', '${project.coverImageUrls.length}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                

                ExpansionTile(
                  title: const Text(
                    'All Cover Image URLs',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  children: project.coverImageUrls.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String url = entry.value;
                    String fullUrl;
                    

                    if (url.startsWith('/')) {
                      final parts = url.split('/');
                      final encodedParts = parts.map((part) {
                        if (part.isEmpty || part == 'public') return part;
                        return Uri.encodeComponent(part);
                      }).join('/');
                      fullUrl = 'https://www.propstake.ai$encodedParts';
                    } else {
                      fullUrl = url;
                    }
                    
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        child: Text('${idx + 1}'),
                      ),
                      title: Text(
                        fullUrl,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            url.startsWith('/') ? 'Relative URL (encoded)' : 'Absolute URL',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                          if (url.startsWith('/'))
                            Text(
                              'Original: $url',
                              style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr == 'N/A') return dateStr;
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
