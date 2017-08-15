# ---------------------------------------------------------------------- #
# Script generated with: DeZign for Databases v5.2.0                     #
# Target DBMS:           MySQL 5                                         #
# Project file:          Modelo_CloudDP_MySQL.dez                        #
# Project name:                                                          #
# Author:                                                                #
# Script type:           Database creation script                        #
# Created on:            2010-08-12 04:34                                #
# Model version:         Version 2010-08-12 12                           #
# ---------------------------------------------------------------------- #


# ---------------------------------------------------------------------- #
# Tables                                                                 #
# ---------------------------------------------------------------------- #

# ---------------------------------------------------------------------- #
# Add table "USUARIOS"                                                   #
# ---------------------------------------------------------------------- #

CREATE TABLE `USUARIOS` (
    `USUARIO` VARCHAR(30) NOT NULL COMMENT 'El DNI del usuario',
    `NOMBRE` VARCHAR(40),
    `ROL` INTEGER,
    `MOVIL` CHAR(10),
    `EMAIL` VARCHAR(40),
    `TIPO` CHAR(2) COMMENT 'Tipo de Cliente CL,clientes IN clientes indirectos',
    `SIP` VARCHAR(40),
    `PERFIL` VARCHAR(50) COMMENT 'url del servidor al que se conecta',
    `PASSWD` VARCHAR(20),
    `DIGITOS` VARCHAR(16),
    `IDDATOSPER` INTEGER,
    `IDROL` INTEGER NOT NULL,
    CONSTRAINT `PK_USUARIOS` PRIMARY KEY (`USUARIO`)
);

# ---------------------------------------------------------------------- #
# Add table "USOS_CERTIFICADO"                                           #
# ---------------------------------------------------------------------- #

CREATE TABLE `USOS_CERTIFICADO` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `DESCRIPCION` VARCHAR(90),
    CONSTRAINT `PK_USOS_CERTIFICADO` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "TRANSACCIONES"                                              #
# ---------------------------------------------------------------------- #

CREATE TABLE `TRANSACCIONES` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `FECHA` DATE,
    `NUMERO_BYTES` NUMERIC(10),
    `DURACION` NUMERIC(5),
    `ID_USUARIO` NUMERIC(38),
    `URL` VARCHAR(256),
    `ID_CLIENTE_ASESOR` NUMERIC(38),
    `TIPO_OPERACION` VARCHAR(20),
    `TIPO_DOCUMENTO` VARCHAR(20),
    `USUARIO` VARCHAR(30) NOT NULL,
    CONSTRAINT `PK_TRANSACCIONES` PRIMARY KEY (`ID`, `USUARIO`)
);

# ---------------------------------------------------------------------- #
# Add table "SERVICIOS_CONTRATADOS"                                      #
# ---------------------------------------------------------------------- #

CREATE TABLE `SERVICIOS_CONTRATADOS` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `ID_SERVICIOS` NUMERIC(38),
    `PRECIO` NUMERIC(10,3),
    `MODALIDAD` VARCHAR(20),
    `PERIODICIDAD` VARCHAR(20),
    `ID_CLIENTE` NUMERIC(38),
    CONSTRAINT `PK_SERVICIOS_CONTRATADOS` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "SERVICIOS"                                                  #
# ---------------------------------------------------------------------- #

CREATE TABLE `SERVICIOS` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `SERVICIO` VARCHAR(50),
    `PRECIO` NUMERIC(10,3),
    `MODALIDAD` VARCHAR(20),
    `PERIODICIDAD` VARCHAR(20),
    `TIPO_IVA` NUMERIC(5,2),
    CONSTRAINT `PK_SERVICIOS` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "PETICIONES"                                                 #
# ---------------------------------------------------------------------- #

