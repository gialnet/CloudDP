


-- Leer los valores de una sesion

create or replace Procedure GetSesion(xIDSesion IN Integer,
	xFECHA OUT SESIONES.FECHA%Type,
	xESTADO OUT SESIONES.ESTADO%Type,
	xID_CLIENTE OUT SESIONES.ID_CLIENTE%Type,
	xERROR_VAR OUT SESIONES.ERROR_VAR%Type,
	xTIPO OUT SESIONES.TIPO%Type)
as
begin

	BEGIN
		SELECT FECHA,ESTADO,ID_CLIENTE,ERROR_VAR,TIPO 
		INTO  xFECHA,xESTADO,xID_CLIENTE,xERROR_VAR,xTIPO
			FROM SESIONES WHERE ID=xIDSesion;
	EXCEPTION
   		when no_data_found then
 		begin  	
 			xERROR_VAR:='NO FOUND';
  			RETURN;
   		end;
   	END;
   	
end;
/

-- Buscar el nombre de un servicio por su ID
create or replace function getBucket(xIDDoc in integer) return varchar2
as
xBUCKET varchar2(40);
begin

	begin
		select BUCKET into xBUCKET from Gremios 
			where ID = (SELECT IDGREMIO FROM CLIENTES 
			WHERE ID = (SELECT CLIENTE FROM DOC_CUSTODIA WHERE ID = xIDDoc) );
	exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
   	
END;
		
return xBUCKET;

end;
/



-- Buscar el nombre de un servicio por su ID
create or replace function nombreServicioFindByID(xIDServicio in integer) return varchar2
as
xServicio varchar2(50);
begin
	begin
		select servicio into xServicio from Servicios where id= xIDServicio ;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;
		
return xServicio;

end;
/

--
-- Saber si un documento esta encriptado
--
CREATE OR REPLACE Function KnowIFEncryp(xIDDoc IN Integer) return boolean
as
xALMACENCERT integer;
begin

-- Buscar los datos del cliente

BEGIN
	SELECT ALMACENCERT INTO xALMACENCERT FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
  		  RETURN False;
   	end;
END;

IF (xALMACENCERT IS NULL) Then
	return False;
ELSE
	return True;
End if;

end;
/

--
-- Saber si un documento esta encriptado
--
CREATE OR REPLACE Procedure PKnowIFEncryp(xIDDoc IN Integer, xEncryp out boolean)
as
xALMACENCERT integer;
begin

-- Buscar los datos del cliente

BEGIN
	SELECT ALMACENCERT INTO xALMACENCERT FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
 		xEncryp:=False;
  		RETURN;
   	end;
END;

IF (xALMACENCERT IS NULL) Then
	xEncryp:=False;
ELSE
	xEncryp:=True;
End if;

end;
/

--
-- Saber si un documento esta encriptado
--
CREATE OR REPLACE Procedure getALMACENCERT(xIDCliente IN Integer, xALMACENCERT out INTEGER)
as
begin

-- Buscar los datos del cliente

BEGIN
	SELECT ALMACENCERT INTO xALMACENCERT FROM CLIENTES WHERE ID=xIDCliente;
exception
   	when no_data_found then
 	begin  		
  		RETURN;
   	end;
END;

end;
/

--
-- Tipo MIME de un documento 
--
CREATE OR REPLACE Function GetMIMETypeByIDDoc(xIDDoc IN Integer) return varchar2
as
xTIPO_MIME varchar(12);
begin

-- Buscar los datos del cliente

BEGIN
	SELECT TIPO_MIME INTO xTIPO_MIME FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

return xTIPO_MIME;

end;
/
--
-- Tipo MIME de un documento 
--
CREATE OR REPLACE PROCEDURE PGetMIMETypeByIDDoc(xIDDoc IN Integer, xTIPO_MIME OUT varchar2)
as
begin

-- Buscar los datos del cliente

BEGIN
	SELECT TIPO_MIME INTO xTIPO_MIME FROM DOC_CUSTODIA WHERE ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
        xTIPO_MIME:=NULL;
  		  RETURN;
   	end;
END;


end;
/


-- Buscar el Nif de un cliente por su ID

CREATE OR REPLACE Function ClientFindNIFByID(xIDCliente IN Integer) return varchar2
as
xNIF varchar(12);
begin

-- Buscar los datos del cliente

BEGIN
	select nif into xNIF from clientes where id= xIDCliente;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

return xNIF;

end;
/

-- saber el id de cliente por el id de un empleado

CREATE OR REPLACE Function getIDClientByIDEmployee(xIDEmpleado IN Integer) return integer
as
xIDCliente Integer;
begin

-- Buscar los datos del cliente

BEGIN
	select Pertenece_A into xIDCliente from clientes where id= xIDEmpleado;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

return xIDCliente;

end;
/


