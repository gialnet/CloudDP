/* ---------------------------------------------------------------------- */
/* Script generated with: DeZign for Databases v5.2.0                     */
/* Target DBMS:           Oracle 11g                                      */
/* Project file:          Modelo_CloudDP.dez                              */
/* Project name:          Cloud DP                                        */
/* Author:                Antonio Pérez Caballero                         */
/* Script type:           Database creation script                        */
/* Created on:            2010-11-02 20:05                                */
/* Model version:         Version 2010-11-02                              */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Sequences                                                              */
/* ---------------------------------------------------------------------- */

CREATE SEQUENCE s_clientes
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_peticiones
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_hilos
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_gremios
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_servicios
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_consumos
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_facturas
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_doc_custodia
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_invitados
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_sesiones
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE s_almacencert
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE S_Transacciones
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE S_DEPARTAMENTOS
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;

CREATE SEQUENCE S_GRUPOS
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;
 
CREATE SEQUENCE S_WORKFORCE
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    NOMAXVALUE
    nocycle
    noorder;
    
/* ---------------------------------------------------------------------- */
/* Tables                                                                 */
/* ---------------------------------------------------------------------- */

/* ---------------------------------------------------------------------- */
/* Add table "USUARIOS"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE USUARIOS (
    USUARIO VARCHAR2(30) CONSTRAINT NN_USUARIOS NOT NULL,
    NOMBRE VARCHAR2(40),
    IDCLIENTE INTEGER CONSTRAINT SRS_IDCLIENTE NOT NULL,
    IDINVITADO INTEGER,
    MOVIL CHAR(10) CONSTRAINT SRS_MOVIL NOT NULL,
    EMAIL VARCHAR2(90),
    TIPO CHAR(2),
    SIP VARCHAR2(40),
    PERFIL VARCHAR2(250),
    PASSWD VARCHAR2(20),
    DIGITOS VARCHAR2(16),
    IDDATOSPER INTEGER,
    IDGREMIO INTEGER CONSTRAINT SRS_IDGREMIO NOT NULL,
    SMS_PASS CHAR(6),
    SMS_UNTIL DATE,
    CONSTRAINT PK_SRS PRIMARY KEY (USUARIO)
);

CREATE UNIQUE INDEX IDX_USUARIOS_1 ON USUARIOS (MOVIL);

CREATE INDEX IDX_USUARIOS_2 ON USUARIOS (SMS_PASS);

COMMENT ON TABLE USUARIOS IS 'Usuarios de la aplicación, clientes, empleados y clientes de nuestros clientes.';

COMMENT ON COLUMN USUARIOS.USUARIO IS 'El DNI del usuario';

COMMENT ON COLUMN USUARIOS.TIPO IS 'Tipo de Cliente CL,clientes IN clientes indirectos';

COMMENT ON COLUMN USUARIOS.PERFIL IS 'url del servidor al que se conecta';

COMMENT ON COLUMN USUARIOS.SMS_PASS IS 'Clave aleatoria generada por el sistema para una sesión vía SMS';

COMMENT ON COLUMN USUARIOS.SMS_UNTIL IS 'HASTA CUANDO ES VALIDA LA PASSWORD';

/* ---------------------------------------------------------------------- */
/* Add table "USOS_CERTIFICADO"                                           */
/* ---------------------------------------------------------------------- */

CREATE TABLE USOS_CERTIFICADO (
    DESCRIPCION VARCHAR2(90),
    ID INTEGER CONSTRAINT SS_CRTFCD_ID NOT NULL,
    CONSTRAINT PK_SS_CRTFCD PRIMARY KEY (ID)
);

COMMENT ON TABLE USOS_CERTIFICADO IS 'Usos de los certificados, a que se destinan';

/* ---------------------------------------------------------------------- */
/* Add table "TRANSACCIONES"                                              */
/* ---------------------------------------------------------------------- */

CREATE TABLE TRANSACCIONES (
    ID INTEGER CONSTRAINT id_transaciones NOT NULL,
    FECHA TIMESTAMP DEFAULT SYSTIMESTAMP,
    NUMERO_BYTES NUMBER(10),
    DURACION INTEGER,
    IDCLIENTE INTEGER,
    INVITADO INTEGER,
    TIPO_OPERACION VARCHAR2(20),
    RESULTADO CHAR(2),
    USUARIO VARCHAR2(30) CONSTRAINT TRNSCCNS_USUARIO NOT NULL,
    SESION INTEGER,
    CONSTRAINT PK_TRNSCCNS PRIMARY KEY (ID)
);

