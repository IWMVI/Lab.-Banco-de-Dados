CREATE DATABASE exerc02
GO
USE exerc02
GO

-- Criação das Tabelas

CREATE TABLE aluno
(
    ra    INT          NOT NULL,
    nome  VARCHAR(100) NOT NULL,
    idade INT          NOT NULL,

    PRIMARY KEY (ra)
);
GO

CREATE TABLE disciplina
(
    codigo        INT         NOT NULL,
    nome          VARCHAR(80) NOT NULL,
    carga_horaria INT,

    PRIMARY KEY(codigo)
);
GO

CREATE TABLE curso
(
    codigo INT         NOT NULL,
    nome   VARCHAR(50) NOT NULL,
    area   INT         NOT NULL,

    PRIMARY KEY (codigo)
);
GO

CREATE TABLE titulacao
(
    codigo INT         NOT NULL,
    titulo VARCHAR(40) NOT NULL,

    PRIMARY KEY (codigo)
);
GO

CREATE TABLE professor
(
    registro  INT          NOT NULL,
    nome      VARCHAR(100) NOT NULL,
    titulacao INT          NOT NULL,

    PRIMARY KEY (registro),
    FOREIGN KEY (titulacao) REFERENCES titulacao(codigo)
);
GO

CREATE TABLE disciplina_professor
(
    disciplinaCodigo  INT NOT NULL,
    professorRegistro INT NOT NULL,

    PRIMARY KEY (disciplinaCodigo, professorRegistro),
    FOREIGN KEY(disciplinaCodigo) REFERENCES disciplina(codigo),
    FOREIGN KEY (professorRegistro) REFERENCES professor(registro)
);
GO

CREATE TABLE curso_disciplina
(
    cursoCodigo      INT NOT NULL,
    disciplinaCodigo INT NOT NULL,

    PRIMARY KEY(cursoCodigo, disciplinaCodigo),
    FOREIGN KEY (cursoCodigo) REFERENCES curso(codigo),
    FOREIGN KEY (disciplinaCodigo) REFERENCES disciplina(codigo)
);
GO

CREATE TABLE aluno_disciplina
(
    alunoRa          INT NOT NULL,
    disciplinaCodigo INT NOT NULL,

    PRIMARY KEY (alunoRa, disciplinaCodigo),
    FOREIGN KEY (alunoRa) REFERENCES aluno(ra),
    FOREIGN KEY (disciplinaCodigo) REFERENCES disciplina(codigo)
);
GO

-- Alterações

UPDATE curso
SET area = 'Desconhecido' WHERE area IS NULL

ALTER TABLE curso
ALTER COLUMN area VARCHAR(50) NOT NULL;
GO

UPDATE aluno SET idade = 1 WHERE idade <= 0
GO

UPDATE disciplina SET carga_horaria = 32 WHERE carga_horaria <= 32
GO

ALTER TABLE aluno
ADD CONSTRAINT chk_idade CHECK (idade > 0)
GO

ALTER TABLE disciplina
ADD CONSTRAINT chk_carga_horaria CHECK(carga_horaria >= 32)
GO

-- Criação das VIEW's

CREATE VIEW vw_alunos
AS
    SELECT
        ra, nome AS aluno
    FROM
        aluno;
GO

CREATE VIEW vw_disciplinas
AS
    SELECT
        codigo AS CodigoDisciplina,
        nome AS disciplina
    FROM
        disciplina;
GO

CREATE VIEW vw_aluno_disciplina
AS
    SELECT
        alunoRa,
        disciplinaCodigo
    FROM
        aluno_disciplina;
GO

CREATE VIEW vw_professores
AS
    SELECT
        p.registro AS Titulacao,
        p.nome AS NomeProfessor
    FROM
        professor p
        JOIN titulacao t ON p.titulacao = t.codigo
GO

CREATE VIEW vw_disciplina_curso
AS
    SELECT
        d.nome AS nomeDisciplina,
        c.area AS areaCurso,
        c.nome AS nomeCurso
    FROM
        disciplina d
        JOIN curso_disciplina cd ON d.codigo = cd.disciplinaCodigo
        JOIN curso c ON cd.cursoCodigo = c.codigo;
GO

