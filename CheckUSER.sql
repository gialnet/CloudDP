--
-- Utilidades
-- Antonio Pérez Caballero
-- Septiembre 2010
--
-- xIDUser tendrá el valor del ID de clientes para los empleados o el ID de Invitados para estos
--
-- Control de acceso a la aplicación CLOUD DP
--
Create or Replace Procedure CheckUSER(xPOSD1 in INTEGER, 
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
			xNOMBRE OUT varchar2)
as
xDIGITOS VARCHAR2(16);
xIDInvitado Integer;
xIDEmpleado Integer;
begin


		
	BEGIN
	
		-- Via DNIe
		if xPOSD1= -1 then
			SELECT G.ID, U.IDCliente, U.IDInvitado, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE
			INTO  xIDGremio, xIDCliente, xIDInvitado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE
			FROM USUARIOS U, GREMIOS G
      			WHERE U.USUARIO=xUSUARIO AND U.IDGREMIO=G.ID;
		else
			SELECT G.ID, U.IDCliente, U.IDInvitado, U.TIPO, U.IDDatosPer, U.DIGITOS, U.PERFIL, U.EMAIL,U.NOMBRE
			INTO  xIDGremio, xIDCliente, xIDInvitado, xTIPO, xIDDatosPer, xDIGITOS, xPERFIL, xMAIL, xNOMBRE
			FROM USUARIOS U, GREMIOS G
				WHERE U.IDGREMIO=G.ID AND U.USUARIO=xUSUARIO AND U.PASSWD=xPASSWD;
		end if;
		
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
   	if (xTIPO='EM') then
	
		-- buscar el NIF del Cliente
		xIDEmpleado:=xIDCliente;
		xIDUser:=xIDCliente;
		xIDCliente:=getIDClientByIDEmployee(xIDEmpleado);
		xNIF:=ClientFindNIFByID(xIDCliente);
		
	ELSIF (xTIPO='IN') THEN 
	
		-- Buscar al Asesor que pertenece
		xIDUser:=xIDInvitado;
		xIDCliente:=GuestFindIDHostByID(xIDInvitado);
		xNIF:=ClientFindNIFByID(xIDCliente);
		
	ELSIF (xTIPO='CL') THEN 
	
		xNIF:=ClientFindNIFByID(xIDCliente);
		
	else
			xPERFIL:='NO AUTORIZADO, TIPO DE CLIENTE DESCONOCIDO';
			-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, ERROR_VAR, ESTADO) 
			VALUES (xIDCliente, xIP, xREFER, xPERFIL, 'ERROR') RETURNING ID INTO xSESION;
		RETURN;
	end if;
   	
   	
   	if  xPOSD1= -1 then
   		-- Insertar en la tabla de sesiones
			INSERT INTO SESIONES (ID_CLIENTE, IP, REFER, TIPO) 
			VALUES (xIDCliente, xIP, xREFER, xTIPO) RETURNING ID INTO xSESION;
   	    return;
   	end if;
   	
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
			VALUES (xIDCliente, xIP, xREFER, xTIPO) RETURNING ID INTO xSESION;
	
end;
/

--
-- Aceeso a la aplicación vía SMS
-- xMOVIL,xSMS_PASS
--
Create or Replace Procedure AccesSMS(xMOVIL IN varchar2)
as
xSMS_PASS CHAR(6);
xURL varchar2(1024):='http://localhost/OracleEnviarSMS.php'; //enviar SMS del saldo de Arsys
xResp varchar2(2000);
begin

-- Escribir una contraseña aleatoria

-- Guardarla en la tabla
UPDATE USUARIOS SET SMS_PASS=(SELECT dbms_random.string('X', 6) FROM DUAL) WHERE USUARIO=xMOVIL 
	RETURNING SMS_PASS INTO xSMS_PASS;

-- NUMERO DE MOVIL NO REGISTRADO
IF xSMS_PASS IS NULL THEN
	RETURN;
END IF;

-- ENVIAR EL SMS AL MOVIL DEL CLIENTE
xURL:=xURL ||'?mvl=' ||xMOVIL ||'&pass=' ||xSMS_PASS;

select utl_http.request(xURL) into xResp from dual;

IF SubStr(xResp,1,2)='OK' THEN

	-- ENVIO SE REALIZO CON EXITO.
	
ELSE

	-- FALLO AL ENVIAR EL SMS.

END IF;

end;
/




-- Crear la lista
begin
        dbms_network_acl_admin.create_acl (
                acl             => 'Correo_Redmoon.xml',
                description     => 'Normal Access',
                principal       => 'CLOUD_DP_BETA11',
                is_grant        => TRUE,
                privilege       => 'connect',
                start_date      => SYSTIMESTAMP,
                end_date        => null );
end;
/

-- añadir un usuario
begin
  dbms_network_acl_admin.add_privilege ( 
  acl 		=> 'Correo_Redmoon.xml',
  principal 	=> 'LGS',
  is_grant 	=> TRUE, 
  privilege 	=> 'connect', 
  start_date 	=> SYSTIMESTAMP, 
  end_date 	=> null); 
end;
/

-- abrir puertos smtp.redmoon.es  217.76.128.100
begin
  dbms_network_acl_admin.assign_acl (
  acl => 'Correo_Redmoon.xml',
  host => 'smtp.redmoon.es',
  lower_port => 1,
  upper_port => 1024);
end;
/

-- a la red gialnet
begin
  dbms_network_acl_admin.assign_acl (
  acl => 'Correo_Redmoon.xml',
  host => 'www.gialnet.com',
  lower_port => 1,
  upper_port => 1024);
