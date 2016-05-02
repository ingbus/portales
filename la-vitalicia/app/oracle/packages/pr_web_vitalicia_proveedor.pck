create or replace PACKAGE          "PR_WEB_VITALICIA_PROVEEDOR" 
  IS


function polizas_asegurabilidad(cCodprovee IN VARCHAR2,
                                  cCoddocum  IN VARCHAR2,
                                  cNumdocum  IN VARCHAR2,
                                  cCodarea   IN VARCHAR2,
                                  cNumtelef  IN VARCHAR2)
    return sys_refcursor;

  function tickets_asegurabilidad(cCodprovee    IN VARCHAR2,
                                  nIdepol       IN NUMBER,
                                  nNumasegurado IN NUMBER)
    return sys_refcursor;

  procedure crear_ticket(cCodprovee IN VARCHAR2,
                         nIdepol    IN NUMBER,
                         nNumaseg   IN NUMBER,
                         cCodArea   IN VARCHAR2,
                         cNumtelef  IN VARCHAR2,
                         cNumTicket OUT VARCHAR2);
                         
  function asegurados_medicamentos(cCodprovee IN VARCHAR2,
                                   cCoddocum  IN VARCHAR2,
                                   cNumdocum  IN VARCHAR2)
    return sys_refcursor;

  function siniestro_asegurado(cCodprovee IN VARCHAR2,
                               nIdepol    IN NUMBER,
                               nNumaseg   IN NUMBER) return sys_refcursor;

  function obtener_asegurados(nNumAseg IN NUMBER, nNumSini IN NUMBER)
    return sys_refcursor;

  function obtener_medicamento(nIdeMedi IN NUMBER) return sys_refcursor ;

  function obtener_medicamento_nombre(cNombre IN VARCHAR2)
    return sys_refcursor;


  function obtener_montos(nIdeMedi IN NUMBER) return sys_refcursor;
  

  procedure crear_orden_medicamento(nIdeOrden IN NUMBER,
                                    cNumOrden OUT VARCHAR2);                       

END; -- Package spec
/
create or replace PACKAGE BODY          "PR_WEB_VITALICIA_PROVEEDOR" 
IS


 function polizas_asegurabilidad(cCodprovee   IN VARCHAR2,
                                 cCoddocum  IN VARCHAR2,
                                 cNumdocum   IN VARCHAR2,
                                 cCodarea IN VARCHAR2,
                                 cNumtelef IN VARCHAR2) return sys_refcursor is
    l_cursor sys_refcursor;
    BEGIN

      open l_cursor for
      select select idepol, -- 0
             numasegurado, -- 1 
             doc_type, -- 2
             num_doc, -- 3
             0,
             nombre, -- 4
             parentesco, -- 5
             monto_deducible, -- 6 
           --  exceso, -- 7
             mcatitular, -- 7
             numpol, -- 8
             STSASEG --9
     from asegurados_asegurabilidad asegurados
     where idepol IN (select idepol
       from asegurados_asegurabilidad titular
       where titular.codprovee = cCodprovee
   and titular.doc_type = cCoddocum
       and titular.num_doc = cNumdocum
       and titular.area_code = cCodarea
       and titular.phone_num = cNumtelef)
     order by numasegurado asc;

      return l_cursor;
    END;


function tickets_asegurabilidad(cCodprovee   IN VARCHAR2,
                                nIdepol   IN NUMBER,
                                nNumasegurado  IN NUMBER) return sys_refcursor is
  l_cursor sys_refcursor;
  BEGIN

    open l_cursor for
    select 
     numticket, -- 0
     fecha -- 1
   from tickets_asegurabilidad ticket
   where ticket.idepol = nIdepol
     and ticket.numasegurado = nNumasegurado
   order by numticket asc;

    return l_cursor;
  END;

 procedure crear_ticket(cCodprovee IN VARCHAR2,
                         nIdepol    IN NUMBER,
                         nNumaseg   IN NUMBER,
                         cCodArea   IN VARCHAR2,
                         cNumtelef  IN VARCHAR2,
                         cNumTicket OUT VARCHAR2) is
  begin
    cNumTicket := '817347';
  end;

  function asegurados_medicamentos(cCodprovee IN VARCHAR2,
                                   cCoddocum  IN VARCHAR2,
                                   cNumdocum  IN VARCHAR2)
    return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select idepol, -- 0
             numasegurado, -- 1 
             doc_type, -- 2
             num_doc, -- 3
             0,
             nombre, -- 4
             parentesco, -- 5
             monto_deducible, -- 6 
             --  exceso, -- 7
             mcatitular, -- 7
             numpol, -- 8
             STSASEG --9
        from asegurados_asegurabilidad asegurados
       where idepol IN (select idepol
                          from asegurados_asegurabilidad titular
                         where titular.doc_type = cCoddocum
                           and titular.num_doc = cNumdocum)
       order by numasegurado asc;
  
    return l_cursor;
  end;

  function siniestro_asegurado(cCodprovee IN VARCHAR2,
                               nIdepol    IN NUMBER,
                               nNumaseg   IN NUMBER) return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select idepol, numaseg, idesini, numsini, descripcion, fecsini
        from asegurado_siniestro
       where idepol = nIdepol
         and numaseg = nNumaseg;
    return l_cursor;
  end;

  function obtener_asegurados(nNumAseg IN NUMBER, nNumSini IN NUMBER)
    return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select 'Enrique H Vargas A',
             'V',
             '23637749',
             'Titular Maculino',
             '123123', --poliza
             'Operecion de Rodilla derecha' --enfermadad
        from dual;
    return l_cursor;
  end;
  
  function obtener_medicamento(nIdeMedi IN NUMBER) return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select IDMEDI, DESCRIPCION from medicamentos where IDMEDI = nIdeMedi;
    return l_cursor;
  end;

  function obtener_medicamento_nombre(cNombre IN VARCHAR2)
    return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select IDMEDI, INITCAP(DESCRIPCION)
        from medicamentos
       where upper(descripcion) like '%' || upper(cNombre) || '%'
         and rownum < 30;
    return l_cursor;
  end;
  
  function obtener_montos(nIdeMedi IN NUMBER) return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select MTOMIN, MTOMAX from medicamentos where IDMEDI = nIdeMedi;
    return l_cursor;
  end;

  procedure crear_orden_medicamento(nIdeOrden IN NUMBER,
                                    cNumOrden OUT VARCHAR2) is
  begin
    cNumOrden := '1231231';
  end;

END;
/
