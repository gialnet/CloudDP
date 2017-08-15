--
-- Noviembre 2010
--
-- Modficación de usuarios
--
Create or replace package pkEditUsuarios AS

Procedure EditEmployee
		(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xIDempleado IN Integer,
		xUser IN varchar2,
		xMensaje OUT varchar2
		);
		
Procedure EditGuest
		(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xIDGuest IN Integer,
		xUser IN varchar2,
		xMensaje OUT varchar2
		);
PROCEDURE BajaGuest(xIDGuest IN Integer);

PROCEDURE BajaCliente(xID IN Integer);

PROCEDURE AltaGuest(xIDGuest IN Integer);

END pkEditUsuarios;
/


--
-- cuerpo
--
Create or replace package body pkEditUsuarios AS
--
-- AÑADIR UN NUEVO EMPLEADO DE NUESTRO CLIENTE
--
Procedure EditEmployee(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xIDempleado IN Integer,
		xUser IN varchar2,
		xMensaje OUT varchar2)
as
xNumUser INTEGER;
varUser varchar2(30);
BEGIN

begin
SELECT USUARIO INTO varUser from usuarios where idempleado=xIDempleado;
exception
   		when no_data_found then
   	    begin
  		  	xMensaje:='NO';
  		  RETURN;
  		  END;
end;

IF (varUser<>xUser) THEN

	SELECT count(USUARIO) INTO xNumUser FROM USUARIOS WHERE USUARIO=xUser;
		IF (xNumUser>0) THEN 
			xMensaje:='NO';
			RETURN;
		END IF;
END IF;
xMensaje:='SI';
--actualizamos los datos en ususario
UPDATE  USUARIOS SET USUARIO=xUser,NIF=xNIF,NOMBRE=xNOMBRE,MOVIL=xMVL,EMAIL=xMAIL,PASSWD=xPASSWD
	WHERE IDEMPLEADO=xIDempleado;

-- actualizamos los datos en clientes
update clientes set NOMBRE=xNOMBRE,NIF=xNIF,MVL=xMVL,MAIL=xMAIL
where id=xIDempleado;

END;


--
--
--
Procedure EditGuest(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xIDGuest IN Integer,
		xUser IN varchar2,
		xMensaje OUT varchar2)
as
xNumUser INTEGER;
varUser varchar2(30);
BEGIN

begin
SELECT USUARIO INTO varUser from usuarios where IDINVITADO=xIDGuest;
exception
   		when no_data_found then
   	    begin
  		  	xMensaje:='NO';
  		  RETURN;
  		  END;
end;

IF (varUser<>xUser) THEN

	SELECT count(USUARIO) INTO xNumUser FROM USUARIOS WHERE IDINVITADO=xUser;
	IF (xNumUser>0) THEN 
		xMensaje:='NO';
		RETURN;
	END IF;
END IF;
xMensaje:='SI';
--actualizamos los datos en ususario
UPDATE  USUARIOS SET USUARIO=xUser,NIF=xNIF,NOMBRE=xNOMBRE,MOVIL=xMVL,EMAIL=xMAIL,PASSWD=xPASSWD
	WHERE IDINVITADO=xIDGuest;

-- actualizamos los datos en invitados
update INVITADOS set RAZON_SOCIAL=xNOMBRE,NIF=xNIF,EMAIL=xMAIL
where id=xIDGuest;

END;

--
-- Da de baja a un invitado
--
PROCEDURE BajaGuest(xIDGuest IN Integer)
as
begin
update invitados set fecha_baja=SYSTIMESTAMP WHERE ID=xIDGuest;
end;

--
-- Alta invitado
--
PROCEDURE AltaGuest(xIDGuest IN Integer)
as
begin
update invitados set fecha_baja=NULL WHERE ID=xIDGuest;
end;

--
--
--
PROCEDURE BajaCliente(xID IN Integer)
as
begin
update clientes set fecha_baja=SYSTIMESTAMP WHERE ID=xID;
end;


END pkEditUsuarios;
/