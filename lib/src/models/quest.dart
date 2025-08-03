// quest.dart

import 'quest_step.dart';
import '../utils/enums.dart';

class Quest {
  final String id;
  final String title;
  final String description;
  final int xp;
  final String stat;
  final int requiredLevel;
  final String? rewardItemId;
  bool completed;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.xp,
    required this.stat,
    required this.requiredLevel,
    this.rewardItemId,
    this.completed = false,
  });

  factory Quest.fromJson(Map<String, dynamic> json) => Quest(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        xp: json['xp'] as int,
        stat: json['stat'] as String,
        requiredLevel: json['requiredLevel'] as int,
        rewardItemId: json['rewardItemId'] as String?,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'xp': xp,
        'stat': stat,
        'requiredLevel': requiredLevel,
        'rewardItemId': rewardItemId,
        'completed': completed,
      };
}
