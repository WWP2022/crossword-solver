class CrosswordClue {
  List<String> answers;
  final String question;
  final String user_id; //snake case on purpose

  CrosswordClue(this.answers, this.question, this.user_id);

  @override
  String toString() {
    return 'CrosswordClue{userId: $user_id, question: $question, answer: $answers}';
  }

  Map<String, Object?> toJson() =>
      {"user_id": user_id, "question": question, "answers": answers};
}
