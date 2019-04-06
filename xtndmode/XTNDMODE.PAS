
(* ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออป   *)
(* บ                                                        บÛ  *)
(* บ     Borland Pascal Units.                              บÛ  *)
(* บ     XtndMode Interface Unit                            บÛ  *)
(* บ     dark - cloud programming.                          บÛ  *)
(* วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถÛ  *)
(* บ                                                        บÛ  *)
(* บ     Copyright (C) 1996,1997                            บÛ  *)
(* บ                                                        บÛ  *)
(* ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออผÛ  *)
(*  ฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿  *)

Unit XtndMode;

{$G+,S-,D+,L+}

Interface

Const
  MaxX     = 640;
  MaxY     = 400;
  TextMode = 3;

Procedure InitXtended;
Procedure PutPixel( x, y: Integer; Color: Byte );
Function  GetPixel( x, y: Integer ): Byte;
Procedure ClearScreen( Color: Byte );

Procedure Box( x, y, dx, dy: Word ; Color: Byte );
Procedure FastBox( x, y, dx, dy: Word; Color: Byte );
Procedure PutImage( x, y, SizeX, SizeY: Word; Var Image );
Procedure GetImage( x, y, SizeX, SizeY: Word; Var Image );

Procedure HLine( x, y, XLen: Word; Color: Byte );
Procedure VLine( x, y, YLen: Word; Color: Byte );
Procedure Line( x1,y1,x2,y2 : Word; Color : Byte);

Procedure WaitRetrace;
Procedure WaitVRetrace;

Procedure SetVGAMode( n:Byte );
InLine( $58/                      { POP   AX                       }
        $B4/$00/                  { MOV   AH,0                     }
        $CD/$10);                 { INT   10H                      }

Implementation

Procedure InitXtended; ASSEMBLER;
Var
  ScreenMode: Byte absolute $40:$49;
Asm
        MOV     AX,     04F02H
        MOV     BX,     00100H
        INT     10H
        MOV     DX,     003C4h
        MOV     AL,     1
        OUT     DX,     Al
        INC     DX
        IN      AL,     DX
        OR      AL,     020h
        OUT     DX,     Al
        MOV     DX,     003C4H
        MOV     AX,     00604H
        OUT     DX,     AX
        MOV     DX,     003D4H
        MOV     AX,     0E317H
        OUT     DX,     AX
        MOV     DX,     003D4H
        MOV     AX,     00014H
        OUT     DX,     AX
        MOV     DX,     003C4H
        MOV     AX,     00F02H
        OUT     DX,     AX
        MOV     ES,     SegA000
        XOR     DI,     DI
        XOR     AX,     AX
        MOV     CX,     $FFFF/2
        REP     STOSW
        MOV     DX,     3DAH
@L1:    IN      AL,     DX
        TEST    AL,     08H
        JNZ     @L1
        MOV     DX,     03C4H
        MOV     AL,     1
        OUT     DX,     AL
        INC     DX
        IN      AL,     DX
        AND     AL,     0DFH
        OUT     DX,     AL

        PUSH    DS
        MOV     DS,     Seg0040
        MOV     ScreenMode, 13H
        POP     DS
End;

Procedure PutPixel( x, y: Integer; Color: Byte ); Assembler;
Asm
   MOV  CX,     X
   AND  CX,     3
   MOV  AX,     0100H
   SHL  AX,     CL
   ADD  AX,     2
   MOV  DX,     03C4h
   OUT  DX,     AX

   MOV  DI,     Y
   MOV  AX,     DI
   SHL  DI,     7
   SHL  AX,     5
   ADD  DI,     AX
   MOV  AX,     X
   SHR  AX,     2
   ADD  DI,     AX
   MOV  AL,     Color
   MOV  ES,     SegA000
   MOV  ES:[DI],AL
End;

Function GetPixel( x, y: Integer ): Byte; Assembler;
Asm
   MOV  DX,     $3CE
   MOV  AL,     04
   OUT  DX,     AL
   MOV  AX,     x
   AND  AX,     03
   INC  DX
   OUT  DX,     AX

   MOV  DI,     Y
   MOV  AX,     DI
   SHL  DI,     7
   SHL  AX,     5
   ADD  DI,     AX
   MOV  AX,     X
   SHR  AX,     2
   ADD  DI,     AX
   MOV  ES,     SegA000
   MOV  AL,     ES:[DI]
End;

Procedure ClearScreen( Color: Byte ); Assembler;
Asm
        MOV     DX,     03C4H
        MOV     AX,     0F02H
        OUT     DX,     AX
        MOV     ES,     SegA000
        XOR     DI,     DI
        MOV     AL,     Color
        MOV     AH,     AL
        MOV     CX,     $FFFF/2
        REP     STOSW
End;

