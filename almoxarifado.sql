are consultas · SQL
USE vetcare;
 
-- 1) Tira o modelo de estoque. Só rode se categoria, produto e movimentacao estiverem vazias.
DROP TABLE IF EXISTS movimentacao;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS categoria;
 
-- 2) Guarda o agendamento antigo (nome_pet, especie, tipo_consulta...) caso tenha dados.
--    Se der erro dizendo que a tabela não existe, pule esta linha.
RENAME TABLE agendamento TO agendamento_antigo;
 
-- 3) Tipos de consulta (antes: categoria)
CREATE TABLE tipo_consulta (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(60) NOT NULL UNIQUE
);
 
-- 4) Pets, cada um ligado ao tutor da tabela cadastro (antes: produto)
CREATE TABLE pet (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    especie VARCHAR(50),
    data_nascimento DATE,
    responsavel_id INT NOT NULL,              -- tutor
    FOREIGN KEY (responsavel_id) REFERENCES cadastro(id)
);
 
-- 5) Consultas marcadas (antes: movimentacao)
CREATE TABLE agendamento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pet_id INT NOT NULL,
    tipo_consulta_id INT NOT NULL,
    conta_id INT NOT NULL,                    -- quem agendou
    data_hora DATETIME NOT NULL,
    status ENUM('agendada','concluida','cancelada') NOT NULL DEFAULT 'agendada',
    observacoes VARCHAR(255),
    FOREIGN KEY (pet_id)           REFERENCES pet(id),
    FOREIGN KEY (tipo_consulta_id) REFERENCES tipo_consulta(id),
    FOREIGN KEY (conta_id)         REFERENCES conta(id),
    INDEX idx_agendamento_data (data_hora)
);
 
-- 6) Tipos iniciais (ajuste como quiser)
INSERT INTO tipo_consulta (nome) VALUES
('Consulta de rotina'), ('Vacina'), ('Exame'), ('Cirurgia'), ('Retorno');
 
-- 7) Consulta da página inicial. A ordem das colunas é a que o inicio.html espera:
--    item[0] id | [1] tutor | [2] pet | [3] espécie | [4] tipo | [5] data e hora | [6] observações
SELECT a.id,
       c.responsavel,
       p.nome,
       p.especie,
       t.nome,
       a.data_hora,
       a.observacoes
FROM agendamento a
JOIN pet p            ON p.id = a.pet_id
JOIN cadastro c       ON c.id = p.responsavel_id
JOIN tipo_consulta t  ON t.id = a.tipo_consulta_id
WHERE a.status = 'agendada'
ORDER BY a.data_hora;
 
-- 8) Dados de teste (opcional; precisa existir pelo menos uma conta)
INSERT INTO cadastro (responsavel, cpf, data_nascimento_responsavel)
VALUES ('Maria Souza', '000.000.000-00', '1990-05-12');
SET @tutor = LAST_INSERT_ID();
 
INSERT INTO pet (nome, especie, data_nascimento, responsavel_id)
VALUES ('Thor', 'Cachorro', '2021-03-10', @tutor);
SET @pet = LAST_INSERT_ID();
 
INSERT INTO agendamento (pet_id, tipo_consulta_id, conta_id, data_hora, observacoes)
VALUES (@pet,
        (SELECT id FROM tipo_consulta WHERE nome = 'Vacina'),
        (SELECT id FROM conta ORDER BY id LIMIT 1),
        '2026-11-30 09:30:00',
        'Trazer a carteirinha de vacinação');