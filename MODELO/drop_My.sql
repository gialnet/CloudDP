# ---------------------------------------------------------------------- #
# Script generated with: DeZign for Databases v5.2.0                     #
# Target DBMS:           MySQL 5                                         #
# Project file:          Modelo_CloudDP_MySQL.dez                        #
# Project name:                                                          #
# Author:                                                                #
# Script type:           Database drop script                            #
# Created on:            2010-08-12 04:34                                #
# Model version:         Version 2010-08-12 12                           #
# ---------------------------------------------------------------------- #


# ---------------------------------------------------------------------- #
# Drop triggers                                                          #
# ---------------------------------------------------------------------- #

DROP TRIGGER `Trg_SERVICIOS1`;

DROP TRIGGER `Trg_ADDCLIENTES`;

DROP TRIGGER `TRG_ADD_PETICIONES`;

DROP TRIGGER `Trg_ADD_HILOS`;

DROP TRIGGER `TRG_ACT_PETI`;

DROP TRIGGER `Trg_CONSUMOS`;

DROP TRIGGER `Trg_FACTURAS`;

DROP TRIGGER `Trg_GREMIOS1`;

# ---------------------------------------------------------------------- #
# Drop procedures                                                        #
# ---------------------------------------------------------------------- #

DROP PROCEDURE `CheckUSER`;

DROP PROCEDURE `ADD_NuevaPeticionAsesor`;

DROP PROCEDURE `ADD_NuevaPeticionCliente`;

DROP PROCEDURE `Add_DOC_DP`;

# ---------------------------------------------------------------------- #
# Drop foreign key constraints                                           #
# ---------------------------------------------------------------------- #

ALTER TABLE `USOS_CERTIFICADO` DROP FOREIGN KEY `ALMACENCERT_USOS_CERTIFICADO`;

ALTER TABLE `TRANSACCIONES` DROP FOREIGN KEY `USUARIOS_TRANSACCIONES`;

ALTER TABLE `SERVICIOS_CONTRATADOS` DROP FOREIGN KEY `CLIENTES_SERVICIOS_CONTRATADOS`;

ALTER TABLE `SERVICIOS` DROP FOREIGN KEY `CONSUMOS_SERVICIOS`;

ALTER TABLE `PETICIONES` DROP FOREIGN KEY `CLIENTES_PETICIONES`;

ALTER TABLE `DOC_CUSTODIA` DROP FOREIGN KEY `CLIENTES_DOC_CUSTODIA`;

ALTER TABLE `ALMACENCERT` DROP FOREIGN KEY `CLIENTES_ALMACENCERT`;

ALTER TABLE `ALMACENCERT` DROP FOREIGN KEY `DOC_CUSTODIA_ALMACENCERT`;

ALTER TABLE `CONSUMOS` DROP FOREIGN KEY `CLIENTES_CONSUMOS`;

ALTER TABLE `FACTURAS` DROP FOREIGN KEY `CLIENTES_FACTURAS`;

ALTER TABLE `FACTURAS` DROP FOREIGN KEY `FISCALIDAD_FACTURAS`;

ALTER TABLE `FACTURA_DETALLE` DROP FOREIGN KEY `FACTURAS_FACTURA_DETALLE`;

ALTER TABLE `ALIAS_CLIENTES` DROP FOREIGN KEY `CLIENTES_ALIAS_CLIENTES`;

ALTER TABLE `GREMIOS` DROP FOREIGN KEY `USUARIOS_GREMIOS`;

# ---------------------------------------------------------------------- #
# Drop table "USUARIOS"                                                  #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `USUARIOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `USUARIOS`;

# ---------------------------------------------------------------------- #
# Drop table "USOS_CERTIFICADO"                                          #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `USOS_CERTIFICADO` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `USOS_CERTIFICADO`;

# ---------------------------------------------------------------------- #
# Drop table "TRANSACCIONES"                                             #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `TRANSACCIONES` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `TRANSACCIONES`;

