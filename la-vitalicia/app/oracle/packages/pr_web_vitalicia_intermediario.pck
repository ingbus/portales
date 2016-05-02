
CREATE OR REPLACE 
PACKAGE pr_web_vitalicia_intermediario
  IS


 FUNCTION polizas_pre_renovar(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2, cNumpoliza IN VARCHAR2,
                             cCodoficina IN VARCHAR2, nReg_ini IN NUMBER, nReg_fin IN NUMBER) RETURN sys_refcursor;

 FUNCTION total_polizas_pre_renovar(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2,cNumpoliza IN VARCHAR2,
                                   cCodoficina IN VARCHAR2) RETURN NUMBER;

 FUNCTION obtener_planes_pre_renovar(cCodinter IN VARCHAR2, nIdepol IN NUMBER) RETURN sys_refcursor;

 FUNCTION obtener_asegurado(cCodinter IN VARCHAR2, nIdepol IN NUMBER)return sys_refcursor;

 FUNCTION devuelve_oficinas return sys_refcursor;

 FUNCTION obtener_oberturas_planes(cCodinter IN VARCHAR2,
                                   nIdepol   IN NUMBER,
                                   cCodprod  IN varchar2,
                                   cCodplan  IN varchar2,
                                   cRevplan  IN varchar2)RETURN sys_refcursor;

FUNCTION pre_renovar(cCodinter IN VARCHAR2,nIdepol NUMBER, cCodprod VARCHAR2, cCodplan VARCHAR2,
                     cCodrevplan VARCHAR2) RETURN boolean;


FUNCTION polizas_renovadas(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2, cNumpoliza IN VARCHAR2,
                             cCodoficina IN VARCHAR2, nReg_ini IN NUMBER, nReg_fin IN NUMBER) return sys_refcursor;

FUNCTION total_polizas_renovadas(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2,cNumpoliza IN VARCHAR2,
                                   cCodoficina IN VARCHAR2) return NUMBER;

PROCEDURE polizas_no_renovar(cCodinter IN VARCHAR2, nIdpoliza IN NUMBER, cCodoficina IN VARCHAR2);
END; -- Package spec
/


CREATE OR REPLACE 
PACKAGE BODY pr_web_vitalicia_intermediario
IS


 FUNCTION polizas_pre_renovar(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2, cNumpoliza IN VARCHAR2,
                             cCodoficina IN VARCHAR2, nReg_ini IN NUMBER, nReg_fin IN NUMBER) RETURN sys_refcursor IS
    l_cursor sys_refcursor;
    reg NUMBER;
    BEGIN

     /*  RETURN ACSEL.PR_KIMPUS.POLIZAS_PRE_RENOVAR (cCodinter,
                                                   cNombretomador,
                                                   cNumpoliza,
                                                   cCodoficina,
                                                   nReg_ini,
                                                   nReg_fin);*/

      if cNombretomador is not null then
            open l_cursor for
            select  *
            from (select
                  a.*, ROWNUM rnum
                  from (select descprod, oficina, numpol, tomador, idepol, sysdate
                        from pre_renovacion ren
                        where ren.codinter = cCodinter
                        and ren.tomador like  '%'||cNombretomador||'%'
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                        order by ren.numpol) a
                  where ROWNUM < (nReg_ini+nReg_fin))
            where rnum >=nReg_ini;
        else

            open l_cursor for
            select  *
            from (select
                  a.*, ROWNUM rnum
                  from (select descprod, oficina, numpol, tomador, idepol, sysdate
                        from pre_renovacion ren
                        where ren.codinter = cCodinter
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                        order by ren.numpol) a
                  where ROWNUM < (nReg_ini+nReg_fin))
            where rnum >=nReg_ini;

       end if;
    RETURN l_cursor;
    END;


FUNCTION total_polizas_pre_renovar(cCodinter IN VARCHAR2, cNombretomador IN VARCHAR2,cNumpoliza IN VARCHAR2,
                                   cCodoficina IN VARCHAR2) RETURN NUMBER is
  reg NUMBER:=0;
  BEGIN

   --  RETURN ACSEL.PR_KIMPUS.TOTAL_POLIZAS_PRE_RENOVAR(cCodinter, cNombretomador,cNumpoliza,cCodoficina);

    if cNombretomador is not null then
            select count(*)
            into reg
            from pre_renovacion ren
                        where ren.codinter = cCodinter
                        and ren.tomador like  '%'||cNombretomador||'%'
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                   order by ren.numpol;

        else
            select count(*)
            into reg
            from pre_renovacion ren
                        where ren.codinter = cCodinter
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                   order by ren.numpol;

        end if;

        RETURN reg;
    END;

