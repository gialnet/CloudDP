--
-- Añadir un usuario de pruebas a partir de su dirección de e-mail
--
create or replace Procedure Add_BetaTesterByEmail(eMail in varchar2)
as

xNOMBRE VARCHAR2(40);
xNIF VARCHAR2(12);
xMVL VARCHAR2(12):='6..';
xMAIL VARCHAR2(90);
xPASSWD VARCHAR2(20):='b1';
xPERTENECE_A Integer:=1;
begin

xNOMBRE:=eMail;
xMAIL:=eMail;
xNIF:=substr(eMail,1,12);

-- AÑADIR UN NUEVO Beta Tester

/*
EmployeeClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer, xGrupo IN Integer, xDto IN Integer)
*/
pkUsersCDP.EmployeeClientNewUser(xNOMBRE,xNIF, xMVL,xMAIL,xPASSWD,xPERTENECE_A, 1, 1);
		

end;
/

--
-- Procedimiento para añadir empleados de un cliente
--
create or replace Procedure Add_BetaTester(xMOVIL in varchar2, xMail in varchar2, xNombre in varchar2)
as

xNIF VARCHAR2(12);
xPASSWD VARCHAR2(20):='b1';
xPERTENECE_A Integer:=1;

begin


xNIF:=substr(xMail,1,12);

-- AÑADIR UN NUEVO Beta Tester

/*
EmployeeClientNewUser(xNOMBRE IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xPASSWD IN VARCHAR2,
		xPERTENECE_A IN Integer, xGrupo IN Integer, xDto IN Integer)
*/
pkUsersCDP.EmployeeClientNewUser(xNOMBRE,xNIF, xMOVIL, xMAIL,xPASSWD,xPERTENECE_A, 1, 1);
		

end;
/


-- Probar el paquete

create or replace procedure test_pkUsersCDP
as
begin
/*
ClientNewUser(xNOMBRE IN VARCHAR2,
		xRAZON_SOCIAL IN VARCHAR2,
		xNIF IN VARCHAR2,
		xMVL IN VARCHAR2,
		xTLF IN VARCHAR2,
		xMAIL IN VARCHAR2,
		xCALLE_NUM IN VARCHAR2,
		xOBJETO IN VARCHAR2,
		xCP IN VARCHAR2,
		xCIUDAD IN VARCHAR2,
		xPROVINCIA IN VARCHAR2, 
		xCC IN VARCHAR2,
		xTITULAR_CC IN VARCHAR2,
		xPASSWD IN VARCHAR2, xIDGremio Integer);
*/
	pkUsersCDP.ClientNewUser('REDMOON CONSULTORES SL',
		'REDMOON CONSULTORES SL',
		'B18874941',
		'625302112',
		'958596199',
		'ANTONIO.GIALNET@GMAIL.COM',
		'DARRILLO DE LA MAGDALENA 7',
		'3º',
		'18002',
		'GRANADA',
		'GRANADA', 
		'20310373951234567890',
		'REDMOON CONSULTORES SL',
		'a1', 1);
end;
/
