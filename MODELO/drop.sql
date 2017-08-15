/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases v5.2.0                     */
/* Target DBMS:           Oracle 11g                                      */
/* Project file:          Modelo_CloudDP.dez                              */
/* Project name:          Cloud DP                                        */
/* Author:                Antonio Pérez Caballero                         */
/* Script type:           Database drop script                            */
/* Created on:            2010-12-22 12:47                                */
/* Model version:         Version 2010-12-22                              */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Drop triggers                                                          */
/* ---------------------------------------------------------------------- */

DROP TRIGGER Trg_TRANSACCIONES1;

DROP TRIGGER Trg_SERVICIOS1;

DROP TRIGGER Trg_PETICIONES1;

DROP TRIGGER Trg_HILOS1;

DROP TRIGGER Trg_DOC_CUSTODIA1;

DROP TRIGGER Trg_CLIENTES1;

DROP TRIGGER Trg_ALMACENCERT1;

DROP TRIGGER Trg_CONSUMOS;

DROP TRIGGER Trg_FACTURAS;

DROP TRIGGER Trg_GREMIOS1;

DROP TRIGGER Trg_INVITADOS1;

DROP TRIGGER Trg_Sesiones1;

DROP TRIGGER Trg_DEPARTAMENTOS1;

DROP TRIGGER Trg_GRUPOS1;

DROP TRIGGER Trg_WORKFORCE1;

DROP TRIGGER Trg_Consultas1;

DROP TRIGGER Trg_TIPOS_DOC1;

DROP TRIGGER Trg_WEB_PERSONAL1;

DROP TRIGGER Trg_TABLON;

/* ---------------------------------------------------------------------- */
/* Drop foreign key constraints                                           */
/* ---------------------------------------------------------------------- */

ALTER TABLE USOS_CERTIFICADO DROP CONSTRAINT ALMACENCERT_USOS_CERTIFICADO;

ALTER TABLE TRANSACCIONES DROP CONSTRAINT USUARIOS_TRANSACCIONES;

ALTER TABLE SERVICIOS_CONTRATADOS DROP CONSTRAINT CLIENTES_SERVICIOS_CONTRATADOS;

ALTER TABLE SERVICIOS DROP CONSTRAINT CONSUMOS_SERVICIOS;

ALTER TABLE PETICIONES DROP CONSTRAINT CLIENTES_PETICIONES;

ALTER TABLE HILOS DROP CONSTRAINT PETICIONES_HILOS;

ALTER TABLE DOC_CUSTODIA DROP CONSTRAINT CLIENTES_DOC_CUSTODIA;

ALTER TABLE DOC_CUSTODIA DROP CONSTRAINT Docs_Metadatos_DOC_CUSTODIA;

ALTER TABLE CLIENTES DROP CONSTRAINT USUARIOS_CLIENTES;

ALTER TABLE CLIENTES DROP CONSTRAINT GRUPOS_CLIENTES;

ALTER TABLE CLIENTES DROP CONSTRAINT DEPARTAMENTOS_CLIENTES;

ALTER TABLE ALMACENCERT DROP CONSTRAINT CLIENTES_ALMACENCERT;

ALTER TABLE ALMACENCERT DROP CONSTRAINT DOC_CUSTODIA_ALMACENCERT;

ALTER TABLE CONSUMOS DROP CONSTRAINT CLIENTES_CONSUMOS;

ALTER TABLE FACTURAS DROP CONSTRAINT CLIENTES_FACTURAS;

ALTER TABLE FACTURAS DROP CONSTRAINT FISCALIDAD_FACTURAS;

ALTER TABLE FACTURA_DETALLE DROP CONSTRAINT FACTURAS_FACTURA_DETALLE;

ALTER TABLE GREMIOS DROP CONSTRAINT USUARIOS_GREMIOS;

ALTER TABLE INVITADOS DROP CONSTRAINT CLIENTES_INVITADOS;

ALTER TABLE DEPARTAMENTOS DROP CONSTRAINT GRUPOS_DTOS_DEPARTAMENTOS;

ALTER TABLE GRUPOS DROP CONSTRAINT GRUPOS_DTOS_GRUPOS;

ALTER TABLE WORKFORCE DROP CONSTRAINT CONSUMOS_WORKFORCE;

