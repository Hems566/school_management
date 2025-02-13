// Générer un mot de passe à 4 caractères (lettres majuscules et chiffres)
const generatePassword = () => {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let password = '';
  for(let i = 0; i < 4; i++) {
    const randomIndex = Math.floor(Math.random() * charset.length);
    password += charset[randomIndex];
  }
  return password;
};

module.exports = {
  generatePassword
};
