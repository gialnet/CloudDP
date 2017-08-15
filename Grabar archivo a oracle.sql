
--	Necesita previamente la existencia de un directorio ORACLE que se llame IMAGENES
-- 	y que apunte a un único directorio donde se encuentren todas las imágenes.
-- 	Ejemplo de forma de crear el directorio : create directory imagenes as 'f:\fotos\'
-- 	El directorio ha de ser del servidor. Desde delphi se crea.Por lo tanto se debe ejecutar
--	desde el servidor.
--
-- En la aplicacion de Digitalización Certificada
-- create directory imagenes as 'E:\Carga_Oracle';
--
-- El parametro xALMACENCERT indica el ID de la tabla ALMACENCERT
-- El parametro nombre_file es la URL del documento
--
create or replace procedure DBgetFileFromFileSystem(
		xNombreFile in Varchar2, 
		xIDCliente in Integer, 
		xIDServicio IN INTEGER,
		xIDSesion IN INTEGER,
		xTipoDoc IN Varchar2)
as

-- varibles para la carga del fichero externo en la tabla de la base de datos
F BFILE;
xBLOB BLOB;

xIDDoc Integer;
xNumero_Bytes Integer;

BEGIN


pkDocSystemCustody.AddDocMisDocs(xIDCliente, xIDServicio, xIDSesion, xNombreFile, 0, xTipoDoc, xVarSalida, xIDDoc);

IF xVarSalida='' THEN
	RETURN;
END IF;

	-- Obtengo la imagen para modificarla (for update). 
	SELECT CRYPTO INTO xBLOB FROM DOC_CUSTODIA WHERE ID=xIDDoc FOR UPDATE;

	-- crear un manejador de archivo
	F:=BFILENAME('IMAGENES', XNOMBREFILE);
		
	-- abrir el archivo
	DBMS_LOB.FILEOPEN(F,DBMS_LOB.FILE_READONLY);
		
	-- leer el total de bytes del archivo y cargarlo en la variable xLOB
	xNumero_Bytes:=DBMS_LOB.GETLENGTH(F);
	DBMS_LOB.LOADFROMFILE(xBLOB , F, xNumero_Bytes);
		
	-- Cerrar el fichero de entrada
	DBMS_LOB.FILECLOSE(F);

	commit;
	
	-- Bytes Cargados
	UPDATE DOC_CUSTODIA SET NUMERO_BYTES=xNumero_Bytes WHERE ID=xIDDoc;


END;
/

--
-- Grabar un fichero que no pertenece a un lote
--
create or replace procedure Graba_PDF(nombre_file in varchar2, xIDExpe in varchar2, xALMACENCERT in integer, xID_DOC out integer)
as

-- varibles para la carga del fichero externo en la tabla de la base de datos
F BFILE;
xBLOB BLOB;

xNumero_Bytes Integer;

BEGIN



INSERT INTO DOC_CUSTODIA (url_local, ORIGINAL, FIRMA_RAW, FIRMA_B64, CRYPTO, SELLADO_TIEMPO, ALMACENCERT) 
	VALUES (xIDExpe, Empty_Blob(), Empty_Blob(), Empty_Blob(), Empty_Blob(), Empty_Blob(),xALMACENCERT) 
	RETURNING ID INTO xID_DOC;



	-- Obtengo la imagen para modificarla (for update). 
	SELECT ORIGINAL INTO xBLOB FROM DOC_CUSTODIA WHERE ID=xID_DOC FOR UPDATE;

	--xBLOB:=xBLOB_ENCRIPTADO;
	
	-- crear un manejador de archivo
	F:=BFILENAME('IMAGENES', NOMBRE_FILE);
		
-- abrir el archivo
	DBMS_LOB.FILEOPEN(F,DBMS_LOB.FILE_READONLY);
		
-- leer el total de bytes del archivo y cargarlo en la variable xLOB
	xNumero_Bytes:=DBMS_LOB.GETLENGTH(F);
	DBMS_LOB.LOADFROMFILE(xBLOB , F, xNumero_Bytes);
		
-- Cerrar el fichero de entrada
	DBMS_LOB.FILECLOSE(F);

	commit;
	
	-- Bytes Cargados
	UPDATE DOC_CUSTODIA SET NUMERO_BYTES=xNumero_Bytes WHERE ID=xID_DOC;


END;
/