--
-- Devuelve el código de cliente a través del código de Empleado
--
CREATE OR REPLACE Function ClientFindIDByIDEmployee(xIDEmployee IN Integer) return INTEGER
as
xIDCliente Integer;
begin

-- Buscar los datos del cliente

BEGIN
	select PERTENECE_A into xIDCliente from Clientes where ID=xIDEmployee;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

return xIDCliente;

end;
/



-- Devuelve el Código de Asesor de un Invitado

CREATE OR REPLACE Function GuestFindIDHostByID(xIDGuest IN Integer) return INTEGER
as
xIDCliente Integer;
begin

-- Buscar los datos del cliente

BEGIN
	select IDCliente into xIDCliente from Invitados where ID=xIDGuest;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

return xIDCliente;

end;
/


--
-- Nos devuelve la URL en la Nube en función.
--

CREATE OR REPLACE Function GetURLNube(xIDDoc IN Integer) return varchar2
as

xNIF varchar2(12);
xIDInvitado INTEGER;
xCLIENTE  INTEGER;
xEMPLEADO INTEGER;
xURL_Local VARCHAR2(250);
xCarpeta VARCHAR2(250);
xURL_Nube VARCHAR2(250):=NULL;
xOWNER varchar(20);
Begin


BEGIN
select ClientFindNIFByID(cliente) as NIF,CLIENTE, EMPLEADO, INVITADO,URL_LOCAL,UBICACION,ORIGEN_DOC
	INTO xNIF,xCLIENTE, xEMPLEADO, xIDInvitado, xURL_Local, xCarpeta, xOWNER
	from doc_custodia where ID=xIDDoc;
exception
   	when no_data_found then
 	begin  		
  		  RETURN Null;
   	end;
END;

-- Documento PROPIO DEL CLIENTE
if ((xOWNER='CLIENTE') AND  (xIDInvitado IS NULL)) then
	xURL_Nube:=xNIF||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;
end if;

-- DOCUMENTO DE CLIENTE PARA UN INVITADO
if ((xOWNER='CLIENTE') AND (xIDInvitado IS NOT NULL)) then
	xURL_Nube:=xNIF||'/'||xIDInvitado||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;
end if;

-- El concepto sería personas autorizadas (empleados, socios, etc.)
if ((xOWNER='EMPLEADO') AND (xIDInvitado IS NULL)) then
		
	-- Buscar el NIF del cliente en función del ID del Empleado
	xNIF:=ClientFindNIFByID(getIDClientByIDEmployee(xCLIENTE));
	
	xURL_Nube:=xNIF||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;
	
end if;


if ((xOWNER='EMPLEADO') AND (xIDInvitado IS NOT NULL)) then
		
	-- Buscar el NIF del cliente en función del ID del Empleado
	xNIF:=ClientFindNIFByID(getIDClientByIDEmployee(xCLIENTE));
	
	xURL_Nube:=xNIF||'/'||xIDInvitado||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;

	
end if;


-- INVITADO
if (xOWNER='INVITADO') then
	xURL_Nube:=xNIF||'/'||xIDInvitado||'/'||xCarpeta||'/'||xIDDoc||'-'||xURL_Local;
end if;


RETURN xURL_Nube;


end;
/



--
-- Averiguar el usuario y la contraseña de la base de datos Oracle para la conexión
--
create or replace Procedure GetConnUSER(xUSER_CON OUT Varchar2, xUSER_PAS OUT Varchar2)
as
begin

SELECT USER_CON, USER_PAS INTO xUSER_CON, xUSER_PAS FROM Redmoon Where ID=1;

end;
/


--
-- PARA ASIGNAR DEPARTAMENTO Y GRUPO EN LOS DOCUMENTOS DE LOS INVITADOS
--
CREATE OR REPLACE Procedure getDefaultDTOAndGroup(xIDCliente IN INTEGER,xID_DTO OUT INTEGER, xID_GRUPO OUT INTEGER)
as
begin

-- Guardar los datos del documento a custodiar
BEGIN
SELECT ID_DTO INTO xID_DTO FROM DEPARTAMENTOS WHERE IDCLIENTE=xIDCliente AND NOMBRE_DTO='employee';
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;

BEGIN
SELECT ID_GRUPO INTO xID_GRUPO FROM GRUPOS WHERE IDCLIENTE=xIDCliente AND NOMBRE_GRUPO='employee';
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;

end;
/

--
-- PARA ASIGNAR DEPARTAMENTO Y GRUPO EN LOS DOCUMENTOS DE LOS INVITADOS
--
CREATE OR REPLACE Procedure getClientDTOAndGroup(xIDEmployee IN INTEGER,xID_DTO OUT INTEGER, xID_GRUPO OUT INTEGER)
as
begin