ALTER TABLE CALENDARIO_DOCS DROP CONSTRAINT TIPOS_DOC_CALENDARIO_DOCS;

ALTER TABLE WEB_PERSONAL DROP CONSTRAINT CLIENTES_WEB_PERSONAL;

ALTER TABLE TABLON DROP CONSTRAINT WEB_PERSONAL_TABLON;

/* ---------------------------------------------------------------------- */
/* Drop table "USUARIOS"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE USUARIOS DROP CONSTRAINT NN_USUARIOS;

ALTER TABLE USUARIOS DROP CONSTRAINT SRS_IDCLIENTE;

ALTER TABLE USUARIOS DROP CONSTRAINT SRS_MOVIL;

ALTER TABLE USUARIOS DROP CONSTRAINT SRS_IDGREMIO;

ALTER TABLE USUARIOS DROP CONSTRAINT PK_SRS;

/* Drop table */

DROP TABLE USUARIOS;

/* ---------------------------------------------------------------------- */
/* Drop table "USOS_CERTIFICADO"                                          */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE USOS_CERTIFICADO DROP CONSTRAINT SS_CRTFCD_ID;

ALTER TABLE USOS_CERTIFICADO DROP CONSTRAINT PK_SS_CRTFCD;

/* Drop table */

DROP TABLE USOS_CERTIFICADO;

/* ---------------------------------------------------------------------- */
/* Drop table "TRANSACCIONES"                                             */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE TRANSACCIONES DROP CONSTRAINT id_transaciones;

ALTER TABLE TRANSACCIONES DROP CONSTRAINT TRNSCCNS_USUARIO;

ALTER TABLE TRANSACCIONES DROP CONSTRAINT PK_TRNSCCNS;

/* Drop table */

DROP TABLE TRANSACCIONES;

/* ---------------------------------------------------------------------- */
/* Drop table "SERVICIOS_CONTRATADOS"                                     */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE SERVICIOS_CONTRATADOS DROP CONSTRAINT nn_SERVICIOS_CONTRATADOS;

ALTER TABLE SERVICIOS_CONTRATADOS DROP CONSTRAINT SRVCS_CNTRTDS_ID_SERVICIOS;

ALTER TABLE SERVICIOS_CONTRATADOS DROP CONSTRAINT SRVCS_CNTRTDS_ID_CLIENTE;

ALTER TABLE SERVICIOS_CONTRATADOS DROP CONSTRAINT PK_SRVCS_CNTRTDS;

/* Drop table */

DROP TABLE SERVICIOS_CONTRATADOS;

/* ---------------------------------------------------------------------- */
/* Drop table "SERVICIOS"                                                 */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE SERVICIOS DROP CONSTRAINT id_servicios;

ALTER TABLE SERVICIOS DROP CONSTRAINT PK_SRVCS;

/* Drop table */

DROP TABLE SERVICIOS;

/* ---------------------------------------------------------------------- */
/* Drop table "PETICIONES"                                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE PETICIONES DROP CONSTRAINT PTCNS_ID;

ALTER TABLE PETICIONES DROP CONSTRAINT PTCNS_ID_CLIENTE;

ALTER TABLE PETICIONES DROP CONSTRAINT PTCNS_ID_INDIRECTO;

ALTER TABLE PETICIONES DROP CONSTRAINT PTCNS_ESTADO_CLIENTE;

ALTER TABLE PETICIONES DROP CONSTRAINT PK_PTCNS;

/* Drop table */

DROP TABLE PETICIONES;

/* ---------------------------------------------------------------------- */
/* Drop table "PERFILES_DIGITALIZACION"                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE PERFILES_DIGITALIZACION DROP CONSTRAINT PRFLS_DGTLZCN_ID;

ALTER TABLE PERFILES_DIGITALIZACION DROP CONSTRAINT PK_PRFLS_DGTLZCN;

/* Drop table */

DROP TABLE PERFILES_DIGITALIZACION;

/* ---------------------------------------------------------------------- */
/* Drop table "LOTES_CARGA"                                               */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE LOTES_CARGA DROP CONSTRAINT LTS_CRG_ID;

ALTER TABLE LOTES_CARGA DROP CONSTRAINT PK_LTS_CRG;

/* Drop table */

