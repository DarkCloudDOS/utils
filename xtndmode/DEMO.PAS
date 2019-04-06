Program XtndModeDemo;

Uses XtndMode;

Procedure XorPixel( x, y: Word; c: Byte );
Begin
  c:= GetPixel( x, y ) xor c;
  PutPixel( x, y, c );
End;

Var
  x, y, n: Word;
  p      : array[0..100-1, 0..50-1] of Byte;
Begin
  SetVGAMode( TextMode );
  WriteLn( ' This program is a demostration of the XtndMode unit. ');
  WriteLn;
  WriteLn( ' The screen will be filled with horizontal and vertical ');
  WriteLn( 'lines, and there will be boxes on the screen.' );
  WriteLn;
  WriteLn( ' I am Sorry that there are not graphics output procedures but');
  WriteLn( 'there was no time, I had to write a lot of files for the new');
  WriteLn( 'site. Really sorry :)');
  WriteLn;
  Writeln( ' Press [ENTER] to continue' );
  ReadLn;

  Randomize;
  InitXtended;
  ClearScreen( 27 );
  For x:= 0 to MaxX div 5 do VLine( x*5,    0, MaxY, 10 );
  For y:= 0 to MaxY div 5 do HLine(    0, y*5, MaxX, 10 );
  For n:= 0 to 10 do
    Begin
      x:= Random(MaxX);
      y:= Random(MaxY);
      FastBox( Random(MaxX-x), Random(MaxY-y),
           x, y,
           Random(256) );
    End;

  For n:=0 to 500 do
    XorPixel( Random(MaxX), Random(MaxY), Random(256) );
  Line( 0, 0, MaxX-1, MaxY-1, 10 );
  Line( MaxX-1, 0, 0, MaxY-1, 10 );

  x:= Random( MaxX - 100 );
  y:= Random( MaxY - 50 );
  GetImage( x, y, 100, 50, P );
  Repeat
    WaitRetrace; WaitRetrace;
    WaitRetrace; WaitRetrace; { now it will be draw maximum 17
                                times per second, because WaitRetrace
                                slowes it down to 70}
    PutImage( x, y, 100, 50, P );
    x:= Random( MaxX - 100 );
    y:= Random( MaxY - 50 );

    GetImage( x, y, 100, 50, P );
    Box( x, y, 100, 50, 09 );
  Until port[$60]<$80;

  SetVGAMode( TextMode );
End.