COMMENT ON TABLE TRANSACCIONES IS 'LOGS DE LAS OPERCIONES REALIZADAS POR LOS CLEINTES. Se registran todas aquellas operaciones supceptibles de producir tráfico entre el almacenamiento Amazon S3 y nuestros clientes.';

COMMENT ON COLUMN TRANSACCIONES.RESULTADO IS 'OK o NO';

/* ---------------------------------------------------------------------- */
/* Add table "SERVICIOS_CONTRATADOS"                                      */
/* ---------------------------------------------------------------------- */

CREATE TABLE SERVICIOS_CONTRATADOS (
    ID INTEGER CONSTRAINT nn_SERVICIOS_CONTRATADOS NOT NULL,
    ID_SERVICIOS INTEGER CONSTRAINT SRVCS_CNTRTDS_ID_SERVICIOS NOT NULL,
    PRECIO NUMBER(10,3),
    MODALIDAD VARCHAR2(20),
    PERIODICIDAD VARCHAR2(20),
    ID_CLIENTE INTEGER CONSTRAINT SRVCS_CNTRTDS_ID_CLIENTE NOT NULL,
    CONSTRAINT PK_SRVCS_CNTRTDS PRIMARY KEY (ID)
);

COMMENT ON TABLE SERVICIOS_CONTRATADOS IS 'Servicios a los que puede acceder un cliente nuestro.';

/* ---------------------------------------------------------------------- */
/* Add table "SERVICIOS"                                                  */
/* ---------------------------------------------------------------------- */

CREATE TABLE SERVICIOS (
    ID INTEGER CONSTRAINT id_servicios NOT NULL,
    SERVICIO VARCHAR2(50),
    PRECIO NUMBER(10,3),
    MODALIDAD VARCHAR2(20),
    PERIODICIDAD VARCHAR2(20),
    TIPO_IVA NUMBER(5,2),
    CONSTRAINT PK_SRVCS PRIMARY KEY (ID)
);

CREATE INDEX IDX_SERVICIOS_1 ON SERVICIOS (SERVICIO);

COMMENT ON TABLE SERVICIOS IS 'Servicios que presta nuestra compañía';

/* ---------------------------------------------------------------------- */
/* Add table "PETICIONES"                                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE PETICIONES (
    ID INTEGER CONSTRAINT PTCNS_ID NOT NULL,
    ID_CLIENTE INTEGER CONSTRAINT PTCNS_ID_CLIENTE NOT NULL,
    ID_INDIRECTO INTEGER CONSTRAINT PTCNS_ID_INDIRECTO NOT NULL,
    FECHA DATE DEFAULT SYSTIMESTAMP,
    ASUNTO VARCHAR2(100),
    MENSAJE VARCHAR2(250),
    ESTADO_CLIENTE CHAR(8) DEFAULT 'NUEVO' CONSTRAINT PTCNS_ESTADO_CLIENTE NOT NULL,
    REMITENTE INTEGER,
    ESTADO_INVITADO VARCHAR2(8),
    CONSTRAINT PK_PTCNS PRIMARY KEY (ID)
);

COMMENT ON COLUMN PETICIONES.ESTADO_CLIENTE IS '''NUEVO'' ->NUEVA PETICION ''LEIDO''->PETICION ANTIGUA RESUELTA->PETICION CERRADA';

/* ---------------------------------------------------------------------- */
/* Add table "PERFILES_DIGITALIZACION"                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE PERFILES_DIGITALIZACION (
    ID NUMBER(38) CONSTRAINT SYS_C0021781 NOT NULL,
    DESCRIPCION VARCHAR2(256),
    CERTIFICADO NUMBER(38),
    NUMERO_ESCANEOS NUMBER(38),
    CLIENTE INTEGER
);

COMMENT ON TABLE PERFILES_DIGITALIZACION IS 'Diferentes configuraciones de escaneado de documentos.';

/* ---------------------------------------------------------------------- */
/* Add table "LOTES_CARGA"                                                */
/* ---------------------------------------------------------------------- */

CREATE TABLE LOTES_CARGA (
    ID NUMBER(38) CONSTRAINT SYS_C0021780 NOT NULL,
    FECHA TIMESTAMP,
    DESCRIPCION VARCHAR(50),
    WORKFORCE INTEGER,
    MB NUMBER(10,3),
    BYTES NUMBER(15),
    TIEMPO VARCHAR2(20)
);

COMMENT ON TABLE LOTES_CARGA IS 'Lotes de carga de documentos';

/* ---------------------------------------------------------------------- */
/* Add table "LOGS_ESTADISTICO"                                           */
/* ---------------------------------------------------------------------- */

