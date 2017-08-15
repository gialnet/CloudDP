
-- ************************************************************************************************************************
--
-- Antonio Pérez Caballero
-- Septiembre 2010
-- Versión 1.0
-- Octubre 2010
-- ver 1.2
--
--
-- pkDocSystemCustody Paquete de Gestión de Documentos del Sistema de Custodia
--
--
Create or replace package pkDocSystemCustody AS

	--
	-- Añadir un nuevo documento por parte de un empleado con visibilidad por grupos
	--
	Procedure EmployeeAddDocCustodia(xIDEmployee in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xGrupo IN Varchar2,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER);

	--
	-- Añadir un documento
	-- Podrá ser el ID
	-- Se ha añadido el parametro de cifrado que no se estaba actualizando 
	Procedure AddDocCustodia(xIDCliente in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xCifrado IN char,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER);

	--
	-- Añadir un documento de un cliente del despacho
	--
	Procedure AddDocClientToGuest(xIDCliente in integer, xIDInvitado In Integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xOWNER	IN varchar2,
		xCIFRADO IN char,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER);
		
	-- Añadir una factura de un Invitado
	-- xTipoFact='FACTURAS EMITIDAS'
	-- xTipoFact='FACTURAS COMPRAS'
	-- xTipoFact='FACTURAS SUMINISTROS'
	Procedure AddDocsGuest(xTipoFact in varchar2,
		xIDInvitado in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xURL_Nube out varchar2);
		
	--Modificar los datos de una factura añadida anteriormente
	Procedure ModDocsGuest(xIDdoc in integer,
		xTipoFact in varchar2,
		xIDSesion IN INTEGER,
		url_nube_old out varchar2,
		url_nube_new out varchar2);

		
	-- Leer el coste del servicio y el importe de los impuestos.
	Procedure ReadAmountTax(xIDServicio in Integer, 
				xError out Varchar2, 
				xAmount out number, 
				xTax out number);
		

	-- Insertar los datos especificos de cada modelo de negocio
	Procedure AddDocMetadatos(xIDDoc IN INTEGER, xIDSesion IN INTEGER);

	-- OneTimeURL
			
	procedure IDDocOneTimeURL(xRandom in raw, xIDDoc out Integer);
	
	-- Añadir un servicio del tipo OneTimeURL a un cliente determinado
	procedure AddServOneTimeURL(xIDDoc in Integer, duraccion_horas in Integer);

	procedure DBgetFileFromFileSystem(
		xNombreFile in Varchar2, 
		xIDCliente in Integer, 
		xIDServicio IN INTEGER,
		xIDSesion IN INTEGER,
		xTipoDoc IN Varchar2,
		xIDDoc OUT Integer);
	
	-- Escribir el archivo recibido en la tabla temporal
	Procedure Write_tmpBLOB(xIDSesion IN Integer, xIDDoc in INTEGER, xContenFile IN BLOB);
	
	-- Leer la URL en la Nube de un documento y devolver su valor
	Procedure pGetURLNube(xIDDoc IN Integer, xURLNube OUT varchar2);
	
	-- Commuta el estado de compartido a no compartivo y viseversa 

	Procedure Compartir(xIDDoc IN Integer);
	
	Procedure getDocCustodia(xIDDoc IN Integer, 
		xEMPLEADO OUT INTEGER,xLOTE OUT INTEGER,xCLIENTE OUT INTEGER,xINVITADO OUT INTEGER,
		xTIPO_MIME OUT VARCHAR2,xURL_LOCAL OUT VARCHAR2,xUBICACION OUT VARCHAR2,
    	xVISIBLE OUT CHAR, xALMACENCERT OUT INTEGER, xFIRMADO OUT CHAR, xSELLADO OUT CHAR, 
    	xFMTVER_FIRMA OUT VARCHAR2, xTIPO_DOCUMENTO OUT VARCHAR2,
    	xORIGEN_DOC OUT VARCHAR2, xFECHA_DOC OUT DATE, xURLNube OUT Varchar2, xBUCKET OUT Varchar2,xCIFRADO OUT CHAR);

    --
	-- Establecer la extensión de archivo que nos indica de que tipo mime estamos hablando
	--
	function getTipoMimeByUrl(xURLOCAL IN DOC_CUSTODIA.URL_LOCAL%Type) return varchar2;

	Procedure setWorkForce(xIDdoc IN Integer);
	
	---
	--- Editar los datos de un documento cuando lo hemos modificado el documento ya estaba creado
	---
	Procedure EditDocCustodia(xIDdoc in integer,
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xNombreFile IN varchar2);

