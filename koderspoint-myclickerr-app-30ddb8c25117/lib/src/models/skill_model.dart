class Skill {
  final int id;
  final String skillType;
  final String skill;

  Skill({
    required this.id,
    required this.skillType,
    required this.skill,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      skillType: json['skill_type'],
      skill: json['skill'],
    );
  }
}

class SkillsResponse {
  final bool status;
  final String message;
  final Map<String, List<Skill>> data;

  SkillsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SkillsResponse.fromJson(Map<String, dynamic> json) {
    final preProduction = (json['data']['pre_production'] as List)
        .map((skillJson) => Skill.fromJson(skillJson))
        .toList();
    final postProduction = (json['data']['post_production'] as List)
        .map((skillJson) => Skill.fromJson(skillJson))
        .toList();

    return SkillsResponse(
      status: json['status'],
      message: json['message'],
      data: {
        'pre_production': preProduction,
        'post_production': postProduction,
      },
    );
  }
}
