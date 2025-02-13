const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');
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

// Routes pour tous les utilisateurs authentifiés
router.get('/', scheduleController.getAllSchedules);
router.get('/class/:class_name', scheduleController.getClassSchedule);
router.get('/teacher/:teacherId', scheduleController.getTeacherSchedule);

// Routes admin uniquement
router.post('/', adminMiddleware, scheduleController.createSchedule);
router.put('/:id', adminMiddleware, scheduleController.updateSchedule);
router.delete('/:id', adminMiddleware, scheduleController.deleteSchedule);

module.exports = router;