DROP TABLE LOTES_CARGA;

/* ---------------------------------------------------------------------- */
/* Drop table "LOGS_ESTADISTICO"                                          */
/* ---------------------------------------------------------------------- */

/* Drop table */

DROP TABLE LOGS_ESTADISTICO;

/* ---------------------------------------------------------------------- */
/* Drop table "HILOS"                                                     */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE HILOS DROP CONSTRAINT HLS_ID;

ALTER TABLE HILOS DROP CONSTRAINT SYS_C0021790;

ALTER TABLE HILOS DROP CONSTRAINT PK_HLS;

/* Drop table */

DROP TABLE HILOS;

/* ---------------------------------------------------------------------- */
/* Drop table "DOC_CUSTODIA"                                              */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE DOC_CUSTODIA DROP CONSTRAINT DC_CSTDA_ID;

ALTER TABLE DOC_CUSTODIA DROP CONSTRAINT DC_CSTDA_CLIENTE;

ALTER TABLE DOC_CUSTODIA DROP CONSTRAINT PK_DC_CSTDA;

/* Drop table */

DROP TABLE DOC_CUSTODIA;

/* ---------------------------------------------------------------------- */
/* Drop table "CLIENTES"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE CLIENTES DROP CONSTRAINT CLNTS_ID;

ALTER TABLE CLIENTES DROP CONSTRAINT CLNTS_NOMBRE;

ALTER TABLE CLIENTES DROP CONSTRAINT CLNTS_NIF;

ALTER TABLE CLIENTES DROP CONSTRAINT CLNTS_MVL;

ALTER TABLE CLIENTES DROP CONSTRAINT CLNTS_IDGREMIO;

ALTER TABLE CLIENTES DROP CONSTRAINT PK_CLNTS;

/* Drop table */

DROP TABLE CLIENTES;

/* ---------------------------------------------------------------------- */
/* Drop table "ALMACENCERT"                                               */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE ALMACENCERT DROP CONSTRAINT LMCNCRT_ID;

ALTER TABLE ALMACENCERT DROP CONSTRAINT LMCNCRT_USO_CERTIFICADO;

ALTER TABLE ALMACENCERT DROP CONSTRAINT PK_LMCNCRT;

/* Drop table */

DROP TABLE ALMACENCERT;

/* ---------------------------------------------------------------------- */
/* Drop table "CONSUMOS"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE CONSUMOS DROP CONSTRAINT CNSMS_ID;

ALTER TABLE CONSUMOS DROP CONSTRAINT CNSMS_ID_SERVICIO;

ALTER TABLE CONSUMOS DROP CONSTRAINT CNSMS_ID_CLIENTE;

ALTER TABLE CONSUMOS DROP CONSTRAINT PK_CNSMS;

/* Drop table */

DROP TABLE CONSUMOS;

/* ---------------------------------------------------------------------- */
/* Drop table "FACTURAS"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE FACTURAS DROP CONSTRAINT FCTRS_ID;

ALTER TABLE FACTURAS DROP CONSTRAINT PK_FCTRS;

/* Drop table */

DROP TABLE FACTURAS;

/* ---------------------------------------------------------------------- */
/* Drop table "FACTURA_DETALLE"                                           */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

/* Drop table */

DROP TABLE FACTURA_DETALLE;

/* ---------------------------------------------------------------------- */
/* Drop table "GREMIOS"                                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE GREMIOS DROP CONSTRAINT GRMS_ID;

ALTER TABLE GREMIOS DROP CONSTRAINT PK_GRMS;

/* Drop table */

DROP TABLE GREMIOS;

/* ---------------------------------------------------------------------- */
/* Drop table "REDMOON"                                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE REDMOON DROP CONSTRAINT RDMN_ID;

ALTER TABLE REDMOON DROP CONSTRAINT PK_RDMN;

/* Drop table */

DROP TABLE REDMOON;

/* ---------------------------------------------------------------------- */
/* Drop table "FISCALIDAD"                                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE FISCALIDAD DROP CONSTRAINT FSCLDD_IDFactura;

/* Drop table */

DROP TABLE FISCALIDAD;

/* ---------------------------------------------------------------------- */
/* Drop table "INVITADOS"                                                 */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE INVITADOS DROP CONSTRAINT NVTDS_ID;

