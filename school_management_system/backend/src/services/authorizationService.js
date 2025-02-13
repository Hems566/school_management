const db = require('../config/database');
const LoggerService = require('./loggerService');

class AuthorizationService {
  static async getTeacherId(userId) {
    const [teacher] = await db.query(
      'SELECT id FROM teachers WHERE user_id = ?',
      [userId]
    );
    return teacher.length > 0 ? teacher[0].id : null;
  }

  static async verifyTeacherTrackAccess(userId, track) {
    const teacherId = await this.getTeacherId(userId);
    if (!teacherId) {
      LoggerService.warning('Profil enseignant non trouvé', { userId });
      return false;
    }

    LoggerService.info('Vérification accès track enseignant', { teacherId, track });
    
    const [subjects] = await db.query(
      `SELECT s.id 
       FROM subjects s
       JOIN teacher_subjects ts ON s.id = ts.subject_id
       WHERE ts.teacher_id = ? AND s.track = ?`,
      [teacherId, track]
    );
    
    const hasAccess = subjects.length > 0;
    if (!hasAccess) {
      LoggerService.security('Accès track refusé', { teacherId, track });
    }
    
    return hasAccess;
  }

  static async verifyTeacherSubjectAccess(userId, subjectId) {
    const teacherId = await this.getTeacherId(userId);
    if (!teacherId) {
      LoggerService.warning('Profil enseignant non trouvé', { userId });
      return false;
    }

    LoggerService.info('Vérification accès matière enseignant', { teacherId, subjectId });
    
    const [subjects] = await db.query(
      `SELECT ts.* 
       FROM teacher_subjects ts
       WHERE ts.teacher_id = ? AND ts.subject_id = ?`,
      [teacherId, subjectId]
    );
    
    const hasAccess = subjects.length > 0;
    if (!hasAccess) {
      LoggerService.security('Accès matière refusé', { teacherId, subjectId });
    }
    
    return hasAccess;
  }

  static async verifyStudentResultAccess(studentId, requestingUserId, userRole) {
    LoggerService.info('Vérification accès résultats étudiant', { 
      studentId, 
      requestingUserId, 
      userRole 
    });

    // Les admins ont toujours accès
    if (userRole === 'admin') return true;

    // Pour les enseignants, vérifier qu'ils ont des matières avec cet étudiant
    if (userRole === 'teacher') {
      const teacherId = await this.getTeacherId(requestingUserId);
      if (!teacherId) return false;

      const [subjects] = await db.query(
        `SELECT DISTINCT s.id
         FROM subjects s
         JOIN teacher_subjects ts ON s.id = ts.subject_id
         JOIN exam_results er ON s.id = er.subject_id
         WHERE ts.teacher_id = ? AND er.student_id = ?`,
        [teacherId, studentId]
      );

      return subjects.length > 0;
    }

    // Pour les étudiants, vérifier qu'ils accèdent à leurs propres résultats
    if (userRole === 'student') {
      const [student] = await db.query(
        'SELECT id FROM students WHERE user_id = ?',
        [requestingUserId]
      );

      if (student.length === 0) {
        LoggerService.warning('Profil étudiant non trouvé', { requestingUserId });
        return false;
      }

      const hasAccess = student[0].id === parseInt(studentId);
      if (!hasAccess) {
        LoggerService.security('Tentative accès résultats autre étudiant', {
          requestingStudentId: student[0].id,
          requestedStudentId: studentId
        });
      }

      return hasAccess;
    }

    return false;
  }
}

module.exports = AuthorizationService;