END pkDocSystemCustody;
/

/* **********************************************************************************************************************


************************************************************************************************************************* */

-- Antonio Perez Caballero
-- 
--
-- Cabecera del paquete
--
--

Create or replace package body pkDocSystemCustody AS

--
-- Establecer la extensión de archivo que nos indica de que tipo mime estamos hablando
--
function getTipoMimeByUrl(xURLOCAL IN DOC_CUSTODIA.URL_LOCAL%Type) return varchar2
as
xExtension DOC_CUSTODIA.URL_LOCAL%Type;
xResultado DOC_CUSTODIA.URL_LOCAL%Type;
xTipoMime DOC_CUSTODIA.TIPO_MIME%Type;
begin


-- Buscamos el primer punto
select substr(xURLOCAL,instr(xURLOCAL,'.',-1)+1,length(xURLOCAL)) into xExtension 
		from DUAL;
		
-- No ha encontrado ningún '.', no tiene extensión
if (length(xExtension) <= 0) then
	-- se asigna un valor binario application/octet-stream .bin
	return 'application/octet-stream';
end if;

xResultado:=upper(xExtension);

case xResultado
	when 'PDF' then xTipoMime:='application/pdf';
	when 'WAV' then xTipoMime:='audio/wav';
	when 'JPEG' then xTipoMime:='image/jpeg';
	when 'JPG' then xTipoMime:='image/jpeg';
	when 'JP' then xTipoMime:='image/jpeg';
	when 'DOC' then xTipoMime:='application/msword';
	when 'DOT' then xTipoMime:='application/msword';
	when 'XLS' then xTipoMime:='application/vnd.ms-excel';
	when 'XLM' then xTipoMime:='application/vnd.ms-excel';
	when 'XLA' then xTipoMime:='application/vnd.ms-excel';
	when 'XLC' then xTipoMime:='application/vnd.ms-excel';
	when 'XLT' then xTipoMime:='application/vnd.ms-excel';
	when 'XLW' then xTipoMime:='application/vnd.ms-excel';
	when 'PPT' then xTipoMime:='application/vnd.ms-powerpoint'; 
	when 'PPS' then xTipoMime:='application/vnd.ms-powerpoint'; 
	when 'POT' then xTipoMime:='application/vnd.ms-powerpoint';
	when 'HTML' then xTipoMime:='text/html'; 
	when 'HTM' then xTipoMime:='text/html';
	else
		xTipoMime:='application/octet-stream';
end case;

return xTipoMime;


end;


--
-- Commuta el estado de compartido a no compartido y viseversa
--
Procedure Compartir(xIDDoc IN Integer)
as
begin

UPDATE DOC_CUSTODIA SET VISIBLE=DECODE(VISIBLE, 'S', 'N', 'S') WHERE ID=xIDDoc;

end;


--
-- Devuelve los principales metadatos de un documento
--
Procedure getDocCustodia(xIDDoc IN Integer, 
		xEMPLEADO OUT INTEGER,xLOTE OUT INTEGER,xCLIENTE OUT INTEGER,xINVITADO OUT INTEGER,
		xTIPO_MIME OUT VARCHAR2,xURL_LOCAL OUT VARCHAR2,xUBICACION OUT VARCHAR2,
    	xVISIBLE OUT CHAR, xALMACENCERT OUT INTEGER, xFIRMADO OUT CHAR, xSELLADO OUT CHAR, 
    	xFMTVER_FIRMA OUT VARCHAR2, xTIPO_DOCUMENTO OUT VARCHAR2,
    	xORIGEN_DOC OUT VARCHAR2, xFECHA_DOC OUT DATE, xURLNube OUT Varchar2, xBUCKET OUT Varchar2,
    	xCIFRADO OUT CHAR)
