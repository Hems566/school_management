const db = require('../config/database');

const teacherController = {
    // Récupérer tous les enseignants avec leurs matières
    getAllTeachers: async (req, res) => {
        try {
            const [teachers] = await db.query(`
                SELECT 
                    t.*, 
                    u.email, 
                    u.name,
                    GROUP_CONCAT(DISTINCT s.name) as subject_names,
                    GROUP_CONCAT(DISTINCT s.id) as subject_ids
                FROM teachers t
                JOIN users u ON t.user_id = u.id
                LEFT JOIN teacher_subjects ts ON t.id = ts.teacher_id
                LEFT JOIN subjects s ON ts.subject_id = s.id
                GROUP BY t.id
                ORDER BY t.first_name, t.last_name
            `);

            const formattedTeachers = teachers.map(teacher => ({
                ...teacher,
                subjects: teacher.subject_ids 
                    ? teacher.subject_ids.split(',').map((id, index) => ({
                        id: parseInt(id),
                        name: teacher.subject_names.split(',')[index]
                    }))
                    : []
            }));

            res.status(200).json({
                status: 'success',
                data: formattedTeachers
            });
        } catch (error) {
            console.error('Erreur lors de la récupération des enseignants:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la récupération des enseignants'
            });
        }
    },

    // Récupérer toutes les matières disponibles
    getAvailableSubjects: async (req, res) => {
        try {
            const [subjects] = await db.query(
                'SELECT id, name, track FROM subjects ORDER BY track, name'
            );
            res.status(200).json({
                status: 'success',
                data: subjects
            });
        } catch (error) {
            console.error('Erreur lors de la récupération des matières:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la récupération des matières'
            });
        }
    },

    // Créer un nouvel enseignant
    createTeacher: async (req, res) => {
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            const { first_name, last_name, phone_number, user_id, subject_ids } = req.body;
            
            if (!first_name || !last_name || !user_id) {
                return res.status(400).json({
                    status: 'error',
                    message: 'Veuillez fournir tous les champs requis'
                });
            }

            // Créer l'enseignant
            const [result] = await connection.query(
                'INSERT INTO teachers (first_name, last_name, phone_number, user_id) VALUES (?, ?, ?, ?)',
                [first_name, last_name, phone_number, user_id]
            );

            const teacherId = result.insertId;

            // Associer les matières si fournies
            if (Array.isArray(subject_ids) && subject_ids.length > 0) {
                const values = subject_ids.map(subjectId => [teacherId, subjectId]);
                await connection.query(
                    'INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES ?',
                    [values]
                );
            }

            await connection.commit();

            res.status(201).json({
                status: 'success',
                message: 'Enseignant créé avec succès',
                data: {
                    id: teacherId,
                    first_name,
                    last_name,
                    phone_number,
                    user_id,
                    subject_ids
                }
            });
        } catch (error) {
            await connection.rollback();
            console.error('Erreur lors de la création de l\'enseignant:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la création de l\'enseignant'
            });
        } finally {
            connection.release();
        }
    },

    // Mettre à jour un enseignant
    updateTeacher: async (req, res) => {
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            const { id } = req.params;
            const { first_name, last_name, phone_number, subject_ids } = req.body;

            if (!first_name && !last_name && !phone_number && !subject_ids) {
                return res.status(400).json({
                    status: 'error',
                    message: 'Aucune donnée fournie pour la mise à jour'
                });
            }

            const [existingTeacher] = await connection.query(
                'SELECT * FROM teachers WHERE id = ?',
                [id]
            );
            
            if (existingTeacher.length === 0) {
                await connection.rollback();
                return res.status(404).json({
                    status: 'error',
                    message: 'Enseignant non trouvé'
                });
            }

            // Mettre à jour les informations de l'enseignant
            await connection.query(
                'UPDATE teachers SET first_name = ?, last_name = ?, phone_number = ? WHERE id = ?',
                [
                    first_name || existingTeacher[0].first_name,
                    last_name || existingTeacher[0].last_name,
                    phone_number || existingTeacher[0].phone_number,
                    id
                ]
            );

            // Mettre à jour les matières si fournies
            if (Array.isArray(subject_ids)) {
                await connection.query(
                    'DELETE FROM teacher_subjects WHERE teacher_id = ?',
                    [id]
                );

                if (subject_ids.length > 0) {
                    const values = subject_ids.map(subjectId => [id, subjectId]);
                    await connection.query(
                        'INSERT INTO teacher_subjects (teacher_id, subject_id) VALUES ?',
                        [values]
                    );
                }
            }

            await connection.commit();

            res.status(200).json({
                status: 'success',
                message: 'Enseignant mis à jour avec succès',
                data: {
                    id: parseInt(id),
                    first_name: first_name || existingTeacher[0].first_name,
                    last_name: last_name || existingTeacher[0].last_name,
                    phone_number: phone_number || existingTeacher[0].phone_number,
                    subject_ids: subject_ids || []
                }
            });
        } catch (error) {
            await connection.rollback();
            console.error('Erreur lors de la mise à jour de l\'enseignant:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la mise à jour de l\'enseignant'
            });
        } finally {
            connection.release();
        }
    },

    // Supprimer un enseignant
    deleteTeacher: async (req, res) => {
        const connection = await db.getConnection();
        await connection.beginTransaction();

        try {
            const { id } = req.params;

            // Récupérer d'abord l'ID utilisateur de l'enseignant
            const [teacher] = await connection.query(
                'SELECT user_id FROM teachers WHERE id = ?',
                [id]
            );

            if (teacher.length === 0) {
                await connection.rollback();
                return res.status(404).json({
                    status: 'error',
                    message: 'Enseignant non trouvé'
                });
            }

            const userId = teacher[0].user_id;

            // Supprimer les associations avec les matières
            await connection.query(
                'DELETE FROM teacher_subjects WHERE teacher_id = ?',
                [id]
            );

            // Supprimer l'enseignant
            await connection.query(
                'DELETE FROM teachers WHERE id = ?',
                [id]
            );

            // Supprimer l'utilisateur associé
            await connection.query(
                'DELETE FROM users WHERE id = ?',
                [userId]
            );

            await connection.commit();

            res.status(200).json({
                status: 'success',
                message: 'Enseignant et son compte utilisateur supprimés avec succès'
            });
        } catch (error) {
            await connection.rollback();
            console.error('Erreur lors de la suppression de l\'enseignant:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la suppression de l\'enseignant'
            });
        } finally {
            connection.release();
        }
    }
};

module.exports = teacherController;
