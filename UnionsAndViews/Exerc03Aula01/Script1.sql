CREATE DATABASE onibus
GO
USE onibus
GO

-- Criação Tabelas

CREATE TABLE motorista
(
    codigo       INT         NOT NULL,
    nome         VARCHAR(40) NOT NULL,
    naturalidade VARCHAR(40) NOT NULL,

    PRIMARY KEY(codigo)
)
GO
CREATE TABLE onibus
(
    placa     CHAR(7)     NOT NULL,
    marca     VARCHAR(15) NOT NULL,
    ano       INT         NOT NULL,
    descricao VARCHAR(20) NOT NULL,

    PRIMARY KEY (placa)
)
GO
CREATE TABLE viagem
(
    codigo       INT         NOT NULL,
    onibus       CHAR(7)     NOT NULL,
    motorista    INT         NOT NULL,
    hora_saida   INT         NOT NULL CHECK(hora_saida >=0),
    hora_chegada INT         NOT NULL CHECK(hora_chegada >= 0),
    partida      VARCHAR(40) NOT NULL,
    destino      VARCHAR(40) NOT NULL,

    PRIMARY KEY (codigo),
    FOREIGN KEY (onibus) REFERENCES onibus (placa),
    FOREIGN KEY (motorista) REFERENCES motorista (codigo)
)

-- Correções

-- EXEC sp_rename 'viagem.pratida', 'partida', 'COLUMN'

-- Consultas

-- 1) Criar um Union das tabelas Motorista e ônibus, com as colunas ID (Código e Placa) e Nome (Nome e Marca)

    SELECT
        CAST(codigo AS VARCHAR) AS ID,
        nome AS Nome
    FROM motorista
UNION
    SELECT
        placa AS ID,
        marca AS Nome
    FROM onibus
GO

-- 2) Criar uma View (Chamada v_motorista_onibus) do Union acima

CREATE VIEW v_motorista_onibus
AS
            SELECT
            CAST(codigo AS VARCHAR) AS ID,
            nome AS Nome
        FROM motorista
    UNION
        SELECT
            placa AS ID,
            marca AS Nome
        FROM onibus
GO

/*
    3) Criar uma View (Chamada v_descricao_onibus) que mostre o Código da Viagem, o Nome do motorista, a placa do ônibus (Formato XXX-0000),
    a Marca do ônibus, o Ano do ônibus e a descrição do onibus
*/

CREATE VIEW v_descricao_onibus
AS
    SELECT
        v.codigo AS codigoViagem,
        m.nome AS nomeMotorista,
        CONCAT(SUBSTRING(UPPER(o.placa), 1, 3), '-', SUBSTRING(o.placa, 4, 4)) AS Placa,
        o.marca AS marcaOnibus,
        o.ano AS anoOnibus,
        o.descricao AS descricaoOnibus
    FROM
        viagem v
        JOIN motorista m ON m.codigo = v.motorista
        JOIN onibus o ON o.placa = v.onibus
GO

/*
    4) Criar uma View (Chamada v_descricao_viagem) que mostre o Código da viagem, a placa do ônibus(Formato XXX-0000),
    a Hora da Saída da viagem (Formato HH:00), a Hora da Chegada da viagem (Formato HH:00), partida e destino
*/

CREATE VIEW v_descricao_viagem
AS
    SELECT
        v.codigo AS codigoViagem,
        CONCAT(SUBSTRING(UPPER(o.placa), 1,3), '-', SUBSTRING(o.placa, 4,4)) AS Placa,
        CONCAT(RIGHT('0' + CAST(v.hora_saida AS VARCHAR(2)), 2), ':00') AS horaSaida,
        CONCAT(RIGHT('0' + CAST(v.hora_chegada AS VARCHAR(2)), 2), ':00') AS horaChegada,
        v.partida AS Partida,
        v.destino AS Destino
    FROM
        viagem v
        JOIN onibus o ON o.placa = v.onibus
GO