class ReadCourse {
  final String courseId;
  final String title;
  ReadCourse({required this.courseId, required this.title});
}

class ReadUnits {
  final String unitid;
  final String title;
  final String description;
  final String fromunitCourseID;
  ReadUnits(
      {required this.unitid,
      required this.title,
      required this.description,
      required this.fromunitCourseID});
}

class ReadLessons {
  final String lessonid;
  final String title;
  final String unitID;
  ReadLessons({
    required this.lessonid,
    required this.title,
    required this.unitID,
  });
}
