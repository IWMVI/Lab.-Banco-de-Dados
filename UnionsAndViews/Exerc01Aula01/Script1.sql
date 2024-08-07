CREATE DATABASE unions_views
GO
USE unions_views
GO
CREATE TABLE Curso
(
    Codigo_curso INT         NOT NULL,
    Nome         VARCHAR(70) NOT NULL,
    Sigla        VARCHAR(10) NOT NULL,

    PRIMARY KEY (Codigo_curso)
)
GO
CREATE TABLE Aluno
(
    RA           CHAR(7)      NOT NULL,
    Nome         VARCHAR(250) NOT NULL,
    Codigo_curso INT          NOT NULL,

    PRIMARY KEY (RA),
    FOREIGN KEY (Codigo_curso) REFERENCES Curso (Codigo_curso)
)
GO
CREATE TABLE Palestrante
(
    Codigo_Palestrante INT          IDENTITY,
    Nome               VARCHAR(250) NOT NULL,
    Empresa            VARCHAR(100) NOT NULL,

    PRIMARY KEY (Codigo_Palestrante)
)
GO
CREATE TABLE Palestra
(
    Codigo_Palestra    INT          IDENTITY,
    Titulo             VARCHAR(MAX) NOT NULL,
    Carga_Horaria      INT          NULL,
    Data               DATETIME     NOT NULL,
    Codigo_Palestrante INT          NOT NULL,

    PRIMARY KEY (Codigo_Palestra),
    FOREIGN KEY (Codigo_Palestrante) REFERENCES Palestrante(Codigo_Palestrante)
)
GO
CREATE TABLE Alunos_inscritos
(
    RA              CHAR(7) NOT NULL,
    Codigo_Palestra INT     NOT NULL,

    PRIMARY KEY (RA,Codigo_Palestra),
    FOREIGN KEY (RA) REFERENCES Aluno(RA),
    FOREIGN KEY (Codigo_Palestra) REFERENCES Palestra(Codigo_Palestra)
)
GO
CREATE TABLE Nao_Alunos
(
    RG        VARCHAR(9)   NOT NULL,
    Orgao_EXP CHAR(5)      NOT NULL,
    Nome      VARCHAR(250) NOT NULL,

    PRIMARY KEY (RG,Orgao_EXP)
)
GO
CREATE TABLE Nao_Alunos_Inscritos
(
    Codigo_Palestra INT        NOT NULL,
    RG              VARCHAR(9) NOT NULL,
    Orgao_EXP       CHAR(5)    NOT NULL,

    PRIMARY KEY (Codigo_Palestra, RG, Orgao_EXP),
    FOREIGN KEY (Codigo_Palestra) REFERENCES Palestra(Codigo_Palestra),
    FOREIGN KEY (RG,Orgao_Exp) REFERENCES Nao_Alunos(RG,Orgao_Exp)
)

CREATE VIEW v_chamadaPalestra
AS
            SELECT al.RA AS num_documento, alu.Nome AS Nome_Pessoa, pa.Titulo AS Titulo_Palestra, pl.Nome AS Nome_Palestrante,
            pa.Carga_Horaria AS Carga_Horária, CONVERT(CHAR(10),pa.Data,103) AS Data
        FROM Alunos_inscritos al, Palestra pa, Palestrante pl, Aluno alu
        WHERE al.Codigo_Palestra = pa.Codigo_Palestra
            AND al.RA = alu.RA
            AND pa.Codigo_Palestrante = pl.Codigo_Palestrante
    UNION
        SELECT nai.RG + nai.Orgao_EXP AS num_documento, Na.Nome AS Nome_Pessoa, pa.Titulo AS Titulo_Palestra, pl.Nome AS Nome_Palestrante,
            pa.Carga_Horaria AS Carga_Horária, CONVERT(CHAR(10),pa.Data,103) AS Data
        FROM Nao_Alunos Na, Nao_Alunos_Inscritos nai, Palestra pa, Palestrante pl
        WHERE Na.RG =nai.RG AND nai.Orgao_EXP = Na.Orgao_EXP
            AND nai.Codigo_Palestra = pa.Codigo_Palestra
            AND pa.Codigo_Palestrante = pl.Codigo_Palestrante

INSERT INTO Curso
VALUES
    (123, 'Analise e Desenvolvimento de Sistemas', 'ADS')

INSERT INTO Aluno
VALUES
    ('1111111', 'Wallace', 123)

INSERT INTO Palestrante
VALUES
    ('Leandro', 'FATEC')

INSERT INTO Palestra
VALUES
    ('Banco de Dados', 10, '2024-10-10', 1)

INSERT INTO Alunos_inscritos
VALUES
    ('1111111', 1)

INSERT INTO Nao_Alunos
VALUES
    ('123456789', 'SP', 'Fulano')

INSERT INTO Nao_Alunos_Inscritos
VALUES
    (1, '123456789', 'SP')

SELECT *
FROM v_chamadaPalestra
ORDER BY Nome_Pessoa