CREATE TABLE LOGS_ESTADISTICO (
    ID_LOTE NUMBER(38),
    LOTE VARCHAR2(50),
    NUMERO_BYTES NUMBER(38),
    FECHA_EJECUCION TIMESTAMP,
    OPCION VARCHAR2(150),
    TIEMPO VARCHAR2(20)
);

COMMENT ON TABLE LOGS_ESTADISTICO IS 'Los datos estadisticos para control y seguimiento de la actividad del sistema';

/* ---------------------------------------------------------------------- */
/* Add table "HILOS"                                                      */
/* ---------------------------------------------------------------------- */

CREATE TABLE HILOS (
    ID INTEGER CONSTRAINT HLS_ID NOT NULL,
    ID_PETICION INTEGER CONSTRAINT SYS_C0021790 NOT NULL,
    FECHA TIMESTAMP DEFAULT SYSTIMESTAMP,
    MENSAJE VARCHAR2(512),
    ESTADO_CLIENTE CHAR(5) DEFAULT 'NUEVO',
    REMITENTE INTEGER,
    ID_DOC_ADJUNTO INTEGER,
    ESTADO_INVITADO VARCHAR2(8),
    CONSTRAINT PK_HLS PRIMARY KEY (ID)
);

/* ---------------------------------------------------------------------- */
/* Add table "DOC_CUSTODIA"                                               */
/* ---------------------------------------------------------------------- */

CREATE TABLE DOC_CUSTODIA (
    ID INTEGER CONSTRAINT DC_CSTDA_ID NOT NULL,
    LOTE INTEGER,
    CLIENTE INTEGER CONSTRAINT DC_CSTDA_CLIENTE NOT NULL,
    EMPLEADO INTEGER,
    INVITADO INTEGER,
    TIPO_MIME VARCHAR2(90),
    URL_LOCAL VARCHAR2(250),
    UBICACION VARCHAR2(250),
    NUMERO_BYTES NUMBER(10),
    FECHA TIMESTAMP DEFAULT SYSTIMESTAMP,
    VISIBLE CHAR(1) DEFAULT 'N',
    ALMACENCERT INTEGER,
    FIRMADO CHAR(1),
    SELLADO CHAR(1),
    FMTVER_FIRMA VARCHAR2(40),
    TIPO_DOCUMENTO VARCHAR2(90),
    ORIGEN_DOC VARCHAR2(20),
    FECHA_DOC DATE,
    HASH_SH1 VARCHAR2(200),
    CIFRADO CHAR(1) DEFAULT 'N',
    NOTA VARCHAR2(40),
    GRUPO INTEGER,
    DTO INTEGER,
    WORKFORCE CHAR(2) DEFAULT 'NO',
    CONSTRAINT PK_DC_CSTDA PRIMARY KEY (ID)
);

CREATE INDEX IDX_DOC_CUSTODIA_1 ON DOC_CUSTODIA (UBICACION);

CREATE INDEX IDX_DOC_CUSTODIA_2 ON DOC_CUSTODIA (EMPLEADO);

CREATE INDEX IDX_DOC_CUSTODIA_3 ON DOC_CUSTODIA (INVITADO);

CREATE INDEX IDX_DOC_CUSTODIA_4 ON DOC_CUSTODIA (CLIENTE);

CREATE INDEX IDX_DOC_CUSTODIA_5 ON DOC_CUSTODIA (TIPO_DOCUMENTO);

CREATE INDEX IDX_DOC_CUSTODIA_6 ON DOC_CUSTODIA (ORIGEN_DOC);

CREATE INDEX IDX_DOC_CUSTODIA_7 ON DOC_CUSTODIA (GRUPO);

COMMENT ON TABLE DOC_CUSTODIA IS 'Los datos referentes a los documentos almacenados en la nube. Los metadatos. Relaciona clientes y servicios';

COMMENT ON COLUMN DOC_CUSTODIA.EMPLEADO IS 'CODIGO DEL EMPLEADO';

COMMENT ON COLUMN DOC_CUSTODIA.INVITADO IS 'CODIGO DE LA TABLA DE INVITADOS. SON LOS CLIENTES DE NUESTROS CLIENTES';

COMMENT ON COLUMN DOC_CUSTODIA.UBICACION IS 'La carpeta en la que se almacena el documento en la nube';

COMMENT ON COLUMN DOC_CUSTODIA.TIPO_DOCUMENTO IS 'DESCRIBE EL DOCUMENTO Y SU CARACTER EJEMPLO 110 RETENCIONES DE AL RENTA, 330 IVA, ETC, VENTAS,COMPRAS, BALANCE SITUACION, POERDIDAS Y GANANCIAS DACIONES, MORATORIOS, ETC.';