# ---------------------------------------------------------------------- #
# Drop table "SERVICIOS_CONTRATADOS"                                     #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `SERVICIOS_CONTRATADOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `SERVICIOS_CONTRATADOS`;

# ---------------------------------------------------------------------- #
# Drop table "SERVICIOS"                                                 #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `SERVICIOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `SERVICIOS`;

# ---------------------------------------------------------------------- #
# Drop table "PETICIONES"                                                #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `PETICIONES` ALTER COLUMN `FECHA` DROP DEFAULT;

ALTER TABLE `PETICIONES` ALTER COLUMN `ESTADO` DROP DEFAULT;

# Drop table #

DROP TABLE `PETICIONES`;

# ---------------------------------------------------------------------- #
# Drop table "PERFILES_DIGITALIZACION"                                   #
# ---------------------------------------------------------------------- #

# Drop constraints #

# Drop table #

DROP TABLE `PERFILES_DIGITALIZACION`;

# ---------------------------------------------------------------------- #
# Drop table "LOTES_CARGA"                                               #
# ---------------------------------------------------------------------- #

# Drop constraints #

# Drop table #

DROP TABLE `LOTES_CARGA`;

# ---------------------------------------------------------------------- #
# Drop table "LOGS_ESTADISTICO"                                          #
# ---------------------------------------------------------------------- #

# Drop table #

DROP TABLE `LOGS_ESTADISTICO`;

# ---------------------------------------------------------------------- #
# Drop table "HILOS"                                                     #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `HILOS` ALTER COLUMN `FECHA` DROP DEFAULT;

ALTER TABLE `HILOS` ALTER COLUMN `ESTADO` DROP DEFAULT;

ALTER TABLE `HILOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `HILOS`;

# ---------------------------------------------------------------------- #
# Drop table "DOC_CUSTODIA"                                              #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `DOC_CUSTODIA` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `DOC_CUSTODIA`;

# ---------------------------------------------------------------------- #
# Drop table "CLIENTES"                                                  #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `CLIENTES` ALTER COLUMN `FECHA_ALTA` DROP DEFAULT;

ALTER TABLE `CLIENTES` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `CLIENTES`;

# ---------------------------------------------------------------------- #
# Drop table "ALMACENCERT"                                               #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `ALMACENCERT` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `ALMACENCERT`;

# ---------------------------------------------------------------------- #
# Drop table "CONSUMOS"                                                  #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `CONSUMOS` ALTER COLUMN `FECHA` DROP DEFAULT;

ALTER TABLE `CONSUMOS` ALTER COLUMN `FACTURADO` DROP DEFAULT;

ALTER TABLE `CONSUMOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `CONSUMOS`;

# ---------------------------------------------------------------------- #
# Drop table "FACTURAS"                                                  #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `FACTURAS` ALTER COLUMN `ESTADO` DROP DEFAULT;

ALTER TABLE `FACTURAS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `FACTURAS`;

# ---------------------------------------------------------------------- #
# Drop table "FACTURA_DETALLE"                                           #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `FACTURA_DETALLE` ALTER COLUMN `TIPO_IVA` DROP DEFAULT;

# Drop table #

DROP TABLE `FACTURA_DETALLE`;

# ---------------------------------------------------------------------- #
# Drop table "ALIAS_CLIENTES"                                            #
# ---------------------------------------------------------------------- #

# Drop constraints #

# Drop table #

DROP TABLE `ALIAS_CLIENTES`;

# ---------------------------------------------------------------------- #
# Drop table "GREMIOS"                                                   #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `GREMIOS` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `GREMIOS`;

# ---------------------------------------------------------------------- #
# Drop table "REDMOON"                                                   #
# ---------------------------------------------------------------------- #

# Drop constraints #

ALTER TABLE `REDMOON` DROP PRIMARY KEY;

# Drop table #

DROP TABLE `REDMOON`;

# ---------------------------------------------------------------------- #
# Drop table "FISCALIDAD"                                                #
# ---------------------------------------------------------------------- #

# Drop constraints #

# Drop table #

DROP TABLE `FISCALIDAD`;
