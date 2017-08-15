

--
-- PAQUETE DE MENSAJES
--

Create or replace package pkMensajes AS


	PROCEDURE AddNewPeticionCliente(xIndirecto IN INTEGER, 
			xCliente IN INTEGER, xMensaje IN VARCHAR2, xAsunto in VARCHAR2);
	
	PROCEDURE AddNewPeticionGuest(xIndirecto IN INTEGER, xMensaje IN VARCHAR2,	xAsunto in VARCHAR2);

	PROCEDURE HiloLeidoCliente(xID_PETI IN INTEGER);
	
	PROCEDURE HiloLeidoGuest(xID_PETI IN INTEGER);
	
	PROCEDURE CerrarPeticion(xID_PETI IN INTEGER);

	PROCEDURE AddAtachDocHilo(xIDpet in integer,xMensaje in varchar2,xIDUser in integer,xTipoCliente in char,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,xURL_Local in varchar2, xNUMERO_Bytes in INTEGER,xTipoMIME in varchar2,
		xURL_Nube out varchar2);
		
	PROCEDURE AddHiloCliente(xMensaje IN varchar2, 	
	xIDcliente IN integer, 
	xIDpeti IN integer);
		
	PROCEDURE AddHiloInvitado(xMensaje IN varchar2,
		xIDguest in integer, 
		xIDpeti IN integer);
				
END pkMensajes;
/


create or replace package body pkMensajes AS


--
--Añadir documento adjunto a un hilo
--
--xTipoCliente podra ser:
-- 'CL' cliente
-- 'IN' invitado
-- 'EM' empleado
Procedure AddAtachDocHilo(xIDpet in integer,
		xMensaje in varchar2,
		xIDUser in integer,
		xTipoCliente in char,
		xIDServicio in Integer,
		xIDSesion IN INTEGER,
		xURL_Local in varchar2, 
		xNUMERO_Bytes in INTEGER,
		xTipoMIME in varchar2,
		xURL_Nube out varchar2)
		
as

xID INTEGER;
xALMACENCERT INTEGER;
xIDInvitado INTEGER :=NULL;
xIDCliente INTEGER;
xCarpeta varchar2(50);
xNIF VARCHAR2(12);
xError varchar2(20);
xAmount number(10,3);
xTax number(5,2);
xID_DTO INTEGER;
xID_GRUPO INTEGER;
xEstado_Cliente Char(8):='LEIDO';
xEstado_Invitado Char(8):='LEIDO';
BEGIN

--utilizar una logica acorde a cada tipo de cliente
IF(xTipoCliente='IN') THEN
	-- Buscar el código de asesor
	xIDInvitado:=xIDUser;
	xIDCliente:=GuestFindIDHostByID(xIDUser);
	
	xEstado_CLiente:='NUEVO';
	
	IF  (xIDCliente IS NULL) THEN

		xURL_Nube:='NO INVITADO';
  		RETURN;
  	
	END IF;

	xNIF:=ClientFindNIFByID(xIDCliente);

	IF  (xNIF IS NULL) THEN

		xURL_Nube:='NO CLIENTE';
  		RETURN;
  	
	END IF;

	
	
ELSIF(xTipoCliente='CL')THEN

	xIDCliente:=xIDUser;
	xNIF:=ClientFindNIFByID(xIDUser);
	
	xEstado_Invitado:='NUEVO';
	
	IF  (xNIF IS NULL) THEN

		xURL_Nube:='NO CLIENTE';
  		RETURN;
  	
	END IF;
	
	

ELSIF(xTipoCliente='EM')THEN
	xEstado_Invitado:='NUEVO';
	xIDCliente:=getIDClientByIDEmployee(xIDUser);
	IF (xIDCliente IS NULL) THEN
		xURL_Nube:='NO EMPLEADO';
  		RETURN;
	END IF;
	xNIF:=ClientFindNIFByID(xIDCliente);

	IF  (xNIF IS NULL) THEN

		xURL_Nube:='NO CLIENTE';
  		RETURN;
  	
	END IF;
	
	
	
ELSE
		xURL_Nube:='TIPO DE USUARIO DESCONOCIDO';
  		RETURN;
END IF;





-- Buscar el servicio
pkDocSystemCustody.ReadAmountTax(xIDServicio, xError, xAmount, xTax);
IF xError='NO EXISTE EL SERVICIO' THEN
	xURL_Nube:='NO EXISTE EL SERVICIO';
	RETURN;
END IF;

-- Anotar el Consumo del servicio en este caso gratuito para los invitados de nuestros clientes

INSERT INTO CONSUMOS (ID_SERVICIO, ID_CLIENTE, PRECIO, TIPO_IVA) 
	VALUES (xIDServicio, xIDCliente, xAmount, xTax);

	
	-- TOMAR EL APUNTADOR DE ALMACENCERT
	getALMACENCERT(xIDCliente, xALMACENCERT);
	
	-- LEER LOS ID DE DEPARTAMENTO Y GRUPO POR DEFECTO.
	getDefaultDTOAndGroup(xIDCliente, xID_DTO, xID_GRUPO);

	
	