-- Guardar los datos del documento a custodiar
BEGIN
SELECT DTO, GRUPO INTO xID_DTO,xID_GRUPO  FROM CLIENTES WHERE ID=xIDEmployee;
exception
   	when no_data_found then
 	begin  		
  		  RETURN;
   	end;
END;

end;
/

--
-- Forma juridica segun el nif
--

CREATE OR REPLACE function FormaJuridicaByNIF(xNIF in varchar2) return varchar2
as
xLetra Char(1);
xForma varchar2(40);
begin
xLetra:=Substr(xNIF,1,1);


CASE
WHEN xLetra='A' THEN xForma:='SA';
WHEN xLetra='B' THEN xForma:='SL';
WHEN xLetra='C' THEN xForma:='Sociedades colectivas';
WHEN xLetra='D' THEN xForma:='Sociedades comanditarias';
WHEN xLetra='E' THEN xForma:='Comunidades de bienes y herencias yacentes';
WHEN xLetra='F' THEN xForma:='Sociedades cooperativas';
WHEN xLetra='G' THEN xForma:='Asociaciones';
WHEN xLetra='H' THEN xForma:='Comunidades de propietarios en régimen de propiedad horizontal';
WHEN xLetra='J' THEN xForma:='Sociedades civiles, con o sin personalidad jurídica';
WHEN xLetra='P' THEN xForma:='Corporaciones Locales';
WHEN xLetra='Q' THEN xForma:='Organismos públicos';
WHEN xLetra='R' THEN xForma:='Congregaciones e instituciones religiosas';
WHEN xLetra='S' THEN xForma:='Órganos de la Administración del Estado y de las Comunidades Autónomas';
WHEN xLetra='U' THEN xForma:='Uniones Temporales de Empresas';
WHEN xLetra='V' THEN xForma:='Otros tipos no definidos en el resto de claves';
WHEN xLetra='N' THEN xForma:='Entidades extranjeras';
WHEN xLetra='W' THEN xForma:='Establecimientos permanentes de entidades no residentes en España';
WHEN xLetra='X' THEN xForma:='NIE extranjeros no residentes';
WHEN xLetra='M' THEN xForma:='NIF que otorga la Agencia Tributaria a extranjeros que no tienen NIE';
WHEN xLetra='L' THEN xForma:='Españoles residentes en el extranjero sin DNI';
WHEN xLetra='K' THEN xForma:='Españoles menores de 14 años';
WHEN xLetra='Y' THEN xForma:='Extranjeros identificados por la Policía con un NIE, asignado desde e l 16 de julio de 2008 (Orden INT/2058/2008, BOE del 15 de julio )';

ELSE xForma:='NO';
END CASE;

return xForma;

end;
/
--
--Saber si un nombre de usuario esta disponible
--
CREATE OR REPLACE Function NameUserIsFree(xNameUser in VARCHAR2) RETURN VARCHAR2
as
xNOM varchar2(10);
BEGIN

BEGIN
SELECT USUARIO INTO xNOM  FROM USUARIOS WHERE USUARIO=xNameUser;
exception
   	when no_data_found then
 	begin  		
  		  RETURN 'OK';
   	end;
END;
IF xNOM is NULL then return 'OK';
ELSE return 'NO';
END IF;

end;
/


--
--Creamos el tipo de dato para consultar un documento
--
CREATE TYPE row_docConsulta AS OBJECT (
  id              	INTEGER,
  URL_LOCAL        	VARCHAR2(250),
  FECHA        		TIMESTAMP(6),
  VISIBLE           CHAR(1),
  CIFRADO			CHAR(1),
  SELLADO			CHAR(1),
  FIRMADO			CHAR(1),
  TIPO_DOCUMENTO	VARCHAR2(90),
  UBICACION			VARCHAR2(250)
);
/
-- LA TABLA TIPO DOC_CONSULTA
CREATE TYPE table_docConsulta AS TABLE OF row_docConsulta;
/
--CREAMOS LA FUNCION QUE DEVUELVE LOS DATOS   select * from TABLE(get_docconsulta(118))
CREATE OR REPLACE FUNCTION get_docConsulta (
 xSesion in Integer)
  RETURN table_docConsulta AS
  
  v_tab table_docConsulta := table_docConsulta();
BEGIN
  FOR cur IN (select id,url_local, fecha,
	VISIBLE,CIFRADO,SELLADO,FIRMADO,TIPO_DOCUMENTO,UBICACION
	from doc_custodia where id in 
	(SELECT id_doc FROM TEMPCONSULTAS where sesion=xSesion))
	
	
  LOOP
    v_tab.extend;
    v_tab(v_tab.last) := row_docConsulta(cur.id, cur.url_local, cur.fecha,cur.VISIBLE,
    cur.CIFRADO,cur.SELLADO,cur.FIRMADO,cur.TIPO_DOCUMENTO,cur.UBICACION);
    
  END LOOP;
  RETURN v_tab;
END;
/
