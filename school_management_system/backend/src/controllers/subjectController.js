const db = require('../config/database');

const subjectController = {
  // Récupérer tous les tracks disponibles
  getTracks: async (req, res) => {
    try {
      const [tracks] = await db.query(
        'SELECT DISTINCT track FROM subjects ORDER BY track'
      );
      res.json({ status: 'success', data: tracks.map(t => t.track) });
    } catch (error) {
      console.error('Error getting tracks:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des tracks'
      });
    }
  },

  // Récupérer tous les enseignants disponibles
  getAvailableTeachers: async (req, res) => {
    try {
      const [teachers] = await db.query(`
        SELECT 
          t.id,
          t.first_name,
          t.last_name,
          CONCAT(t.first_name, ' ', t.last_name) as full_name
        FROM teachers t
        ORDER BY t.last_name, t.first_name
      `);
      
      console.log('Enseignants disponibles:', teachers);
      res.json({ status: 'success', data: teachers });
    } catch (error) {
      console.error('Error getting available teachers:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des enseignants'
      });
    }
  },

  // Récupérer toutes les matières avec les informations des enseignants
  getAllSubjects: async (req, res) => {
    try {
      const [subjects] = await db.query(`
        SELECT 
          s.*,
          GROUP_CONCAT(
            DISTINCT CONCAT(t.first_name, ' ', t.last_name)
            ORDER BY t.last_name, t.first_name
          ) as teacher_names,
          GROUP_CONCAT(DISTINCT t.id) as teacher_ids
        FROM subjects s
        LEFT JOIN teacher_subjects ts ON s.id = ts.subject_id
        LEFT JOIN teachers t ON ts.teacher_id = t.id
        GROUP BY s.id
        ORDER BY s.track, s.name
      `);

      const formattedSubjects = subjects.map(subject => ({
        ...subject,
        teachers: subject.teacher_ids
          ? subject.teacher_ids.split(',').map((id, index) => ({
              id: parseInt(id),
              name: subject.teacher_names.split(',')[index]
            }))
          : []
      }));

      console.log('Matières récupérées:', formattedSubjects);
      res.json({ status: 'success', data: formattedSubjects });
    } catch (error) {
      console.error('Error getting subjects:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des matières'
      });
    }
  },

  // Récupérer les matières d'un enseignant
  getTeacherSubjects: async (req, res) => {
    try {
      const { teacherId } = req.params;
      const [subjects] = await db.query(`
        SELECT s.* 
        FROM subjects s 
        INNER JOIN teacher_subjects ts ON s.id = ts.subject_id 
        WHERE ts.teacher_id = ?
        ORDER BY s.track, s.name
      `, [teacherId]);

      console.log(`Matières de l'enseignant ${teacherId}:`, subjects);
      res.json({ status: 'success', data: subjects });
    } catch (error) {
      console.error('Error getting teacher subjects:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la récupération des matières de l\'enseignant'
      });
    }
  },

  // Créer une nouvelle matière
  createSubject: async (req, res) => {
    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const { name, track, teacherIds } = req.body;
      
      if (!name || !track) {
        return res.status(400).json({
          status: 'error',
          message: 'Le nom et le track de la matière sont requis'
        });
      }

      // Vérifier si la matière existe déjà dans ce track
      const [existing] = await connection.query(
        'SELECT * FROM subjects WHERE name = ? AND track = ?',
        [name, track]
      );

      if (existing.length > 0) {
        await connection.rollback();
        return res.status(400).json({
          status: 'error',
          message: 'Cette matière existe déjà dans ce track'
        });
      }

      // Créer la matière
      const [result] = await connection.query(
        'INSERT INTO subjects (name, track) VALUES (?, ?)',
        [name, track]
      );

      const subjectId = result.insertId;

      // Assigner les enseignants si fournis
      if (Array.isArray(teacherIds) && teacherIds.length > 0) {
        const values = teacherIds.map(teacherId => [teacherId, subjectId]);
        await connection.query(
          'INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES ?',
          [values]
        );
      }

      await connection.commit();

      res.status(201).json({
        status: 'success',
        message: 'Matière créée avec succès',
        data: {
          id: subjectId,
          name,
          track,
          teacherIds
        }
      });
    } catch (error) {
      await connection.rollback();
      console.error('Error creating subject:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la création de la matière'
      });
    } finally {
      connection.release();
    }
  },

  // Mettre à jour une matière
  updateSubject: async (req, res) => {
    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const { id } = req.params;
      const { name, track, teacherIds } = req.body;

      if (!name || !track) {
        await connection.rollback();
        return res.status(400).json({
          status: 'error',
          message: 'Le nom et le track de la matière sont requis'
        });
      }

      // Vérifier si la matière existe
      const [existing] = await connection.query(
        'SELECT * FROM subjects WHERE id = ?',
        [id]
      );

      if (existing.length === 0) {
        await connection.rollback();
        return res.status(404).json({
          status: 'error',
          message: 'Matière non trouvée'
        });
      }

      // Mettre à jour la matière
      await connection.query(
        'UPDATE subjects SET name = ?, track = ? WHERE id = ?',
        [name, track, id]
      );

      // Mettre à jour les enseignants
      await connection.query(
        'DELETE FROM teacher_subjects WHERE subject_id = ?',
        [id]
      );

      if (Array.isArray(teacherIds) && teacherIds.length > 0) {
        const values = teacherIds.map(teacherId => [teacherId, id]);
        await connection.query(
          'INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES ?',
          [values]
        );
      }

      await connection.commit();

      res.json({
        status: 'success',
        message: 'Matière mise à jour avec succès',
        data: {
          id: parseInt(id),
          name,
          track,
          teacherIds
        }
      });
    } catch (error) {
      await connection.rollback();
      console.error('Error updating subject:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la mise à jour de la matière'
      });
    } finally {
      connection.release();
    }
  },

  // Supprimer une matière
  deleteSubject: async (req, res) => {
    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const { id } = req.params;

      // Vérifier si la matière existe
      const [existing] = await connection.query(
        'SELECT * FROM subjects WHERE id = ?',
        [id]
      );

      if (existing.length === 0) {
        await connection.rollback();
        return res.status(404).json({
          status: 'error',
          message: 'Matière non trouvée'
        });
      }

      // Vérifier si la matière est utilisée dans l'emploi du temps
      const [schedules] = await connection.query(
        'SELECT * FROM schedule WHERE subject_id = ?',
        [id]
      );

      if (schedules.length > 0) {
        await connection.rollback();
        return res.status(400).json({
          status: 'error',
          message: 'Impossible de supprimer cette matière car elle est utilisée dans l\'emploi du temps'
        });
      }

      // Supprimer les associations avec les enseignants
      await connection.query(
        'DELETE FROM teacher_subjects WHERE subject_id = ?',
        [id]
      );

      // Supprimer la matière
      await connection.query(
        'DELETE FROM subjects WHERE id = ?',
        [id]
      );

      await connection.commit();

      res.json({
        status: 'success',
        message: 'Matière supprimée avec succès'
      });
    } catch (error) {
      await connection.rollback();
      console.error('Error deleting subject:', error);
      res.status(500).json({
        status: 'error',
        message: 'Erreur lors de la suppression de la matière'
      });
    } finally {
      connection.release();
    }
  }
};

module.exports = subjectController;