-- Guardar los datos del documento a custodiar
INSERT INTO DOC_CUSTODIA (CLIENTE, INVITADO, TIPO_MIME, URL_LOCAL, 
	NUMERO_BYTES, ORIGEN_DOC, TIPO_DOCUMENTO, UBICACION, ALMACENCERT, DTO, GRUPO)
VALUES (xIDCliente, xIDInvitado, pkDocSystemCustody.getTipoMimeByUrl(xURL_Local), xURL_Local, xNUMERO_Bytes, 
	DECODE (xTipoCliente,'IN','INVITADO','CL','CLIENTE','EM','EMPLEADO'), 'ADJUNTO', 'adjuntos',
	xALMACENCERT, xID_DTO, xID_GRUPO)
	RETURNING ID INTO xID;


xURL_Nube:=xNIF||'/adjuntos/'||xID||'-'||xURL_Local;

--Insertamos el hilo

insert into hilos (ID_DOC_ADJUNTO,mensaje,remitente,ID_PETICION, estado_cliente, estado_invitado) 
		VALUES (xID,xMensaje,xIDUser,xIDpet, xEstado_Cliente, xEstado_Invitado);

end AddAtachDocHilo;

--
--
--
Procedure HiloLeidoCliente(xID_PETI IN INTEGER)
as
begin

UPDATE hilos SET estado_cliente='LEIDO' WHERE  id_peticion=xID_PETI;

UPDATE peticiones SET estado_cliente='LEIDO' WHERE  id=xID_PETI;

end;

--
--
--
Procedure HiloLeidoGuest(xID_PETI IN INTEGER)
as
begin

UPDATE hilos SET estado_invitado='LEIDO' WHERE  id_peticion=xID_PETI;

UPDATE peticiones SET estado_invitado='LEIDO' WHERE  id=xID_PETI;

end;


--
--
--
PROCEDURE CerrarPeticion(xID_PETI IN INTEGER)
as
begin


UPDATE peticiones SET estado_cliente='RESUELTA',estado_invitado='RESUELTA' WHERE  id=xID_PETI;

end;


--
-- Asunto abierto por el Asesor
--

PROCEDURE AddNewPeticionCliente(xIndirecto IN INTEGER, 
		xCliente IN INTEGER,xMensaje IN VARCHAR2,xAsunto in VARCHAR2)
AS
xid_peti INTEGER;
BEGIN

    INSERT INTO peticiones (asunto,remitente,id_indirecto,id_cliente)
    VALUES (xAsunto,xCliente,xIndirecto,xCliente) returning id into xid_peti;
	
    INSERT INTO  hilos (mensaje,remitente,id_peticion,estado_cliente,estado_invitado)
    VALUES (xMensaje,xCliente,xid_peti,'LEIDO','NUEVO');
		
	UPDATE peticiones set estado_INVITADO='NUEVO',estado_cliente='LEIDO' WHERE id=xid_peti;


END;


--
-- Asunto abierto por el invitado
--

PROCEDURE AddNewPeticionGuest(xIndirecto IN INTEGER,xMensaje IN VARCHAR2,xAsunto in VARCHAR2)
AS
xid_peti INTEGER;
xid_cliente integer;
BEGIN

	
	BEGIN
    	select id into xid_cliente from clientes where id=xIndirecto;
    EXCEPTION
   		when no_data_found then
 		begin  			
  			RETURN;
   		end;
   	END;

    INSERT INTO peticiones (asunto,remitente, id_indirecto, id_cliente)
    VALUES (xAsunto,xIndirecto,xIndirecto,xid_cliente) returning id into xid_peti;
	
    INSERT INTO  hilos (mensaje,remitente,id_peticion,estado_cliente,estado_invitado)
    VALUES (xMensaje,xIndirecto,xid_peti,'NUEVO','LEIDO');
		
	UPDATE peticiones set estado_CLIENTE='NUEVO',ESTADO_INVITADO='LEIDO' WHERE id=xid_peti;


END;

PROCEDURE AddHiloCliente(xMensaje IN varchar2, 	xIDcliente IN integer, xIDpeti IN integer)
		as
		xid_hilo integer;
		begin
		
		INSERT INTO HILOS (mensaje,remitente,id_peticion, estado_invitado,estado_cliente) 
		VALUES (xMensaje,xIDcliente,xIDpeti,'NUEVO','LEIDO') returning id into xid_hilo;
		
		UPDATE peticiones set estado_INVITADO='NUEVO',ESTADO_CLIENTE='LEIDO' WHERE id=xid_hilo;
end;

PROCEDURE AddHiloInvitado(xMensaje IN varchar2,xIDguest in integer, xIDpeti IN integer)
		as
		xid_hilo integer;
		begin
		
		INSERT INTO HILOS (mensaje,remitente,id_peticion, estado_cliente,estado_invitado) 
		VALUES (xMensaje,xIDguest,xIDpeti,'NUEVO','LEIDO') returning id into xid_hilo;
		
		UPDATE peticiones set estado_cliente='NUEVO',ESTADO_INVITADO='LEIDO' WHERE id=xid_hilo;
end;

END pkMensajes;
/
