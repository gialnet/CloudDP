
--
-- PAQUETE DE TABLON DE LA WEB PERSONAL
-- DICIEMBRE 2010

Create or replace package pkTablon AS


	PROCEDURE AddNewComent(xIDCliente IN INTEGER,xComent in VARCHAR2);
	PROCEDURE DeleteComent(xID IN INTEGER);
	
				
END pkTablon;
/


create or replace package body pkTablon AS

	---
	---
	PROCEDURE AddNewComent(xIDCliente IN INTEGER,xComent in VARCHAR2)	
	AS
	numComent Integer;
	xBorrar Integer;
	BEGIN
	
		select count(id) into numComent from tablon where idcliente=xIDCliente;
		IF(numComent=5) THEN
			select min(id) into xBorrar from tablon where idcliente=xIDCliente;
			DELETE TABLON  WHERE id=xBorrar;
		END IF;
		
		INSERT INTO TABLON (IDCLIENTE,COMENTARIO) VALUES (xIDCliente,xComent);
	END;
	
	---
	---
	PROCEDURE DeleteComent(xID IN INTEGER)	
	AS
	BEGIN
		
		
		DELETE FROM TABLON WHERE ID=xID;
	END;

END pkTablon;
/
