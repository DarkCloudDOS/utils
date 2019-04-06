
(* ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»   *)
(* º                                                        ºÛ  *)
(* º     Borland Pascal Units.                              ºÛ  *)
(* º     MCGAMode Interface Unit.                           ºÛ  *)
(* º     dark - cloud programming                           ºÛ  *)
(* ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶Û  *)
(* º                                                        ºÛ  *)
(* º     Copyright (C) 1995,1996,1997                       ºÛ  *)
(* º                                                        ºÛ  *)
(* ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼Û  *)
(*  ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß  *)

Unit MCGAMode;
{$G+,X+,I-,O+,D+,L+,S-}

Interface

Const
  MaxX      = 320;
  MaxY      = 200;
  TextMode  =   3;

Procedure NewScreen( Var P: Pointer );
Procedure DoneScreen( Var P: Pointer );
Procedure WriteScreen( P: Pointer );

Procedure Flip( Var Source, Dest );
Function  GetScreen: Pointer;

Function  GetPixel( x,y: Integer ): Byte;
Procedure PutPixel( x,y: Integer; Color: Byte );
Procedure ClearScreen( Color: Byte );

Procedure Box( X, Y, DX, DY: Integer; Color: Byte );
Procedure PutImage( X,Y,SizeX, SizeY: Word; Var Image );
Procedure GetImage( X,Y,SizeX, SizeY: Integer; Var Image );

Procedure HLine( x, y, XLen: Word; Color: Byte );
Procedure VLine( x, y, YLen: Word; Color: Byte );
Procedure Line( x1,y1,x2,y2 : Word; Color : Byte);

Procedure WaitRetrace;
Procedure WaitVRetrace;

Procedure SetSVGAMode( n:Byte );
InLine( $58/                      { POP   AX                       }
	$B4/$00/		  { MOV   AH,0                     }
	$CD/$10);                 { INT   10H                      }

Implementation

Var
  CurScr: Word;

Procedure NewScreen( Var P: Pointer );
Begin
  GetMem( P, 320*200 );
End;

Procedure DoneScreen( Var P: Pointer );
Begin
  FreeMem( P, 320*200 );
End;

Procedure WriteScreen( P: Pointer );
Begin
  CurScr:= Seg( P^ );
End;

Procedure Flip( Var Source, Dest ); Assembler;
Asm
   PUSH DS
   LES  DI,     Dest
   LDS  SI,     Source
   MOV  CX,     320*200/4
   DB   $66
   REP  MOVSW
   POP  DS
End;

Function GetScreen: Pointer; Assembler;
Asm
  MOV   DX,     SegA000
  XOR   AX,     AX
End;

Procedure PutPixel( x,y: Integer; Color: Byte ); Assembler;
Asm
   MOV  DI,     Y
   SHL  DI,     6
   DB   $67,$8D,$3C,$BF          {LEA di,[edi+edi*4]}
   ADD  DI,     X
   MOV  ES,    CurScr
   MOV  AL,    Color
   MOV  ES:[DI],AL
End;

Function GetPixel( x,y: Integer): Byte; Assembler;
Asm
   MOV  DI,     Y
   SHL  DI,     6
   DB   $67,$8D,$3C,$BF          {LEA di,[edi+edi*4]}
   ADD  DI,     X
   MOV  ES,    CurScr
   MOV  AL,    ES:[DI]
End;

Procedure ClearScreen( Color: Byte ); Assembler;
Asm
        MOV   AL,     Color
        MOV   AH,     AL
        MOV   DX,     AX
        DB    $66
        SHL   AX,     16
        MOV   AX,     DX

        XOR   DI,     DI
        MOV   ES,     CurScr
	MOV   CX,     320*200/4
	DB    $66
	REP   STOSW
End;

Procedure Box( X, Y, DX, DY: Integer; Color: Byte ); Assembler;
Asm
   MOV   ES,     CurScr
   MOV   AL,     Color
   XOR   DI,     DI

   MOV   DI,     Y
   MOV   BX,     DI
   SHL   DI,     6
   SHL   BX,     8
   ADD   DI,     BX
   ADD   DI,     X

   MOV   DX,     &DX    { & Means the varibale no the register }
   MOV   BX,     &DY

@WriteIt:
   MOV   CX,     DX
   REP   STOSB
   ADD   DI,     320
   SUB   DI,     DX
   DEC   BX
   JNZ   @WriteIt
End;

Procedure PutImage( x,y,SizeX,SizeY: Word; Var Image ); Assembler;
Var
  SaveDS: Word;
Asm
	MOV	SaveDS,	DS

	MOV	DI,	y	{First Point}
	MOV	DX,	DI
	SHL	DI,	8
	SHL	DX,	6
	ADD	DI,	DX
	ADD	DI,     x
	MOV	ES,	CurScr	{ES:DI = screen}

	MOV  	DX,	320     {How much add to DI every loop?}
	MOV	BX,	SizeX 	{320 - width}
	SUB	DX,	BX

	MOV	AX,	SizeY	{AX = hiegth}
	LDS	SI,	Image 	{DS:SI = pic}

@PUT_LOOP2:
	MOV	CX,	SizeX	{CX = width}

@PUT_LOOP1:
	MOV	BL,	[SI]
	AND	BL,	BL
	JZ	@CONTINUE

	MOV	ES:[DI],BL
@CONTINUE:
	INC	DI
	INC	SI
	LOOP	@PUT_LOOP1

	ADD	DI,	DX
	DEC	AX
	JNZ     @PUT_LOOP2

	MOV	DS,	SaveDS
End;

Procedure GetImage( x,y,SizeX,SizeY: Integer; Var Image ); Assembler;
Asm
	PUSH    DS	        {Need to save DS because MOVSB needs it}

	MOV	SI,	y	{First Point}
	MOV	AX,	SI
	SHL	SI,	8
	SHL	AX,	6
	ADD	SI,	AX
	ADD	SI,	x
	MOV	DS,	SegA000	{DS:SI = screen}

	MOV  	DX,	320     {How much add to DI every loop?}
	MOV	BX,	SizeX	{320 - width}
	SUB	DX,	BX


	LDS	DI,	Image	{ES:DI = image}
	MOV	AX,	SizeY	{AX = hiegth}

@GET_LOOP:
	MOV	CX,	SizeX	{width}
	REP	MOVSB
	ADD	SI,	DX
	DEC	AX
	JNZ     @GET_LOOP
	POP	DS
End;

Procedure HLine( x, y, XLen: Word; Color: Byte ); Assembler;
Asm
	MOV	ES,	SegA000
        MOV	DI,	y       { y*320 }
        DB      $67,$8D,$3C,$BF {LEA di,[edi+edi*4]}
        SHL	DI,	6
        ADD	DI,	x	{ y*320+x }
	MOV	AL,	Color
        MOV	CX,	XLen
        REP	STOSB
End;

Procedure VLine( x, y, YLen: Word; Color: Byte ); Assembler;
Asm
	MOV	ES,	SegA000
        MOV	DI,	y       { y*320 }
        DB      $67,$8D,$3C,$BF {LEA di,[edi+edi*4]}
        SHL	DI,	6
        ADD	DI,	x	{ y*320+x }
	MOV	AL,	Color
        MOV	CX,	YLen
@VLINE_LOOPY:
	MOV	ES:[DI],AL
        ADD	DI,	MaxX
        LOOP	@VLINE_LOOPY
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

Begin
  CurScr:= SegA000;
End.
