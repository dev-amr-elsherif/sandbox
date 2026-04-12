import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GithubAnalyzerService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>?> analyzeProfile(String username, String token) async {
    try {
      debugPrint('DEBUG: Fetching GitHub data directly from API for $username...');
      
      final response = await _dio.get(
        'https://api.github.com/user/repos?sort=updated&per_page=50',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/vnd.github.v3+json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> repos = response.data;
        
        int publicRepos = repos.length;
        int totalStars = 0;
        Map<String, int> languageDist = {};
        
        for (var repo in repos) {
          if (repo['fork'] == true) continue;
          
          totalStars += (repo['stargazers_count'] as int? ?? 0);
          
          final String? lang = repo['language']?.toString();
          if (lang != null && lang.isNotEmpty) {
            languageDist[lang] = (languageDist[lang] ?? 0) + 1;
          }
        }
        
        // Determine Seniority
        String seniority = 'Junior';
        if (publicRepos >= 20 || totalStars >= 20) {
          seniority = 'Senior';
        } else if (publicRepos >= 5 || totalStars >= 5) {
          seniority = 'Mid-Level';
        }
        
        // Extract Top Skills
        final sortedLanguages = languageDist.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final topSkills = sortedLanguages.take(4).map((e) => e.key).toList();
        
        // Generate Bio
        final skillsStr = topSkills.isNotEmpty ? topSkills.join(", ") : "various technologies";
        final bio = "A passionate $seniority developer specializing in $skillsStr. Built $publicRepos public projects and earned $totalStars GitHub stars.";
        
        debugPrint('DEBUG: Dart Analysis complete. Seniority: $seniority');
        
        return {
          'githubUrl': 'https://github.com/$username',
          'aiBio': bio,
          'githubSeniority': seniority,
          'topAiSkills': topSkills,
        };
      } else {
        debugPrint('GitHub API Error: ${response.statusCode}');
        throw Exception('GitHub API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Analyzer Exception: $e');
      throw Exception('Could not fetch GitHub data: $e');
    }
  }
}
