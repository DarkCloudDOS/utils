Unit KB;
{$F+}

 Interface

  Procedure Capture_Keyboard;

  Var

   Shlf        : Array[0..199] of Word;

   keydown     : Byte;
   keys        : Array [0..127] of Boolean;
   scan        : Byte;
   lastkey     : Byte;
   ExitSaveKey : Pointer;

 Implementation

 Uses Dos;

 Var
   Oldint  : Procedure;

 Procedure INT9; Interrupt;
 Begin
  Scan := port[$60];
   if scan > $7F then Begin
     if keys[scan xor $80] then Dec(keydown);
     keys[scan xor $80] := false;
   End else begin
     if not keys[scan] then Inc(keydown);
     keys[scan] := true;
     lastkey := scan;
   End;
{   oldInt;}
   port[$20] := $20;
 End;

  Procedure KeyExitProc; Far;
  Begin
    Setintvec(9, @oldint);
    ExitProc := ExitSaveKey;
  End;

  Procedure Capture_Keyboard;
  Var Index1 : Word;
  Begin
    For Index1 := 0 to 127 do Keys[Index1] := False;
    Keydown := 0;
    Getintvec(9, @oldint);
    Setintvec(9, @INT9);
    ExitSaveKey := ExitProc;
    ExitProc := @KeyExitProc;
  End;

End.