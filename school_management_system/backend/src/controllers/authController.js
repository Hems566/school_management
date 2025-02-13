const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');
const crypto = require('crypto');
const emailService = require('../config/emailService');

const JWT_SECRET = process.env.JWT_SECRET || crypto.randomBytes(32).toString('hex');
const FRONTEND_URL = 'http://localhost:3000'; // URL fixe pour le développement local

// Fonction pour générer un mot de passe à 4 chiffres
const generateTempPassword = () => {
    // Génère un nombre entre 0 et 9999
    const num = Math.floor(Math.random() * 10000);
    // Ajoute des zéros au début si nécessaire pour avoir toujours 4 chiffres
    return num.toString().padStart(4, '0');
};

const authController = {
  register: async (req, res) => {
    try {
      const { email, name, rollNumber, phoneNumber, role = 'student' } = req.body;
      console.log('Registration attempt for:', email);
      
      const [existingUsers] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
      if (existingUsers.length > 0) {
        return res.status(400).json({ message: 'Email already registered' });
      }

      // Utiliser le nouveau générateur de mot de passe à 4 chiffres
      const tempPassword = generateTempPassword();
      const hashedPassword = await bcrypt.hash(tempPassword, 10);

      const connection = await db.getConnection();
      await connection.beginTransaction();

      try {
        const [userResult] = await connection.query(
          'INSERT INTO users (email, password, name, role) VALUES (?, ?, ?, ?)',
          [email, hashedPassword, name, role]
        );

        if (role === 'student') {
          await connection.query(
            `INSERT INTO students (user_id, first_name, roll_number, phone_number)
             VALUES (?, ?, ?, ?)`,
            [userResult.insertId, name, rollNumber, phoneNumber]
          );
        } else if (role === 'teacher') {
          // Séparer le nom complet en prénom et nom
          const nameParts = name.split(' ');
          const firstName = nameParts[0];
          const lastName = nameParts.slice(1).join(' ') || '';

          // Créer automatiquement l'entrée dans la table teachers
          await connection.query(
            `INSERT INTO teachers (user_id, first_name, last_name, phone_number)
             VALUES (?, ?, ?, ?)`,
            [userResult.insertId, firstName, lastName, phoneNumber || null]
          );
        }

        await emailService.sendRegistrationEmail(email, name, tempPassword);

        await connection.commit();
        console.log('Registration successful for:', email);
        res.status(201).json({
          message: 'Registration successful! Please check your email for login credentials.',
          userId: userResult.insertId
        });
      } catch (error) {
        await connection.rollback();
        throw error;
      } finally {
        connection.release();
      }
    } catch (error) {
      console.error('Registration error:', error);
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  },

  login: async (req, res) => {
    try {
      const { email, password } = req.body;
      console.log('Login attempt for:', email);

      const [rows] = await db.query(
        `SELECT u.*, s.track as className 
         FROM users u 
         LEFT JOIN students s ON u.id = s.user_id 
         WHERE u.email = ?`, 
        [email]
      );
      
      const user = rows[0];
      if (!user) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      const token = jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '24h' });
      
      res.json({ 
        token,
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
          className: user.className
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  },

  forgotPassword: async (req, res) => {
    try {
      const { email } = req.body;
      console.log('Password reset request for:', email);
      
      const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
      if (users.length === 0) {
        return res.status(404).json({ message: 'User not found' });
      }

      const resetToken = crypto.randomBytes(32).toString('hex');
      const tokenExpiry = new Date();
      tokenExpiry.setHours(tokenExpiry.getHours() + 1);

      await db.query(
        'UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE email = ?',
        [resetToken, tokenExpiry, email]
      );

      const resetLink = `${FRONTEND_URL}/reset-password?token=${resetToken}`;
      await emailService.sendEmail(
        email,
        'Reset Your Password - School Management System',
        `
        <h1>Password Reset Request</h1>
        <p>You have requested to reset your password.</p>
        <p>Please click the link below to set a new password:</p>
        <p><a href="${resetLink}">Reset Password</a></p>
        <p>This link will expire in 1 hour.</p>
        <p>If you did not request this password reset, please ignore this email.</p>
        `
      );

      console.log('Password reset email sent to:', email);
      res.json({ message: 'Password reset instructions have been sent to your email' });
    } catch (error) {
      console.error('Forgot password error:', error);
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  },

  resetPassword: async (req, res) => {
    try {
      const { token, newPassword } = req.body;
      console.log('Password reset attempt with token');
      
      const [users] = await db.query(
        'SELECT * FROM users WHERE reset_token = ? AND reset_token_expiry > NOW()',
        [token]
      );

      if (users.length === 0) {
        return res.status(400).json({ message: 'Invalid or expired reset token' });
      }

      const hashedPassword = await bcrypt.hash(newPassword, 10);

      await db.query(
        'UPDATE users SET password = ?, reset_token = NULL, reset_token_expiry = NULL WHERE id = ?',
        [hashedPassword, users[0].id]
      );

      console.log('Password reset successful for user:', users[0].email);
      res.json({ message: 'Password reset successfully' });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  },

  logout: async (req, res) => {
    try {
      console.log('Logout request received');
      res.json({ message: 'Successfully logged out' });
    } catch (error) {
      console.error('Logout error:', error);
      res.status(200).json({ message: 'Logged out' });
    }
  },

  getUserDetails: async (req, res) => {
    try {
      const token = req.headers.authorization?.split(' ')[1];
      if (!token) {
        return res.status(401).json({ message: 'No token provided' });
      }

      const decoded = jwt.verify(token, JWT_SECRET);
      const [rows] = await db.query(
        `SELECT u.*, 
                t.first_name as teacher_first_name, 
                t.last_name as teacher_last_name,
                t.phone_number as teacher_phone,
                t.subject as teacher_subject,
                s.first_name as student_first_name,
                s.roll_number,
                s.master_program,
                s.track,
                s.phone_number as student_phone,
                s.track as className
         FROM users u 
         LEFT JOIN teachers t ON u.id = t.user_id 
         LEFT JOIN students s ON u.id = s.user_id
         WHERE u.id = ?`,
        [decoded.userId]
      );

      if (rows.length === 0) {
        return res.status(404).json({ message: 'User not found' });
      }

      const user = rows[0];
      let response = {
        id: user.id,
        email: user.email,
        role: user.role,
        name: user.name
      };

      if (user.role === 'teacher') {
        response = {
          ...response,
          firstName: user.teacher_first_name,
          lastName: user.teacher_last_name,
          phoneNumber: user.teacher_phone,
          mainSubject: user.teacher_subject,
          name: `${user.teacher_first_name} ${user.teacher_last_name}`
        };
      }

      if (user.role === 'student') {
        response = {
          ...response,
          firstName: user.student_first_name,
          rollNumber: user.roll_number,
          masterProgram: user.master_program,
          track: user.track,
          phoneNumber: user.student_phone,
          className: user.track
        };
      }

      res.json(response);
    } catch (error) {
      console.error('Error getting user details:', error);
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  }
};

module.exports = authController;
