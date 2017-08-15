--
-- Antonio
-- Octubre 2010
--
-- Metodos de autenticación
--
--


Create or replace package pkLogin AS

--
-- Generar una clave aleatoria de números y letras de 6 carácteres de longitud
--
Procedure GenRandomPassToSMS(xUsuario IN USUARIOS.USUARIO%TYPE, 
							xSMS_PASS OUT USUARIOS.SMS_PASS%TYPE, 
							xENVIO OUT Char, 
							xMOVIL out USUARIOS.MOVIL%TYPE);

--
-- COORDENADAS USUARIO Y CONTRASEÑA
-- al insertar la sesion hay que hacer un trim del tipo de cliente(mete espacios)
Procedure ByKeyCoorUserAndPass(xPOSD1 in INTEGER, 
			xPOSD2 in INTEGER, 
			xDIGIT1 in varchar2, 
			xDIGIT2 in varchar2,
			xUSUARIO in varchar2, 
			xPASSWD in varchar2,
			xREFER in varchar2,
			xIP in varchar2,
			
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIF OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2);
--
-- CERTIFICADO x509 v3
--
Procedure ByX509Cert(xUsuario IN USUARIOS.USUARIO%TYPE,
			xNIF IN USUARIOS.NIF%TYPE,
			xREFER in varchar2,
			xIP in varchar2,
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIFAsesor OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2);
--
-- Para el movil
--
Procedure BySMSToUserMovil(
			xUsuario IN USUARIOS.USUARIO%TYPE,			
			xSMS_PASS IN USUARIOS.SMS_PASS%TYPE,
			xREFER in varchar2,
			xIP in varchar2,			
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIF OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2);
						
END pkLogin;
/




--
-- Cuerpo del paquete
--
create or replace package body pkLogin AS

--
-- Aceeso a la aplicación vía SMS
-- xMOVIL NÚMERO DE TELEFONO MOVIL DE NUESTRO CLIENTE
--
Procedure GenRandomPassToSMS(xUsuario IN USUARIOS.USUARIO%TYPE, 
xSMS_PASS OUT USUARIOS.SMS_PASS%TYPE, xENVIO OUT Char, xMOVIL out USUARIOS.MOVIL%TYPE)
as
xURL varchar2(1024):='http://localhost/OracleEnviarSMS.php'; --enviar SMS del saldo de Arsys
xResp varchar2(2000);
begin

-- Escribir una contraseña aleatoria

-- Guardarla en la tabla HOY más un día.
UPDATE USUARIOS SET SMS_PASS=(SELECT dbms_random.string('X', 6) FROM DUAL), SMS_UNTIL=SYSTIMESTAMP + 1 
	WHERE USUARIO=xUsuario AND (SMS_UNTIL IS NULL OR (SMS_UNTIL-SYSDATE<=0) )
	RETURNING SMS_PASS,MOVIL INTO xSMS_PASS,xMOVIL;

	-- sms_until-sysdate<=0 le dejas enviar 
	
-- NUMERO DE MOVIL NO REGISTRADO
IF xSMS_PASS IS NULL THEN
	xENVIO:='N';
	RETURN;
ELSE
	xENVIO:='S';
END IF;

-- ENVIAR EL SMS AL MOVIL DEL CLIENTE
/*
xURL:=xURL ||'?mvl=' ||xMOVIL ||'&pass=' ||xSMS_PASS;

select utl_http.request(xURL) into xResp from dual;


IF SubStr(xResp,1,2)='OK' THEN

	-- ENVIO SE REALIZO CON EXITO.
	xENVIO:='S';
	
ELSE

	-- FALLO AL ENVIAR EL SMS.
	xENVIO:='N';
	
END IF;
*/

end; -- GenRandomPassToSMS()

--
-- Para el movil
--
Procedure BySMSToUserMovil(
			xUsuario IN USUARIOS.USUARIO%TYPE,			
			xSMS_PASS IN USUARIOS.SMS_PASS%TYPE,
			xREFER in varchar2,
			xIP in varchar2,			
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIF OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2)
as
xDIGITOS USUARIOS.DIGITOS%TYPE;
xIDInvitado Integer;
xIDEmpleado Integer;

begin

	-- LAS CONDICIONES SON: coincidir el número de movil, la contraseña aleatoria 
	-- y el tiempo de caducidad de la contraseña no se ha alcanzado.
	BEGIN
		SELECT G.ID, U.IDCliente, U.IDInvitado, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE,U.NIF,g.bucket
			INTO  xIDGremio, xIDCliente, xIDInvitado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE,xNIF,xBucket
			FROM USUARIOS U, GREMIOS G
      			WHERE U.USUARIO=xUsuario
      			AND	U.SMS_PASS=xSMS_PASS 
      			AND U.IDGREMIO=G.ID
      			AND U.SMS_UNTIL >= SYSTIMESTAMP;
	exception
   		when no_data_found then
   	    begin
  		  	xPERFIL:='NO AUTORIZADO, USUARIO O PASSWORD';
  		  	-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
  		  RETURN;
   		end;
   	END;

   	-- Comprobar el tipo de usuario
   IF ( (xTIPO='CL') OR (xTIPO='IN') OR (xTIPO='EM') ) THEN 
	
		xNIF:=trim(xNIF);
		
		
	ELSE
			xPERFIL:='NO AUTORIZADO, TIPO DE CLIENTE DESCONOCIDO';
			-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
		RETURN;
	END IF;

	-- TODO ESTÁ OK.
	INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, TIPO) 
			VALUES (xIDCliente, xIP, xREFER, trim(xTIPO)) RETURNING ID INTO xSESION;
			