COMMENT ON COLUMN DOC_CUSTODIA.ORIGEN_DOC IS 'Nos indica quien ha creado el documento: cliente,invitado,sistema,etc.';

COMMENT ON COLUMN DOC_CUSTODIA.CIFRADO IS 'NO INDICA SI ESTA CIFRADO EL DOCUMENTO';

COMMENT ON COLUMN DOC_CUSTODIA.NOTA IS 'DESCRIPCIÓN DE UNA NOTA DE VOZ ESCRITA POR EL USUARIO';

COMMENT ON COLUMN DOC_CUSTODIA.GRUPO IS 'Control de visibilidad del grupo';

COMMENT ON COLUMN DOC_CUSTODIA.WORKFORCE IS 'NOS INDICA SI ES UN DOCUMENTO A TRATAR POR LA FUERZA DE TRABAJO POR DEFECTO ES NO. CUANDO SE ENCARGUE EL TRABAJO SERÁ WA DE ESPERANDO WAITING cuando se asigne a un workforce PR proceso CUANDO SE PROCESE SERÁ OK';

/* ---------------------------------------------------------------------- */
/* Add table "CLIENTES"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE CLIENTES (
    ID INTEGER CONSTRAINT CLNTS_ID NOT NULL,
    NOMBRE VARCHAR2(40) CONSTRAINT CLNTS_NOMBRE NOT NULL,
    NIF VARCHAR2(12) CONSTRAINT CLNTS_NIF NOT NULL,
    MVL VARCHAR2(12) CONSTRAINT CLNTS_MVL NOT NULL,
    TLF VARCHAR2(12),
    MAIL VARCHAR2(90),
    URL_WEB VARCHAR2(40),
    CALLE_NUM VARCHAR2(90),
    OBJETO VARCHAR2(40),
    CP VARCHAR2(5),
    CIUDAD VARCHAR2(40),
    PROVINCIA VARCHAR2(40),
    LATITUD VARCHAR2(40),
    LONGITUD VARCHAR2(40),
    FECHA_BAJA DATE,
    FECHA_ALTA DATE DEFAULT sysdate,
    ALMACENCERT INTEGER,
    CC VARCHAR2(20),
    TITULAR_CC VARCHAR2(40),
    PERTENECE_A INTEGER,
    IDGREMIO INTEGER CONSTRAINT CLNTS_IDGREMIO NOT NULL,
    RAZON_SOCIAL VARCHAR2(50),
    PAIS VARCHAR2(40) DEFAULT 'ESPAÑA',
    IDIOMA VARCHAR2(40) DEFAULT 'ES',
    GRUPO INTEGER,
    DTO INTEGER,
    CONSTRAINT PK_CLNTS PRIMARY KEY (ID)
);

CREATE INDEX IDX_CLIENTES_1 ON CLIENTES (NIF);

CREATE INDEX IDX_CLIENTES_2 ON CLIENTES (FECHA_BAJA);

COMMENT ON TABLE CLIENTES IS 'Nuestros clientes y sus empleados.';

COMMENT ON COLUMN CLIENTES.URL_WEB IS 'ofertado como servivio adicional pagina web personalizada';

COMMENT ON COLUMN CLIENTES.OBJETO IS 'Identifica la finca objeto, número de la calle, portal, escalera, planta, puerta';

COMMENT ON COLUMN CLIENTES.PERTENECE_A IS 'si tiene un valor será el id de otro cliente para indicar que el cliente pertenece a otro cliente';

COMMENT ON COLUMN CLIENTES.IDGREMIO IS 'A que gremio pertenece de la tabla gremios';

/* ---------------------------------------------------------------------- */
/* Add table "ALMACENCERT"                                                */
/* ---------------------------------------------------------------------- */

CREATE TABLE ALMACENCERT (
    ID INTEGER CONSTRAINT LMCNCRT_ID NOT NULL,
    DESCRIPCION VARCHAR2(256),
    PRIVADA BLOB,
    PUBLICA BLOB,
    AES RAW(32),
    USO_CERTIFICADO INTEGER CONSTRAINT LMCNCRT_USO_CERTIFICADO NOT NULL,
    PKCS12 BLOB,
    PASSPHRASE VARCHAR2(50),
    CONSTRAINT PK_LMCNCRT PRIMARY KEY (ID)
);

COMMENT ON TABLE ALMACENCERT IS 'Almacen de certificados y claves simetricas';