Procedure Box( x, y, dx, dy: Word ; Color: Byte ); Assembler;
Var
  i: Word;
Asm
        {Calculate first point offset and store it in i}
        MOV     ES,     SegA000
        MOV     DI,     y
        MOV     DX,     DI
        SHL     DI,     5
        SHL     DX,     7
        ADD     DI,     DX
        MOV     i,      DI

        {For xx:= 0 to DX-1 do}
        MOV     BX,     0
@LOOPX: {Write to plane}
        MOV     CX,     x
        ADD     CX,     BX
        AND     CX,     3
        MOV     AX,     0100H
        SHL     AX,     CL
        ADD     AX,     2
        MOV     DX,     03C4H
        OUT     DX,     AX
        {Calculate point}
        MOV     DI,     i       {i=160*y}
        MOV     AX,     x
        ADD     AX,     BX
        SHR     AX,     2
        ADD     DI,     AX
        {For yy:= 0 to DX-1 do}
        MOV     AL,     Color
        MOV     CX,     &DY
@LOOPY: MOV     ES:[DI],AL
        ADD     DI,     MaxX/4
        LOOP    @LOOPY          {End For y}

        INC     BX
        CMP     BX,     &DX
        JNE     @LOOPX          {End For x}
End;

Procedure FastBox( x, y, dx, dy: Word; Color: Byte ); Assembler;
Asm
        AND     x,      11111100b       { round x by 4  }
        SHR     &dx,    2               { div dx by 4   }

        MOV     DI,     y               { calculate offset }
        MOV     DX,     DI
        SHL     DI,     7
        SHL     DX,     5
        ADD     DI,     AX
        MOV     DX,     x
        SHR     DX,     2
        ADD     DI,     DX

        MOV     AX,     0F02H           { write to all planes }
        MOV     DX,     03C4H
        OUT     DX,     AX

        MOV     AL,     Color
        MOV     ES,     SegA000
        MOV     DX,     &dx             { & Means the varibale no the register }
        MOV     BX,     &dy
@WriteIt:
        MOV     CX,     DX
        REP     STOSB
        ADD     DI,     MaxX/4
        SUB     DI,     DX
        DEC     BX
        JNZ     @WriteIt
End;

Procedure PutImage( x, y, SizeX, SizeY: Word; Var Image ); Assembler;
Var
  i,j: Word;
Asm
        PUSH    DS
        LDS     SI,     Image
        {Calculate first point offset and store it in i}
        MOV     ES,     SegA000
        MOV     DI,     y
        MOV     DX,     DI
        SHL     DI,     5
        SHL     DX,     7
        ADD     DI,     DX

        MOV     i,      DI      {Save DI, in i}
        MOV     j,      SI      {Save SI, in j}

        {For xx:= 0 to DX-1 do}
        XOR     BX,     BX
@LOOPX: {Write to plane}
        MOV     SI,     j
        MOV     CX,     x
        ADD     CX,     BX
        AND     CX,     3
        MOV     AX,     0100H
        SHL     AX,     CL
        ADD     AX,     2
        MOV     DX,     03C4H
        OUT     DX,     AX
        {Calculate point}
        MOV     DI,     i
        MOV     AX,     x
        ADD     AX,     BX
        SHR     AX,     2
        ADD     DI,     AX
        {For yy:= 0 to DX-1 do
           If Color<>0 then DrawIt}
        MOV     CX,     SizeY
@LOOPY: MOV     AL,     [SI]
        OR      AL,     AL
        JZ      @DONT_PUT
        MOV     ES:[DI],AL
@DONT_PUT:
        ADD     DI,     MaxX/4
        ADD     SI,     SizeX
        LOOP    @LOOPY          {End For y}

        INC     j
        INC     BX
        CMP     BX,     SizeX
        JNE     @LOOPX          {End For x}
        POP     DS
End;

Procedure GetImage( x, y, SizeX, SizeY: Word; Var Image ); Assembler;
Var
  i,j: Word;
Asm
        PUSH    DS
        LDS     SI,     Image
        {Calculate first point offset and store it in i}
        MOV     ES,     SegA000
        MOV     DI,     y
        MOV     DX,     DI
        SHL     DI,     5
        SHL     DX,     7
        ADD     DI,     DX

        MOV     i,      DI      {Save DI, in i}
        MOV     j,      SI      {Save SI, in j}

        {For xx:= 0 to DX-1 do}
        XOR     BX,     BX
@LOOPX: {Read plane and select plane}
        MOV     SI,     j
        MOV     DX,     03CEH
        MOV     AL,     04
        OUT     DX,     AL
        MOV     AX,     x
        ADD     AX,     BX
        AND     AX,     03
        INC     DX
        OUT     DX,     AX

        {Calculate point}
        MOV     DI,     I
        MOV     AX,     x
        ADD     AX,     BX
        SHR     AX,     2
        ADD     DI,     AX
        {For yy:= 0 to DX-1 do
           If Color<>0 then DrawIt}
        MOV     CX,     SizeY
