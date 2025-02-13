CREATE TABLE IF NOT EXISTS system_logs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  type ENUM('error', 'security', 'action') NOT NULL,
  user_id INT,
  message TEXT NOT NULL,
  context JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Index pour améliorer les performances des requêtes
CREATE INDEX idx_logs_type ON system_logs(type);
CREATE INDEX idx_logs_user ON system_logs(user_id);
CREATE INDEX idx_logs_created_at ON system_logs(created_at);
