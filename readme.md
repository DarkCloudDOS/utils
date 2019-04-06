# Utils - video and keyboard

This repository contains a collection
of released source code units, which are important
but do not belong each one on a separate git 
repository.

Projects here:

* __gamepro__ - a TP7 unit for making games. 
  You will find a copy of this in other of our
  games, and its something that evolved into 
  [GMS](https://github.com/DarkCloudDOS/gms)
* __mcga__ - a unit for working with MCGA (320x200). 
  The unit has the option to write off screen, and then
  write that into the main memory to avoid flicker in
  animation. Unit needs 386 to run, as it uses 32bit 
  instructions (`DB 66; rep stosw` - atually means 
  `stosl` wich is not supported by TP7's assmbler).
* __XtndMod__ - a unit which shows how to get a fast
  640x400 screen. Its actually very similar to XMode 
  (which can be done in GamePro). You loose up the virtual 
  screen support, but you gain resolution. 
* __kb__ - this unit lets you read the press status of 
  any key. Instead of a blocking call to the BIOS to read a
  key from the buffer - you read the status of each key 
  on the keyboard (pressed or not).  You can also see the
  last keyboard pressed, and the amount of keys pressed.

  BTW: more about XMode can be read in Wikipedia: https://en.wikipedia.org/wiki/Mode_X
  