CREATE TABLE `PETICIONES` (
    `ID_CLIENTE` INTEGER NOT NULL,
    `ID_INDIRECTO` INTEGER NOT NULL,
    `FECHA` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ASUNTO` VARCHAR(100),
    `MENSAJE` VARCHAR(250),
    `ESTADO` CHAR(8) NOT NULL DEFAULT 'NUEVO' COMMENT 'NUEVO ->NUEVA PETICION LEIDO->PETICION ANTIGUA RESUELTA->PETICION CERRADA',
    `ID` INTEGER NOT NULL,
    `REMITENTE` INTEGER
);

# ---------------------------------------------------------------------- #
# Add table "PERFILES_DIGITALIZACION"                                    #
# ---------------------------------------------------------------------- #

CREATE TABLE `PERFILES_DIGITALIZACION` (
    `ID` INTEGER NOT NULL,
    `DESCRIPCION` VARCHAR(256),
    `CERTIFICADO` NUMERIC(38),
    `NUMERO_ESCANEOS` NUMERIC(38),
    `CLIENTE` INTEGER
);

# ---------------------------------------------------------------------- #
# Add table "LOTES_CARGA"                                                #
# ---------------------------------------------------------------------- #

CREATE TABLE `LOTES_CARGA` (
    `ID` INTEGER NOT NULL,
    `FECHA` DATETIME,
    `USUARIO` NUMERIC(38),
    `PASADOA_VMS` CHAR(1),
    `PASADOA_NUBE` CHAR(1),
    `MB` NUMERIC(10,3),
    `BYTES` NUMERIC(15),
    `TIEMPO` VARCHAR(20)
);

# ---------------------------------------------------------------------- #
# Add table "LOGS_ESTADISTICO"                                           #
# ---------------------------------------------------------------------- #

CREATE TABLE `LOGS_ESTADISTICO` (
    `ID_LOTE` INTEGER,
    `LOTE` VARCHAR(50),
    `NUMERO_BYTES` NUMERIC(38),
    `FECHA_EJECUCION` DATETIME,
    `OPCION` VARCHAR(150),
    `TIEMPO` VARCHAR(20)
);

# ---------------------------------------------------------------------- #
# Add table "HILOS"                                                      #
# ---------------------------------------------------------------------- #

CREATE TABLE `HILOS` (
    `ID_PETICION` INTEGER NOT NULL,
    `ID_HILO` INTEGER NOT NULL,
    `FECHA` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `MENSAJE` VARCHAR(512),
    `ESTADO` CHAR(5) DEFAULT 'NUEVO',
    `REMITENTE` INTEGER,
    `ID` INTEGER NOT NULL,
    CONSTRAINT `PK_HILOS` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "DOC_CUSTODIA"                                               #
# ---------------------------------------------------------------------- #

CREATE TABLE `DOC_CUSTODIA` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `LOTE` INTEGER,
    `CLIENTE` INTEGER,
    `CLIENTE_INDIRECTO` INTEGER,
    `TIPO_DOC` VARCHAR(40),
    `URL_LOCAL` VARCHAR(250),
    `NUMERO_BYTES` INTEGER,
    `URL_NUBE` VARCHAR(250),
    `FECHA` DATETIME,
    `VISIBLE` CHAR(1),
    `ALMACENCERT` INTEGER,
    `PERFIL_DIGITALIZACION` INTEGER,
    `PERFIL_CONSULTA` INTEGER,
    `FIRMADO` CHAR(1),
    `ENVIADOA_VMS` CHAR(1),
    `ORIGINAL` LONGBLOB,
    `FIRMA_RAW` LONGBLOB,
    `FIRMA_B64` LONGBLOB,
    `CRYPTO` LONGBLOB,
    `SELLADO_TIEMPO` LONGBLOB,
    `AES_ENCRIPTADA` LONGBLOB,
    `SELLADO` CHAR(1),
    `XADES` LONGBLOB,
    `FMTVER_FIRMA` VARCHAR(40),
    `MODELO` VARCHAR(90) COMMENT 'DESCRIBE EL DOCUMENTO Y SU CARACTER EJEMPLO 110 RETENCIONES DE AL RENTA, 330 IVA, ETC',
    `YEAR` CHAR(4) COMMENT 'AÑO DEL DOCUMENTO',
    `TRIMESTRE` CHAR(1),
    `RESUMEN` CHAR(1),
    `MES` CHAR(2) COMMENT 'NUMERO DE MES',
    CONSTRAINT `PK_DOC_CUSTODIA` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "CLIENTES"                                                   #
# ---------------------------------------------------------------------- #

CREATE TABLE `CLIENTES` (
    `NOMBRE` VARCHAR(40) NOT NULL,
    `NIF` VARCHAR(12) NOT NULL,
    `MVL` VARCHAR(12),
    `TLF` VARCHAR(12),
    `MAIL` VARCHAR(40),
    `URL_WEB` VARCHAR(40) COMMENT 'ofertado como servivio adicional pagina web personalizada',
    `CALLE_NUM` VARCHAR(40),
    `OBJETO` VARCHAR(40) COMMENT 'Identifica la finca objeto, número de la calle, portal, escalera, planta, puerta',
    `CP` VARCHAR(5),
    `CIUDAD` VARCHAR(40),
    `PROVINCIA` VARCHAR(40),
    `LATITUD` VARCHAR(40),
    `LONGITUD` VARCHAR(40),
    `FECHA_BAJA` DATE,
    `FECHA_ALTA` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ALMACENCERT` INTEGER,
    `ID` INTEGER NOT NULL,
    `CC` VARCHAR(20),
    `TITULAR_CC` VARCHAR(40),
    `PERTENECE_A` INTEGER COMMENT 'si tiene un valor será el id de otro cliente para indicar que el cliente pertenece a otro cliente',
    `GREMIO` VARCHAR(40),
    `RAZON_SOCIAL` VARCHAR(50),
    CONSTRAINT `PK_CLIENTES` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "ALMACENCERT"                                                #
# ---------------------------------------------------------------------- #

CREATE TABLE `ALMACENCERT` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `DESCRIPCION` VARCHAR(256),
    `PRIVADA` LONGBLOB,
    `PUBLICA` LONGBLOB,
    `AES` VARCHAR(32),
    `USO_CERTIFICADO` NUMERIC(38),
    `PKCS12` LONGBLOB,
    `PASSPHRASE` VARCHAR(50),
    CONSTRAINT `PK_ALMACENCERT` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "CONSUMOS"                                                   #
# ---------------------------------------------------------------------- #

TABLA DE CONSUMOS DE SERVICIOS
CREATE TABLE `CONSUMOS` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `ID_SERVICIO` INTEGER,
    `FECHA` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `PRECIO` NUMERIC(10,3),
    `FACTURADO` CHAR(2) DEFAULT 'PE' COMMENT 'Estado de facturacion que podrá ser: ''PE'' PENDIENTE DE FACTURACION ''PR'' PROCESANDO FACTURACION ''FA'' FACTURADO',
    `IDCLIENTE` INTEGER,
    `TIPO_IVA` NUMERIC(5,2),
    CONSTRAINT `PK_CONSUMOS` PRIMARY KEY (`ID`)
);