FUNCTION obtener_planes_pre_renovar(cCodinter IN VARCHAR2, nIdepol IN NUMBER) RETURN sys_refcursor IS
    l_cursor sys_refcursor;
  BEGIN

    --RETURN ACSEL.PR_KIMPUS.OBTENER_PLANES_PRE_RENOVAR(cCodinter,nIdepol);

    open l_cursor for
         select descplan, codplan, revplan, prima, codprod, MCAPRENENOV
         from PLANES_ASEGURADOS_PRERENOV
         where codinter = cCodinter
         and idepol = nIdepol;
    return l_cursor;


  END;

  FUNCTION obtener_asegurado(cCodinter IN VARCHAR2, nIdepol IN NUMBER)
    return sys_refcursor is
    l_cursor sys_refcursor;
  begin

    --RETURN ACSEL.PR_KIMPUS.OBTENER_ASEGURADO(cCodinter, nIdepol);

    open l_cursor for
      select nombre, descprod, numpol, fecini, fecfin
        from ASEGURADOS_PRE_RENOVACION
       where codinter = cCodinter
         and idepol = nIdepol;
    return l_cursor;
  end;

  FUNCTION devuelve_oficinas RETURN sys_refcursor IS
    l_cursor sys_refcursor;
  BEGIN

    --RETURN ACSEL.PR_KIMPUS.DEVUELVE_OFICINAS;

    open l_cursor for
      select *
        from OFICINA;

    return l_cursor;
  END;

FUNCTION obtener_oberturas_planes(cCodinter IN VARCHAR2,
                                   nIdepol   IN NUMBER,
                                   cCodprod  IN varchar2,
                                   cCodplan  IN varchar2,
                                   cRevplan  IN varchar2)
   RETURN sys_refcursor IS
   l_cursor sys_refcursor;
 BEGIN

  --RETURN ACSEL.PR_KIMPUS.OBTENER_COBERTURAS_PLANES(cCodinter , nIdepol, cCodprod, cCodplan, cRevplan);-- no requiere intermediario

   open l_cursor for
     select descobert, sumaaseg, primacobert
       from cobert_plan_prerenov
      where codinter = cCodinter
        and idepol = nIdepol
        and codprod = cCodprod
        and codplan = cCodplan
        and revplan = cRevplan;
   return l_cursor;
 end;

FUNCTION pre_renovar(cCodinter IN VARCHAR2,
                     nIdepol NUMBER,
                     cCodprod VARCHAR2,
                     cCodplan VARCHAR2,
                     cCodrevplan VARCHAR2) RETURN boolean IS

BEGIN

   --RETURN ACSEL.PR_KIMPUS.MARCAR(cCodinter, nIdepol, cCodprod, cCodplan, cCodrevplan); -- no requiere cCodInter


  return true;

END;

 FUNCTION polizas_renovadas(cCodinter IN VARCHAR2,
                              cNombretomador IN VARCHAR2,
                              cNumpoliza IN VARCHAR2,
                              cCodoficina IN VARCHAR2,
                              nReg_ini IN NUMBER,
                              nReg_fin IN NUMBER) return sys_refcursor is
    l_cursor sys_refcursor;
    reg NUMBER;
    BEGIN

/*         RETURN ACSEL.PR_KIMPUS.POLIZAS_RENOVADAS(cCodinter,
                                                  cNombretomador,
                                                  cNumpoliza,
                                                  cCodoficina,
                                                  nReg_ini,
                                                  nReg_fin);
*/


        if cNombretomador is not null then
            open l_cursor for
            select  *
            from (select
                  a.*, ROWNUM rnum
                  from (select codprod, descprod, codofi, oficina, numpol, tomador, idepol
                        from renovacion ren
                        where ren.codinter = cCodinter
                        and ren.tomador like  '%'||cNombretomador||'%'
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                        order by ren.numpol) a
                  where ROWNUM < (nReg_ini+nReg_fin))
            where rnum >=nReg_ini;
        else

            open l_cursor for
            select  *
            from (select
                  a.*, ROWNUM rnum
                  from (select codprod, descprod, codofi, oficina, numpol, tomador, idepol
                        from renovacion ren
                        where ren.codinter = cCodinter
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                        order by ren.numpol) a
                  where ROWNUM < (nReg_ini+nReg_fin))
            where rnum >=nReg_ini;

       end if;

        return l_cursor;
    END;

FUNCTION total_polizas_renovadas(cCodinter IN VARCHAR2,
                                   cNombretomador IN VARCHAR2,
                                   cNumpoliza IN VARCHAR2,
                                   cCodoficina IN VARCHAR2) return NUMBER IS
  reg NUMBER:=0;
  BEGIN

/*  RETURN ACSEL.PR_KIMPUS.TOTAL_POLIZAS_RENOVADAS(cCodinter,
                                                 cNombretomador,
                                                 cNumpoliza,
                                                 cCodoficina);
*/

        if cNombretomador is not null then
            select count(*)
            into reg
            from renovacion ren
                        where ren.codinter = cCodinter
                        and ren.tomador like  '%'||cNombretomador||'%'
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                   order by ren.numpol;

        else
            select count(*)
            into reg
            from renovacion ren
                        where ren.codinter = cCodinter
                        AND ( ren.numpol = NVL(cNumpoliza,0) OR  NVL(cNumpoliza,0) = 0)
                        AND ( ren.codofi = NVL(cCodoficina,0) OR  NVL(cCodoficina,0) = 0)
                   order by ren.numpol;

        end if;

        return reg;
    END;


PROCEDURE polizas_no_renovar(cCodinter IN VARCHAR2, nIdpoliza IN NUMBER, cCodoficina IN VARCHAR2)is
BEGIN

 --ACSEL.PR_KIMPUS.POLIZAS_NO_RENOVAR(cCodinter, nIdpoliza, cCodoficina); -- Solo necesita el IDEPOL

     begin
         delete from renovacion
          where idepol = nIdpoliza
          and codofi = cCodoficina;
          commit;
        end;
END;
END;
/