/* ---------------------------------------------------------------------- */
/* Add table "CONSUMOS"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE CONSUMOS (
    ID INTEGER CONSTRAINT CNSMS_ID NOT NULL,
    ID_SERVICIO INTEGER CONSTRAINT CNSMS_ID_SERVICIO NOT NULL,
    FECHA TIMESTAMP,
    PRECIO NUMBER(10,3),
    FACTURADO CHAR(2) DEFAULT 'PE',
    ID_CLIENTE INTEGER CONSTRAINT CNSMS_ID_CLIENTE NOT NULL,
    TIPO_IVA NUMBER(5,2),
    OneTimeURL RAW(32),
    ACTIVO CHAR(1) DEFAULT 'S',
    IDDOC INTEGER,
    Fecha_Expiracion TIMESTAMP,
    URL VARCHAR2(250),
    WORKFORCE INTEGER,
    CONSTRAINT PK_CNSMS PRIMARY KEY (ID)
);

CREATE INDEX IDX_CONSUMOS_1 ON CONSUMOS (FACTURADO);

CREATE INDEX IDX_CONSUMOS_2 ON CONSUMOS (ID_CLIENTE);

COMMENT ON TABLE CONSUMOS IS 'Consumos de servicios por parte de nuestros clientes. La actividad de la empresa.';

COMMENT ON COLUMN CONSUMOS.FACTURADO IS 'Estado de facturacion que podrá ser: ''PE'' PENDIENTE DE FACTURACION ''PR'' PROCESANDO FACTURACION ''FA'' FACTURADO';

COMMENT ON COLUMN CONSUMOS.OneTimeURL IS 'URL de una sola lectura, para servicios de pago por visión';

COMMENT ON COLUMN CONSUMOS.IDDOC IS 'ID del documento al que apunta esta URL temporal';

COMMENT ON COLUMN CONSUMOS.WORKFORCE IS 'QUIEN HA REALIZADO ESTE TRABAJO';

/* ---------------------------------------------------------------------- */
/* Add table "FACTURAS"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE FACTURAS (
    ID INTEGER CONSTRAINT FCTRS_ID NOT NULL,
    NE VARCHAR2(40),
    FECHA DATE,
    IDCLIENTE INTEGER,
    FORMA_PAGO VARCHAR2(20),
    ESTADO VARCHAR2(20) DEFAULT 'PENDIENTE',
    BASE NUMBER(10,2),
    IMPORTE_IVA NUMBER(10,2),
    CONSTRAINT PK_FCTRS PRIMARY KEY (ID)
);

/* ---------------------------------------------------------------------- */
/* Add table "FACTURA_DETALLE"                                            */
/* ---------------------------------------------------------------------- */

CREATE TABLE FACTURA_DETALLE (
    IDFACTURA INTEGER,
    CANTIDAD INTEGER,
    CONCEPTO VARCHAR2(50),
    IMPORTE NUMBER(10,3),
    TIPO_IVA NUMBER(5,2) DEFAULT 18
);

/* ---------------------------------------------------------------------- */
/* Add table "GREMIOS"                                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE GREMIOS (
    ID INTEGER CONSTRAINT GRMS_ID NOT NULL,
    NOMBRE VARCHAR2(40),
    CORPUS BLOB,
    BUCKET VARCHAR2(40),
    CONSTRAINT PK_GRMS PRIMARY KEY (ID)
);

COMMENT ON TABLE GREMIOS IS 'Los despachos profesionales los dividimos por gremios y representan a abogados, asesorias fiscales, laboral, etc.';

COMMENT ON COLUMN GREMIOS.NOMBRE IS 'nombre del gremio, abogados, peritos, etc';

COMMENT ON COLUMN GREMIOS.CORPUS IS 'conjunto de palabras especificas para cada gremio, ejemplo: para un abogado podría ser civil, penal, moritorios, etc.<xml><corpus>civil</corpus><corpus>penal</corpus><corpus>moritorios</corpus></xml>';

/* ---------------------------------------------------------------------- */
/* Add table "REDMOON"                                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE REDMOON (
    ID INTEGER CONSTRAINT RDMN_ID NOT NULL,
    RAZON_SOCIAL VARCHAR2(40),
    CIF VARCHAR2(10),
    DIRECCION VARCHAR2(40),
    FACTURA INTEGER,
    YEAR CHAR(4),
    IVA NUMBER(5,2),
    PRIVADA BLOB,
    USER_CON VARCHAR2(40),
    USER_PAS VARCHAR2(40),
    CONSTRAINT PK_RDMN PRIMARY KEY (ID)
);

/* ---------------------------------------------------------------------- */
/* Add table "FISCALIDAD"                                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE FISCALIDAD (
    IDFactura INTEGER CONSTRAINT FSCLDD_IDFactura NOT NULL,
    TIPO_IVA NUMBER(5,2),
    BASE NUMBER(10,3)
);

COMMENT ON TABLE FISCALIDAD IS 'DETALLE DE LA FISCALIDAD DE UNA FACTURA';

/* ---------------------------------------------------------------------- */
/* Add table "INVITADOS"                                                  */
/* ---------------------------------------------------------------------- */

