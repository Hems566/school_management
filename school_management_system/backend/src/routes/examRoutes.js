const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const examController = require('../controllers/examController');

// Middleware pour vérifier les rôles
const checkRole = (roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({
      status: 'error',
      message: 'Accès non autorisé'
    });
  }
  next();
};

// Appliquer le middleware d'authentification à toutes les routes
router.use(auth.authenticate);

// Route pour récupérer l'ID étudiant à partir de l'ID utilisateur
router.get('/student/user/:userId', examController.getStudentIdByUserId);

// Route pour récupérer les étudiants par track
router.get(
  '/students/track/:track',
  checkRole(['teacher']),
  examController.getStudentsByTeacherTrack
);

// Routes pour la gestion des résultats d'examens
router.post(
  '/results',
  checkRole(['admin', 'teacher']),
  examController.createOrUpdateExamResults
);

router.get(
  '/results/student/:studentId',
  examController.getStudentResults
);

router.get(
  '/results/subject/:subjectId',
  checkRole(['admin', 'teacher']),
  examController.getSubjectResults
);

// Route pour calculer les résultats finaux
router.post(
  '/results/student/:studentId/calculate-final',
  checkRole(['admin']),
  examController.calculateFinalResults
);

module.exports = router;
