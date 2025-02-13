const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/auth');

// Routes publiques
router.post('/login', authController.login);
router.post('/register', authController.register);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

// Routes protégées nécessitant une authentification
router.use(auth.authenticate);
router.get('/user', authController.getUserDetails);
router.post('/logout', authController.logout);

module.exports = router;
