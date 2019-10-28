CREATE TABLE Log_Assinaturas (
  idLog_Assinaturas SERIAL,
  Usuarios_idUsuarios INTEGER NOT NULL,
  Documentos_idDocumentos INTEGER NOT NULL,
  Solicitacoes_idSolicitacoes INTEGER NOT NULL,
  data_assinatura TIMESTAMP,
  localizacao  VARCHAR(45) NOT NULL,
  CONSTRAINT pk_Log_Assinaturas PRIMARY KEY(idLog_Assinaturas)
);

CREATE TABLE Usuarios (
  idUsuarios SERIAL,
  nome VARCHAR(45) NOT NULL,
  cpf VARCHAR(20) NOT NULL,
  foto VARCHAR(45) NOT NULL,
  email VARCHAR(45) NOT NULL,
  username VARCHAR(45) NOT NULL,
  password VARCHAR(45) NOT NULL,
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
    SELECT d.nome_documento, u.nome, s.assinado, a.data_assinatura, a.localizacao
    FROM documentos d, usuarios u, solicitacoes s, assinaturas a
    WHERE d.iddocumentos = s.documentos_iddocumentos AND
          a.documentos_iddocumentos = d.iddocumentos AND
          s.documentos_iddocumentos = a.documentos_iddocumentos AND
          s.id_solicitado = a.usuarios_idusuarios AND
          s.assinado = true AND
          a.usuarios_idusuarios = u.idusuarios
    ORDER BY a.data_assinatura DESC;

CREATE VIEW solicitacoesPorUsuario AS
    SELECT u.nome, d.nome_documento, s.data_inicio, s.assinado
    FROM Documentos d, Usuarios u, Solicitacoes s
    WHERE s.Usuarios_idUsuarios = u.idUsuarios AND
          d.idDocumentos = s.Documentos_idDocumentos AND
          d.Usuarios_idUsuarios = u.idUsuarios;

CREATE VIEW documentosInseridoPorUsuario AS
    SELECT u.nome, d.nome_documento, d.tipo, d.documento
    FROM Usuarios u, Documentos d
    WHERE u.idUsuarios = d.Usuarios_idUsuarios AND
          d.Usuarios_idUsuarios = u.idUsuarios
    ORDER BY u.nome;

CREATE FUNCTION log_insert()
RETURNS void AS $$
BEGIN
    INSERT INTO log_assinaturas
    SELECT *
    FROM Assinaturas
    WHERE data_assinatura = (
      SELECT MAX(data_assinatura)
      FROM Assinaturas);
END
$$ language 'plpgsql';

CREATE FUNCTION horario()
RETURNS trigger AS $$
BEGIN
    NEW.data_assinatura = now();
    RETURN NEW;
END
$$ language 'plpgsql';

CREATE TRIGGER horario_assinatura
BEFORE INSERT
ON Assinaturas
FOR EACH ROW
EXECUTE PROCEDURE horario();
