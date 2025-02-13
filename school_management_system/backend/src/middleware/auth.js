const jwt = require('jsonwebtoken');
const db = require('../config/database');

const authenticate = async (req, res, next) => {
  try {
    // Vérifier si le token est présent
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Token manquant' });
    }

    // Extraire et vérifier le token
    const token = authHeader.split(' ')[1];
    if (!process.env.JWT_SECRET) {
      console.error('JWT_SECRET is not defined');
      return res.status(500).json({ message: 'Configuration error' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Récupérer les informations de l'utilisateur depuis la base de données
    const [users] = await db.query(
      'SELECT id, email, role FROM users WHERE id = ?',
      [decoded.userId]
    );

    if (users.length === 0) {
      return res.status(401).json({ message: 'Utilisateur non trouvé' });
    }

    // Ajouter les informations de l'utilisateur à la requête
    req.user = users[0];
    next();
  } catch (error) {
    if (error instanceof jwt.JsonWebTokenError) {
      return res.status(401).json({ message: 'Token invalide' });
    }
    console.error('Erreur auth middleware:', error);
    return res.status(500).json({ message: 'Erreur serveur' });
  }
};

module.exports = {
  authenticate
};