@LOOPY: MOV     AL,     ES:[DI]
        MOV     [SI],   AL
        ADD     DI,     MaxX/4
        ADD     SI,     SizeX
        LOOP    @LOOPY          {End For y}

        INC     j
        INC     BX
        CMP     BX,     SizeX
        JNE     @LOOPX          {End For x}
        POP     DS
End;

Procedure HLine( x , y, XLen: Word; Color: Byte ); Assembler;
Var
  DDI: Word;
Asm
        {Calculate first point offset and store it in DDI}
        MOV     DI,     y
        MOV     DX,     DI
        SHL     DI,     5
        SHL     DX,     7
        ADD     DI,     DX
        MOV     DDI,    DI

        MOV     BL,     Color
        MOV     ES,     SegA000
        MOV     DX,     03C4H
        MOV     SI,     XLen
@HLINE_LOOPX:
        MOV     DI,     SI
        ADD     DI,     x
        {SET PORTS}
        MOV     CX,     DI
        AND     CL,     3
        MOV     AH,     1
        SHL     AH,     CL
        MOV     AL,     2
        OUT     DX,     AX       {Select plane to write to}

        SHR     DI,     2
        ADD     DI,     DDI
        MOV     ES:[DI],BL
        DEC     SI
        JNZ     @HLINE_LOOPX
End;

Procedure VLine( x ,y, YLen: Word; Color: Byte ); Assembler;
Asm
        {Calculate first point offset and store it in DDI}
        MOV     ES,     SegA000
        MOV     DI,     y
        MOV     DX,     DI
        SHL     DI,     5
        SHL     DX,     7
        ADD     DI,     DX
        MOV     BX,     DI

        {Write to plane}
        MOV     CX,     x
        AND     CX,     3
        MOV     AX,     0100H
        SHL     AX,     CL
        ADD     AX,     2
        MOV     DX,     03C4H
        OUT     DX,     AX

        {Calculate point}
        MOV     DI,     BX      { DDI = 160*y }
        MOV     AX,     x
        SHR     AX,     2
        ADD     DI,     AX

        {For yy:= 0 to SizeY-1 do}
        MOV     AL,     Color
        MOV     CX,     YLen
@VLINE_LOOPY:
        MOV     ES:[DI],AL
        ADD     DI,     MaxX/4
        LOOP    @VLINE_LOOPY    { End For y }

End;

Procedure Line( x1,y1,x2,y2 : Word; Color : Byte);
Var
  i, DeltaX, DeltaY, NumPixels,
  d, dInc1, dInc2,
  x, xInc1, xInc2,
  y, yInc1, yInc2 : integer;
Begin
  DeltaX := x2 - x1;
  DeltaY := y2 - y1;

  DeltaY := abs(DeltaY);
  DeltaX := abs(DeltaX);

  If DeltaX >= DeltaY
    Then Begin
           NumPixels := DeltaX + 1;
           d := (DeltaY shl 2) - DeltaX;
           dInc1 := DeltaY shl 1;
           dInc2 := (DeltaY - DeltaX) shl 1;
           xInc1 := 1;
           xInc2 := 1;
           yInc1 := 0;
           yInc2 := 1;
         End
    Else Begin
           NumPixels := DeltaY + 1;
           d := (DeltaX shl 2) - DeltaY;
           dInc1 := DeltaX shl 1;
           dInc2 := (DeltaX - DeltaY) shl 1;
           xInc1 := 0;
           xInc2 := 1;
           yInc1 := 1;
           yInc2 := 1;
         End;

  If x1 > x2 Then
    Begin
      xInc1 := - xInc1;
      xInc2 := - xInc2;
    End;
  If y1 > y2 Then
    Begin
      yInc1 := - yInc1;
      yInc2 := - yInc2;
    End;

  x := x1;
  y := y1;

  For i := 1 to NumPixels do
    Begin
      PutPixel(x, y, color);
      If d < 0
        Then Begin
               d := d + dinc1;
               x := x + xInc1;
               y := y + yInc1;
             End
        Else Begin
               d := d + dInc2;
               x := x + xInc2;
               y := y + yInc2;
             End;
    End;
End;

Procedure WaitRetrace; assembler;
asm
     MOV  DX,3DAh
@L1: IN   AL,DX
     TEST AL,08h
     JNZ  @L1
@L2: IN   AL,DX
     TEST AL,08h
     JZ   @L2
end;

Procedure WaitVRetrace; assembler;
asm
     MOV  DX,3DAh
@L1: IN   AL,DX
     TEST AL,08h
     JNZ  @L1
end;

End.
