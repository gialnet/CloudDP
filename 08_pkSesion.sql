--
-- Antonio
-- Septiembre 2010
--
-- Gestión de sesiones de usuario
--
--


Create or replace package pkSesiones AS

-- Leer los valores de una sesion
Procedure GetSesion(xIDSesion IN Integer,
	xFECHA OUT SESIONES.FECHA%Type,
	xESTADO OUT SESIONES.ESTADO%Type,
	xID_CLIENTE OUT SESIONES.ID_CLIENTE%Type,
	xERROR_VAR OUT SESIONES.ERROR_VAR%Type,
	xTIPO OUT SESIONES.TIPO%Type);


Function ElapsedTime(xIDSesion IN Integer) return INTEGER;

--
-- Que se hace de forma automática cada intervalo de minutos
--
Procedure ReglaMinutos(minutos in integer, xIDSesion IN Integer);
--
-- Que se hace de forma automática cada intervalo horas
--
Procedure ReglaHoras(horas in integer, xIDSesion IN Integer);

-- Buscar sesiones muertas
--Procedure FindSesionDead();

-- Sumar caudal consumido en una sesion
FUNCTION SumarCaudal(xIDSesion In Integer) RETURN NUMBER;

--
-- Añadir una nueva transacción, Cada ver que subimos un archivo o lo bajamos estamos produciéndo una transacción
-- en Amazon AWS vamos a registrar todos los movimientos de nuestros clientes
--
Procedure AddTransaccion(xIDDoc In Integer, xIDSesion In Integer, 
		xDURACION in Number, 
		xTIPO_OPERACION in varchar2,
		xResultado IN Char, 
		xUSUARIO in varchar2);

END pkSesiones;
/




--
-- Cuerpo del paquete
--
create or replace package body pkSesiones AS

--
--
--
FUNCTION SumarCaudal(xIDSesion In Integer) RETURN NUMBER
as
SUMA NUMBER(10,0);
begin

SELECT SUM(NUMERO_BYTES) INTO SUMA FROM TRANSACCIONES WHERE SESION = xIDSesion;

RETURN SUMA;

end;


--
-- Añadir una nueva transacción, Cada ver que subimos un archivo o lo bajamos estamos produciéndo una transacción
-- en Amazon AWS vamos a registrar todos los movimientos de nuestros clientes
--
Procedure AddTransaccion(xIDDoc In Integer, xIDSesion In Integer, 
		xDURACION in Number, 
		xTIPO_OPERACION in varchar2,
		xResultado IN Char, 
		xUSUARIO in varchar2)
as
xNUMERO_BYTES number(10,0);
xCLIENTE integer;
xINVITADO integer;

begin

	
	BEGIN
		SELECT NUMERO_BYTES,CLIENTE,INVITADO
		INTO xNUMERO_BYTES,xCLIENTE,xINVITADO
			FROM DOC_CUSTODIA WHERE ID=xIDDoc;
	EXCEPTION
   		when no_data_found then
 		begin  	
  			RETURN;
   		end;
   	END;
   	
INSERT INTO TRANSACCIONES (SESION,NUMERO_BYTES,DURACION,IDCLIENTE,INVITADO,TIPO_OPERACION,USUARIO, Resultado) 
		values (xIDSesion,xNUMERO_BYTES, xDURACION,xCLIENTE,xINVITADO,xTIPO_OPERACION,xUSUARIO, SubStr(xResultado,1,2));

end;

--
-- Tiempo que lleva activo una sesión
--
Function ElapsedTime(xIDSesion IN Integer) return INTEGER
as
xDiferencia varchar2(30);
signo Char(1);
dias number(3,0);
horas number(2,0);
minutos number(2,0);
begin


	BEGIN
		SELECT to_char(SYSTIMESTAMP - FECHA) INTO xDiferencia FROM SESIONES WHERE ID=xIDSesion;
	EXCEPTION
   		when no_data_found then
 		begin  	
  			RETURN -1;
   		end;
   	END;
   	
   	-- ejemplo de cadena devuelta en Into xDiferencia
   	--'12345678901234567890123456'
   	--'+000000003 07:14:57.296000'
   	signo:=to_number(substr(xDiferencia,1,1));
   	dias:=to_number(substr(xDiferencia,2,10));
   	horas:=to_number(substr(xDiferencia,12,13));
   	minutos:=to_number(substr(xDiferencia,15,16));
   	
   	
   	return minutos;
end;


--
-- Que se hace de forma automática cada intervalo de minutos
--
Procedure ReglaMinutos(minutos in integer, xIDSesion IN Integer)
as
xCaudal Number(10);
begin

-- Leer umbrales cada 5 minutos hacer ...
if (minutos >=5) then
	-- compruebo su IP y si no coinciden ...
	-- en caso de coincidir anoto en el log de la sesion	
	xCaudal:=SumarCaudal(xIDSesion);
end if;


end;

--
-- Que se hace de forma automática cada intervalo horas
--
Procedure ReglaHoras(horas in integer, xIDSesion IN Integer)
as
xCaudal Number(10);
begin

-- Leer umbrales cada hora hacer ...
if (horas >=1) then

	-- sumo el caudal que ha consumido
	xCaudal:=SumarCaudal(xIDSesion);
	
	-- compruebo valores dentro de la media si se salen 
	-- lanzar una alarma al administrador del sistema
end if;

end;

--
-- Leer los datos de una sesion
--
Procedure GetSesion(xIDSesion IN Integer,
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

END pkSesiones;
/

