const db = require('../config/database');
const LoggerService = require('./loggerService');

class ExamService {
  static calculateFinalScore(tp, ca, exam, retake, withRetake = false) {
    LoggerService.info('Calcul note finale', { tp, ca, exam, retake, withRetake });
    
    let finalScore;
    if (withRetake && retake > 0) {
      finalScore = Math.max((exam + retake) / 2, exam);
      LoggerService.info('Note finale avec rattrapage', { 
        exam,
        retake,
        finalScore
      });
    } else {
      finalScore = (tp * 0.2) + (ca * 0.3) + (exam * 0.5);
      LoggerService.info('Note finale standard', {
        tp: tp * 0.2,
        ca: ca * 0.3,
        exam: exam * 0.5,
        finalScore
      });
    }
    
    return finalScore;
  }

  static async getStudentsByTrack(track) {
    LoggerService.info('Recherche étudiants par track', { track });
    
    const [students] = await db.query(
      `SELECT 
        s.id,
        s.user_id,
        COALESCE(u.name, s.first_name) as name,
        s.roll_number as rollNumber,
        s.track,
        u.email,
        'student' as role
       FROM students s 
       JOIN users u ON s.user_id = u.id 
       WHERE s.track = ?`,
      [track]
    );
    
    LoggerService.info('Étudiants trouvés', { 
      track, 
      count: students.length 
    });
    
    return students;
  }

  static async saveExamResults(connection, data) {
    const { studentId, subjectId, results, userId } = data;
    const { coefficient, tp_score, continuous_assessment_score, 
            final_exam_score, retake_score = 0 } = results;

    const final_score = this.calculateFinalScore(
      tp_score,
      continuous_assessment_score,
      final_exam_score,
      retake_score,
      retake_score > 0
    );

    const [existing] = await connection.query(
      'SELECT id FROM exam_results WHERE student_id = ? AND subject_id = ?',
      [studentId, subjectId]
    );

    if (existing.length > 0) {
      LoggerService.info('Mise à jour résultats', { studentId, subjectId });
      await connection.query(
        `UPDATE exam_results 
         SET coefficient = ?, tp_score = ?, continuous_assessment_score = ?, 
             final_exam_score = ?, retake_score = ?, final_score = ?,
             created_by = ?, updated_at = CURRENT_TIMESTAMP
         WHERE student_id = ? AND subject_id = ?`,
        [coefficient, tp_score, continuous_assessment_score, final_exam_score, 
         retake_score, final_score, userId, studentId, subjectId]
      );
    } else {
      LoggerService.info('Création résultats', { studentId, subjectId });
      await connection.query(
        `INSERT INTO exam_results 
         (student_id, subject_id, coefficient, tp_score, continuous_assessment_score,
          final_exam_score, retake_score, final_score, created_by)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [studentId, subjectId, coefficient, tp_score, continuous_assessment_score,
         final_exam_score, retake_score, final_score, userId]
      );
    }

    return final_score;
  }

  static async getStudentResults(studentId) {
    LoggerService.info('Récupération résultats étudiant', { studentId });

    const [results] = await db.query(
      `SELECT 
        er.*,
        s.name as subject_name,
        s.teacher_id,
        t.first_name as teacher_first_name,
        t.last_name as teacher_last_name,
        u.name as teacher_name
       FROM exam_results er
       JOIN subjects s ON er.subject_id = s.id
       LEFT JOIN teachers t ON s.teacher_id = t.id
       LEFT JOIN users u ON er.created_by = u.id
       WHERE er.student_id = ?
       ORDER BY s.name`,
      [studentId]
    );

    LoggerService.info('Résultats trouvés', {
      studentId,
      count: results.length,
      subjects: results.map(r => r.subject_name)
    });

    return results;
  }

  static async getSubjectResults(subjectId) {
    LoggerService.info('Récupération résultats matière', { subjectId });

    const [results] = await db.query(
      `SELECT er.*, s.name as student_name
       FROM exam_results er
       JOIN students s ON er.student_id = s.id
       WHERE er.subject_id = ?
       ORDER BY s.name`,
      [subjectId]
    );

    LoggerService.info('Résultats trouvés', {
      subjectId,
      count: results.length
    });

    return results;
  }
}

module.exports = ExamService;
