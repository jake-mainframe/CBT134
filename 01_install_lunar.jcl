//LUNAR JOB (SYS),'INSTALL LUNAR',CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             USER=IBMUSER,PASSWORD=SYS1,REGION=2048K
//ASM     EXEC PGM=IFOX00,PARM='NODECK,LOAD,TERM'
//SYSGO    DD  DSN=&&LOADSET,DISP=(MOD,PASS),SPACE=(CYL,(1,1)),
//             UNIT=VIO,DCB=(DSORG=PS,RECFM=FB,LRECL=80,BLKSIZE=800)
//SYSLIB   DD  DSN=SYS1.MACLIB,DISP=SHR
//SYSTERM  DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSPUNCH DD  DSN=NULLFILE
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT2   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSUT3   DD  UNIT=VIO,SPACE=(CYL,(6,1))
//SYSIN    DD  *
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
LLS      TITLE 'L U N A R -- LUNAR LANDING SIMULATION'
         SPACE 1
        PRINT  OFF
         MACRO
&NAME   #CALL  &WHERE
         AIF   ('&WHERE' NE '').W1
         MNOTE 8,'--- "WHERE" OPERAND MISSING ---'
         MEXIT
.W1      AIF   ('&WHERE'(1,1) EQ '(').W2
&NAME    L     R15,=A(&WHERE)      GET ENTRY POINT
         AGO   .W3
.W2      AIF   ('&WHERE' EQ '(15)').W4
         AIF   ('&WHERE' EQ '(R15)').W4
&NAME    LR    R15,&WHERE          SET ENTRY POINT
.W3      BASR  R14,R15             GO TO ROUTINE
         MEXIT
.W4      ANOP
&NAME    BASR  R14,R15             GO TO ROUTINE
         MEND
         MACRO
&NAME   #DSP   &A,&N
&NAME    BAS   R14,&A
         NOP   &N*4
         MEND
         MACRO
&NAME   #XENT  &DUMMY
         CNOP  0,8
&NAME    STM   R14,R12,12(R13)     SAVE REGISTERS
         B     16(,R15)            BRANCH AROUND ID
         DC    CL8'&NAME'          IDENTIFIER
         LR    R8,R15              SET BASE REGISTER
         USING &NAME,R8            SET ADDRESSABILITY
         LR    R15,R13             PREVIOUS SAVE AREA
         LA    R13,18*4(R13)       NEW CURRENT SAVE AREA
         ST    R13,8(R15)          LINK SAVE AREAS
         ST    R15,4(R13)
         SPACE 1
         MEND
         MACRO
&NAME   #XRET  &RC=
&NAME    L     R13,4(R13)          PREVIOUS SAVE AREA
         AIF   ('&RC' EQ '').N1
         AIF   ('&RC'(1,1) EQ '(').N2
         AIF   ('&RC' NE '0').N3
.N1      XR    R15,R15             SET RC=0
         ST    R15,16(R13)         STORE IT (R15)
         AGO   .N4
.N2      ST    &RC(1),16(R13)      STORE RC (R15)
         AGO   .N4
.N3      MVC   16(4,R13),=AL4(&RC) SET RC (R15)
.N4      LM    R14,R12,12(R13)     RESTORE REGISTERS
         MVI   12(R13),X'FF'       SET RETURN INDICATOR
         BR    R14                 RETURN
         SPACE 1
         MEND
         MACRO
        #XEND  &DUMMY
        LTORG  ,                   LITERALS
         SPACE 1
         DROP  R8                  END OF LOCAL ADDRESSABILITY
         MEND
        PRINT  ON
         SPACE 1
LUNAR    START 0
         SPACE 1
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*
*   LUNAR :    LUNAR LANDING SIMULATION.                              *
*   AUTHOR :   UNKNOWN (ORIGINAL MODULE WAS IN FORTRAN)               *
*              FULL SCREEN BY : MOINIL P.A.                           *
*                               COMPUTING CENTRE                      *
*                               J.R.C. - ISPRA ESTABLISHMENT          *
*                               21020 ISPRA (VA), ITALY               *
*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*
         SPACE 1
        PRINT  NOGEN
        $DEFREG
*------- MAIN ENTRY, INITIALIZE
         SPACE 1
        $XENT  BASE=(R11,R12),LV=DATALEN,TYPE=RENT
         LR    R9,R13              SET DATA ADDRESSABILITY
         USING DATA,R9
         MVC   EXTR(LEXTR),EXTRP
        EXTRACT ATSO,'S',FIELDS=(TSO),MF=(E,EXTR)
         L     R2,ATSO
         TM    0(R2),X'80'
         BZ    NOTTSO              WE ARE'NT IN TSO
         XC    EXTR(LEXTR),EXTR
        GTSIZE ,
         LTR   R15,R15
         BNZ   ERGTSZ              ERROR RETURN CODE
         LTR   R15,R0
         BZ    NDTERM              NOT DISPLAY TERMINAL
         CL    R1,=F'80'           TEST LINE LENGTH
         BE    TSTSC
         CL    R1,=F'132'
         BNE   NDTERM
         CL    R0,=F'27'           TEST NUMBER OF LINES
         BNE   NDTERM
         B     SETSCT