as
begin

-- Buscar los datos del cliente

BEGIN
	SELECT EMPLEADO,LOTE,CLIENTE,INVITADO,TIPO_MIME,URL_LOCAL,UBICACION,
    	VISIBLE, ALMACENCERT, FIRMADO, SELLADO, FMTVER_FIRMA, TIPO_DOCUMENTO,
    ORIGEN_DOC, FECHA_DOC,GetURLNube(ID),getBucket(ID),CIFRADO
	INTO xEMPLEADO,xLOTE,xCLIENTE,xINVITADO,xTIPO_MIME,xURL_LOCAL,xUBICACION,
    	xVISIBLE, xALMACENCERT, xFIRMADO, xSELLADO, xFMTVER_FIRMA, xTIPO_DOCUMENTO,
    	xORIGEN_DOC, xFECHA_DOC, xURLNube, xBUCKET,xCIFRADO
		FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
  		RETURN;
   	end;
END;


end;
--
--
--
Procedure pGetURLNube(xIDDoc IN Integer, xURLNube OUT varchar2)
as
begin
	SELECT GetURLNube(xIDDoc) INTO xURLNube FROM DUAL;
end;

--
-- Escribir en la tabla temporal tmpBLOB
-- 
--
Procedure Write_tmpBLOB(xIDSesion IN Integer, xIDDoc in INTEGER, xContenFile IN BLOB)
as
xORIGINAL BLOB;
begin

	
	DELETE FROM  tmpBLOB WHERE IDSESION=xIDSesion;
	
	INSERT INTO tmpBLOB (IDSESION, ORIGINAL, CIFRADO) values (xIDSesion, Empty_Blob(), Empty_Blob());
	
	SELECT ORIGINAL INTO xORIGINAL FROM tmpBLOB WHERE IDSESION=xIDSesion FOR UPDATE;
	
	DBMS_LOB.APPEND(xORIGINAL, xContenFile);
	
	
end;

--
-- Grabar ficheros en Oracle procedentes del sistema de archivos
--

procedure DBgetFileFromFileSystem(
		xNombreFile in Varchar2, 
		xIDCliente in Integer, 
		xIDServicio IN INTEGER,
		xIDSesion IN INTEGER,
		xTipoDoc IN Varchar2,
		xIDDoc OUT Integer)
as

-- varibles para la carga del fichero externo en la tabla de la base de datos
F BFILE;
xBLOB BLOB;

xAlmacencert integer;
xNumero_Bytes Integer;
xVarSalida varchar2(250);
BEGIN


	-- añadir la tupla del documento en Doc_Custodia
	AddDocCustodia(xIDCliente, xIDServicio, xIDSesion, xNombreFile, 0, xTipoDoc, 
				'misdocs','N' ,xVarSalida, xIDDoc, xAlmacencert);

	IF xIDDoc=0 THEN
		RETURN;
	END IF;

		-- Obtengo la imagen para modificarla (for update).
		DELETE FROM tmpBLOB WHERE IDSESION=xIDSesion;
		
		INSERT INTO tmpBLOB (IDSESION, ORIGINAL, CIFRADO) VALUES (xIDSesion, Empty_Blob(), Empty_Blob());
		
		BEGIN
			SELECT ORIGINAL INTO xBLOB FROM tmpBLOB WHERE IDSESION=xIDSesion FOR UPDATE;
		exception
	   		when no_data_found then
 			begin  		
  		  		RETURN;
   			end;
		END;

	-- crear un manejador de archivo
	F:=BFILENAME('IMAGENES', XNOMBREFILE);
		
	-- abrir el archivo
	DBMS_LOB.FILEOPEN(F,DBMS_LOB.FILE_READONLY);
		
	-- leer el total de bytes del archivo y cargarlo en la variable xLOB
	xNumero_Bytes:=DBMS_LOB.GETLENGTH(F);
	DBMS_LOB.LOADFROMFILE(xBLOB , F, xNumero_Bytes);
		
	-- Cerrar el fichero de entrada
	DBMS_LOB.FILECLOSE(F);

	
	-- Bytes Cargados
	UPDATE tmpBLOB SET NUMERO_BYTES=xNumero_Bytes WHERE IDSESION=xIDSesion;

	commit;

