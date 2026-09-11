/// Shared grading scale used by daily memorization assessments and Ikhtibar
/// (periodic Juz exams): Mumtaz (excellent), Jayyid Jiddan (very good),
/// Jayyid (good), Maqbul (acceptable/passing), Rasib (fail).
enum Grade { mumtaz, jayyidJiddan, jayyid, maqbul, rasib }

Grade gradeFromApi(String value) {
  switch (value) {
    case 'MUMTAZ':
      return Grade.mumtaz;
    case 'JAYYID_JIDDAN':
      return Grade.jayyidJiddan;
    case 'JAYYID':
      return Grade.jayyid;
    case 'MAQBUL':
      return Grade.maqbul;
    default:
      return Grade.rasib;
  }
}

String gradeToApi(Grade grade) {
  switch (grade) {
    case Grade.mumtaz:
      return 'MUMTAZ';
    case Grade.jayyidJiddan:
      return 'JAYYID_JIDDAN';
    case Grade.jayyid:
      return 'JAYYID';
    case Grade.maqbul:
      return 'MAQBUL';
    case Grade.rasib:
      return 'RASIB';
  }
}

String gradeLabel(Grade grade) {
  switch (grade) {
    case Grade.mumtaz:
      return 'Mumtaz';
    case Grade.jayyidJiddan:
      return 'Jayyid Jiddan';
    case Grade.jayyid:
      return 'Jayyid';
    case Grade.maqbul:
      return 'Maqbul';
    case Grade.rasib:
      return 'Rasib';
  }
}
