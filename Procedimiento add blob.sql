

--	Necesita previamente la existencia de un directorio ORACLE que se llame IMAGENES
-- 	y que apunte a un único directorio donde se encuentren todas las imágenes.
-- 	Ejemplo de forma de crear el directorio : create directory imagenes as 'f:\fotos\'
-- 	El directorio ha de ser del servidor. Desde delphi se crea.Por lo tanto se debe ejecutar
--	desde el servidor.
--
-- En la aplicacion de Asesorias Abril 2010
-- create directory imagenes as 'E:\Carga_Oracle';
--
create or replace procedure(nombre_file in varchar2)
as
F BFILE;
xLOB BLOB;
begin

		-- Obtengo la imagen para modificarla (for update). ID_NOTI debe ser el de la tupla
		-- que representa a todos los valores de esa relacion y orden.	
		SELECT IMAGEN INTO xLOB FROM IMAGENES_NOTI WHERE ID=xID_IMAGEN FOR UPDATE;
		
F:=BFILENAME('IMAGENES',v_IMA.ARCHIVO);
		DBMS_LOB.FILEOPEN(F,DBMS_LOB.FILE_READONLY);
		DBMS_LOB.LOADFROMFILE(xLOB ,F,DBMS_LOB.GETLENGTH(F));
		DBMS_LOB.FILECLOSE(F);

end;
/