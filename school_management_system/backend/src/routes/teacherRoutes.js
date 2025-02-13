const express = require('express');
const router = express.Router();
const teacherController = require('../controllers/teacherController');
const auth = require('../middleware/auth');

// Middleware pour vérifier si l'utilisateur est un admin
const adminMiddleware = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Access denied. Admin only.' });
    }
    next();
};

// Appliquer le middleware d'authentification à toutes les routes
router.use(auth.authenticate);

// Routes accessibles à tous les utilisateurs authentifiés
router.get('/', teacherController.getAllTeachers);
router.get('/subjects', teacherController.getAvailableSubjects);

// Routes protégées (admin uniquement)
router.post('/', adminMiddleware, teacherController.createTeacher);
router.put('/:id', adminMiddleware, teacherController.updateTeacher);
router.delete('/:id', adminMiddleware, teacherController.deleteTeacher);

module.exports = router;
