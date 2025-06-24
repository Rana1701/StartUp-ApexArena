-- 🔁 Nettoyage et création de la base
DROP DATABASE IF EXISTS dataBasestartup;
CREATE DATABASE dataBasestartup;
USE dataBasestartup;

-- 👤 Utilisateurs
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    email VARCHAR(100) NOT NULL,
    hashed_password VARCHAR(255),
    numero_phone VARCHAR(20),
    sexe VARCHAR(10),
    pays VARCHAR(100),
    province VARCHAR(100),
    adresse VARCHAR(255),
    code_postal VARCHAR(20),
    photo VARCHAR(255),
    role ENUM('client', 'admin', 'visiteur') DEFAULT 'client',
    statut VARCHAR(50) DEFAULT 'client',
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 👨‍💼 Administrateurs
CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    email VARCHAR(150),
    numero_phone VARCHAR(50),
    pays VARCHAR(100),
    province VARCHAR(100),
    adresse VARCHAR(255),
    code_postal VARCHAR(20),
    hashed_password TEXT,
    photo TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 🧠 Jeux
CREATE TABLE games (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(100),
    genre VARCHAR(50),
    min_players INT,
    max_players INT,
    duree_par_session INT,
    tarif_par_heure DECIMAL(10,2),
    min_age INT,
    game_area VARCHAR(100),
    video TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- 🎉 Événements
CREATE TABLE events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(100),
    emoji VARCHAR(10),
    description TEXT,
    tarification_type ENUM('par_joueur', 'par_heure', 'par_jour', 'fixe'),
    prix_unitaire DECIMAL(10,2),
    duree_minimale INT,
    min_players INT,
    max_players INT,
    duree VARCHAR(50),
    image TEXT,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- 💰 Plans de tarification
CREATE TABLE event_tarifs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    duree INT NOT NULL,
    min_players INT NOT NULL,
    max_players INT NOT NULL,
    prix DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE (event_id, duree, min_players, max_players)
);

CREATE TABLE event_tarifs_par_heure (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    duree INT NOT NULL,
    min_players INT NOT NULL,
    max_players INT NOT NULL,
    prix_par_heure DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE (event_id, duree, min_players, max_players)
);

CREATE TABLE event_tarif_jour (
    id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    duree INT NOT NULL,
    min_players INT NOT NULL,
    max_players INT NOT NULL,
    prix_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
    UNIQUE (event_id, duree, min_players, max_players)
);

-- 📅 Réservations
CREATE TABLE reservations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    jeu_id INT NOT NULL,
    event_id INT,
    event_type VARCHAR(100),
    date_time DATETIME,
    duree INT,
    players INT,
    prix_total DECIMAL(10,2),
    is_paid BOOLEAN DEFAULT FALSE,
    amount_paid DECIMAL(10,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'confirmée',
    source ENUM('client', 'admin', 'autre') DEFAULT 'client',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_modified_at DATETIME,
    last_modified_by VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES users(id),
    FOREIGN KEY (jeu_id) REFERENCES games(id),
    FOREIGN KEY (event_id) REFERENCES events(id)
);

-- 💵 Paiements
CREATE TABLE paiements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT,
    montant DECIMAL(10,2),
    mode_paiement VARCHAR(50),
    source VARCHAR(50),
    moyen VARCHAR(50),
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id)
);

-- 💳 Transactions
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT,
    reservation_id INT,
    montant DECIMAL(10,2),
    date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
    methode_paiement VARCHAR(50),
    statut VARCHAR(50),
    FOREIGN KEY (client_id) REFERENCES users(id),
    FOREIGN KEY (reservation_id) REFERENCES reservations(id)
);

-- 🕒 Horaires (jours de la semaine)
CREATE TABLE horaires (
    id INT AUTO_INCREMENT PRIMARY KEY,
    jour_semaine VARCHAR(20),           -- ex: "lundi"
    heure_debut TIME,
    heure_fin TIME,
    actif BOOLEAN DEFAULT TRUE,
    is_ferme BOOLEAN DEFAULT FALSE
);

-- ⛔ Plages bloquées par l'admin
CREATE TABLE plages_bloquees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    raison TEXT,
    niveau ENUM('admin', 'maintenance', 'privé') DEFAULT 'admin',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 📅 Jours fériés
CREATE TABLE jours_feries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    nom VARCHAR(100),
    ouverture TIME,          -- NULL = fermé
    fermeture TIME,          -- NULL = fermé
    commentaire TEXT
);

-- 📝 Modifications
CREATE TABLE modifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    reservation_id INT NOT NULL,
    admin_id INT NOT NULL,
    modification TEXT,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reservation_id) REFERENCES reservations(id),
    FOREIGN KEY (admin_id) REFERENCES admins(id)
);

-- 📚 Logs
CREATE TABLE logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,
    client_id INT,
    changements TEXT,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    FOREIGN KEY (client_id) REFERENCES users(id)
);

-- ⚙️ Paramètres globaux
CREATE TABLE parametres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cle VARCHAR(100) UNIQUE,
    valeur TEXT
);

-- ➕ Paramètre important déjà intégré
INSERT INTO parametres (cle, valeur) VALUES ('delai_minimum_reservation_minutes', '60');

-- 📰 Publications
CREATE TABLE publications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(255),
    contenu TEXT,
    type VARCHAR(50),
    date_publication DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 👑 Création de l'admin par défaut
INSERT INTO admins (
    username, nom, prenom, email, numero_phone, pays, province,
    adresse, code_postal, hashed_password, photo
) VALUES (
    'admin', 'Root', 'Admin', 'admin@example.com', '0000000000',
    'Canada', 'Québec', '123 rue Admin', 'H0H0H0',
    '$2b$12$ZdJ/4R5oaEWf2zaRsquIUubLi7BPGauTLzjIb/JXEIfrWSBUEIUTy',
    'admin.jpg'
);