CREATE TABLE INVITADOS (
    ID INTEGER CONSTRAINT NVTDS_ID NOT NULL,
    IDCLIENTE INTEGER CONSTRAINT NVTDS_IDCLIENTE NOT NULL,
    NIF VARCHAR2(12),
    RAZON_SOCIAL VARCHAR2(40),
    EMAIL VARCHAR2(90),
    ESTADO CHAR(5) DEFAULT 'OPEN',
    F_ESTADO DATE DEFAULT SYSDATE,
    FECHA_BAJA DATE,
    CONSTRAINT PK_NVTDS PRIMARY KEY (ID)
);

COMMENT ON TABLE INVITADOS IS 'Son los clientes de nuestros clientes que son invitados a realizar algunas tareas como la de visualización de los documentos, poder realizar peticiones en el foro, subir facturas al sistema.';

COMMENT ON COLUMN INVITADOS.IDCLIENTE IS 'A QUE CLIENTE PERTENECE COMO ASESOR, ABOGADO, ETC.';

/* ---------------------------------------------------------------------- */
/* Add table "Docs_Metadatos"                                             */
/* ---------------------------------------------------------------------- */

CREATE TABLE Docs_Metadatos (
    ID_DOC INTEGER CONSTRAINT Dcs_Mtdts_ID_DOC NOT NULL,
    ATRIBUTO VARCHAR2(40),
    VALOR VARCHAR2(40)
);

COMMENT ON TABLE Docs_Metadatos IS 'Metadatos de cada documento custodiado.';

/* ---------------------------------------------------------------------- */
/* Add table "Gremios_Corpus"                                             */
/* ---------------------------------------------------------------------- */

CREATE TABLE Gremios_Corpus (
    ID_GREMIO INTEGER CONSTRAINT GRMS_CRPS_ID_GREMIO NOT NULL,
    ATRIBUTO VARCHAR2(40),
    IDIOMA CHAR(5) DEFAULT 'ES'
);

COMMENT ON TABLE Gremios_Corpus IS 'Conjunto de palabras que conforman el cuerpo especifico del lenguaje de una actividad profesional';

/* ---------------------------------------------------------------------- */
/* Add table "TMP_CORPUS"                                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE TMP_CORPUS (
    IDSesion INTEGER CONSTRAINT TMP_CRPS_IDSesion NOT NULL,
    ATRIBUTO VARCHAR2(40),
    VALOR VARCHAR2(40),
    FECHA DATE DEFAULT SYSDATE
);

COMMENT ON COLUMN TMP_CORPUS.FECHA IS 'Necesario para borrar las sesiones antiguas en desuso';

/* ---------------------------------------------------------------------- */
/* Add table "Sesiones"                                                   */
/* ---------------------------------------------------------------------- */

CREATE TABLE Sesiones (
    ID INTEGER CONSTRAINT ssns_ID NOT NULL,
    ID_CLIENTE INTEGER,
    FECHA TIMESTAMP DEFAULT SYSTIMESTAMP,
    ESTADO CHAR(5) DEFAULT 'OPEN',
    REFER VARCHAR2(250),
    IP VARCHAR2(20),
    ERROR_VAR VARCHAR2(90),
    TIPO CHAR(2),
    CONSTRAINT PK_ssns PRIMARY KEY (ID)
);

COMMENT ON TABLE Sesiones IS 'Control de sesiones de usuario';

COMMENT ON COLUMN Sesiones.TIPO IS 'TIPO DE SESION CL CLIENTE, EM EMPLEADO, IN INVITADO AL SISTEMA';

/* ---------------------------------------------------------------------- */
/* Add table "Confi_User"                                                 */
/* ---------------------------------------------------------------------- */

CREATE TABLE Confi_User (
    IDCLIENTE INTEGER CONSTRAINT cnfsr_IDCLIENTE NOT NULL,
    NOMBRE_COMERCIAL VARCHAR2(40),
    LOGOTIPO BLOB
);

COMMENT ON TABLE Confi_User IS 'Almacena los parametros de configuración por cada usuario.';

/* ---------------------------------------------------------------------- */
/* Add table "tmpBLOB"                                                    */
/* ---------------------------------------------------------------------- */

CREATE TABLE tmpBLOB (
    IDSESION INTEGER CONSTRAINT tmpBLB_IDSESION NOT NULL,
    ORIGINAL BLOB,
    CIFRADO BLOB,
    NUMERO_BYTES NUMBER(10)
);

