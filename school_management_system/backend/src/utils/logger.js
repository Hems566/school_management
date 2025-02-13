const db = require('../config/database');

// Types de logs
const LOG_TYPES = {
  ERROR: 'error',
  SECURITY: 'security',
  ACTION: 'action'
};

const logger = {
  // Log une erreur système
  async logError(error, context = {}) {
    try {
      await db.query(
        `INSERT INTO system_logs (type, message, context, created_at)
         VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
        [LOG_TYPES.ERROR, error.message, JSON.stringify(context)]
      );
    } catch (err) {
      console.error('Erreur lors du log:', err);
    }
  },

  // Log une action utilisateur
  async logAction(userId, action, details) {
    try {
      await db.query(
        `INSERT INTO system_logs (type, user_id, message, context, created_at)
         VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)`,
        [LOG_TYPES.ACTION, userId, action, JSON.stringify(details)]
      );
    } catch (err) {
      console.error('Erreur lors du log action:', err);
    }
  },

  // Log une alerte de sécurité
  async logSecurity(userId, message, details) {
    try {
      await db.query(
        `INSERT INTO system_logs (type, user_id, message, context, created_at)
         VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)`,
        [LOG_TYPES.SECURITY, userId, message, JSON.stringify(details)]
      );
    } catch (err) {
      console.error('Erreur lors du log sécurité:', err);
    }
  }
};

module.exports = logger;