CREATE VIEW vw_disciplina_professor_titulo
AS
    SELECT
        d.disciplina AS Disciplina,
        t.titulo AS Titulo_Professor
    FROM
        disciplina_professor dp
        JOIN vw_disciplinas d ON dp.disciplinaCodigo = d.CodigoDisciplina
        JOIN vw_professores p ON dp.professorRegistro = p.Titulacao
        JOIN titulacao t ON p.Titulacao = t.codigo
GO

-- Consultas

/*
   01) Fazer uma pesquisa que permita gerar as listas de chamadas, com RA e nome por disciplina
*/

SELECT d.disciplina, a.ra, a.aluno
FROM
    vw_aluno_disciplina ad
    JOIN vw_alunos a ON ad.alunoRa = a.ra
    JOIN vw_disciplinas d ON ad.disciplinaCodigo = d.CodigoDisciplina
ORDER BY d.disciplina, a.aluno;

/*
    02) Fazer uma pesquisa que liste o nome das disciplinas e o nome dos professores que as ministram
*/

SELECT
    d.disciplina AS Disciplina,
    p.nomeProfessor AS Professor
FROM
    disciplina_professor dp
    JOIN vw_disciplinas d ON dp.disciplinaCodigo = d.CodigoDisciplina
    JOIN vw_professores p ON dp.professorRegistro = p.Titulacao
ORDER BY d.disciplina

/*
    3) Fazer uma pesquisa que , dado o nome de uma disciplina, retorne o nome do curso
*/

SELECT
    nomeCurso
FROM
    vw_disciplina_curso
WHERE nomeDisciplina LIKE 'Gestão%'

/*
    4) Fazer uma pesquisa que , dado o nome de uma disciplina, retorne sua área
*/

SELECT
    areaCurso
FROM
    vw_disciplina_curso
WHERE nomeDisciplina LIKE 'Teste%'

/*
    5) Fazer uma pesquisa que, dado o nome de uma disciplina, retorne o título do professor que a ministra
*/

SELECT
    t.titulo AS Titulação
FROM
    professor p
    JOIN disciplina_professor dp ON dp.professorRegistro = p.registro
    JOIN disciplina d ON d.codigo = dp.disciplinaCodigo
    JOIN titulacao t ON t.codigo = p.titulacao
WHERE d.nome LIKE 'Redes%'

/*
    6) Fazer uma pesquisa que retorne o nome da disciplina e quantos alunos estão matriculados em cada uma delas
*/

SELECT
    d.nome AS nomeDisciplina,
    COUNT(ad.alunoRa) AS quantidadeAlunos
FROM
    disciplina d
    LEFT JOIN aluno_disciplina ad ON d.codigo = ad.disciplinaCodigo
GROUP BY d.nome
ORDER BY nomeDisciplina

/*
    7) Fazer uma pesquisa que, dado o nome de uma disciplina, retorne o nome do professor.  Só deve retornar de disciplinas que tenham, no mínimo, 5 alunos matriculados
*/

WITH
    disciplinaComAlunos
    AS
    (
        SELECT ad.disciplinaCodigo,
            COUNT(ad.alunoRa) AS quantidadeAlunos
        FROM aluno_disciplina ad
        GROUP BY ad.disciplinaCodigo
        HAVING COUNT(ad.alunoRa) >= 5
    )

SELECT
    d.nome AS NomeDisciplina,
    p.nome AS NomeProfessor
FROM
    disciplinaComAlunos dca
    JOIN disciplina d ON dca.disciplinaCodigo = d.codigo
    JOIN disciplina_professor dp ON d.codigo = dp.disciplinaCodigo
    JOIN professor p ON dp.professorRegistro = p.registro
ORDER BY d.nome, p.nome

/*
    8) Fazer uma pesquisa que retorne o nome do curso e a quatidade de professores cadastrados que ministram aula nele. A coluna de ve se chamar quantidade
*/

SELECT
    c.nome AS NomeCurso,
    count(DISTINCT dp.professorRegistro) AS Quantidade
FROM
    curso c
    JOIN curso_disciplina cd ON c.codigo = cd.cursoCodigo
    JOIN disciplina_professor dp ON dp.disciplinaCodigo = cd.disciplinaCodigo
GROUP BY c.nome
ORDER BY c.nome