CREATE INDEX `IDX_CONSUMOS_1` ON `CONSUMOS` (`FACTURADO`);

CREATE INDEX `IDX_CONSUMOS_2` ON `CONSUMOS` (`IDCLIENTE`);

# ---------------------------------------------------------------------- #
# Add table "FACTURAS"                                                   #
# ---------------------------------------------------------------------- #

CREATE TABLE `FACTURAS` (
    `ID` INTEGER NOT NULL,
    `NE` VARCHAR(40),
    `FECHA` DATE,
    `IDCLIENTE` INTEGER,
    `FORMA_PAGO` VARCHAR(20),
    `ESTADO` VARCHAR(20) DEFAULT 'PENDIENTE',
    `BASE` NUMERIC(10,2),
    `IMPORTE_IVA` NUMERIC(10,2),
    CONSTRAINT `PK_FACTURAS` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "FACTURA_DETALLE"                                            #
# ---------------------------------------------------------------------- #

CREATE TABLE `FACTURA_DETALLE` (
    `IDFACTURA` INTEGER,
    `CANTIDAD` INTEGER,
    `CONCEPTO` VARCHAR(50),
    `IMPORTE` NUMERIC(10,3),
    `TIPO_IVA` NUMERIC(5,2) DEFAULT 18
);

# ---------------------------------------------------------------------- #
# Add table "ALIAS_CLIENTES"                                             #
# ---------------------------------------------------------------------- #

CREATE TABLE `ALIAS_CLIENTES` (
    `IDCliente` INTEGER NOT NULL,
    `Nombre` VARCHAR(50),
    `MVL` VARCHAR(15),
    `TLF` VARCHAR(15),
    `NIF` VARCHAR(15),
    `EMAIL` VARCHAR(50)
);

# ---------------------------------------------------------------------- #
# Add table "GREMIOS"                                                    #
# ---------------------------------------------------------------------- #

CREATE TABLE `GREMIOS` (
    `ID` INTEGER NOT NULL AUTO_INCREMENT,
    `NOMBRE` VARCHAR(40) COMMENT 'nombre del gremio, abogados, peritos, etc',
    `CORPUS` TINYTEXT COMMENT 'conjunto de palabras especificas para cada gremio, ejemplo: para un abogado podría ser civil, penal, moritorios, etc.<xml><corpus>civil</corpus><corpus>penal</corpus><corpus>moritorios</corpus></xml>',
    CONSTRAINT `PK_GREMIOS` PRIMARY KEY (`ID`)
) COMMENT = 'Los despachos profesionales los dividimos por gremios y representan a abogados, asesorias fiscales, laboral, etc.';

# ---------------------------------------------------------------------- #
# Add table "REDMOON"                                                    #
# ---------------------------------------------------------------------- #

CREATE TABLE `REDMOON` (
    `ID` INTEGER NOT NULL,
    `RAZON_SOCIAL` VARCHAR(40),
    `CIF` VARCHAR(10),
    `DIRECCION` VARCHAR(40),
    `FACTURA` INTEGER,
    `YEAR` CHAR(4),
    `IVA` NUMERIC(5,2),
    CONSTRAINT `PK_REDMOON` PRIMARY KEY (`ID`)
);

# ---------------------------------------------------------------------- #
# Add table "FISCALIDAD"                                                 #
# ---------------------------------------------------------------------- #

CREATE TABLE `FISCALIDAD` (
    `IDFactura` INTEGER NOT NULL,
    `TIPO_IVA` NUMERIC(5,2),
    `BASE` NUMERIC(10,3)
) COMMENT = 'DETALLE DE LA FISCALIDAD DE UNA FACTURA';

# ---------------------------------------------------------------------- #
# Foreign key constraints                                                #
# ---------------------------------------------------------------------- #

ALTER TABLE `USOS_CERTIFICADO` ADD CONSTRAINT `ALMACENCERT_USOS_CERTIFICADO` 
    FOREIGN KEY (`ID`, `ID`) REFERENCES `ALMACENCERT` (`USO_CERTIFICADO`,`ID`);

ALTER TABLE `TRANSACCIONES` ADD CONSTRAINT `USUARIOS_TRANSACCIONES` 
    FOREIGN KEY (`USUARIO`) REFERENCES `USUARIOS` (`USUARIO`);

ALTER TABLE `SERVICIOS_CONTRATADOS` ADD CONSTRAINT `CLIENTES_SERVICIOS_CONTRATADOS` 
    FOREIGN KEY (`ID_CLIENTE`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `SERVICIOS` ADD CONSTRAINT `CONSUMOS_SERVICIOS` 
    FOREIGN KEY (`ID`) REFERENCES `CONSUMOS` (`ID_SERVICIO`);

ALTER TABLE `PETICIONES` ADD CONSTRAINT `CLIENTES_PETICIONES` 
    FOREIGN KEY (`ID`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `DOC_CUSTODIA` ADD CONSTRAINT `CLIENTES_DOC_CUSTODIA` 
    FOREIGN KEY (`ID`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `ALMACENCERT` ADD CONSTRAINT `CLIENTES_ALMACENCERT` 
    FOREIGN KEY (`ID`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `ALMACENCERT` ADD CONSTRAINT `DOC_CUSTODIA_ALMACENCERT` 
    FOREIGN KEY (`ID`, `ID`) REFERENCES `DOC_CUSTODIA` (`ALMACENCERT`,`ID`);

ALTER TABLE `CONSUMOS` ADD CONSTRAINT `CLIENTES_CONSUMOS` 
    FOREIGN KEY (`IDCLIENTE`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `FACTURAS` ADD CONSTRAINT `CLIENTES_FACTURAS` 
    FOREIGN KEY (`IDCLIENTE`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `FACTURAS` ADD CONSTRAINT `FISCALIDAD_FACTURAS` 
    FOREIGN KEY (`ID`) REFERENCES `FISCALIDAD` (`IDFactura`);

ALTER TABLE `FACTURA_DETALLE` ADD CONSTRAINT `FACTURAS_FACTURA_DETALLE` 
    FOREIGN KEY (`IDFACTURA`) REFERENCES `FACTURAS` (`ID`);

ALTER TABLE `ALIAS_CLIENTES` ADD CONSTRAINT `CLIENTES_ALIAS_CLIENTES` 
    FOREIGN KEY (`IDCliente`) REFERENCES `CLIENTES` (`ID`);

ALTER TABLE `GREMIOS` ADD CONSTRAINT `USUARIOS_GREMIOS` 
    FOREIGN KEY (`ID`) REFERENCES `USUARIOS` (`IDROL`);

# ---------------------------------------------------------------------- #
# Procedures                                                             #
# ---------------------------------------------------------------------- #

DROP PROCEDURE IF EXISTS `CheckUSER`;
 create or replace Procedure CheckUSER(xPOSD1 in INTEGER, xPOSD2 in INTEGER, xDIGIT1 in varchar2, xDIGIT2 in varchar2,
xUSUARIO in varchar2, xPASSWD in varchar2, xPERFIL OUT varchar2,xALMACENCER out integer, xRol out integer)
as
xDIGITOS VARCHAR2(16);
begin

	BEGIN
		if xPOSD1= -1 then
			SELECT DIGITOS,PERFIL,Rol,ALMACENCER
			INTO xDIGITOS,xPERFIL,xRol,xALMACENCER
			FROM USUARIOS 
				WHERE USUARIO=xUSUARIO;		
		else
			SELECT DIGITOS,PERFIL,Rol,ALMACENCER
			INTO xDIGITOS,xPERFIL,xRol,xALMACENCER
			FROM USUARIOS 
				WHERE USUARIO=xUSUARIO AND PASSWD=xPASSWD;
		end if;
	exception
   		when no_data_found then
   	    begin
  		  xPERFIL:='NO AUTORIZADO, USUARIO O PASSWORD';
  		  RETURN;
   		end;
   	END;

   	if  xPOSD1= -1 then
   	    return;
   	end if;
   	
   	-- COMPROBAR LOS DOS PRIMEROS DÍGITOS
	IF SUBSTR(xDIGITOS,xPOSD1,2)!=xDIGIT1 THEN
	   xPERFIL:='NO AUTORIZADO, PRIMEROS DIGITOS'||SUBSTR(xDIGITOS,xPOSD1,2);
	   RETURN;
	END IF;
	
	-- COMPROBAR LOS DOS SEGUNDOS DÍGITOS
	IF SUBSTR(xDIGITOS,xPOSD2,2)!=xDIGIT2 THEN
	   xPERFIL:='NO AUTORIZADO, SEGUNDOS DIGITOS'||SUBSTR(xDIGITOS,xPOSD2,2);
	   RETURN;	
	END IF;
   	
	-- TODO ESTÁ OK.
	
	
end;;

DROP PROCEDURE IF EXISTS `ADD_NuevaPeticionAsesor`;
 CREATE PROCEDURE `ADD_NuevaPeticionAsesor`
(xIndirecto IN INTEGER, xCliente IN INTEGER,xMensaje IN VARCHAR2,xAsunto in VARCHAR2)
AS
xid_peti INTEGER;
BEGIN

    INSERT INTO peticiones (asunto,remitente,id_indirecto,id_cliente)
    VALUES (xAsunto,xCliente,xIndirecto,xCliente) returning id into xid_peti;
	
    INSERT INTO  hilos (mensaje,remitente,id_peticion)
    VALUES (xMensaje,xCliente,xid_peti);
		



END;;

DROP PROCEDURE IF EXISTS `ADD_NuevaPeticionCliente`;
 CREATE PROCEDURE `ADD_NuevaPeticionCliente`
(xIndirecto IN INTEGER,xMensaje IN VARCHAR2,xAsunto in VARCHAR2)
AS
xid_peti INTEGER;
xid_cliente integer;
BEGIN
    select id into xid_cliente from clientes where id=xIndirecto;

    INSERT INTO peticiones (asunto,remitente, id_indirecto, id_cliente)
    VALUES (xAsunto,xIndirecto,xIndirecto,xid_cliente) returning id into xid_peti;
	
    INSERT INTO  hilos (mensaje,remitente,id_peticion)
    VALUES (xMensaje,xIndirecto,xid_peti);
		



END;;

DROP PROCEDURE IF EXISTS `Add_DOC_DP`;
 create or replace procedure Add_DOC_DP(
	xID_CLIENTE in integer, 
	xID_CLIENTE_INDIRECTO in integer, 
	xTIPO_DOC in varchar2, 
	xURL_LOCAL in varchar2, 
	xNUMERO_BYTES in number,
	xURL_Nube out varchar2)
as

xID INTEGER;
xNIF VARCHAR2(12);

BEGIN



BEGIN
	select nif into xNIF from clientes where id= xID_CLIENTE;
exception
   	when no_data_found then
 	begin  		
		xURL_Nube:='NO CLIENTE';
  		  RETURN;
   	end;
END;

INSERT INTO DOC_CUSTODIA (CLIENTE,CLIENTE_INDIRECTO, TIPO_DOC, URL_LOCAL, NUMERO_BYTES)
VALUES (xID_CLIENTE, xID_CLIENTE_INDIRECTO, xTIPO_DOC, xURL_LOCAL, xNUMERO_BYTES)
	RETURNING ID INTO xID;

xURL_Nube:=xNIF||'/'||xID||'-'||xURL_LOCAL;



END;
/;

# ---------------------------------------------------------------------- #
# Triggers                                                               #
# ---------------------------------------------------------------------- #

CREATE TRIGGER `Trg_SERVICIOS1`
BEFORE INSERT ON servicios FOR EACH ROW
BEGIN
  SELECT S_servicios.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;

CREATE TRIGGER `Trg_ADDCLIENTES`
BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
  SELECT S_clientes.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;

CREATE TRIGGER `TRG_ADD_PETICIONES`
BEFORE INSERT ON PETICIONES FOR EACH ROW
BEGIN
  SELECT SE_PETICIONES.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;

CREATE TRIGGER `Trg_ADD_HILOS`
BEFORE INSERT ON HILOS FOR EACH ROW
BEGIN
  SELECT SE_HILOS.NEXTVAL
  INTO :NEW.ID_HILO
  FROM DUAL;
END;;

CREATE TRIGGER `TRG_ACT_PETI`
AFTER INSERT ON HILOS FOR EACH ROW
BEGIN
 UPDATE peticiones set estado='NUEVO' WHERE id=:NEW.ID_PETICIONO;
END;;

CREATE TRIGGER `Trg_CONSUMOS`
BEFORE INSERT ON consumos FOR EACH ROW
BEGIN
  SELECT S_consumos.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;

CREATE TRIGGER `Trg_FACTURAS`
BEFORE INSERT ON facturas FOR EACH ROW
BEGIN
  SELECT S_facturas.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;

CREATE TRIGGER `Trg_GREMIOS1`
BEFORE INSERT ON clientes FOR EACH ROW
BEGIN
  SELECT S_gremios.NEXTVAL
  INTO :NEW.ID
  FROM DUAL;
END;;
