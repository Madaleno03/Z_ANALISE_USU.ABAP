*&---------------------------------------------------------------------*
*& Report Z_ANALISE_USU
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_ANALISE_USU.

* DECLARANDO A TABELA QUE IREI USAR
TABLES: USR02.

PARAMETERS: P_NAME TYPE USR02-BNAME.

* VALIDACAO DE PARAMETRO
IF P_NAME IS INITIAL.
  MESSAGE 'PREENCHA TODOS OS CAMPOS!' TYPE 'E'.
  ENDIF.

  TYPES: BEGIN OF TY_USU,
    BNAME      TYPE USR02-BNAME,
    TRDAT      TYPE USR02-TRDAT,
    LTIME      TYPE USR02-LTIME,
    LINE_COLOR TYPE CHAR4,
    END OF TY_USU.

* CRIANDO TABELA INTERNA
    DATA: T_USU TYPE TABLE OF TY_USU,
          T_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
          T_HEADER   TYPE SLIS_T_LISTHEADER.

* CRIANDO WORK AREA
    DATA: W_USU      TYPE TY_USU,
          W_LAYOUT   TYPE SLIS_LAYOUT_ALV,
          W_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
          W_HEADER   TYPE SLIS_LISTHEADER.


    START-OF-SELECTION.
    SELECT BNAME, TRDAT, LTIME
      FROM USR02
      INTO TABLE @T_USU.
      END-OF-SELECTION.

*  ESSA PARTE E PRA DESTACAR  A COR DA LINHA QUE O USUARIO NAO ACESSA O SAP A MAIS DE 30 DIAS
* CRIANDO VARIAVEL LOCAL
LOOP AT T_USU INTO W_USU.
    DATA(VL_NOLOG) = SY-DATUM - W_USU-TRDAT.

    IF W_USU-TRDAT IS NOT INITIAL AND VL_NOLOG > 30.
      W_USU-LINE_COLOR = 'C610'.
      ENDIF.
      MODIFY T_USU FROM W_USU.
ENDLOOP.



* CRIANDO ROTINA DE DADOS COM PERFORM
    PERFORM F_LAYOUT.
    PERFORM F_HEADER.
    PERFORM F_FIELDCAT.
    PERFORM F_DISPLAY.
*&---------------------------------------------------------------------*
*& Form F_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_layout .

  W_LAYOUT-ZEBRA = 'X'.
  W_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  W_LAYOUT-INFO_FIELDNAME = 'LINE_COLOR'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_header .

* CRIANDO O CABECALHO MANUALMENTE

* CRIANDO VARIAVEL LOCAL
  DATA: VL_DATA TYPE SY-DATUM,
        VL_HORA TYPE SY-UZEIT,
        VL_USER TYPE SY-UNAME.

* CHAMANDO AS VARIAVEIS DECLARADAS
  VL_DATA = SY-DATUM.
  VL_HORA = SY-UZEIT.
  VL_USER = SY-UNAME.

  WRITE: SY-DATUM TO VL_DATA DD/MM/YY.
  WRITE: SY-UZEIT TO VL_HORA.
  WRITE: SY-UNAME TO  VL_USER.

* PREENCHENDO O CABECALHO
  CLEAR W_HEADER.
  W_HEADER-TYP = 'H'.
  W_HEADER-INFO = 'Análise de usuários!'.
  APPEND W_HEADER TO T_HEADER.

  CLEAR W_HEADER.
  W_HEADER-TYP = 'S'.
  W_HEADER-KEY = 'DATA: '.
  W_HEADER-INFO = VL_DATA.
  APPEND W_HEADER TO T_HEADER.

  CLEAR W_HEADER.
  W_HEADER-TYP = 'S'.
  W_HEADER-KEY = 'HORÁRIO: '.
  W_HEADER-INFO = VL_HORA.
  APPEND W_HEADER TO T_HEADER.

  CLEAR W_HEADER.
  W_HEADER-TYP = 'S'.
  W_HEADER-KEY = 'USUÁRIO: '.
  W_HEADER-INFO = VL_USER.
  APPEND W_HEADER TO T_HEADER.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary       = T_HEADER.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_fieldcat .

* MONTANDO O FIELDCAT MANUALENTE

CLEAR W_FIELDCAT .
W_FIELDCAT-FIELDNAME = 'BNAME'.
W_FIELDCAT-SELTEXT_M = 'Nome do usuário'.
W_FIELDCAT-COL_POS   = 1.
APPEND W_FIELDCAT TO T_FIELDCAT.

CLEAR W_FIELDCAT .
W_FIELDCAT-FIELDNAME = 'TRDAT'.
W_FIELDCAT-SELTEXT_M = 'Último logon'.
W_FIELDCAT-COL_POS   = 2.
APPEND W_FIELDCAT TO T_FIELDCAT.

CLEAR W_FIELDCAT .
W_FIELDCAT-FIELDNAME = 'LTIME'.
W_FIELDCAT-SELTEXT_M = 'Horário do último logon'.
W_FIELDCAT-COL_POS   = 3.
APPEND W_FIELDCAT TO T_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_display .

* CRIANDO O RELATORIO QUE IRA APARECER PRO USUARIO
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
   EXPORTING
     I_CALLBACK_PROGRAM                = 'SY-REPID'
     I_CALLBACK_TOP_OF_PAGE            = 'T_HEADER'
*     I_STRUCTURE_NAME                  =
     IS_LAYOUT                         = W_LAYOUT
     IT_FIELDCAT                       = T_FIELDCAT
     I_DEFAULT                         = 'X'
     I_SAVE                            = 'X'
    TABLES
      t_outtab                          = T_USU.
  IF sy-subrc <> 0.
    MESSAGE 'ERRO AO EXIBIR O ALV!' TYPE 'E'.
  ENDIF.


ENDFORM.