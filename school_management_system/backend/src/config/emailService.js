const nodemailer = require('nodemailer');
const { google } = require('googleapis');

// Gmail OAuth2 configuration
const oAuth2Client = new google.auth.OAuth2(
  process.env.GMAIL_CLIENT_ID,
  process.env.GMAIL_CLIENT_SECRET,
  process.env.GMAIL_REDIRECT_URI
);

oAuth2Client.setCredentials({ refresh_token: process.env.GMAIL_REFRESH_TOKEN });

// Create reusable transporter
async function createTransporter() {
  try {
    // Vérification des variables d'environnement requises
    const requiredEnvVars = [
      'GMAIL_CLIENT_ID',
      'GMAIL_CLIENT_SECRET',
      'GMAIL_REDIRECT_URI',
      'GMAIL_REFRESH_TOKEN',
      'GMAIL_USER'
    ];

    const missingEnvVars = requiredEnvVars.filter(varName => !process.env[varName]);
    if (missingEnvVars.length > 0) {
      throw new Error(`Variables d'environnement manquantes: ${missingEnvVars.join(', ')}`);
    }

    console.log('Obtention du token d\'accès...');
    const accessToken = await oAuth2Client.getAccessToken();
    console.log('Token d\'accès obtenu avec succès');
    
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        type: 'OAuth2',
        user: process.env.GMAIL_USER,
        clientId: process.env.GMAIL_CLIENT_ID,
        clientSecret: process.env.GMAIL_CLIENT_SECRET,
        refreshToken: process.env.GMAIL_REFRESH_TOKEN,
        accessToken: accessToken.token,
      },
    });

    // Vérifier la connexion
    await transporter.verify();
    console.log('Connexion SMTP vérifiée avec succès');

    return transporter;
  } catch (error) {
    console.error('Erreur lors de la création du transporteur email:', error);
    throw new Error(`Erreur de configuration email: ${error.message}`);
  }
}

async function sendEmail(to, subject, html) {
  try {
    if (!to || !subject || !html) {
      throw new Error('Paramètres manquants pour l\'envoi d\'email');
    }

    console.log('Création du transporteur email...');
    const transporter = await createTransporter();

    console.log('Préparation de l\'envoi email à:', to);
    const mailOptions = {
      from: `School Management System <${process.env.GMAIL_USER}>`,
      to,
      subject,
      html,
    };

    console.log('Tentative d\'envoi email...');
    const result = await transporter.sendMail(mailOptions);
    console.log('Email envoyé avec succès:', result.messageId);
    return result;
  } catch (error) {
    console.error('Erreur d\'envoi email:', error);
    if (error.response) {
      console.error('Réponse SMTP:', error.response.body);
    }
    throw new Error(`Échec d\'envoi email: ${error.message}`);
  }
}

async function sendRegistrationEmail(email, firstName, Password) {
  if (!email || !firstName || !Password) {
    throw new Error('Paramètres manquants pour l\'email d\'inscription');
  }

  console.log('Préparation de l\'email d\'inscription pour:', email);
  const subject = 'Inscription Approuvée - School Management System';
  const html = `
    <h1>Bienvenue sur School Management System</h1>
    <p>Cher/Chère ${firstName},</p>
    <p>Votre inscription a été automatiquement approuvée. Vous pouvez maintenant vous connecter à votre compte avec les identifiants suivants:</p>
    <p><strong>Email:</strong> ${email}<br>
    <strong>Mot de passe:</strong> ${Password}</p>
    <p>Veuillez changer votre mot de passe après votre première connexion pour des raisons de sécurité.</p>
    <p>Cordialement,<br>L'équipe School Management</p>
  `;

  return sendEmail(email, subject, html);
}

module.exports = {
  sendRegistrationEmail,
  sendEmail
};