end;


--
-- CERTIFICADO x509 v3
--
Procedure ByX509Cert(xUsuario IN USUARIOS.USUARIO%TYPE,
			xNIF IN USUARIOS.NIF%TYPE,
			xREFER in varchar2,
			xIP in varchar2,
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIFAsesor OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2)
as
xDIGITOS VARCHAR2(16);
xIDInvitado Integer;
xIDEmpleado Integer;
begin


		
	BEGIN
	
		
	
		-- Via DNIe
		
			SELECT G.ID, U.IDCliente, U.IDInvitado,U.IDEmpleado, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE,U.NIF,g.bucket
			INTO  xIDGremio, xIDCliente, xIDInvitado,xIDEmpleado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE,xNIFAsesor,xBucket
			FROM USUARIOS U, GREMIOS G
      			WHERE USUARIO=xUsuario AND U.NIF=trim(xNIF) AND U.IDGREMIO=G.ID;		
	exception
   		when no_data_found then
   	    begin
  		  	xPERFIL:='NO AUTORIZADO, USUARIO O PASSWORD';
  		  	-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
  		  RETURN;
   		end;
   	END;

   	-- Comprobar el tipo de usuario
   	IF ( (xTIPO='CL') OR (xTIPO='IN') OR (xTIPO='EM') ) THEN 
	
		xNIFAsesor:=trim(xNIF);
		
		
	ELSE
			xPERFIL:='NO AUTORIZADO, TIPO DE CLIENTE DESCONOCIDO';
			-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
		RETURN;
	END IF;

   	
   	   	
	-- TODO ESTÁ OK.
	INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, TIPO) 
			VALUES (xIDCliente, xIP, xREFER, xTIPO) RETURNING ID INTO xSESION;
	
end;


--
-- COORDENADAS USUARIO Y CONTRASEÑA
--
Procedure ByKeyCoorUserAndPass(xPOSD1 in INTEGER, 
			xPOSD2 in INTEGER, 
			xDIGIT1 in varchar2, 
			xDIGIT2 in varchar2,
			xUSUARIO in varchar2, 
			xPASSWD in varchar2,
			xREFER in varchar2,
			xIP in varchar2,
			
			xPERFIL OUT varchar2,
			xIDGremio OUT Integer, 
			xIDCliente OUT Integer,
			xIDUser OUT Integer,
			xNIF OUT varchar2,
			xMAIL OUT varchar2, 
			xIDDatosPer OUT integer,
			xSESION OUT Integer,
			xTIPO OUT CHAR,
			xNOMBRE OUT varchar2,
			xBucket OUT varchar2)
as
xDIGITOS VARCHAR2(16);
xIDInvitado Integer;
xIDEmpleado Integer;
begin


		
	BEGIN
	
			SELECT G.ID, U.IDCliente, U.IDInvitado,U.IDEMPLEADO, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE,U.NIF,g.bucket
			INTO  xIDGremio, xIDCliente, xIDInvitado,xIDEmpleado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE,xNIF,xBucket
			FROM USUARIOS U, GREMIOS G
      			WHERE U.USUARIO=xUSUARIO AND U.IDGREMIO=G.ID;
	exception
   		when no_data_found then
   	    begin
  		  	xPERFIL:='NO AUTORIZADO, USUARIO O PASSWORD';
  		  	-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
  		  RETURN;
   		end;
   	END;


		
	 IF ( (xTIPO='CL') OR (xTIPO='IN') OR (xTIPO='EM') ) THEN 
	
		xNIF:=trim(xNIF);
		
		
	ELSE
			xPERFIL:='NO AUTORIZADO, TIPO DE CLIENTE DESCONOCIDO';
			-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
		RETURN;
	END IF;

   	
   	   	
   	-- COMPROBAR LOS DOS PRIMEROS DÍGITOS
	IF SUBSTR(xDIGITOS,xPOSD1,2)!=xDIGIT1 THEN
	   xPERFIL:='NO AUTORIZADO, PRIMEROS DIGITOS'||SUBSTR(xDIGITOS,xPOSD1,2);
	   -- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
	   RETURN;
	END IF;
	
	-- COMPROBAR LOS DOS SEGUNDOS DÍGITOS
	IF SUBSTR(xDIGITOS,xPOSD2,2)!=xDIGIT2 THEN
	   xPERFIL:='NO AUTORIZADO, SEGUNDOS DIGITOS'||SUBSTR(xDIGITOS,xPOSD2,2);
	   -- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
	   RETURN;	
	END IF;
   	
	-- TODO ESTÁ OK.
	INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, TIPO) 
			VALUES (xIDCliente, xIP, xREFER, trim(xTIPO)) RETURNING ID INTO xSESION;
	
end;

END pkLogin;
/
