const db = require('../config/database');

const scheduleController = {
    getAllSchedules: async (req, res) => {
        try {
            console.log('Récupération de tous les emplois du temps');
            const [schedules] = await db.query(`
                SELECT s.*, 
                    CONCAT(t.first_name, ' ', t.last_name) as teacher_name, 
                    sub.name as subject_name 
                FROM schedule s
                LEFT JOIN teachers t ON s.teacher_id = t.id
                LEFT JOIN subjects sub ON s.subject_id = sub.id
                ORDER BY s.day_of_week, s.start_time
            `);

            console.log(`Nombre d'emplois du temps trouvés: ${schedules.length}`);
            const normalizedSchedules = schedules.map(schedule => ({
                ...schedule,
                start_time: schedule.start_time.slice(0, 5),
                end_time: schedule.end_time.slice(0, 5),
                className: schedule.className.trim()
            }));

            res.status(200).json({
                status: 'success',
                data: normalizedSchedules
            });
        } catch (error) {
            console.error('Erreur lors de la récupération des emplois du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la récupération des emplois du temps'
            });
        }
    },

    getClassSchedule: async (req, res) => {
        try {
            const { class_name } = req.params;
            console.log('Recherche emploi du temps pour la classe:', class_name);

            const [schedule] = await db.query(`
                SELECT s.*, 
                    CONCAT(t.first_name, ' ', t.last_name) as teacher_name, 
                    sub.name as subject_name 
                FROM schedule s
                LEFT JOIN teachers t ON s.teacher_id = t.id
                LEFT JOIN subjects sub ON s.subject_id = sub.id
                WHERE s.className = ?
                ORDER BY s.day_of_week, s.start_time
            `, [class_name.trim()]);

            const normalizedSchedules = schedule.map(s => ({
                ...s,
                start_time: s.start_time.slice(0, 5),
                end_time: s.end_time.slice(0, 5),
                className: s.className.trim()
            }));

            res.status(200).json({
                status: 'success',
                data: normalizedSchedules
            });
        } catch (error) {
            console.error('Erreur lors de la récupération de l\'emploi du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la récupération de l\'emploi du temps'
            });
        }
    },

    getTeacherSchedule: async (req, res) => {
        try {
            const { teacherId } = req.params;
            console.log('Recherche emploi du temps pour l\'enseignant:', teacherId);

            const [teacher] = await db.query(
                'SELECT CONCAT(first_name, " ", last_name) as name FROM teachers WHERE id = ?',
                [teacherId]
            );

            if (teacher.length === 0) {
                return res.status(404).json({
                    status: 'error',
                    message: 'Enseignant non trouvé'
                });
            }

            const [schedule] = await db.query(`
                SELECT s.*, 
                    ? as teacher_name,
                    sub.name as subject_name
                FROM schedule s
                LEFT JOIN subjects sub ON s.subject_id = sub.id
                WHERE s.teacher_id = ?
                ORDER BY s.day_of_week, s.start_time
            `, [teacher[0].name, teacherId]);

            const normalizedSchedules = schedule.map(s => ({
                ...s,
                start_time: s.start_time.slice(0, 5),
                end_time: s.end_time.slice(0, 5),
                className: s.className.trim()
            }));

            res.status(200).json({
                status: 'success',
                data: normalizedSchedules
            });
        } catch (error) {
            console.error('Erreur lors de la récupération de l\'emploi du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la récupération de l\'emploi du temps'
            });
        }
    },

    createSchedule: async (req, res) => {
        try {
            const {
                teacher_id,
                subject_id,
                className,
                day_of_week,
                start_time,
                end_time,
                room_number
            } = req.body;

            if (!teacher_id || !subject_id || !className || !day_of_week || !start_time || !end_time || !room_number) {
                return res.status(400).json({
                    status: 'error',
                    message: 'Tous les champs requis doivent être remplis'
                });
            }

            // Vérifier les conflits d'horaire
            const [conflicts] = await db.query(`
                SELECT * FROM schedule 
                WHERE (teacher_id = ? OR room_number = ?) 
                AND day_of_week = ? 
                AND ((start_time BETWEEN ? AND ?) OR (end_time BETWEEN ? AND ?))
            `, [teacher_id, room_number, day_of_week, start_time, end_time, start_time, end_time]);

            if (conflicts.length > 0) {
                return res.status(400).json({
                    status: 'error',
                    message: 'Conflit d\'horaire détecté'
                });
            }

            const [result] = await db.query(
                'INSERT INTO schedule (teacher_id, subject_id, className, day_of_week, start_time, end_time, room_number) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [teacher_id, subject_id, className.trim(), day_of_week, start_time, end_time, room_number]
            );

            res.status(201).json({
                status: 'success',
                message: 'Emploi du temps créé avec succès',
                data: {
                    id: result.insertId,
                    teacher_id,
                    subject_id,
                    className: className.trim(),
                    day_of_week,
                    start_time,
                    end_time,
                    room_number
                }
            });
        } catch (error) {
            console.error('Erreur lors de la création de l\'emploi du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la création de l\'emploi du temps'
            });
        }
    },

    updateSchedule: async (req, res) => {
        try {
            const { id } = req.params;
            const {
                teacher_id,
                subject_id,
                className,
                day_of_week,
                start_time,
                end_time,
                room_number
            } = req.body;

            // Vérifier si l'emploi du temps existe
            const [existingSchedule] = await db.query(
                'SELECT * FROM schedule WHERE id = ?',
                [id]
            );

            if (existingSchedule.length === 0) {
                return res.status(404).json({
                    status: 'error',
                    message: 'Emploi du temps non trouvé'
                });
            }

            // Vérifier les conflits d'horaire
            const [conflicts] = await db.query(`
                SELECT * FROM schedule 
                WHERE id != ? 
                AND (teacher_id = ? OR room_number = ?) 
                AND day_of_week = ? 
                AND ((start_time BETWEEN ? AND ?) OR (end_time BETWEEN ? AND ?))
            `, [id, teacher_id, room_number, day_of_week, start_time, end_time, start_time, end_time]);

            if (conflicts.length > 0) {
                return res.status(400).json({
                    status: 'error',
                    message: 'Conflit d\'horaire détecté'
                });
            }

            await db.query(
                'UPDATE schedule SET teacher_id = ?, subject_id = ?, className = ?, day_of_week = ?, start_time = ?, end_time = ?, room_number = ? WHERE id = ?',
                [teacher_id, subject_id, className.trim(), day_of_week, start_time, end_time, room_number, id]
            );

            res.status(200).json({
                status: 'success',
                message: 'Emploi du temps mis à jour avec succès',
                data: {
                    id,
                    teacher_id,
                    subject_id,
                    className: className.trim(),
                    day_of_week,
                    start_time,
                    end_time,
                    room_number
                }
            });
        } catch (error) {
            console.error('Erreur lors de la mise à jour de l\'emploi du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la mise à jour de l\'emploi du temps'
            });
        }
    },

    deleteSchedule: async (req, res) => {
        try {
            const { id } = req.params;

            const [result] = await db.query(
                'DELETE FROM schedule WHERE id = ?',
                [id]
            );

            if (result.affectedRows === 0) {
                return res.status(404).json({
                    status: 'error',
                    message: 'Emploi du temps non trouvé'
                });
            }

            res.status(200).json({
                status: 'success',
                message: 'Emploi du temps supprimé avec succès'
            });
        } catch (error) {
            console.error('Erreur lors de la suppression de l\'emploi du temps:', error);
            res.status(500).json({
                status: 'error',
                message: 'Erreur lors de la suppression de l\'emploi du temps'
            });
        }
    }
};

module.exports = scheduleController;
