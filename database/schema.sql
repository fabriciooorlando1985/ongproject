-- ConectaDoa · schema.sql
-- Projeto Integrador Extensionista II · Atividade 2
--
-- Transforma em tabelas o MER do ConectaDoa (Documento de Visão, Seção 3):
--   Doador 1:N Doacao · Doacao N:N Item (tabela associativa doacao_item) · Item N:1 Categoria
--
-- Recria o banco do zero. Atenção: apaga os dados que já existirem.
-- Pode ser executado várias vezes seguidas, sempre com o mesmo resultado.
-- Requer MySQL 8.0.16 ou superior (ou MariaDB 10.2 ou superior), que aplicam o CHECK.

SET NAMES utf8mb4;

DROP DATABASE IF EXISTS conectadoa;
CREATE DATABASE conectadoa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE conectadoa;

-- ---------------------------------------------------------------------------
-- doador: quem doa para a ONG (pessoa ou empresa)
-- LGPD: o campo cpf do MER ficou de fora. A ONG não precisa dele para registrar
-- doações, e quanto menos dado pessoal guardado, menor o risco de vazamento.
-- ---------------------------------------------------------------------------
CREATE TABLE doador (
  id_doador     INT AUTO_INCREMENT PRIMARY KEY,
  nome          VARCHAR(150) NOT NULL,
  email         VARCHAR(100) UNIQUE,
  telefone      VARCHAR(20),
  ativo         BOOLEAN      NOT NULL DEFAULT TRUE,
  data_cadastro TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_doador_nome  CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_doador_email CHECK (email IS NULL OR email LIKE '_%@_%._%')
);

-- ---------------------------------------------------------------------------
-- categoria: agrupa os itens do catálogo (Alimento, Higiene, Vestuário...)
-- ---------------------------------------------------------------------------
CREATE TABLE categoria (
  id_categoria INT AUTO_INCREMENT PRIMARY KEY,
  nome         VARCHAR(60) NOT NULL UNIQUE,
  CONSTRAINT ck_categoria_nome CHECK (CHAR_LENGTH(TRIM(nome)) > 0)
);

-- ---------------------------------------------------------------------------
-- item: o catálogo do que a ONG recebe. Cada item pertence a uma categoria (N:1).
-- quantidade_estoque é o saldo do item na ONG (atributo "quantidade" do MER);
-- o nome diferente evita confusão com doacao_item.quantidade.
-- ---------------------------------------------------------------------------
CREATE TABLE item (
  id_item            INT AUTO_INCREMENT PRIMARY KEY,
  id_categoria       INT          NOT NULL,
  nome               VARCHAR(150) NOT NULL,
  unidade            VARCHAR(20)  NOT NULL DEFAULT 'unidade',
  quantidade_estoque INT          NOT NULL DEFAULT 0,
  prioridade         ENUM('baixa', 'media', 'alta') NOT NULL DEFAULT 'media',
  ativo              BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT uq_item_categoria_nome UNIQUE (id_categoria, nome),
  CONSTRAINT ck_item_nome    CHECK (CHAR_LENGTH(TRIM(nome)) > 0),
  CONSTRAINT ck_item_estoque CHECK (quantidade_estoque >= 0),
  CONSTRAINT fk_item_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria)
);

-- ---------------------------------------------------------------------------
-- doacao: um registro de doação feito por um doador (1:N).
-- Sem CASCADE na chave estrangeira: o banco impede excluir um doador que tem
-- doações, o que protege o histórico da ONG.
-- ---------------------------------------------------------------------------
CREATE TABLE doacao (
  id_doacao    INT AUTO_INCREMENT PRIMARY KEY,
  id_doador    INT          NOT NULL,
  data_doacao  DATE         NOT NULL,
  observacao   VARCHAR(255),
  status       ENUM('pendente', 'entregue', 'cancelada') NOT NULL DEFAULT 'pendente',
  data_entrega DATE,
  criado_em    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- Regras de negócio garantidas pelo próprio banco:
  CONSTRAINT ck_doacao_entrega_apos_doacao
    CHECK (data_entrega IS NULL OR data_entrega >= data_doacao),
  CONSTRAINT ck_doacao_entregue_tem_data
    CHECK (status <> 'entregue' OR data_entrega IS NOT NULL),
  CONSTRAINT fk_doacao_doador FOREIGN KEY (id_doador)
    REFERENCES doador (id_doador),
  INDEX idx_doacao_data (data_doacao)
);

-- ---------------------------------------------------------------------------
-- doacao_item: tabela associativa do relacionamento N:N entre doacao e item.
-- A chave primária composta impede o mesmo item duas vezes na mesma doação.
-- quantidade é atributo da relação: não pertence nem à doação nem ao item.
-- ---------------------------------------------------------------------------
CREATE TABLE doacao_item (
  id_doacao  INT NOT NULL,
  id_item    INT NOT NULL,
  quantidade INT NOT NULL,
  PRIMARY KEY (id_doacao, id_item),
  CONSTRAINT ck_doacao_item_quantidade CHECK (quantidade > 0),
  -- Excluir a doação apaga os itens dela; o item do catálogo não pode ser
  -- excluído enquanto houver doação que o use.
  CONSTRAINT fk_doacao_item_doacao FOREIGN KEY (id_doacao)
    REFERENCES doacao (id_doacao) ON DELETE CASCADE,
  CONSTRAINT fk_doacao_item_item FOREIGN KEY (id_item)
    REFERENCES item (id_item)
);