END;



--
--
--
procedure AddServOneTimeURL(xIDDoc in Integer, duraccion_horas in Integer)
as
num_key_bytes NUMBER := 256/8; -- key length 256 bits (32 bytes)

xIDServicio integer;
xIDCliente integer;

xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
begin


-- comprobar que existe el archivo que vamos a publicar

begin
SELECT cliente INTO xIDCliente FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;

-- buscar el precio del coste del servicio
begin
SELECT ID INTO xIDServicio FROM SERVICIOS WHERE SERVICIO='OneTimeURL';
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;


-- Insertar el consumo
-- Anotar el Consumo del servicio

ReadAmountTax(xIDServicio, xError, xAmount, xTax);
		
IF (xError='NO EXISTE EL SERVICIO') THEN
	RETURN;
END IF;

-- Insertamos los valores en la tabla consumos

INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA, OneTimeURL,IDDOC,Fecha_Expiracion) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax, DBMS_CRYPTO.RANDOMBYTES(num_key_bytes),xIDDoc, SYSTIMESTAMP);


end;

--
-- Saber si esta disponible una URL temporal y en caso afirmativo devuelde el ID de la tabla Doc_Custodia
--

procedure IDDocOneTimeURL(xRandom in raw, xIDDoc out Integer)
as
begin

begin
	SELECT IDDoc Into xIDDoc FROM CONSUMOS 
			WHERE ONETIMEURL=xRandom AND ACTIVO='S' and Fecha_Expiracion <=sysdate;
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;


end;



--
-- Añadir los metadatos de cada modelo de negocio
--
Procedure AddDocMetadatos(xIDDoc IN INTEGER, xIDSesion IN INTEGER)
as
CURSOR cCORPUS IS SELECT ATRIBUTO,VALOR,BASE FROM TMP_CORPUS WHERE IDSesion=xIDSesion;
begin


FOR vCORPUS IN cCORPUS LOOP

	IF ( vCORPUS.ATRIBUTO='FECHA') THEN
		UPDATE DOC_CUSTODIA SET FECHA_DOC=to_date(vCORPUS.VALOR,'dd/mm/YYYY') WHERE ID=xIDDoc;
	END IF;
	
	INSERT INTO Docs_Metadatos (ID_DOC, ATRIBUTO, VALOR,BASE) 
		VALUES (xIDDoc, vCORPUS.ATRIBUTO, vCORPUS.VALOR ,vCORPUS.BASE);

END LOOP;


end;

--
-- Añadir un nuevo documento por parte de un empleado
-- ESTE DOCUMENTO Será visible por su administrador y opcionalmente por los compañeros
--
Procedure EmployeeAddDocCustodia(xIDEmployee in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xGrupo IN Varchar2,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER)
AS

xNIF VARCHAR2(12);

xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
xInvitado INTEGER;
xIDCliente INTEGER;
xTipoCliente varchar2(20):='EMPLEADO'; -- EMPLEADO, SOCIO, ETC.
xID_DTO INTEGER;
xID_GRUPO INTEGER;
BEGIN


-- Buscar a que cliente pertenece este empleado

xIDCliente:=getIDClientByIDEmployee(xIDEmployee);

-- Buscar los datos del cliente

xNIF:=ClientFindNIFByID(xIDCliente);

IF  (xNIF IS NULL) THEN

	xURL_Nube:='NO CLIENTE';
  	RETURN;
  	
END IF;


-- Anotar el Consumo del servicio

ReadAmountTax(xIDServicio, xError, xAmount, xTax);
		
