import 'dart:convert';

class Note {
  final String? id;
  final String title;
  final String? content;
  final String type; // 'normal', 'church', 'chama'
  
  // Church specific
  final String? speaker;
  final List<String>? bibleVerses;
  
  // Chama specific
  final DateTime? meetingDate;
  final List<String>? members;
  final Map<String, dynamic>? contributions; // { "MemberA": 500, "MemberB": false }
  final double? totalCollected;
  final double? expectedTotal;
  final String? recipient;

  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    this.id,
    required this.title,
    this.content,
    required this.type,
    this.speaker,
    this.bibleVerses,
    this.meetingDate,
    this.members,
    this.contributions,
    this.totalCollected,
    this.expectedTotal,
    this.recipient,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'speaker': speaker,
      'bible_verses': bibleVerses != null ? jsonEncode(bibleVerses) : null,
      'meeting_date': meetingDate?.toIso8601String(),
      'members': members != null ? jsonEncode(members) : null,
      'contributions': contributions != null ? jsonEncode(contributions) : null,
      'total_collected': totalCollected,
      'expected_total': expectedTotal,
      'recipient': recipient,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      type: map['type'],
      speaker: map['speaker'],
      bibleVerses: map['bible_verses'] != null 
          ? List<String>.from(jsonDecode(map['bible_verses'])) 
          : null,
      meetingDate: map['meeting_date'] != null 
          ? DateTime.parse(map['meeting_date']) 
          : null,
      members: map['members'] != null 
          ? List<String>.from(jsonDecode(map['members'])) 
          : null,
      contributions: map['contributions'] != null 
          ? jsonDecode(map['contributions']) 
          : null,
      totalCollected: map['total_collected'],
      expectedTotal: map['expected_total'],
      recipient: map['recipient'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
