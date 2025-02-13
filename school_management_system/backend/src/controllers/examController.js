const db = require('../config/database');
const LoggerService = require('../services/loggerService');
const AuthorizationService = require('../services/authorizationService');
const ExamService = require('../services/examService');

const examController = {
  getStudentIdByUserId: async (req, res) => {
    try {
      const { userId } = req.params;
      LoggerService.info('Recherche ID étudiant', { userId });

      const [student] = await db.query(
        'SELECT id FROM students WHERE user_id = ?',
        [userId]
      );
      
      if (student.length === 0) {
        LoggerService.warning('Étudiant non trouvé', { userId });
        return res.status(404).json({
          status: 'error',
          message: 'Profil étudiant non trouvé'
        });
      }
      
      LoggerService.info('ID étudiant trouvé', { 
        userId, 
        studentId: student[0].id 
      });
      
      res.json({
        status: 'success',
        data: { id: student[0].id }
      });
    } catch (error) {
      LoggerService.error('Erreur recherche ID étudiant', error, {
        userId: req.params.userId
      });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération de l\'ID étudiant'
      });
    }
  },

  getStudentsByTeacherTrack: async (req, res) => {
    try {
      const track = decodeURIComponent(req.params.track);
      
      if (req.user.role !== 'teacher') {
        LoggerService.security('Tentative accès non autorisé', {
          userId: req.user.id,
          role: req.user.role,
          track
        });
        return res.status(403).json({
          status: 'error',
          message: 'Accès non autorisé'
        });
      }

      const hasAccess = await AuthorizationService.verifyTeacherTrackAccess(req.user.id, track);
      if (!hasAccess) {
        return res.status(403).json({
          status: 'error',
          message: 'Vous n\'avez pas de matières dans ce track'
        });
      }

      const students = await ExamService.getStudentsByTrack(track);
      res.json({ status: 'success', data: students });
    } catch (error) {
      LoggerService.error('Erreur récupération étudiants', error, {
        track: req.params.track
      });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des étudiants'
      });
    }
  },

  createOrUpdateExamResults: async (req, res) => {
    const connection = await db.getConnection();
    try {
      const { studentId, subjectId, results, track } = req.body;

      // Vérifier que l'utilisateur est un enseignant
      if (req.user.role !== 'teacher') {
        LoggerService.security('Tentative modification notes non autorisée', {
          userId: req.user.id,
          role: req.user.role
        });
        return res.status(403).json({
          status: 'error',
          message: 'Accès non autorisé'
        });
      }

      // Vérifier l'accès à la matière
      const hasAccess = await AuthorizationService.verifyTeacherSubjectAccess(
        req.user.id,
        subjectId
      );

      if (!hasAccess) {
        return res.status(403).json({
          status: 'error',
          message: 'Vous n\'êtes pas autorisé à modifier les notes de cette matière'
        });
      }

      await connection.beginTransaction();
      
      const final_score = await ExamService.saveExamResults(connection, {
        studentId,
        subjectId,
        results,
        userId: req.user.id
      });

      await connection.commit();
      
      res.json({
        status: 'success',
        message: 'Résultats enregistrés avec succès',
        data: { final_score }
      });
    } catch (error) {
      await connection.rollback();
      LoggerService.error('Erreur sauvegarde résultats', error, { body: req.body });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de l\'enregistrement des résultats'
      });
    } finally {
      connection.release();
    }
  },

  getStudentResults: async (req, res) => {
    try {
      const { studentId } = req.params;

      const hasAccess = await AuthorizationService.verifyStudentResultAccess(
        studentId,
        req.user.id,
        req.user.role
      );

      if (!hasAccess) {
        return res.status(403).json({
          status: 'error',
          message: 'Non autorisé'
        });
      }

      const results = await ExamService.getStudentResults(studentId);
      res.json({ status: 'success', data: results });
    } catch (error) {
      LoggerService.error('Erreur récupération résultats étudiant', error, {
        studentId: req.params.studentId
      });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des résultats'
      });
    }
  },

  getSubjectResults: async (req, res) => {
    try {
      const { subjectId } = req.params;
      
      // Vérifier que l'utilisateur n'est pas un étudiant
      if (req.user.role === 'student') {
        LoggerService.security('Tentative accès résultats matière non autorisée', {
          userId: req.user.id,
          subjectId
        });
        return res.status(403).json({
          status: 'error',
          message: 'Non autorisé'
        });
      }

      // Pour les enseignants, vérifier l'accès à la matière
      if (req.user.role === 'teacher') {
        const hasAccess = await AuthorizationService.verifyTeacherSubjectAccess(
          req.user.id,
          subjectId
        );
        if (!hasAccess) {
          return res.status(403).json({
            status: 'error',
            message: 'Vous n\'êtes pas autorisé à voir les notes de cette matière'
          });
        }
      }

      const results = await ExamService.getSubjectResults(subjectId);
      res.json({ status: 'success', data: results });
    } catch (error) {
      LoggerService.error('Erreur récupération résultats matière', error, {
        subjectId: req.params.subjectId
      });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des résultats'
      });
    }
  },

  calculateFinalResults: async (req, res) => {
    const connection = await db.getConnection();
    try {
      const { studentId } = req.params;
      LoggerService.info('Début calcul résultats finaux', { studentId });

      await connection.beginTransaction();

      // Récupérer tous les résultats de l'étudiant
      const [results] = await connection.query(
        `SELECT er.*
         FROM exam_results er
         WHERE er.student_id = ?`,
        [studentId]
      );

      // Calculer la moyenne générale
      let totalCoefficient = 0;
      let weightedSum = 0;
      
      results.forEach(result => {
        totalCoefficient += result.coefficient;
        weightedSum += result.final_score * result.coefficient;
      });

      const generalAverage = weightedSum / totalCoefficient;
      const decision = generalAverage >= 10 ? 'validé' : 'non validé';

      // Sauvegarder les résultats finaux
      const [existing] = await connection.query(
        'SELECT id FROM final_results WHERE student_id = ?',
        [studentId]
      );

      if (existing.length > 0) {
        await connection.query(
          `UPDATE final_results 
           SET general_average = ?, decision = ?, updated_at = CURRENT_TIMESTAMP
           WHERE student_id = ?`,
          [generalAverage, decision, studentId]
        );
      } else {
        await connection.query(
          `INSERT INTO final_results (student_id, general_average, decision)
           VALUES (?, ?, ?)`,
          [studentId, generalAverage, decision]
        );
      }

      await connection.commit();
      LoggerService.info('Résultats finaux calculés', {
        studentId,
        generalAverage,
        decision
      });

      res.json({
        status: 'success',
        message: 'Résultats finaux calculés avec succès',
        data: {
          generalAverage,
          decision,
          totalCredits: totalCoefficient
        }
      });
    } catch (error) {
      await connection.rollback();
      LoggerService.error('Erreur calcul résultats finaux', error, {
        studentId: req.params.studentId
      });
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors du calcul des résultats finaux'
      });
    } finally {
      connection.release();
    }
  }
};

module.exports = examController;