IF (xError='NO EXISTE EL SERVICIO') THEN
	xURL_Nube:='NO EXISTE EL SERVICIO';
	RETURN;
END IF;

	
	-- TOMAR EL APUNTADOR DE ALMACENCERT
	getALMACENCERT(xIDCliente, xALMACENCERT);

	-- LEER LOS ID DE DEPARTAMENTO Y GRUPO POR DEFECTO.
	getClientDTOAndGroup(xIDEmployee, xID_DTO, xID_GRUPO);

-- Guardar los datos del documento a custodiar

INSERT INTO DOC_CUSTODIA (CLIENTE, EMPLEADO, URL_LOCAL, NUMERO_BYTES, ORIGEN_DOC, TIPO_DOCUMENTO, 
	UBICACION, ALMACENCERT, INVITADO, TIPO_MIME, DTO, GRUPO)
	VALUES (xIDCliente, xIDEmployee, xURL_Local, xNUMERO_Bytes, xTipoCliente, xTipoDoc, 
		xCarpeta, xALMACENCERT, xInvitado, getTipoMimeByUrl(xURL_Local), xID_DTO, xID_GRUPO)
	RETURNING ID INTO xIDDoc;
	
INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA, IDDOC) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax, xIDDoc);
-- AÑADIR LOS METADATOS DEL DOCUMENTO
AddDocMetadatos(xIDDoc, xIDSesion);

xURL_Nube:=xNIF||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;

end;


--
-- Añadir un documento compartido
--
Procedure AddDocClientToGuest(xIDCliente in integer, xIDInvitado In Integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xOWNER	IN varchar2,
		xCIFRADO in char,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER)
as

xNIF VARCHAR2(12);

xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
xInvitado INTEGER;
xID_DTO INTEGER;
xID_GRUPO INTEGER;
BEGIN


-- Buscar los datos del cliente

xNIF:=ClientFindNIFByID(xIDCliente);

IF  (xNIF IS NULL) THEN

	xURL_Nube:='NO CLIENTE';
  	RETURN;
  	
END IF;


-- Anotar el Consumo del servicio

ReadAmountTax(xIDServicio, xError, xAmount, xTax);
		
IF (xError='NO EXISTE EL SERVICIO') THEN
	xURL_Nube:='NO EXISTE EL SERVICIO';
	RETURN;
END IF;

	
	-- TOMAR EL APUNTADOR DE ALMACENCERT
	getALMACENCERT(xIDCliente, xALMACENCERT);
	
	-- Leer el departamento y el grupo
	getClientDTOAndGroup(xIDCliente, xID_DTO, xID_GRUPO);
	
-- Guardar los datos del documento a custodiar

INSERT INTO DOC_CUSTODIA (CLIENTE,URL_LOCAL, NUMERO_BYTES, ORIGEN_DOC, TIPO_DOCUMENTO, 
	UBICACION, ALMACENCERT, INVITADO, CIFRADO, TIPO_MIME, DTO, GRUPO,WORKFORCE)
	VALUES (xIDCliente, xURL_Local, xNUMERO_Bytes, xOWNER, 
	xTipoDoc, xCarpeta, xALMACENCERT, xIDInvitado,xCIFRADO, getTipoMimeByUrl(xURL_Local), xID_DTO, xID_GRUPO,DECODE(xIDServicio,13,'WA','NO'))
	RETURNING ID INTO xIDDoc;

INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA, IDDOC) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax, xIDDoc);
	
-- AÑADIR LOS METADATOS DEL DOCUMENTO
AddDocMetadatos(xIDDoc, xIDSesion);

xURL_Nube:=xNIF||'/'||xIDInvitado||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;

end;

--
-- Añadir un documento al sistema de custodia
-- 
Procedure AddDocCustodia(xIDCliente in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xCarpeta IN varchar2,
		xCifrado IN char,
		xURL_Nube out varchar2, xIDDoc out Integer, xALMACENCERT out INTEGER)
AS

xNIF VARCHAR2(12);

xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
xInvitado INTEGER;
xTipoCliente varchar2(20):='CLIENTE'; -- EMPLEADO, SOCIO, ETC.
xID_DTO INTEGER;
xID_GRUPO INTEGER;

BEGIN


-- Comprobar si es un empleado: empleado, socio, etc.
IF (getIDClientByIDEmployee(xIDCliente) is NOT null) THEN
	xTipoCliente:='EMPLEADO';
END IF;

-- Buscar los datos del cliente

xNIF:=ClientFindNIFByID(xIDCliente);

IF  (xNIF IS NULL) THEN

	xURL_Nube:='NO CLIENTE';
  	RETURN;
  	
END IF;


-- Anotar el Consumo del servicio

ReadAmountTax(xIDServicio, xError, xAmount, xTax);
		
IF (xError='NO EXISTE EL SERVICIO') THEN
	xURL_Nube:='NO EXISTE EL SERVICIO';
	RETURN;
END IF;

	
	-- TOMAR EL APUNTADOR DE ALMACENCERT
	getALMACENCERT(xIDCliente, xALMACENCERT);
	
	-- LEER LOS ID DE DEPARTAMENTO Y GRUPO POR DEFECTO.
	getClientDTOAndGroup(xIDCliente, xID_DTO, xID_GRUPO);
	
-- Guardar los datos del documento a custodiar

INSERT INTO DOC_CUSTODIA (CLIENTE, URL_LOCAL, NUMERO_BYTES, ORIGEN_DOC, TIPO_DOCUMENTO, 
	UBICACION, ALMACENCERT, INVITADO, TIPO_MIME,CIFRADO, DTO, GRUPO)
VALUES (xIDCliente,xURL_Local, xNUMERO_Bytes, xTipoCliente, xTipoDoc, xCarpeta, 
		xALMACENCERT, xInvitado, getTipoMimeByUrl(xURL_Local),xCifrado, xID_DTO, xID_GRUPO)
		RETURNING ID INTO xIDDoc;

INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA, IDDOC) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax, xIDDoc);		

-- AÑADIR LOS METADATOS DEL DOCUMENTO
AddDocMetadatos(xIDDoc, xIDSesion);

xURL_Nube:=xNIF||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;

end;


-- ******************************************
-- Añadir un documento por parte del Invitado
-- ******************************************
Procedure AddDocsGuest(xTipoFact in varchar2,
		xIDInvitado in integer,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xURL_Nube out varchar2)
as

xID INTEGER;
xALMACENCERT INTEGER;
xIDCliente INTEGER;
xCarpeta varchar2(250);
xNIF VARCHAR2(12);
xID_DTO INTEGER;
xID_GRUPO INTEGER;

xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
BEGIN


-- Buscar el código de asesor

xIDCliente:=GuestFindIDHostByID(xIDInvitado);

IF  (xIDCliente IS NULL) THEN

	xURL_Nube:='NO INVITADO';
  	RETURN;
  	
END IF;

xNIF:=ClientFindNIFByID(xIDCliente);

IF  (xNIF IS NULL) THEN

	xURL_Nube:='NO CLIENTE';
  	RETURN;
  	
END IF;


if (xTipoFact='FACTURAS EMITIDAS') then
	xCarpeta:='emitidas';
end if;

if (xTipoFact='FACTURAS COMPRAS') then
	xCarpeta:='recibidas';
end if;

if (xTipoFact='FACTURAS SUMINISTROS') then
	xCarpeta:='suministros';
end if;

if (xTipoFact='NOMINAS') then
	xCarpeta:='nominas';
end if;

if (xTipoFact='ALQUILERES') then
	xCarpeta:='alquileres';
end if;

if (xTipoFact='BALANCES Y PAGOS DE TRIBUTOS') then
	xCarpeta:='situacion';
end if;

if (xTipoFact='INTRACOMUNITARIO') then
	xCarpeta:='ivaintra';
end if;

-- Anotar el Consumo del servicio en este caso gratuito para los invitados de nuestros clientes

	-- TOMAR EL APUNTADOR DE ALMACENCERT
	getALMACENCERT(xIDCliente, xALMACENCERT);
	