COMMENT ON TABLE tmpBLOB IS 'Se utiliza para almacenar temporalmente los archivos a cifrar, descifrar, firmar, etc.';

/* ---------------------------------------------------------------------- */
/* Add table "VistasInterfaz"                                             */
/* ---------------------------------------------------------------------- */

CREATE TABLE VistasInterfaz (
    Nombre_Interfaz VARCHAR2(40) CONSTRAINT Vstsntrfz_Nombre_Interfaz NOT NULL,
    OBJETO VARCHAR2(50),
    IDGREMIO INTEGER,
    Etiqueta VARCHAR2(90),
    Explicacion VARCHAR2(512),
    IDIOMA CHAR(5) DEFAULT 'ES',
    SERVICIO VARCHAR2(40),
    CARPETA VARCHAR2(250)
);

COMMENT ON TABLE VistasInterfaz IS 'Contenedor de controles visuales. Las vistas de cada interfaz, se cargan de controles y valores difrentes a nivel de objeto visual, para cada gremio (conjunto de profesionales con servicios afines, abogados, Asesores, Consultores, etc.) además de cada  idioma soportado.';

/* ---------------------------------------------------------------------- */
/* Add table "Temas_Usuarios"                                             */
/* ---------------------------------------------------------------------- */

CREATE TABLE Temas_Usuarios (
    IDCLIENTE INTEGER CONSTRAINT TMS_sr_IDCLIENTE NOT NULL,
    CARPETA VARCHAR2(250)
);

COMMENT ON TABLE Temas_Usuarios IS 'Palabras de busqueda defindas por el usuario. Tesauro. especificos de un usuario.';

COMMENT ON COLUMN Temas_Usuarios.CARPETA IS 'Nombre de la carpeta';

/* ---------------------------------------------------------------------- */
/* Add table "DEPARTAMENTOS"                                              */
/* ---------------------------------------------------------------------- */

CREATE TABLE DEPARTAMENTOS (
    ID_DTO INTEGER CONSTRAINT DPRTMNTS_ID_DTO NOT NULL,
    IDCLIENTE INTEGER CONSTRAINT DPRTMNTS_IDCLIENTE NOT NULL,
    NOMBRE_DTO VARCHAR2(40) CONSTRAINT DPRTMNTS_NOMBRE_DTO NOT NULL,
    CONSTRAINT PK_DPRTMNTS PRIMARY KEY (ID_DTO)
);

COMMENT ON TABLE DEPARTAMENTOS IS 'LOS VALORES PERSONALIZADOS DE DEPARTAMENTOS POR CLIENTE';

/* ---------------------------------------------------------------------- */
/* Add table "GRUPOS_DTOS"                                                */
/* ---------------------------------------------------------------------- */

CREATE TABLE GRUPOS_DTOS (
    ID_GRUPO INTEGER CONSTRAINT GRPS_DTS_ID_GRUPO NOT NULL,
    IDCLIENTE INTEGER CONSTRAINT GRPS_DTS_IDCLIENTE NOT NULL,
    ID_DTO INTEGER,
    CONSTRAINT TUC_GRPS_DTS_1 UNIQUE (ID_DTO, IDCLIENTE, ID_GRUPO)
);

COMMENT ON TABLE GRUPOS_DTOS IS 'De qué departamento está autorizado a ver sus documentos';

COMMENT ON COLUMN GRUPOS_DTOS.ID_GRUPO IS 'GRUPO';

COMMENT ON COLUMN GRUPOS_DTOS.IDCLIENTE IS 'CLIENTE';

COMMENT ON COLUMN GRUPOS_DTOS.ID_DTO IS 'ID DEL DEPARTAMENTO';

/* ---------------------------------------------------------------------- */
/* Add table "GRUPOS"                                                     */
/* ---------------------------------------------------------------------- */

CREATE TABLE GRUPOS (
    ID_GRUPO INTEGER CONSTRAINT GRPS_ID_GRUPO NOT NULL,
    NOMBRE_GRUPO VARCHAR2(40) CONSTRAINT GRPS_NOMBRE_GRUPO NOT NULL,
    IDCLIENTE INTEGER CONSTRAINT GRPS_IDCLIENTE NOT NULL,
    CONSTRAINT PK_GRPS PRIMARY KEY (ID_GRUPO)
);

/* ---------------------------------------------------------------------- */
/* Add table "WORKFORCE"                                                  */
/* ---------------------------------------------------------------------- */

