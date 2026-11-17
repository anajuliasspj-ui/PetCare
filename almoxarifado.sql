
CREATE DATABASE IF NOT EXISTS vetcare;
USE vetcare;

CREATE TABLE cadastro (
    id INT PRIMARY KEY AUTO_INCREMENT,
    responsavel VARCHAR(100) NOT NULL,
    cpf VARCHAR(255) NOT NULL,
    data_nascimento_responsavel DATE
);

CREATE TABLE conta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    tipo VARCHAR(20) NOT NULL DEFAULT 'usuario',
    senha VARCHAR(255) NOT NULL
);

CREATE TABLE agendamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_pet VARCHAR(100) NOT NULL,
    data_nascimento_animal DATE,
    especie VARCHAR(50),
    tipo_consulta VARCHAR(100)
);
