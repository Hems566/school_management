class LoggerService {
  static info(message, context = {}) {
    console.log(`[INFO] ${message}`, context);
  }

  static warning(message, context = {}) {
    console.log(`[WARNING] ${message}`, context);
  }

  static error(message, error, context = {}) {
    console.error(`[ERROR] ${message}`, {
      ...context,
      error: error.message,
      stack: error.stack
    });
  }

  static security(message, context = {}) {
    console.log(`[SECURITY] ${message}`, context);
  }
}

module.exports = LoggerService;
