class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int sort;

  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.sort,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      category: json['category'],
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'sort': sort,
    };
  }
} 