ALTER TABLE INVITADOS DROP CONSTRAINT NVTDS_IDCLIENTE;

ALTER TABLE INVITADOS DROP CONSTRAINT PK_NVTDS;

/* Drop table */

DROP TABLE INVITADOS;

/* ---------------------------------------------------------------------- */
/* Drop table "Docs_Metadatos"                                            */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Docs_Metadatos DROP CONSTRAINT Dcs_Mtdts_ID_DOC;

/* Drop table */

DROP TABLE Docs_Metadatos;

/* ---------------------------------------------------------------------- */
/* Drop table "Gremios_Corpus"                                            */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Gremios_Corpus DROP CONSTRAINT GRMS_CRPS_ID_GREMIO;

/* Drop table */

DROP TABLE Gremios_Corpus;

/* ---------------------------------------------------------------------- */
/* Drop table "TMP_CORPUS"                                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE TMP_CORPUS DROP CONSTRAINT TMP_CRPS_IDSesion;

/* Drop table */

DROP TABLE TMP_CORPUS;

/* ---------------------------------------------------------------------- */
/* Drop table "Sesiones"                                                  */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Sesiones DROP CONSTRAINT ssns_ID;

ALTER TABLE Sesiones DROP CONSTRAINT PK_ssns;

/* Drop table */

DROP TABLE Sesiones;

/* ---------------------------------------------------------------------- */
/* Drop table "Confi_User"                                                */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Confi_User DROP CONSTRAINT cnfsr_IDCLIENTE;

/* Drop table */

DROP TABLE Confi_User;

/* ---------------------------------------------------------------------- */
/* Drop table "tmpBLOB"                                                   */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE tmpBLOB DROP CONSTRAINT tmpBLB_IDSESION;

/* Drop table */

DROP TABLE tmpBLOB;

/* ---------------------------------------------------------------------- */
/* Drop table "VistasInterfaz"                                            */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE VistasInterfaz DROP CONSTRAINT Vstsntrfz_Nombre_Interfaz;

/* Drop table */

DROP TABLE VistasInterfaz;

/* ---------------------------------------------------------------------- */
/* Drop table "Temas_Usuarios"                                            */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Temas_Usuarios DROP CONSTRAINT TMS_sr_IDCLIENTE;

/* Drop table */

DROP TABLE Temas_Usuarios;

/* ---------------------------------------------------------------------- */
/* Drop table "DEPARTAMENTOS"                                             */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE DEPARTAMENTOS DROP CONSTRAINT DPRTMNTS_ID_DTO;

ALTER TABLE DEPARTAMENTOS DROP CONSTRAINT DPRTMNTS_IDCLIENTE;

ALTER TABLE DEPARTAMENTOS DROP CONSTRAINT DPRTMNTS_NOMBRE_DTO;

ALTER TABLE DEPARTAMENTOS DROP CONSTRAINT PK_DPRTMNTS;

/* Drop table */

DROP TABLE DEPARTAMENTOS;

/* ---------------------------------------------------------------------- */
/* Drop table "GRUPOS_DTOS"                                               */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE GRUPOS_DTOS DROP CONSTRAINT GRPS_DTS_ID_GRUPO;

ALTER TABLE GRUPOS_DTOS DROP CONSTRAINT GRPS_DTS_IDCLIENTE;

ALTER TABLE GRUPOS_DTOS DROP CONSTRAINT TUC_GRPS_DTS_1;

/* Drop table */

DROP TABLE GRUPOS_DTOS;

/* ---------------------------------------------------------------------- */
/* Drop table "GRUPOS"                                                    */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE GRUPOS DROP CONSTRAINT GRPS_ID_GRUPO;

ALTER TABLE GRUPOS DROP CONSTRAINT GRPS_NOMBRE_GRUPO;

ALTER TABLE GRUPOS DROP CONSTRAINT GRPS_IDCLIENTE;

ALTER TABLE GRUPOS DROP CONSTRAINT PK_GRPS;

/* Drop table */

DROP TABLE GRUPOS;

/* ---------------------------------------------------------------------- */
/* Drop table "WORKFORCE"                                                 */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE WORKFORCE DROP CONSTRAINT WRKFRC_ID;

