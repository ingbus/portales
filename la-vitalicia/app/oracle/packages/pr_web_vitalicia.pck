create or replace package pr_web_vitalicia is

  
  function obtener_perfil(v_token VARCHAR2) return sys_refcursor;

  function imprimir_reporte(nIdepol IN NUMBER) return sys_refcursor;


end pr_web_vitalicia;
/
create or replace package body pr_web_vitalicia is

  

  FUNCTION obtener_perfil(v_token VARCHAR2) return sys_refcursor IS
    l_cursor sys_refcursor;
  BEGIN
    OPEN l_cursor FOR
      SELECT INITCAP(nominter) nominter, coduser codinter, rolname, fecsts
        FROM usuario_portal_web
       WHERE token = v_token
         and status = '0';
    return l_cursor;
  END;

  function imprimir_reporte(nIdepol IN NUMBER) return sys_refcursor is
  begin
    --return acsel.pr_kimpus.CUADRO_POLIZA(nIdepol);                                    
    return null;
  end;



end pr_web_vitalicia;
/
