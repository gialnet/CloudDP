--
-- Antonio
-- Diciembre 2010
--
-- Gestion de Carpetas de usuario
--
--


Create or replace package pkCarpetas AS

Procedure  AddCarpeta
	(xID IN INTEGER,
	xTIPO in char,
	xNombre in varchar2,
	xOut OUT varchar2);

						
Procedure ConsultaCarpetas
	(xID IN INTEGER, 
	xTipo IN char,
	xSesion in varchar2);

	
Procedure RenameCarpeta
	(xID IN INTEGER,
	xIDcarpeta in INTEGER,
	xNombre in varchar2, 
	xOUT out varchar2);
	
Procedure MoverDocCarpeta(xIDdoc In Integer, 
	xNombre In varchar2);
--Procedure DeleteCarpeta(xIDcarpeta in Integer);
--Procedure RenameCarpeta(xIDcarpeta in Integer);
--Procedure MoveDocCarpeta(xIDOrigen in Integer,xIDdestiono in Integer, xIDdoc in Integer);


END pkCarpetas;
/


--
-- Cuerpo del paquete
--
create or replace package body pkCarpetas AS


Procedure AddCarpeta(xID IN INTEGER,xTIPO in char,xNombre in varchar2,xOut OUT varchar2)
as
xUsuario varchar2(30);
xNumCarpetas Integer;
begin

IF (xTIPO='CL') THEN
	BEGIN
		SELECT USUARIO INTO xUsuario   FROM USUARIOS 
      		WHERE IDCLIENTE=xID and idempleado is NULL and idinvitado is null;
	exception
   		when no_data_found then
   	    begin
  		  	xOut:='NO';
  		  RETURN;
   		end;
   	END;
	
END IF;

IF (xTIPO='EM') THEN
	BEGIN
		SELECT USUARIO into xUsuario FROM USUARIOS WHERE IDEMPLEADO=xID;
	exception
   		when no_data_found then
   	    begin
  		  	xOut:='NO';
  		  RETURN;
   		end;
   	END;
	
END IF;

IF (xTIPO='IN') THEN
	BEGIN
		SELECT USUARIO into xUsuario FROM USUARIOS WHERE IDINVITADO=xID;
	exception
   		when no_data_found then
   	    begin
  		  	xOut:='NO';
  		  RETURN;
   		end;
   	END;
	
END IF;

--comprabamos que el usuario no tenga otra carpeta con el mismo nombre
SELECT count(nombre) into xNumCarpetas from carpetasUsuario where usuario=xUsuario and nombre=xNombre;

IF(xNumCarpetas>0) THEN
	xOut:='CARPETA DUPLICADA';
	return;
END IF;

Insert into carpetasUsuario (USUARIO,NOMBRE) VALUES (xUsuario,xNombre);
xOut:='OK';

END;


--
-- Guardamos en una tabla temporal el serializado de las carpetas
--
Procedure ConsultaCarpetas(xID IN INTEGER, xTipo IN char,xSesion in varchar2)
as

	xUsuario varchar2(30);
	CURSOR cCursor IS select ETIQUETA,CARPETA 
		FROM vistaSinterfaz	
		where NOMBRE_INTERFAZ='Docs Asesor' AND idioma='ES' and objeto='gridTipoArchivo';
		
	CURSOR aCursor (cUsuario varchar2) IS select id,nombre
		FROM carpetasUsuario	
		where usuario=cUsuario;
	

begin

DELETE FROM TEMP_CARPETAS WHERE SESION=xSesion;

IF (xTIPO='CL') THEN
	BEGIN
		SELECT USUARIO INTO xUsuario   FROM USUARIOS 
      		WHERE IDCLIENTE=xID and idempleado is NULL and idinvitado is null;
	exception
   		when no_data_found then
   	    begin
  		  
  		  RETURN;
   		end;
   	END;
	
END IF;

IF (xTIPO='EM') THEN
	BEGIN
		SELECT USUARIO into xUsuario FROM USUARIOS WHERE IDEMPLEADO=xID;
	exception
   		when no_data_found then
   	    begin
  		  	
  		  RETURN;
   		end;
   	END;
	
END IF;

IF (xTIPO='IN') THEN
	BEGIN
		SELECT USUARIO into xUsuario FROM USUARIOS WHERE IDINVITADO=xID;
	exception
   		when no_data_found then
   	    begin
  		  	
  		  RETURN;
   		end;
   	END;
	
END IF;



--INSERTAMOS EN LA TABLA TEMPORAL
FOR vCURSOR IN cCURSOR LOOP
	
	INSERT INTO TEMP_CARPETAS (SESION,TIPO,ETIQUETA,CARPETA) values (xSESION,'FI',vCURSOR.ETIQUETA,vCURSOR.CARPETA);

END LOOP;



FOR tCURSOR IN aCURSOR(xUsuario) LOOP
	
	INSERT INTO TEMP_CARPETAS (SESION,TIPO,ETIQUETA,CARPETA,id_carpeta) 
		values (xSESION,'TE',tCURSOR.NOMBRE,tCURSOR.NOMBRE,tCURSOR.id);

END LOOP;

	
end;

Procedure RenameCarpeta(xID IN INTEGER,xIDcarpeta in Integer, xNombre in varchar2, xOUT out varchar2)
as
xUsuario varchar2(30);
xTIPO CHAR(2);
xNUM integer;
xOLD VARCHAR2(20);
begin

	
	BEGIN
		SELECT USUARIO,NOMBRE into xUsuario,xOLD FROM carpetasUsuario WHERE ID=xIDcarpeta;
	exception
   		when no_data_found then
   	    begin
  		  	xOUT:='NO USER';
  		  RETURN;
   		end;
   	END;
   	
   	-- comprobamos que el nombre de la carpeta no exista
	SELECT count(nombre) into xNUM FROM carpetasUsuario WHERE usuario=xUsuario and nombre=xNombre;
	
	IF(xNUM>0) then
		xOUT:='CARPETA DUPLICADA';
  		  RETURN;
	end if;
   	
   	
   	BEGIN
		SELECT tipo into xTIPO FROM usuarios WHERE usuario=xUsuario;
	exception
   		when no_data_found then
   	    begin
  		  		xOUT:='NO TIPO';
  		  RETURN;
   		end;
   	END;
   	
   	
   	
   	
IF (xTIPO='CL') THEN
	
	UPDATE DOC_CUSTODIA SET TIPO_DOCUMENTO=trim(xNombre) 
		WHERE CLIENTE=xID AND ORIGEN_DOC='CLIENTE' and TIPO_DOCUMENTO=xOLD;
	
END IF;

IF (xTIPO='EM') THEN
	
	UPDATE DOC_CUSTODIA SET TIPO_DOCUMENTO=trim(xNombre) 
		WHERE EMPLEADO=xID AND ORIGEN_DOC='EMPLEADO' AND TIPO_DOCUMENTO=xOLD;	

END IF;

UPDATE carpetasUsuario SET NOMBRE = trim(xNombre) WHERE USUARIO = trim(xUsuario) AND ID=xIDcarpeta;

xOUT:='OK';

end;

Procedure MoverDocCarpeta(xIDdoc In Integer, 
	xNombre In varchar2)
	
as
	
begin

update doc_custodia set tipo_documento=xNombre where id=xIDdoc;
	
end;


END pkCarpetas;
/