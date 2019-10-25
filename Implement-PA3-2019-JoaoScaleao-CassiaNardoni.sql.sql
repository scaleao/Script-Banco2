CREATE TABLE Log_Assinaturas (
  idLog_Assinaturas SERIAL,
  log_id INTEGER NOT NULL,
  data_criacao DATE NOT NULL,
  CONSTRAINT pk_Log_Assinaturas PRIMARY KEY(idLog_Assinaturas)
);

CREATE TABLE Usuarios (
  idUsuarios SERIAL,
  nome VARCHAR(45) NOT NULL,
  cpf VARCHAR(20) NOT NULL,
  foto VARCHAR(45) NOT NULL,
  CONSTRAINT pk_Usuarios PRIMARY KEY(idUsuarios)
);

CREATE TABLE Perfil (
  idPerfil SERIAL,
  Usuarios_idUsuarios INTEGER NOT NULL,
  rua VARCHAR(45) NULL,
  numero VARCHAR(45) NULL,
  cidade VARCHAR(45) NULL,
  CEP VARCHAR(45) NULL,
  profissao VARCHAR(20) NULL,
  cartao VARCHAR(20) NULL,
  CONSTRAINT fk_Perfil_Usuarios FOREIGN KEY(Usuarios_idUsuarios) REFERENCES Usuarios(idUsuarios),
  CONSTRAINT pk_Perfil PRIMARY KEY(idPerfil)
);

CREATE TABLE Documentos (
  idDocumentos SERIAL,
  Usuarios_idUsuarios INTEGER NOT NULL,
  nome_documento VARCHAR(45) NOT NULL,
  tipo VARCHAR(45) NOT NULL,
  documento VARCHAR(45) NOT NULL,
  CONSTRAINT fk_Documentos_Usuarios FOREIGN KEY(Usuarios_idUsuarios) REFERENCES Usuarios(idUsuarios),
  CONSTRAINT pk_Documentos PRIMARY KEY(idDocumentos)
);

CREATE TABLE Solicitacoes (
  idSolicitacoes SERIAL,
  data_inicio TIMESTAMP NOT NULL,
  id_Solicitado INTEGER NOT NULL,
  assinado BOOLEAN,
  Usuarios_idUsuarios INTEGER NOT NULL,
  Documentos_idDocumentos INTEGER NOT NULL,
  CONSTRAINT fk_Solicitacoes_Usuarios FOREIGN KEY(Usuarios_idUsuarios) REFERENCES Usuarios(idUsuarios),
  CONSTRAINT fk_Solicitacoes_Documentos FOREIGN KEY(Documentos_idDocumentos) REFERENCES Documentos(idDocumentos),
  CONSTRAINT pk_Solicitacoes PRIMARY KEY(idSolicitacoes, Usuarios_idUsuarios)
);

CREATE TABLE Assinaturas (
  id_Assinatura SERIAL,
  Usuarios_idUsuarios INTEGER NOT NULL,
  Documentos_idDocumentos INTEGER NOT NULL,
  Solicitacoes_idSolicitacoes INTEGER NOT NULL,
  data_assinatura TIMESTAMP NOT NULL,
  localizacao  VARCHAR(45) NOT NULL,
  CONSTRAINT pk_Assinaturas PRIMARY KEY(id_Assinatura)
);

CREATE USER scaleao WITH PASSWORD ‘scaleao123‘;
CREATE USER nardoni WITH PASSWORD ‘nardoni123‘;
CREATE USER funcionario WITH PASSWORD ‘abcde54321*‘;

CREATE VIEW documentosAssinados AS
    SELECT d.nome, u.nome, s.assinado, a.data_assinatura
    FROM Documentos d, Usuarios u, Solicitacoes s, Assinaturas a
    WHERE d.idDocumentos = s.Documentos_idDocumentos AND
	        a.Documentos_idDocumentos = d.idDocumentos AND
		      s.Documentos_idDocumentos = a.Documentos_idDocumentos AND
		      s.Usuarios_idUsuarios = 1 AND
		      s.id_Solicitado = a.Usuarios_idUsuarios AND
		      s.assinado = 'true' AND
		      a.Usuarios_idUsuarios = u.idUsuarios;

CREATE VIEW solicitacoesPorUsuario AS
    SELECT u.nome, d.nome, s.data_inicio, s.assinado
    FROM Documentos d, Usuarios u, Solicitacoes s
    WHERE s.id_Solicitado = 2 AND
          d.idDocumentos = s.Documentos_idDocumentos AND
          d.Usuarios_idUsuarios = u.idUsuarios;

CREATE VIEW documentosInseridoPorUsuario AS
    FROM Usuarios u, Documentos d
    WHERE u.idUsuarios = d.Usuarios_idUsuarios AND
          d.Usuarios_idUsuarios = 1;

CREATE TRIGGER tr_deposicao
AFTER UPDATE ON Estoque
FOR EACH row
SET quantidade = 10;


Assinaturas FOREIGN KEY=
  CONSTRAINT fk_Assinaturas_Usuarios FOREIGN KEY(Usuarios_idUsuarios) REFERENCES Usuarios(idUsuarios),
  CONSTRAINT fk_Assinaturas_Documentos FOREIGN KEY(Documentos_idDocumentos) REFERENCES Documentos(idDocumentos),
  CONSTRAINT fk_Assinaturas_Usuarios FOREIGN KEY(Solicitacoes_idSolicitacoes) REFERENCES Solicitacoes(idSolicitacoes),