-- LEER LOS ID DE DEPARTAMENTO Y GRUPO POR DEFECTO.
getDefaultDTOAndGroup(xIDCliente, xID_DTO, xID_GRUPO);


-- Guardar los datos del documento a custodiar
INSERT INTO DOC_CUSTODIA (CLIENTE,INVITADO, TIPO_MIME, URL_LOCAL, NUMERO_BYTES, ORIGEN_DOC, TIPO_DOCUMENTO, UBICACION,
	 ALMACENCERT, DTO, GRUPO)
VALUES (xIDCliente, xIDInvitado, getTipoMimeByUrl(xURL_Local), xURL_Local, xNUMERO_Bytes, 'INVITADO', 
		xTipoFact, xCarpeta, xALMACENCERT, xID_DTO, xID_GRUPO)
		RETURNING ID INTO xID;

-- Anotar el Consumo del servicio
ReadAmountTax(xIDServicio, xError, xAmount, xTax);

INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA, IDDOC) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax, xID);
	
-- AÑADIR LOS METADATOS DEL DOCUMENTO
AddDocMetadatos(xID, xIDSesion);

xURL_Nube:=xNIF||'/'||xIDInvitado||'/'||xCarpeta||'/'||xID||'-'||xURL_Local;

end;

--
--Modificar los datos de una factura añadida anteriormente
--
Procedure ModDocsGuest(xIDdoc in integer,
		xTipoFact in varchar2,
		xIDSesion IN INTEGER,
		url_nube_old out varchar2,
		url_nube_new out varchar2)
as
xCarpeta varchar2(250);
begin

	--coger la url de la nube
	url_nube_old:=GetURLNube(xIDdoc);

if (xTipoFact='FACTURAS EMITIDAS') then
	xCarpeta:='emitidas';
end if;

if (xTipoFact='FACTURAS COMPRAS') then
	xCarpeta:='recibidas';
end if;

if (xTipoFact='FACTURAS SUMINISTROS') then
	xCarpeta:='suministros';
end if;

if (xTipoFact='NOMINAS') then
	xCarpeta:='nominas';
end if;

if (xTipoFact='ALQUILERES') then
	xCarpeta:='alquileres';
end if;

if (xTipoFact='BALANCES Y PAGOS DE TRIBUTOS') then
	xCarpeta:='situacion';
end if;

if (xTipoFact='INTRACOMUNITARIO') then
	xCarpeta:='ivaintra';
end if;


	update doc_custodia set ubicacion=xCarpeta,tipo_documento=xTipoFact where id=xIDdoc;

	delete from docs_metadatos where id_doc=xIDdoc;

	AddDocMetadatos(xIDdoc, xIDSesion);

	url_nube_new:=GetURLNube(xIDdoc);

end ModDocsGuest;




--
-- Leer el coste del servicio y el importe de los impuestos.
--
Procedure ReadAmountTax(xIDServicio in Integer, xError out Varchar2, xAmount out number, xTax out number)
as
begin

BEGIN
	select Precio,Tipo_IVA into xAmount,xTax from Servicios where id= xIDServicio;
exception
   	when no_data_found then
 	begin  		
		xError:='NO EXISTE EL SERVICIO';
  		  RETURN;
   	end;
END;

end;

Procedure setWorkForce(xIDdoc IN Integer)
as
begin
update doc_custodia set workforce='WA' where id=xIDdoc;
end;



Procedure EditDocCustodia(xIDdoc in integer,
		xNUMERO_Bytes in INTEGER,
		xTipoDoc IN varchar2,
		xNombreFile IN varchar2)
AS



BEGIN

-- Modificamos los datos del documento a custodiar
UPDATE DOC_CUSTODIA SET NUMERO_BYTES=xNUMERO_Bytes,TIPO_DOCUMENTO=xTipoDoc,URL_LOCAL=xNombreFile
	WHERE ID=xIDdoc;
	

end;
	
END pkDocSystemCustody;
/