ALTER TABLE WORKFORCE DROP CONSTRAINT WRKFRC_NOMBRE;

ALTER TABLE WORKFORCE DROP CONSTRAINT WRKFRC_NIF;

ALTER TABLE WORKFORCE DROP CONSTRAINT WRKFRC_MVL;

ALTER TABLE WORKFORCE DROP CONSTRAINT PK_WRKFRC;

/* Drop table */

DROP TABLE WORKFORCE;

/* ---------------------------------------------------------------------- */
/* Drop table "FormasJuridicas"                                           */
/* ---------------------------------------------------------------------- */

/* Drop table */

DROP TABLE FormasJuridicas;

/* ---------------------------------------------------------------------- */
/* Drop table "Consultas"                                                 */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE Consultas DROP CONSTRAINT CNSLTS_ID;

ALTER TABLE Consultas DROP CONSTRAINT CNSLTS_IDGREMIO;

ALTER TABLE Consultas DROP CONSTRAINT PK_CNSLTS;

/* Drop table */

DROP TABLE Consultas;

/* ---------------------------------------------------------------------- */
/* Drop table "DocConsulta"                                               */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE DocConsulta DROP CONSTRAINT DCCNSLT_ID_CONSULTA;

/* Drop table */

DROP TABLE DocConsulta;

/* ---------------------------------------------------------------------- */
/* Drop table "TempConsultas"                                             */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE TempConsultas DROP CONSTRAINT TMPCNSLTS_ID_DOC;

ALTER TABLE TempConsultas DROP CONSTRAINT TMPCNSLTS_SESION;

/* Drop table */

DROP TABLE TempConsultas;

/* ---------------------------------------------------------------------- */
/* Drop table "TmpResultados"                                             */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE TmpResultados DROP CONSTRAINT TMPRSLTDS_SESION;

/* Drop table */

DROP TABLE TmpResultados;

/* ---------------------------------------------------------------------- */
/* Drop table "TIPOS_DOC"                                                 */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE TIPOS_DOC DROP CONSTRAINT TPS_DC_ID;

ALTER TABLE TIPOS_DOC DROP CONSTRAINT TPS_DC_IDGREMIO;

ALTER TABLE TIPOS_DOC DROP CONSTRAINT PK_TPS_DC;

/* Drop table */

DROP TABLE TIPOS_DOC;

/* ---------------------------------------------------------------------- */
/* Drop table "CALENDARIO_DOCS"                                           */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE CALENDARIO_DOCS DROP CONSTRAINT CLDNDR_DCS_IDTIPODOC;

/* Drop table */

DROP TABLE CALENDARIO_DOCS;

/* ---------------------------------------------------------------------- */
/* Drop table "WEB_PERSONAL"                                              */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

ALTER TABLE WEB_PERSONAL DROP CONSTRAINT WB_PRSNL_IDCLIENTE;

ALTER TABLE WEB_PERSONAL DROP CONSTRAINT PK_WB_PRSNL;

/* Drop table */

DROP TABLE WEB_PERSONAL;

/* ---------------------------------------------------------------------- */
/* Drop table "TABLON"                                                    */
/* ---------------------------------------------------------------------- */

/* Drop constraints */

/* Drop table */

DROP TABLE TABLON;

/* ---------------------------------------------------------------------- */
/* Drop sequences                                                         */
/* ---------------------------------------------------------------------- */

DROP SEQUENCE s_clientes;

DROP SEQUENCE s_peticiones;

DROP SEQUENCE s_hilos;

DROP SEQUENCE s_gremios;

DROP SEQUENCE s_servicios;

DROP SEQUENCE s_consumos;

DROP SEQUENCE s_facturas;

DROP SEQUENCE s_doc_custodia;

DROP SEQUENCE s_invitados;

DROP SEQUENCE s_sesiones;

DROP SEQUENCE s_almacencert;

DROP SEQUENCE S_Transacciones;

DROP SEQUENCE S_DEPARTAMENTOS;

DROP SEQUENCE S_GRUPOS;

DROP SEQUENCE S_WORKFORCE;

DROP SEQUENCE S_CONSULTAS;

DROP SEQUENCE S_TIPOS_DOC;

DROP SEQUENCE S_WEB_PERSONAL;

DROP SEQUENCE s_tablon;
