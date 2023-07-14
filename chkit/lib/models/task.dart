class Tasks {
  final String taskId;
  final String title;
  final bool image;

  Tasks({
    required this.title,
    required this.taskId,
    this.image = false,
  });
}