end;
/


-- borrar una lista de acceso
BEGIN
  DBMS_NETWORK_ACL_ADMIN.drop_acl ( 
    acl         => 'Correo_Redmoon.xml');

  COMMIT;
END;
/

-- ver privilegios
SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls;


-- VER LOS PRIVILEGIOS
SELECT HOST, LOWER_PORT, UPPER_PORT, ACL,
DECODE(
DBMS_NETWORK_ACL_ADMIN.CHECK_PRIVILEGE_ACLID(aclid, 'LGS', 'connect'),
1, 'GRANTED', 0, 'DENIED', null) PRIVILEGE
FROM DBA_NETWORK_ACLS
WHERE host IN
(SELECT * FROM
TABLE(DBMS_NETWORK_ACL_UTILITY.DOMAINS('smtp.redmoon.es')))
ORDER BY
DBMS_NETWORK_ACL_UTILITY.DOMAIN_LEVEL(host) DESC, LOWER_PORT, UPPER_PORT;

-- Ver el idioma de la base de datos
select sys_context('userenv', 'language') as nls_lang from dual

--
-- autorizar el esquema 
--
GRANT execute ON utl_mail TO lgs;
--
-- indicar el servidor de correo
--
ALTER SYSTEM SET smtp_out_server = 'smtp.redmoon.es' SCOPE=BOTH;

  create or replace procedure
   e_mail_message
(
   from_name varchar2,
   to_name varchar2,
   subject varchar2,
   message varchar2
)
is
  l_mailhost    VARCHAR2(64) := 'smtp.redmoon.es';
  l_from        VARCHAR2(64) := 'antonio@redmoon.es';
  l_to          VARCHAR2(64) := 'antonio.gialnet@gmail.com';
  l_mail_conn   UTL_SMTP.connection;
BEGIN

  l_mail_conn := UTL_SMTP.open_connection(l_mailhost, 25);
  utl_smtp.command(l_mail_conn,'AUTH LOGIN');
  utl_smtp.command(l_mail_conn,utl_encode.base64_encode(utl_raw.cast_to_raw('ict342c')));
  utl_smtp.command(l_mail_conn,utl_encode.base64_encode(utl_raw.cast_to_raw('Redmoon2010')));
  
  UTL_SMTP.helo(l_mail_conn, l_mailhost);
  UTL_SMTP.mail(l_mail_conn, l_from);
  UTL_SMTP.rcpt(l_mail_conn, l_to);
 
  UTL_SMTP.open_data(l_mail_conn);
 
  UTL_SMTP.write_data(l_mail_conn, 'Date: '    || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || Chr(13));
  UTL_SMTP.write_data(l_mail_conn, 'From: '    || l_from || Chr(13));
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || subject || Chr(13));
  UTL_SMTP.write_data(l_mail_conn, 'To: '      || l_to || Chr(13));
  UTL_SMTP.write_data(l_mail_conn, ''          || Chr(13));
 
  FOR i IN 1 .. 10 LOOP
    UTL_SMTP.write_data(l_mail_conn, 'This is a test message. Line ' || To_Char(i) || Chr(13));
  END LOOP;
 
  UTL_SMTP.close_data(l_mail_conn);
 
  UTL_SMTP.quit(l_mail_conn);
END;
/


--
--
--
DECLARE
  l_url            VARCHAR2(50) := 'http://www.gialnet.com:80';
  l_http_request   UTL_HTTP.req;
  l_http_response  UTL_HTTP.resp;
  value VARCHAR2(1024);
BEGIN
  -- Make a HTTP request and get the response.
  l_http_request  := UTL_HTTP.begin_request(l_url);
  l_http_response := UTL_HTTP.get_response(l_http_request);
  --UTL_HTTP.end_response(l_http_response);
  LOOP
    UTL_HTTP.READ_LINE(l_http_response, value, TRUE);
    DBMS_OUTPUT.PUT_LINE(value);
  END LOOP;
  
  UTL_HTTP.END_RESPONSE(l_http_response);
  
EXCEPTION
  WHEN UTL_HTTP.END_OF_BODY THEN
    UTL_HTTP.END_RESPONSE(l_http_response);

END;
/


--
-- Ver los datos del DAC de Oracle
--

DECLARE
  l_dadNames     DBMS_EPG.VARCHAR2_TABLE;
  l_attrNames    DBMS_EPG.VARCHAR2_TABLE;
  l_attrValues   DBMS_EPG.VARCHAR2_TABLE;
BEGIN
  DBMS_EPG.GET_DAD_LIST(l_dadNames);
  FOR d IN 1..l_dadNames.COUNT LOOP
    DBMS_OUTPUT.PUT_LINE(CHR(10)||l_dadNames(d));
    DBMS_EPG.GET_ALL_DAD_ATTRIBUTES(l_dadNames(d),l_attrNames,l_attrValues);
    FOR a IN 1..l_attrValues.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('-  '||RPAD(l_attrNames(a),25)||' : '||l_attrValues(a));
    END LOOP;
    DBMS_EPG.GET_ALL_DAD_MAPPINGS(l_dadNames(d),l_attrValues);
    FOR a IN 1..l_attrValues.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('-  '||RPAD('mapping',25)||' : '||l_attrValues(a));
    END LOOP;
    FOR a IN ( SELECT username FROM dba_epg_dad_authorization WHERE dad_name = l_dadNames(d) ) LOOP
      DBMS_OUTPUT.PUT_LINE('-  '||RPAD('authorized',25)||' : '||a.username);
    END LOOP;
  END LOOP;
END;
/ 