TSTSC    CL    R0,=F'24'
         BE    SETSCT
         CL    R0,=F'32'
         BE    SETSCT
         CL    R0,=F'43'
         BNE   NDTERM
SETSCT   OI    FLAGS,SCTERM
         B     NDTERM+L'NDTERM
NDTERM   NI    FLAGS,255-SCTERM
         XC    LIST0(5*4),LIST0    RESET LIST
         LA    R1,REPLY            WHERE TO REPLY
         ST    R1,LIST0+2*4        INTO LIST
         LA    R1,L'REPLY          READ LENGTH
         ST    R1,LIST0+3*4        INTO LIST
         SPACE 1
*------- ASK USER WANT INSTRUCTIONS
         SPACE 1
REINM    LA    R1,INMSG            INITIAL MESSAGE
         LA    R0,L'INMSG          LENGTH
        #DSP   DSPLAY,0            SEND THE MESSAGE        CALL FS = 0
         L     R0,LIST0+4*4        GET READ LENGTH
         LTR   R0,R0               NULL?
         BNP   NEWGAME             YES, BYPASS INSTRUCTIONS
         CLI   REPLY,C'N'
         BE    NEWGAME             NO, BYPASS INSTRUCTIONS
         CLI   REPLY,C'Y'
         BNE   REINM
         LA    R1,EXMSG            INSTRUCTIONS MESSAGE
         LA    R0,LEXMSG           LENGTH
         MVC   SVRDP(L'SVRDP),LIST0+2*4 SAVE REPLY ADDRESS/LENGTH
         XC    LIST0+2*4(2*4),LIST0+2*4 NO READ
        #DSP   DSPLAY,1            SEND THE MESSAGE        CALL FS = 1
         MVC   LIST0+2*4(L'SVRDP),SVRDP RESTORE REPLY ADDRESS/LENGTH
         SPACE 1
*------- START LANDING
         SPACE 1
NEWGAME  LA    R1,ONMSG            NEW LANDING MESSAGE
         LA    R0,LONMSG           LENGTH
         MVC   SVRDP(L'SVRDP),LIST0+2*4 SAVE REPLY ADDRESS/LENGTH
         XC    LIST0+2*4(2*4),LIST0+2*4 NO READ
        #DSP   DSPLAY,2            SEND THE MESSAGE        CALL FS = 2
         MVC   LIST0+2*4(L'SVRDP),SVRDP RESTORE REPLY ADDRESS/LENGTH
         XC    $T,$T               T = 0
         MVC   $H,=F'5000'         H = 500.0
         MVC   $V,=F'500'          V = 50.0
         MVC   $F,=F'120'          F = 120
         SPACE 1
*------- EXECUTE LANDING
         SPACE 1
LOOP     BAS   R6,PRPLOT
         LA    R1,WLNE             STATUS MESSAGE
         LA    R0,L'WLNE           LENGTH
        #DSP   DSPLAY,3            SEND THE MESSAGE        CALL FS = 3
         L     R3,LIST0+4*4        GET READ LENGTH
         XR    R0,R0               SET ZERO
         LTR   R3,R3               NULL?
         BNP   PRCVL               YES, SET AS ZERO
         LA    R4,REPLY
         LA    R2,1
         LA    R3,REPLY-1(R3)
         CLI   0(R4),C' '
         BNE   *+L'*+8
         BXLE  R4,R2,*-8
         B     PRCVL               NONE, SET AS ZERO
         LR    R1,R0
         LA    R15,15
CSCAN    CLI   0(R4),C'0'
         BL    PRBAD               BAD VALUE SPECIFIED
         CLI   0(R4),C'9'
         BH    PRBAD               BAD VALUE SPECIFIED
         IC    R1,0(R4)
         NR    R1,R15
         LTR   R0,R0
         BNP   *+L'*+4
         MH    R0,=H'10'
         AR    R0,R1
         CH    R0,=H'30'
         BNH   *+L'*+10
PRBAD    MVC   WLNE,BLANKS         BAD VALUE SPECIFIED
         B     LOOP+L'LOOP
         BXLE  R4,R2,*+L'*+4
         B     PRCVL
         CLI   0(R4),C' '
         BNE   CSCAN
PRCVL    LTR   R2,R0
         BZ    *+L'*+12
         CL    R2,$F
         BNH   *+L'*+4
         L     R2,$F
CYCLE    L     R5,$F               (R5) F = F - B
         SR    R5,R2
         ST    R5,$F
         LTR   R2,R2
         BZ    *+L'*+4
         MH    R2,=H'10'
         ST    R2,$B               (R2) B
         L     R3,=F'50'           (R3) V1 = V + 5 - B
         SR    R3,R2
         ST    R3,$W1              W1 = 5 - B
         A     R3,$V
         ST    R3,$V1
         L     R1,$V               (R4) H = H - ((V + V1)/2)
         AR    R1,R3
         BZ    *+L'*+10
         XR    R0,R0
         M     R0,=F'1'
         D     R0,=F'2'
         ST    R1,$W2              W2 = (V + V1)/2
         L     R4,$H
         SR    R4,R1
         ST    R4,$H
         BNP   TCHDWN
         ST    R3,$V               V = V1
         L     R0,$T               T = T + 1
         A     R0,=F'1'
         ST    R0,$T
         LTR   R5,R5               F ?
         BP    LOOP
         MVC   SVRDP(L'SVRDP),LIST0+2*4 SAVE REPLY ADDRESS/LENGTH
         XC    LIST0+2*4(2*4),LIST0+2*4 NO READ
         LTR   R2,R2               B ?
         BZ    NOTOFF
         LA    R1,OFMSG            OFF MESSAGE
         LA    R0,L'OFMSG          LENGTH
        #DSP   DSPLAY,4            SEND THE MESSAGE        CALL FS = 4
NOTOFF   BAS   R6,PRPLOT
         LA    R1,WLNE             STATUS MESSAGE
         LA    R0,L'WLNE           LENGTH
        #DSP   DSPLAY,3            SEND THE MESSAGE        CALL FS = 3
         MVC   LIST0+2*4(L'SVRDP),SVRDP RESTORE REPLY ADDRESS/LENGTH
         XR    R2,R2               (R2) B = 0
         B     CYCLE
         SPACE 1
*------- LANDING TERMINATED
         SPACE 1
TCHDWN   MVC   SVRDP(L'SVRDP),LIST0+2*4 SAVE REPLY ADDRESS/LENGTH
         XC    LIST0+2*4(2*4),LIST0+2*4 NO READ
         MVC   WLNE,BLANKS
         MVC   WLNE+1(22),=CL22'---------- CONTACT ---'
         L     R0,$H
         LTR   R0,R0
         BM    *+L'*+8
         MVI   WLNE+25,C'*'
         B     *+L'*+4
         MVI   WLNE+24,C'?'
         LA    R1,WLNE             STATUS MESSAGE
         LA    R0,L'WLNE           LENGTH
        #DSP   DSPLAY,3            SEND THE MESSAGE        CALL FS = 3
         L     R4,$H               H = H + ((V + V1)/2)
         A     R4,$W2
         ST    R4,$H
         L     R0,$B               B - 5 ?
         S     R0,=F'50'
         BZ    SKPT1
         L     R1,$W1
         A     R1,$W1              D = (SQRT((V*V) + H*(2*W1))-V) / W1
         XR    R0,R0
         M     R0,$H
         XR    R2,R2
         L     R3,$V
         M     R2,$V
         AR    R1,R3
         XR    R0,R0
         LTR   R1,R1
         BNP   SQROK
         L     R0,$V
         CLR   R1,R3
         BE    SQROK
         BL    SQRLOW
SQRHIGH  A     R0,=F'10'
         LR    R3,R0
         XR    R2,R2
         MR    R2,R0
         CLR   R1,R3
         BE    SQROK
         BH    SQRHIGH
         S     R0,=F'10'
         B     SQROK
SQRLOW   S     R0,=F'10'
         LR    R3,R0
         XR    R2,R2
         MR    R2,R0
         CLR   R1,R3
         BE    SQROK
         BL    SQRLOW
SQROK    LR    R1,R0
         S     R1,$V
         XR    R0,R0
         M     R0,=F'10'
         D     R0,$W1              (R1) = D
         B     SKPT2
SKPT1    XR    R0,R0               D = H / V
         L     R1,$H
         M     R0,=F'10'
         D     R0,$V               (R1) = D
SKPT2    L     R3,$W1              V1 = V + (W1 * D)
         XR    R2,R2
         MR    R2,R1
         CL    R3,=F'10'
         BNL   *+L'*+6
         XR    R3,R3
         B     *+L'*+4
         D     R2,=F'10'
         A     R3,$V
         ST    R3,$V1
         L     R0,$T               T = T + D
         MH    R0,=H'10'
         AR    R0,R1
         BAS   R14,EDTVLD
         MVC   F1MSG+13(5),EDWRK+L'EDWRK-5
         L     R0,$V1
         BAS   R14,EDTVLD
         MVC   F1MSG+47(6),EDWRK+L'EDWRK-6
         L     R0,$F
         BAS   R14,EDTVAL
         MVC   F1MSG+109(3),EDWRK+L'EDWRK-3
         LA    R1,F1MSG            FINAL MESSAGE
         LA    R0,LF1MSG           LENGTH
        #DSP   DSPLAY,4            SEND THE MESSAGE        CALL FS = 4
         L     R1,$V1
         LTR   R0,R1               V1 ?
         BZ    *+L'*+14
         BP    *+L'*+2
         LPR   R0,R0
         S     R0,=F'20'           ABS(V1) - 2 ?
         BNM   SKPT3
         LA    R1,F2MSG            FINAL MESSAGE
         LA    R0,L'F2MSG          LENGTH
        #DSP   DSPLAY,4            SEND THE MESSAGE        CALL FS = 4
         B     SKRST
SKPT3    XR    R0,R0               X = V1 / 2
         M     R0,=F'1'
         D     R0,=F'2'            (R1) = X
         LR    R0,R1
         BAS   R14,EDTVLD
         MVC   F3MSG+22(6),EDWRK+L'EDWRK-6
         LA    R1,F3MSG            FINAL MESSAGE
         LA    R0,LF3MSG           LENGTH
        #DSP   DSPLAY,4            SEND THE MESSAGE        CALL FS = 4
SKRST    MVC   LIST0+2*4(L'SVRDP),SVRDP RESTORE REPLY ADDRESS/LENGTH
REAMM    LA    R1,AMMSG            ASK FOR ANOTHER MISSION
         LA    R0,L'AMMSG          LENGTH
        #DSP   DSPLAY,5            SEND THE MESSAGE        CALL FS = 5
         L     R0,LIST0+4*4        GET READ LENGTH
         LTR   R0,R0               NULL?
         BNP   REAMM               YES, ASK AGAIN
         CLI   REPLY,C'Y'          NEW GAME?
         BE    NEWGAME             YES, GO TO IT
         CLI   REPLY,C'N'          NO?
         BNE   REAMM               ASK AGAIN
         TM    FLAGS,SCTERM        FULL SCREEN?
         BZ    QUIT                NO
LEAVE    MVI   OPTFS,FSEXIT        YES
        @FS    OPTFS,MF=(E,FSPARM)
         LR    R10,R15             RETAIN RETURN CODE
         XR    R0,R0
         ICM   R0,B'0011',ERRMSL
         BZ    NOMSGE
        TPUT   MSWRK,(0)
NOMSGE   LTR   R10,R10
         BZ    QUIT
         MVC   MSWRK(L'ERRMS2),ERRMS2
         CVD   R10,DBLW
         MVC   MSWRK+29(4),=XL4'40202120'
         ED    MSWRK+29(4),DBLW+L'DBLW-2
         XR    R0,R0
         IC    R0,OPTFS
         STC   R0,MSWRK+21
         SRL   R0,4
         STC   R0,MSWRK+20
         NC    MSWRK+20(2),=XL2'0F0F'
         TR    MSWRK+20(2),HEXTB
        TPUT   MSWRK,L'ERRMS2
         B     QUIT
         SPACE 1
*------- ERROR MESSAGE, EXIT
         SPACE 1
NOTTSO  TPUT   ERRMS0,L'ERRMS0
         B     QUIT
ERGTSZ   MVC   MSWRK(L'ERRMS1),ERRMS1
         MVC   MSWRK+5(6),=CL6'GTSIZE'
         CVD   R15,DBLW
         MVC   MSWRK+19(4),=XL4'40202120'
         ED    MSWRK+19(4),DBLW+L'DBLW-2
SHTDWN  TPUT   MSWRK,L'ERRMS1
         SPACE 1
*------- WHEN DONE, EXIT
*        IF USER IS THROUGH, EXIT
         SPACE 1
QUIT    $XRET  CC=0,LV=DATALEN,TYPE=RENT
         EJECT
*======= EDTVAL : EDIT VALUE ROUTINES
*                 INPUT - R0  = BINARY VALUE
*                         R14 = RETURN ADDRESS
*                         R15 = WORK REGISTER
*                 OUTPUT - EDWRK = EDITED VALUE (RIGHT JUSTIFIED)
         SPACE 1
EDTVLD   LTR   R15,R0
         BNM   *+L'*+2
         LPR   R15,R15
         MVC   EDWRK,=XL8'4040202021204B20'
         CVD   R15,DBLW
         ED    EDWRK,DBLW+L'DBLW-3
         LTR   R0,R0
         BNMR  R14
         LA    R15,EDWRK+L'EDWRK-3
         BCTR  R15,0
         CLI   0(R15),C' '
         BNE   *-6
         MVI   0(R15),C'-'
         BR    R14                 RETURN
         SPACE 1
EDTVAL   LTR   R15,R0
         BNM   *+L'*+2
         LPR   R15,R15
         MVC   EDWRK,=XL8'4040402020202120'
         CVD   R15,DBLW
         ED    EDWRK,DBLW+L'DBLW-3
         LTR   R0,R0
         BNMR  R14
         LA    R15,EDWRK+L'EDWRK-1
         BCTR  R15,0
         CLI   0(R15),C' '
         BNE   *-6
         MVI   0(R15),C'-'
         BR    R14                 RETURN
         SPACE 1
*======= PRPLOT : PREPARE PLOT LINE
*                 INPUT - R6  = RETURN ADDRESS
*                         R14 = LINK USED
         SPACE 1
PRPLOT   MVC   WLNE,BLANKS
         L     R0,$T
         BAS   R14,EDTVAL
         MVC   WLNE+1(3),EDWRK+L'EDWRK-3
         L     R0,$H
         BAS   R14,EDTVLD
         MVC   WLNE+5(6),EDWRK+L'EDWRK-6
         L     R0,$V
         BAS   R14,EDTVLD
         MVC   WLNE+12(6),EDWRK+L'EDWRK-6
         L     R0,$F
         BAS   R14,EDTVAL
         MVC   WLNE+20(3),EDWRK+L'EDWRK-3
         MVI   WLNE+25,C'+'
         XR    R0,R0
         L     R1,$H
         CL    R1,=F'100'
         BNL   *+L'*+6
         LR    R1,R0
         B     *+L'*+16
         D     R0,=F'100'
         CL    R0,=F'50'
         BL    *+L'*+4
         A     R1,=F'1'
         CL    R1,=F'50'
         BH    *+L'*+10
         LA    R1,WLNE+26(R1)
         MVI   0(R1),C'*'
         BR    R6                  RETURN
         MVI   WLNE+77,C'?'
         BR    R6                  RETURN
         SPACE 1
*======= DSPLAY : DISPLAY AND EVENTUALLY READ ROUTINE
*                 INPUT - R0  = LENGTH OF DISPLAY SCREEN
*                         R1  = ADDRESS OF DISPLAY
*                         R14 = RETURN ADDRESS
         SPACE 1
DSPLAY   MVC   REPLY(L'REPLY),BLANKS NOTHING READ YET
         ST    R1,LIST0            SAVE SCREEN ADDR
         ST    R0,LIST0+4          AND LENGTH
         TM    FLAGS,SCTERM        FULL SCREEN?
         BZ    NOTFS               NO
         ST    R14,SVR14           YES, SAVE RETURN AROUND CALL
        #CALL  DOFS
         L     R14,SVR14           RESTORE RETURN AFTER CALL
         CH    R15,=H'4'           WHERE GO?
         BE    SHTDWN              +4 - ERROR, MESSAGE AND EXIT
         BH    LEAVE               +8 - ERROR, MESSAGE AND EXIT
         CLI   REPLY,C'E'          +0 - OK, END?
         BE    LEAVE               YES
         BR    R14                 NO, RETURN
NOTFS    STM   R14,R12,12(R13)     SAVE HIS REGS
         L     R3,LIST0            GET BUFFER LOCATION
         L     R4,LIST0+4          GET LENGTH TO DISPLAY
TPLOOP   LA    R0,80               ASSUME FULL LINE
         CR    R4,R0               JUST THIS LINE?
         BH    *+L'*+2             YES
         LR    R0,R4               ELSE DO REMAINDER
         LA    R1,0(R3)            GET ADDRESS
        TPUT   (1),(0),R           DUMP THE LINE
         LA    R3,80(R3)           NEXT LINE
         SH    R4,=H'80'           GET REMAINING LENGTH
         BP    TPLOOP              YES, CONTINUE
         OC    LIST0+2*4(2*4),LIST0+2*4 READ?
         BZ    TSOXT               NO
         L     R1,LIST0+2*4        GET READ ADDRESS
         L     R0,LIST0+3*4        GET LENGTH
         O     R1,=X'80000000'     TGET
        TGET   (1),(0),R           READ
         ST    R1,LIST0+4*4        AND SAVE RETURNED LENGTH
TSOXT    LM    R14,R12,12(R13)     RESTORE REGS
         OC    REPLY(L'REPLY),BLANKS MAKE IT UPPER CASE
         CLI   REPLY,C'E'          END?
         BE    QUIT                YES
         BR    R14                 RETURN
         EJECT
*- - - - C O N S T A N T S - - - - - - - - - - - - - - - - - - - - - -*
         SPACE 1
EXTRP   EXTRACT *-*,'S',MF=L
HEXTB    DC    CL16'0123456789ABCDEF'
         SPACE 1
*------- MESSAGES
         SPACE 1
INMSG    DC    C'LUNAR LANDING SIMULATION. DO YOU WANT INSTRUCTIONS ? (X
               Y/N)'
EXMSG    DC    CL80'YOU ARE LANDING ON THE MOON AND HAVE TAKEN OVER MANX
               UAL CONTROL 500 FEET ABOVE'
         DC    CL80'A GOOD LANDING SPOT. YOU HAVE A DOWNWARD VELOCITY OX
               F 50 FT/SEC. AND 120 UNITS'
         DC    CL80'OF FUEL REMAIN. EACH UNIT OF FUEL EXPENDED WILL SLOX
               W YOUR DESCENT BY 1 FT/SEC.'
         DC    C'THE MAXIMUM THRUST OF YOUR ENGINE IS 30 FT/SEC. OR 30 X
               UNITS OF FUEL.'
LEXMSG   EQU   *-EXMSG
ONMSG    DC    CL80'ONBOARD COMPUTER FAILURE TAKE OVER MANUAL CONTROL.'
         DC    CL80'ENTER BURN VALUE (0-30 FUEL UNITS).'
BLANKS   DC    CL80' '
TLMSG    DC    C' SEC   FEET  SPEED FUEL PLOT'
LONMSG   EQU   *-ONMSG
AMMSG    DC    C'ANOTHER MISSION ? (Y/N)'
OFMSG    DC    C' ****** OUT OF FUEL ***'
F1MSG    DC    CL80'TOUCHDOWN AT ..... SECONDS - LANDING VELOCITY =    X
                   FT/SEC.'
         DC    C'                                  UNITS OF FUEL REMAINX
               ING'
LF1MSG   EQU   *-F1MSG
F2MSG    DC    C'CONGRATULATIONS, A PERFECT LANDING.'
F3MSG    DC    CL80'YOU PRODUCED A CRATER        FEET DEEP.'
         DC    C'SORRY YOU BLEW IT, CONDOLENCES SENT TO NEXT OF KIN.'
LF3MSG   EQU   *-F3MSG
ERRMS0   DC    C' => NOT OUTSIDE TSO ENVIRONMENT | BYE-BYE'
ERRMS1   DC    C' => "      " - RC = ... - EXIT -'
ERRMS2   DC    C' => "FSRTN" - OPT = .. , RC = ... - EXIT -'
         EJECT
*------- LITERALS
         SPACE 1
        LTORG
         EJECT
*- - - - D O     F U L L     S C R E E N - - - - - - - - - - - - - - -*
         SPACE 1
DOFS    #XENT  ,
         XR    R10,R10
         TM    SWFSW,SW1ST
         BO    DOFSW
        @FSI   ,
         LTR   R15,R15
         BNZ   DOFIMM
         OI    OPTFS,FSSKIP
         LM    R2,R3,INITRA
        @FS    OPTFS,(R2),(R3),MF=(E,FSPARM)
         LTR   R15,R15
         BNZ   DOFERR
         OI    SWFSW,SW1ST
DOFSW    LM    R2,R3,LIST0
         CH    R3,=H'80'
         BNH   *+L'*+22
         CLC   0(80,R2),BLANKS
         BNE   *+L'*+12
         LA    R2,80(R2)
         SH    R3,=H'80'
         B     DOFSW+L'DOFSW
         STM   R2,R3,DFSTL
         XR    R7,R7
         L     R1,SVR14
         ICM   R7,B'0011',2(R1)    GET CALL FS NUMBER
         CL    R7,=A(DOFSMX)
         BNL   DOFVER
         B     DOFSV(R7)
DOFSV    B     DOFS0
         B     DOFS1
         B     DOFS2
         B     DOFS3
         B     DOFS4
         B     DOFS5
DOFSMX   EQU   *-DOFSV
DOFS0    L     R1,=A(FSMS)
         BAS   R14,DOFSRZ
         LA    R0,6
         L     R1,=A(FSMS)
         BAS   R7,DOFSMV
         NI    OPTFS,255-FSSKIP
         BAS   R7,DOFSTM
         B     DOFSX
DOFS1    L     R1,=A(FSMS)
         BAS   R14,DOFSRZ
         LA    R0,6
         L     R1,=A(FSMS)
         BAS   R7,DOFSMV
         OI    SWFSW,SWNMS
         B     DOFSX
DOFS2    TM    SWFSW,SWNMS
         BO    *+L'*+8
         L     R1,=A(FSMS)
         BAS   R14,DOFSRZ
         L     R1,=A(FSGS)
         BAS   R14,DOFSRZ
         BAS   R14,DOFSRZ
         L     R2,DFSTL
         LA    R3,80
         LA    R0,6
         L     R1,=A(FSMS)
         BAS   R7,DOFSMV+L'DOFSMV
         L     R1,=A(FSGI)
         MVC   0(L'FSGI,R1),80(R2)
         L     R1,=A(FSGT)
         MVC   0(80,R1),BLANKS
         MVC   0(L'TLMSG,R1),3*80(R2)
         OI    SWFSW,SWNMS
         NI    SWFSW,255-SWHMS
         B     DOFSX
DOFS3    TM    SWFSW,SWNMS+SWHMS
         BNZ   *+L'*+8
         L     R1,=A(FSMS)
         BAS   R14,DOFSRZ
         L     R1,=A(FSGL)
         CLC   0(80,R1),BLANKS
         BE    DOFS3A
         L     R2,=A(FSGS)
         L     R5,=A(11*80+X'40000000')
         LA    R3,0(R5)
         LA    R4,80(R2)
         MVCL  R2,R4
         B     DOFS3B
DOFS3A   L     R1,=A(FSGS)
         CLC   0(80,R1),BLANKS
         BE    DOFS3B
         LA    R1,80(R1)
         B     DOFS3A+L'DOFS3A
DOFS3B   L     R2,DFSTL
         MVC   0(80,R1),0(R2)
         OC    LIST0+2*4(2*4),LIST0+2*4
         BZ    *+L'*+8
         NI    OPTFS,255-FSSKIP
         B     *+L'*+4
         OI    OPTFS,FSSKIP
         BAS   R7,DOFSTM
         NI    SWFSW,255-SWNMS
         B     DOFSX
DOFS4    LA    R0,6
         L     R1,=A(FSMS)
         BAS   R7,DOFSMV
         L     R1,=A(FSGI)
         MVC   0(L'FSGI,R1),BLANKS
         OI    SWFSW,SWHMS
         B     DOFSX
DOFS5    L     R1,=A(FSGI)
         MVC   0(L'FSGI,R1),BLANKS
         LM    R2,R3,DFSTL
         BCT   R3,*+L'*+6
         MVC   0(*-*,R1),0(R2)          << EXECUTED >>
         EX    R3,*-6
         NI    OPTFS,255-FSSKIP
         BAS   R7,DOFSTM
         B     DOFSX
         SPACE 1
DOFSRZ   LA    R0,6                          R14 = LINK REGISTER
         MVC   0(80,R1),BLANKS
         LA    R1,80(R1)
         BCT   R0,*-10
         BR    R14
DOFSMV   LM    R2,R3,DFSTL                   R7 = LINK REGISTER
DOFSMV1  CLC   0(80,R1),BLANKS
         BNE   DOFSMV2
         CH    R3,=H'80'
         BNH   DOFSMV3
         MVC   0(80,R1),0(R2)
         SH    R3,=H'80'
         LA    R2,80(R2)
DOFSMV2  LA    R1,80(R1)
         BCT   R0,DOFSMV1
         BR    R7
DOFSMV3  BCT   R3,*+L'*+6
         MVC   0(*-*,R1),0(R2)          << EXECUTED >>
         EX    R3,*-6
         BR    R7
DOFSTM   LM    R2,R3,FSCRA                   R7 = LINK REGISTER
        @FS    OPTFS,(R2),(R3),MF=(E,FSPARM)
         LTR   R15,R15
         BNZ   DOFERR
         XC    LIST0+4*4(4),LIST0+4*4
         TM    OPTFS,FSSKIP
         BOR   R7
         OC    LIST0+2*4(2*4),LIST0+2*4 NO READ?
         BZR   R7
         LM    R2,R3,LIST0+2*4
         BASR  R4,0
         LA    R5,C' '
         SLL   R5,24
         MVCL  R2,R4
         LTR   R1,R1
         BZ    DOFSTM1
         CLI   0(R1),X'F3'         PF-KEY 3?
         BE    *+L'*+8
         CLI   0(R1),X'C3'         PF-KEY 15 (ALT. 3)?
         BNE   DOFSTM1
         L     R2,LIST0+2*4
         MVC   0(3,R2),=CL3'END'
         LA    R2,3
         ST    R2,LIST0+4*4
         BR    R7
DOFSTM1 @FSR   ,
         LTR   R15,R15
         BZR   R7
         LTR   R1,R1
         BNPR  R7
         L     R2,LIST0+2*4
DOFSTM2  OC    0(1,R2),3(R15)
         CLI   0(R2),C' '
         BNE   DOFSTM3
         LA    R15,1(R15)
         BCT   R1,DOFSTM2
         BR    R7
DOFSTM3  LR    R0,R2
         LA    R2,1(R2)
         LA    R15,1(R15)
         BCT   R1,*+L'*+4
         B     *+L'*+10
         OC    0(1,R2),3(R15)
         B     DOFSTM3+L'DOFSTM3
         SR    R2,R0
         ST    R2,LIST0+4*4
         BR    R7
         SPACE 1
DOFIMM   MVC   MSWRK(L'ERRMS1),ERRMS1
         MVC   MSWRK+5(6),=CL6'FSRTNI'
         CVD   R15,DBLW
         MVC   MSWRK+19(4),=XL4'40202120'
         ED    MSWRK+19(4),DBLW+L'DBLW-2
         LA    R10,4
         B     DOFSX
DOFERR   MVC   MSWRK(L'ERRMS2),ERRMS2
         CVD   R15,DBLW
         MVC   MSWRK+29(4),=XL4'40202120'
         ED    MSWRK+29(4),DBLW+L'DBLW-2
         XR    R0,R0
         IC    R0,OPTFS
         STC   R0,MSWRK+21
         SRL   R0,4
         STC   R0,MSWRK+20
         NC    MSWRK+20(2),=XL2'0F0F'
         TR    MSWRK+20(2),HEXTB
         LA    R0,L'ERRMS2
         B     DOFERX
DOFVER   MVC   MSWRK(L'DOFMSE),DOFMSE
         SRL   R7,2
         CVD   R7,DBLW
         MVC   MSWRK+21(6),=XL6'402020202120'
         ED    MSWRK+21(6),DBLW+L'DBLW-3
         LA    R0,L'DOFMSE
DOFERX   STH   R0,ERRMSL
         LA    R10,8
DOFSX   #XRET  RC=(R10)
INITRA   DC    A(INITR,*+4,INITRL)
FSCRA    DC    A(FSCR,*+4,FSCRL)
DOFMSE   DC    C' => "DOFS" - NUMBER = ..... - EXIT -'
         SPACE 1
        #XEND  ,
         SPACE 1
         DROP  R9,R11,R12          KILL ALL ADDRESSABILITIES
         EJECT
*- - - - S C R E E N     D A T A - - - - - - - - - - - - - - - - - - -*
         SPACE 1
INITR   $FS    CC=EW,WCC=(AL,RMDT),SBA=(24,79),MF=L
        $FS    SBA=(1,1),RA=(1,1,00),MF=L
        $FS    SBA=(1,1),SF=(IC),MF=L
INITRL   EQU   *-INITR
         SPACE 1
FSCR    $FS    CC=EW,WCC=(KBR,RMDT),SBA=(1,1),RA=(1,1,00),MF=L
        $FS    SBA=(1,1),SF=(PROT,INT),MF=L
        $FS    SBA=(1,22),MF=L
        $FS    TEXT='L U N A R -- LUNAR LANDING SIMULATION',MF=L
        $FS    SBA=(2,1),SF=(PROT,INT),RA=(2,80,-),MF=L
        $FS    SF=(PROT),MF=L
FSGT    $FS    TEXT=(' ',80),MF=L       T -> (3,1)
FSGS    $FS    TEXT=(' ',80),MF=L       1 -> (4,1)
        $FS    TEXT=(' ',80),MF=L       2
        $FS    TEXT=(' ',80),MF=L       3
        $FS    TEXT=(' ',80),MF=L       4
        $FS    TEXT=(' ',80),MF=L       5
        $FS    TEXT=(' ',80),MF=L       6
        $FS    TEXT=(' ',80),MF=L       7
        $FS    TEXT=(' ',80),MF=L       8
        $FS    TEXT=(' ',80),MF=L       9
        $FS    TEXT=(' ',80),MF=L      10
        $FS    TEXT=(' ',80),MF=L      11
FSGL    $FS    TEXT=(' ',80),MF=L      12 -> (15,1)
        $FS    SF=(PROT,INT),RA=(16,80,=),MF=L
        $FS    SF=(PROT),MF=L
FSMS    $FS    TEXT=(' ',80),MF=L       1 -> (17,1)
        $FS    TEXT=(' ',80),MF=L       2
        $FS    TEXT=(' ',80),MF=L       3
        $FS    TEXT=(' ',80),MF=L       4
        $FS    TEXT=(' ',80),MF=L       5
        $FS    TEXT=(' ',80),MF=L       6 -> (22,1)
        $FS    SF=(PROT,INT),MF=L
        $FS    TEXT='===>',MF=L
        $FS    SF=NORMAL,MF=L
        $FS    SBA=(23,20),SF=(PROT),MF=L
FSGI    $FS    TEXT=(' ',50),MF=L
        $FS    SBA=(1,1),SF=(PT,IC),MF=L
FSCRL    EQU   *-FSCR
         EJECT
*- - - - V A R I A B L E S - - - - - - - - - - - - - - - - - - - - - -*
         SPACE 1
DATA     DSECT
         DS    18F                 SAVE AREA
         DS    18F                 ADDITIONAL SAVE AREA
DBLW     DS    D
ATSO     EQU   DBLW,4
EXTR    EXTRACT *-*,'S',MF=L
LEXTR    EQU   *-EXTR
SVR14    DS    F
SVRDP    DS    XL8
EDWRK    DS    XL8
$T       DS    F
$H       DS    F
$V       DS    F
$F       DS    F
$B       DS    F
$V1      DS    F
$W1      DS    F
$W2      DS    F
ERRMSL   DS    H
FLAGS    DS    XL1                 GENERAL FUNCTIONS
SCTERM   EQU   X'08'                    SCREEN TERMINAL
SWFSW    DS    XL1                 SCREEN FUNCTIONS
SW1ST    EQU   X'10'
SWNMS    EQU   X'08'
SWHMS    EQU   X'04'
LIST0    DS    A         TPUT-TGET LIST +0 = SCREEN ADDRESS
         DS    F                        +4 = SCREEN TEXT LENGTH
         DS    A                        +8 = REPLY ADDRESS
         DS    F                        +12 = MAX. REPLY LENGTH
         DS    F                        +16 = TRUE REPLY LENGTH
REPLY    DS    CL80
WLNE     DS    CL80
MSWRK    DS    CL80
         SPACE 1
DFSTL    DS    2F                  TEXT ADDRESS / LENGTH
DFSML    DS    2F                  MESSAGE ADDRESS / LENGTH
FSPARM  @FS    ,,,MF=L
OPTFS   @FSO   ,
         SPACE 1
DATALEN  EQU   (((*-DATA)+7)/8)*8
         SPACE 2
         SPACE 2
         END
/*
//LKED    EXEC PGM=IEWL,PARM='MAP,LIST'
//SYSLIN   DD  DSN=&&LOADSET,DISP=(OLD,DELETE)
//         DD  *
  NAME LUNAR(R)
/*
//SYSLMOD  DD  DSN=SYS2.CMDLIB,DISP=SHR
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=VIO,SPACE=(CYL,(5,2))
//