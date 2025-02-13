const express = require('express');
const router = express.Router();
const subjectController = require('../controllers/subjectController');
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

// Routes publiques (accessibles à tous les utilisateurs authentifiés)
router.get('/', subjectController.getAllSubjects);
router.get('/tracks', subjectController.getTracks);
router.get('/teacher/:teacherId', subjectController.getTeacherSubjects);
router.get('/teachers', subjectController.getAvailableTeachers);

// Routes protégées (admin uniquement)
router.post('/', adminMiddleware, subjectController.createSubject);
router.put('/:id', adminMiddleware, subjectController.updateSubject);
router.delete('/:id', adminMiddleware, subjectController.deleteSubject);

module.exports = router;