CREATE TABLE WORKFORCE (
    ID INTEGER CONSTRAINT WRKFRC_ID NOT NULL,
    NOMBRE VARCHAR2(40) CONSTRAINT WRKFRC_NOMBRE NOT NULL,
    NIF VARCHAR2(12) CONSTRAINT WRKFRC_NIF NOT NULL,
    MVL VARCHAR2(12) CONSTRAINT WRKFRC_MVL NOT NULL,
    TLF VARCHAR2(12),
    MAIL VARCHAR2(90),
    URL_WEB VARCHAR2(40),
    CALLE_NUM VARCHAR2(90),
    OBJETO VARCHAR2(40),
    CP VARCHAR2(5),
    CIUDAD VARCHAR2(40),
    PROVINCIA VARCHAR2(40),
    LATITUD VARCHAR2(40),
    LONGITUD VARCHAR2(40),
    FECHA_BAJA DATE,
    FECHA_ALTA DATE DEFAULT sysdate,
    ALMACENCERT INTEGER,
    CC VARCHAR2(20),
    TITULAR_CC VARCHAR2(40),
    PERTENECE_A INTEGER,
    PAIS VARCHAR2(40) DEFAULT 'ESPAÑA',
    IDIOMA VARCHAR2(40) DEFAULT 'ES',
    CONSTRAINT PK_WRKFRC PRIMARY KEY (ID)
);

CREATE INDEX IDX_WORKFORCE_1 ON WORKFORCE (NIF);

CREATE INDEX IDX_WORKFORCE_2 ON WORKFORCE (FECHA_BAJA);

COMMENT ON TABLE WORKFORCE IS 'FUERZA DE TRABAJO, MECANICA TURCA. COLABORADORES EXTERNOS QUE TRABAJAN DESDE SU CASA';

COMMENT ON COLUMN WORKFORCE.URL_WEB IS 'ofertado como servivio adicional pagina web personalizada';

COMMENT ON COLUMN WORKFORCE.OBJETO IS 'Identifica la finca objeto, número de la calle, portal, escalera, planta, puerta';

COMMENT ON COLUMN WORKFORCE.PERTENECE_A IS 'si tiene un valor será el id de otro cliente para indicar que el cliente pertenece a otro cliente';

/* ---------------------------------------------------------------------- */
/* Foreign key constraints                                                */
/* ---------------------------------------------------------------------- */



/* ---------------------------------------------------------------------- */
/* Views                                                                  */
/* ---------------------------------------------------------------------- */


/* ---------------------------------------------------------------------- */
/* Triggers                                                               */
/* ---------------------------------------------------------------------- */

CREATE TRIGGER Trg_TRANSACCIONES1
BEFORE INSERT ON Transacciones FOR EACH ROW
BEGIN
  SELECT S_Transacciones.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_SERVICIOS1
BEFORE INSERT ON servicios FOR EACH ROW
BEGIN
  SELECT S_servicios.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_PETICIONES1
BEFORE INSERT ON PETICIONES FOR EACH ROW
BEGIN
  SELECT s_PETICIONES.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_HILOS1
BEFORE INSERT ON HILOS FOR EACH ROW
BEGIN
  SELECT s_HILOS.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_DOC_CUSTODIA1
BEFORE INSERT ON Doc_Custodia FOR EACH ROW
BEGIN
  SELECT s_doc_custodia.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_CLIENTES1
BEFORE INSERT ON CLIENTES FOR EACH ROW
BEGIN
  SELECT S_CLIENTES.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_ALMACENCERT1
BEFORE INSERT ON ALMACENCERT FOR EACH ROW
BEGIN
  SELECT s_ALMACENCERT.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_CONSUMOS
BEFORE INSERT ON consumos FOR EACH ROW
BEGIN
  SELECT S_consumos.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_FACTURAS
BEFORE INSERT ON facturas FOR EACH ROW
BEGIN
  SELECT S_facturas.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_GREMIOS1
BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
  SELECT S_gremios.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_INVITADOS1
BEFORE INSERT ON INVITADOS FOR EACH ROW
BEGIN
  SELECT s_invitados.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_Sesiones1
BEFORE INSERT ON SESIONES FOR EACH ROW
BEGIN
  SELECT s_sesiones.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_DEPARTAMENTOS1
BEFORE INSERT ON DEPARTAMENTOS FOR EACH ROW
BEGIN
  SELECT S_DEPARTAMENTOS.NEXTVAL
  INTO :NEW.ID_DTO
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_GRUPOS1
BEFORE INSERT ON GRUPOS FOR EACH ROW
BEGIN
  SELECT S_GRUPOS.NEXTVAL
  INTO :NEW.ID_GRUPO
  FROM DUAL;
END;
/

CREATE TRIGGER Trg_WORKFORCE1
BEFORE INSERT ON WORKFORCE FOR EACH ROW
BEGIN
  SELECT S_WORKFORCE.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;
/