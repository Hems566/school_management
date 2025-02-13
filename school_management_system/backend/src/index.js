const dotenv = require('dotenv');
const path = require('path');

// Charger les variables d'environnement depuis le fichier .env
dotenv.config({
  path: path.resolve(__dirname, '../.env')
});

// Vérifier les variables critiques
if (!process.env.JWT_SECRET || !process.env.DB_HOST || !process.env.DB_USER || !process.env.DB_PASSWORD) {
  console.error('Missing critical environment variables. Please check your .env file.');
  process.exit(1);
}
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const examRoutes = require('./routes/examRoutes');
const teacherRoutes = require('./routes/teacherRoutes');
const subjectRoutes = require('./routes/subjectRoutes');
const scheduleRoutes = require('./routes/scheduleRoutes');

const app = express();

// Verify environment variables are loaded
console.log('Environment Check:', {
  port: process.env.PORT,
  dbHost: process.env.DB_HOST,
  hasJwtSecret: !!process.env.JWT_SECRET,
  hasSendGridKey: !!process.env.SENDGRID_API_KEY
});

// Middleware
app.use(cors({
  origin: '*', // Autoriser toutes les origines en développement
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/exam', examRoutes);
app.use('/api/teachers', teacherRoutes);
app.use('/api/subjects', subjectRoutes);
app.use('/api/schedule', scheduleRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Global error handler:', err);
  
  // Gérer les erreurs de parsing JSON
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({ 
      status: 'error',
      message: 'Invalid JSON payload'
    });
  }
  
  // Gérer les erreurs d'URL malformée
  if (err instanceof URIError) {
    return res.status(400).json({
      status: 'error',
      message: 'Invalid URL encoding'
    });
  }

  // Toute autre erreur non gérée
  res.status(500).json({ 
    status: 'error',
    message: 'Une erreur inattendue est survenue',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
