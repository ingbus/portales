create table ASEGURADOS_ASEGURABILIDAD
(
  NUMPOL           VARCHAR2(20),
  IDEPOL           NUMBER,
  DOC_TYPE         VARCHAR2(1),
  NUM_DOC          VARCHAR2(10),
  NOMBRE           VARCHAR2(300),
  AREA_CODE        VARCHAR2(4),
  PHONE_NUM        VARCHAR2(7),
  PARENTESCO       VARCHAR2(100),
  STATUS_ASEGURADO VARCHAR2(10),
  MONTO_DEDUCIBLE  NUMBER,
  EXCESO           VARCHAR2(1),
  CODPROVEE        VARCHAR2(12),
  NUMASEGURADO     NUMBER,
  MCATITULAR       VARCHAR2(1),  
  STSASEG          VARCHAR2(12)
);