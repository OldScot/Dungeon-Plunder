' Dungeon Plunder
' DND.BAS
' C Squared Software
' Craig S. Buchanan
' 2023-May-06

OPTION EXPLICIT
OPTION DEFAULT NONE

' ++++++++++++++++++++++++++
' User Machine Configuration
' ++++++++++++++++++++++++++

' Modes
'  1 800x600
'  2 640x400
'  3 XXX Too Small
'  4 480x432
'  5 XXX Way too small
'  6 XXX Way too small
'  7 320x240 ' Smallest (Carry Lost)
'  8 640x480 ' Good
'  9 1024x768 ' Tiny. Hard to see
' 10 848x480 ' 6 column doesn't fit!!!
' 11 1280x720 ' Missing first column???
' 12 960x540 ' Very nice
' 13 400x300 ' Very nice
' 14 XXX 960x540 Doesn't work on monitor!
' 15 1280x1024 ' Crazy. little hard to read but works!
' 16 1920x1080 ' Super Crazy but works
' 17 384x240  ' Nice. Edge to Edge


' Classic Controllers
CONST CON_CLASS_ON = 0 '1
CONST CON_CLASS_P1 = 0
CONST CON_CLASS_P2 = 1
' Atari Controller
CONST CON_ATARI_ON = 0 '1
CONST CON_ATARI_UP = 35
CONST CON_ATARI_DOWN = 36
CONST CON_ATARI_LEFT = 38
CONST CON_ATARI_RIGHT = 40
CONST CON_ATARI_FIRE = 32

' Start Up
MODE 1

' Load Libraries
#Include "library.window.inc"

' ++++++++++++++++++++++++++
' Variable Naming Convention
' ++++++++++++++++++++++++++
' Board -> b
' Constants -> Long
' Debug -> d
' Edges -> e
' Game -> g
' Level -> l
' Monster -> m
' Option -> o
' Player -> p
' Screen -> s
' Turn -> t

' ++++++++++++++++++++++++++
' Variable Notes
' ++++++++++++++++++++++++++
' Sprites - 16
' 1,2,3,4 gh 1-4 Hit Sprites
' 5 gmb Book Sprite
' 6 gt Treasure Sprite
' 7 gl Light/Torch Sprite
' 8 shm Home
' 9 sg Ghost
' 10,11,12 sm Monsters 1-3 smCnt = 3
' 13,14,15,16 4 sw Players 1-4 swCnt = 4   
' => Hits don't need to be sprites -> Move from Background?  Or From File as PNG.
' => Need seperate Monsters, Ghosts and Players (MAX)
' => Sets Maximums. 2 Players 15,16. 2 Ghosts 10,11. 3 Monsters 12,13,14.

' ++++++++++
' CONSTANTS
' ++++++++++

CONST MM =20 ' Max Monsters
CONST MP = 4 ' Max Players

CONST WS = 1 ' Wall Solid
CONST WD = 2 ' Wall Door

CONST IH = 1 ' Icon Home  
CONST IT = 2 ' Icon Treasure
CONST IB = 3 ' Icon Map Book
CONST IL = 4 ' Icon Light/Torch
CONST IP = 5 ' Icon Potion

CONST MI = 25 ' Monster Icons
CONST GI = 2 ' Ghost Icons
CONST WI = 8 ' Warrior Icons

CONST ACT_PLAY = 1
CONST ACT_BAD = 3
CONST ACT_AWAKE = 4
CONST ACT_FLY = 5
CONST ACT_ATTACK = 6
CONST ACT_DEFEAT = 7
CONST ACT_VICTORY = 8
CONST ACT_MOVE = 10
CONST ACT_TREASURE = 11
CONST ACT_WALL = 12
CONST ACT_SLEEP = 13
CONST ACT_FLY_HOME = 14
CONST ACT_RAGE = 15
CONST ACT_RETURN = 16
CONST ACT_GAME_OVER = 17
CONST ACT_NO_FUEL = 18
CONST ACT_LIGHT = 19
CONST ACT_MAP = 20
CONST ACT_SPOTTED = 21
CONST ACT_LEVEL_OVER = 22
CONST ACT_POTION = 23
CONST ACT_WON = 30
CONST ACT_LOST = 31
CONST ACT_TIED = 32
CONST ACT_SCORE = 33
CONST ACT_PLAYERWIN = 34
CONST ACT_BLANK = 35

CONST KEY_BAD = -1
CONST KEY_NOTHING = 0
CONST KEY_UP = 1
CONST KEY_DOWN = 2
CONST KEY_LEFT = 3
CONST KEY_RIGHT = 4
CONST KEY_DONE = 5
CONST KEY_QUIT = 6
CONST KEY_PICKUP = 7
CONST KEY_SOUND = 8
CONST KEY_TALK = 9
CONST KEY_DEBUG_TREASURE = 100
CONST KEY_DEBUG_MONSTERS = 101
CONST KEY_DEBUG_SHOW = 102
CONST KEY_DEBUG_LIGHT = 103

CONST PTS_SQUARE = 1
CONST PTS_MAP = 20
CONST PTS_LIGHT = 20
CONST PTS_PTREASURE = 20
CONST PTS_HTREASURE = 100
CONST PTS_POTION = 20

CONST S_HIT1 = 1
CONST S_HIT2 = 2
CONST S_HIT3 = 3
CONST S_HIT4 = 4
CONST S_MAP  = 5
CONST S_TORCH= 6
CONST S_TREA = 7
CONST S_BASE = 8
CONST S_POTION = 9
CONST S_WAR1 = 10
CONST S_WAR2 = 11
CONST S_GHOST1 = 12
CONST S_GHOST2 = 13
CONST S_MON1 = 14
CONST S_MON2 = 15
CONST S_MON3 = 16 

' +++++
' Main
' +++++

Main_Variables
IO_BaseGraphicsLoad
IO_WelcomeDisplay
IO_ScreenDetermine
IO_BaseGraphicsPreload
Main_Initialize
Do
  IO_GameDetermine
  If quit <> 0 Then Exit Do
  IO_BaseGraphicsReload
  Game_Play
  If quit = 0 Then 
    Game_ResultDisplay
  End If
Loop Until 1 = 2
Main_Deinitialize
End 

' ++++++++++++++
' Main_Variables
' ++++++++++++++

Sub Main_Variables
' Globals

' Options
  Dim Integer ot ' Option Talk
  Dim Integer os ' Option Sound
  Dim Integer oq ' Option Query

' Game
  Dim Integer gl ' Game Level
  Dim Integer gp ' Game Players
  Dim Integer gm ' Game Monsters
  Dim Integer gf ' Game Found
  Dim Integer gap ' Game Autopickup
  Dim Integer gt ' Game Type 1=Surpise, 2=Explore, 3=Site
  Dim Integer gd ' Game Difficulty 1,2,3,4,5 Beg, Easy, Norm, Hard, Fiendish
  Dim Integer gc ' Game Complete

' Level
  Dim Integer lt ' Level Treasures
  Dim Integer lc ' Level Complete
  Dim Integer lm ' Level Map Found

' Dungeon & Screen
  Dim Integer bdx, bdy, bsx, bsy, bx, by

' Debug!
  Dim Integer df ' Debug Flag
  Dim Integer dm ' Monsters
  Dim Integer dt ' Treasures
  Dim Integer dc ' Code
  Dim Integer ds ' Debug Setup 1= Done

' Environment
  Dim String ePath ' Current Path

' Player
  DIM INTEGER pCx(MP), pCy(MP) ' Player Current x,y
  DIM INTEGER pSx(MP), pSy(MP) ' Player Safe/Home x,y
  DIM INTEGER pM(MP) ' Player Moves Left - Just for reporting purposes!
  DIM INTEGER pT(MP) ' Player Treasure
  DIM INTEGER pS(MP) ' Player Sprite
  DIM INTEGER pL(MP) ' Player has Light?
  DIM INTEGER pP(MP) ' Player Points (scored)
  DIM INTEGER pF(MP) ' Player Fuel (Torch)
  DIM INTEGER pH(MP) ' Player Health - New - 0 = Dead, 1,2,3 (Replace pA AND pM)
  DIM INTEGER pE     ' Player Event

' Monster
  DIM INTEGER mCx(MM), mCy(MM) ' Monster Current x,y
  DIM INTEGER mHx(MM), mHy(MM) ' Monster Home x,y
  DIM INTEGER mTx(MM), mTy(MM) ' Monster Treasure x,y
  DIM INTEGER mA(MM) ' Monster Awake? -1 if Dead, 0 if Asleep, 1 if Moving!, 2 if Returning
  DIM INTEGER mS(MM) ' Monster Sprite
  DIM INTEGER mTp(MM) ' Monster Treasure Player - Reverse of PT(MP)
  Dim Integer mD(MM) ' Monster Mode. 0 = Ghost, 1 = Guard, 2 = Wanderer

' Screen
  Dim Integer sm ' Screen Mode
  Dim Integer sx, sy ' Screen Size
  Dim Integer sBx, sBy, sBw, sBh ' Screen Banner
  Dim Integer sSx, sSy, sSw, sSh ' Screen Status
  Dim Integer sFw, sFh, sF2w, sF2h ' Screen Font width/height
  Dim Integer sPx(MP), sPy(MP), sPw(MP), sPh(MP) ' Screen Player Status

' Board Creation
  Dim Integer bd(4) ' Board Direction
  Dim Integer ba(4) ' Board Available

' Flags
  Dim Integer quit
  Dim Integer done
  Dim Integer wo,wc,wm 'wall open/closed max

' Environment 
  ePath = Mid$(mm.info$(Current),1,Instr(mm.info$(Current), "dnd.bas")-1)

' Setup Later! ' Should set this to max! (19x14)
  'Dim Integer bm(bsx,bsy), bv(bsx,bsy), bs(bsx,bsy)
  'Dim Integer ex1(bsx*2+bsy*2), ey1(bsx*2+bsy*2)
  'Dim Integer ex2(bsx*2+bsy*2), ey2(bsx*2+bsy*2)

' Init 
  ds = 0
  oq = 0
End Sub

' +++++++++++++++++++++++
' Initialization Routines
' +++++++++++++++++++++++

Sub Main_Initialize
  IO_DisplayInitialize

' Should set this to max! (19x14)
  Dim Integer bm(bsx,bsy), bv(bsx,bsy), bs(bsx,bsy)
  Dim Integer ex1(bsx*2+bsy*2), ey1(bsx*2+bsy*2)
  Dim Integer ex2(bsx*2+bsy*2), ey2(bsx*2+bsy*2)

' Main_Initialize Controllers
  IO_AtariInitialize
  IO_ClassicInitialize

' Game Defaults
  gp = 1
  gt = 1
  gd = 3
  gl = 1
  os = 1
  ot = 0
End Sub


Sub Main_DeInitialize
    IO_ClassicDeInitialize
End Sub


Sub Game_ResultDisplay
' Who Won? Good Question
  Local Integer hs, ps, p
  Local String m$
  IO_Event ACT_GAME_OVER
' By Game Type
    If gp = 1 And gt < 3 Then
      If pH(1)>0 Then IO_Event ACT_WON Else IO_Event ACT_LOST
    Else if gp=1 And gt = 3 Then
      IO_Event ACT_SCORE 
    Else if pp(1) = pp(2) Then
      IO_Event ACT_TIED
    Else if pp(1) < pp(2) Then
      IO_Event ACT_PLAYERWIN 2
    Else
      IO_Event ACT_WIN 1
    End If
End Sub


' +++++++++++++++++
' Game
' +++++++++++++++++


Sub Game_Play
  gl = 1
  Game_Setup
  Do
    Level_Play
    Game_OverCheck
    If quit <> 0 Then Exit Do
    If gc = 0 Then
      Level_ResultDisplay
      Inc gl
    End If
  Loop Until gc <> 0
End Sub

Sub Game_Setup
  Local Integer p
' By Game Type
  Select Case gt
    Case 1:
    ' No Lights
      For p = 1 to gp: pL(p)=0: pF(p)= 0: Next
    Case 2:
      For p = 1 to gp: pL(p)=1: pF(p)= bdx*bdy*.5: Next
    Case 3:
      For p = 1 to gp: pL(p)=1: pF(p)= bdx*bdy*.5: Next
  End Select
' Begin
  gl = 1
End Sub


Sub Game_OverCheck
' By Game Type
  If gt<3 Then
    gc = 1
    Return
  End If
' All Dead?
  Local Integer p
  For p = 1 to gp
    If pH(p)>0 Then Return
  Next 
  gc = 1
End Sub

Sub Game_SoundToggle
  os = os xor 1
  IO_SoundDraw
End Sub

Sub Game_TalkToggle
  ot = ot xor 1
  IO_TalkDraw
End Sub

' +++++++++++++++++
' Level
' +++++++++++++++++

Sub Level_OverCheck
' All Treasures Removed?
  If lt = 0 Then
    lc = 1    
  End If
' All Dead?
  Local Integer p
  For p = 1 to gp
    If pH(p)>0 Then Return
  Next 
  lc = 1
End Sub


Sub Level_Setup
  gc = 0
  lc = 0
  lm = 0
  dm = 0
  dt = 0
  IO_GameSpritesLoad
  Cls
  IO_DebugSetup
  Level_BoardSetup
End Sub


Sub Level_Play
  Level_Setup
  IO_ScreenDraw
  Board_Show
  Do
    Player_Turns
    If (lc = 0 And quit = 0) Then Monster_Turns
  Loop Until lc <> 0 Or quit <> 0
End Sub


Sub Level_ResultDisplay
  Local Integer hs, ps, p
' By Game Type
  If gt = 3 Then
    IO_Event ACT_LEVEL_OVER
  End If
End Sub

Sub Level_BoardSetup
  Local Integer x,y,p,m,bad,cnt
  Level_BoardMazeCreate
  ' Place the Players, Set Moves, and Make Active
  For p=1 to gp
    Do           
      x = DnXRnd()
      y = DnYRnd()
    Loop Until DnOccupied(x,y) = 0 
  ' Assign Current
    pCx(p) = x 
    pCy(p) = y
  ' Assign SafeSpace (Base!)
    pSx(p) = x
    pSy(p) = y
  ' Place Base
    bm(x, y) = IH
    bv(x, y) = 1
  ' Init Player
    pH(p) = 3
    pM(p) = 0
    pS(p) = S_WAR1 + Rnd0N(1)
    ' Apply Player Light to Square!
    Player_SquareLight p
  Next
  dc = 722
' Create the Monsters
  gm = 1 + (gd-1)*2 + gl/10
  If gp > 1 Then Inc gm
  If gm > (bdx*bdy*0.25) Then gm = bdx*bdy*0.25
  If gm > MM Then gm = MM
  lt = 0 'Treasure Countdown
  For m=1 to gm
  ' Monster Mode
  ' Must Have at least one non-Wanderer!
    mD(m) = 0 'Default Ghost
    If gt > 1 Then
      If m > 1 Then
        mD(m) = Rnd0N(2) 'Ghost/Monster/Wanderer
      Else
        mD(m) = Rnd0N(1) 'Ghost/Monster
      End If
    End If    
    cnt = 0 ' Don't look forever!
    Do
      bad = 0
    ' Find Empty Square
      Do
        x = DnXRnd()
        y = DnYRnd()
      Loop Until DnEmpty(x,y)=1 And MonsterAt(x,y)=0 And PlayerAt(x,y)=0
    ' Must be 3 squares away from All Players!
      For p%=1 to gp
        If InRange(pCx(p%),pCy(p%),x,y) Then
          bad = 1
          Exit For
        End If
      Next
      Inc cnt
      If bad = 1 and m > 1 and cnt > 100 Then Exit Do
    Loop Until bad = 0
  ' Square is Bad? 
    If bad = 1 Then Exit For
  ' Square is Good!
    mCx(m) = x
    mCy(m) = y
  ' Setup Ghost/Monster (not Wanderer)
    If mD(m) <> 2 Then
      mTx(m) = x
      mTy(m) = y
      mHx(m) = x
      mHy(m) = y
      lt = lt + 1
    End If
    mA(m) = 0
  ' Assign Sprite
    If mD(m) = 0 Then
      mS(m) = S_GHOST1 + Rnd0N(1)
    Else
     mS(m) = S_MON1 + Rnd0N(2)
    End If
  Next
  dc = 724
' Place Map Book
  If gt > 1 And gd < 4 Then
    Do
      x = DnXRnd()
      y = DnYRnd()
    Loop Until DnEmpty(x,y)=1 And PlayerAt(x,y)=0 And MonsterAt(x,y)=0
    bm(x,y) = IB
  End If
  dc = 726
' Place Light
  If gt > 1 And gd < 5 Then
    Do
      x = DnXRnd()
      y = DnYRnd()
    Loop Until DnEmpty(x,y)=1 And PlayerAt(x,y)=0 And MonsterAt(x,y)=0
    bm(x,y) = IL
  End If
  dc = 728
' Place Potion
  If gt > 1 And gd < 5 Then
    Do
      x = DnXRnd()
      y = DnYRnd()
    Loop Until DnEmpty(x,y)=1 And PlayerAt(x,y)=0 And MonsterAt(x,y)=0
    bm(x,y) = IP
  End If
End Sub



' +++++++++++++++++++++++
' Level - Maze Generation
' +++++++++++++++++++++++


Sub Level_BoardMazeCreate
  Local Integer t1, t2, un, x, y, d, nx, ny, ox, oy, w
' Clear Old Maze!
  For x=1 to bsx
    For y=1 to bsy
      bv(x,y)=0
      bm(x,y)=0
    Next
  Next
' Side Walls
  For x=1 to bsx
    bm(x,1) = ws
    bm(x,bsy) = ws
    bv(x,1) = 1
    bv(x,bsy) = 1
  Next
  For y=1 to bsy
    bm(1,y) = ws
    bm(bsx,y) = ws
    bv(1,y) = 1
    bv(bsx,y) = 1
  Next      
' Set All Walls And Unvisited
  For y = 2 To bsy-1
    For x = 2 To bsx-1
      ox = Odd(x) 
      oy = Odd(y)
      If ox And oy Then
      ' Vertex
      Else If ox Or oy Then
      ' Side
        bm(x,y) = WS
      Else
      ' Inside
        bm(x,y) = 999
      End If
    Next
  Next
  wc = (bdx-1) * bdy + bdx * (bdy-1)
  t1 = timer
' Random Walk Until All Visited
' Level_BoardRandomWalk 
  Level_BoardHuntAndKill
  t2 = timer
  Debug "Time="+str$(t2-t1)

' Remove Random Walls to make it easier!
' Calc Percent to Keep - By Level 100 keep All!
  wm = (gd * 10) + gl
  If (wm > 100) then wm = 100
  wm = wc*(wm/100)
' Debug "wc="+str$(wc)+", wm="+str$(wm)
  Do While wc > wm
    x = DnSxInterior()
    y = DnSyInterior()
  ' Remove Wall if Exists
    If DnOccupied(x,y) Then
      bm(x,y) = 0
      wc = wc - 1
    End If    
  Loop

' Compute Post Walls
  For y = 3 to bsy-2 Step 2
    For x = 3 to bsx-2 Step 2
      If bm(x-1,y) > 0 Or bm(x+1,y) > 0 Or bm(x,y-1) > 0 Or bm(x,y+1) > 0 Then
        bm(x,y) = 1
      Else
        bm(x,y) = 0
      End If
    Next
  Next
End Sub


Sub Level_BoardRandomWalk
  Local Integer un, x, y, d, nx, ny, ox, oy, w
' Random Walk Until All Visited
  un = bdx * bdy
  x = DnXRnd()
  y = DnYRnd()
  Do
  ' Go Direction
    d = Rnd1N(4)
    ox = 0: oy = 0
    Select Case d
      Case 1: ox = -1
      Case 2: ox = 1
      Case 3: oy = -1
      Case 4: oy = 1
    End Select
  ' Valid?
    nx = x + ox*2: ny = y + oy*2
    If nx > 1 And nx < bsx And ny > 1 And ny < bsy Then
    ' UnVisited?
      If bm(nx, ny) = 999 Then
        bm(nx,ny) = 0
        bm(x+ox,y+oy) = 0
        un = un - 1
        wc = wc - 1
      End If
      x = nx: y = ny
    End If
  Loop Until un = 0
End Sub


Sub Level_BoardHuntAndKill
  Local Integer i, f, t1, t2, un, x, y, d, nx, ny, ox, oy, w, bc
' Initialize board direction vector
  For d = 1 to 4: bd(d) = d: next
' Random Walk Until All Visited
  un = bdx * bdy
  x = DnXRnd()
  y = DnYRnd()
  bm(x,y) = 0 : un = un - 1
  Do
  ' Randomize Vector
    For d = 1 to 4: t1 = Rnd1N(4): t2 = bd(d): bd(d) = bd(t1): bd(t1)=t2:Next
  ' Get Valid Direction
    i = 0 : f = 0
    Do
      i = i + 1
      d = bd(i)
      ox = 0: oy = 0
      Select Case d
        Case 1: ox = -1
        Case 2: ox = 1
        Case 3: oy = -1
        Case 4: oy = 1
      End Select
      nx = x + ox*2: ny = y + oy*2
    ' Valid?
      If nx > 1 And nx < bsx And ny > 1 And ny < bsy Then
        If bm(nx,ny) = 999 Then f = 1        
      End If
    Loop Until f=1 OR i=4
  ' If Found Then Take Down the Wall
    If f Then
      bm(nx,ny) = 0
      bm(x+ox,y+oy) = 0
      un = un - 1
      wc = wc - 1
      x = nx: y = ny
    Else
    ' Hunt for new Starting Point
    ' First find Unvisited (999) - So faster as fills up!
      nx = 2 : ny = 2 : d = 0 : bc = 0
      Do
      ' Debug "nx="+str$(nx)+" ny="+str$(ny)
        If bm(nx,ny) = 999 Then
          If BoardTest(nx-2,ny,0) Then
            bc = bc + 1: ba(bc) = 1
          Else If BoardTest(nx+2,ny,0) Then
            bc = bc + 1: ba(bc) = 2
          Else If BoardTest(nx,ny-2,0) Then
            bc = bc + 1: ba(bc) = 3
          Else If BoardTest(nx,ny+2,0) Then
            bc = bc + 1: ba(bc) = 4
          End If 
        End If
        If bc = 0 Then
          nx = nx + 2    
          If nx >= bsx Then nx = 2:ny = ny + 2
        End If      
      Loop Until bc > 0
    ' Choose Available Direction at Random!
      d = ba(Rnd1N(bc))
    ' Move
      ox = 0: oy = 0
      Select Case d
        Case 1: ox = -1
        Case 2: ox = 1
        Case 3: oy = -1
        Case 4: oy = 1
      End Select
    ' Take Down the Wall
    ' Debug "nx="+str$(nx)+" ny="+str$(ny)+", d="+str$(d)+", ox="+str$(ox)+", oy="+str$(oy)
      bm(nx,ny) = 0
      bm(nx+ox,ny+oy) = 0
      un = un - 1
      wc = wc - 1
      x = nx: y = ny
    End If
  Loop Until un = 0
' Sanity Check!
'  i = 0
'  For y = 2 to bsy Step 2
'    For x = 2 to bsx Step 2
'      If bm(x,y) <> 0 Then i = i + 1
'    Next
'  Next
'  Debug "Missed squares="+str$(i)
End Sub


' +++++++++++++++
' Player Routines
' +++++++++++++++


Sub Player_Turns
  Local Integer p
  For p = 1 To gp
    If lc > 0 Or quit >0 Then Return
    Player_Turn(p)
  Next
End Sub


Sub Player_Turn p%
  Local Integer moveCnt, moveContinue
' Player Still Alive?
  If pH(p%) = 0 Then Return
  IO_PlayerHighlight p%, 1
' Sound Warrior Start
  IO_Event ACT_PLAY,p%,0
  ' Player Torch Runs Down
  If pF(p%) > 0 Then
    pF(p%) = pF(p%) - 1
    If pF(p%) = 0 Then
      IO_Event ACT_NO_FUEL,p%,0
      pL(p%) = 0
    End If
  End If
' Loop Through Moves
  pM(p%) = 4
  If pT(p%)=0 Then pM(p%) = pM(p%) + (pH(p%)-1)*2
  IO_PlayerUpdate p%
  Do
    pE = 0
    moveContinue = Player_Move(p%)
  ' Debug "pE="+str$(pE)
    If pE = 0 Then IO_Event ACT_BLANK
  ' Debug "Player "+str$(p%)+" score="+str$(pP(p%))
    If pM(p%) > 0 Then pM(p%) = pM(p%) - 1
    IO_PlayerUpdate p%
  Loop Until lc <> 0 OR quit <> 0 OR pM(p%) < 1 OR moveContinue = 0
  pM(p%) = 0
  IO_PlayerHighlight p%, 0
End Sub



Function Player_Move(p%) as Integer '1 If Move Successful, 0 If Stopped.
  Local Integer c, dx, dy, nx, ny, px, py, m, move,pf, ox, oy
' Default Fail
  Player_Move = 0
' Get Move
  move = 0
  c = Player_Input(p%)
  ox = pCx(p%)
  oy = pCy(p%)
  dx = 0: dy = 0
  Select Case c
    Case KEY_LEFT: dx = -1
    Case KEY_RIGHT: dx = 1
    Case KEY_UP: dy = -1
    Case KEY_DOWN: dy = 1
    Case KEY_DONE: Exit Function
    Case KEY_QUIT: Exit Function
  End Select
' Compute Wall Crossing
  nx = pCx(p%)+dx: ny = pCy(p%)+dy 
' Make Wall Visible
  bv(nx,ny) = 1
  CheckPosts nx,ny
' Move Sound
  IO_Event ACT_MOVE,p%,0
' Check Wall in the way
  If bm(nx,ny) <> 0 Then
    IO_SquareAndWallsDisplay ox, oy
    IO_Event ACT_WALL,p%,0
  Else
  ' Move
    px = pCx(p%) + dx*2
    py = pCy(p%) + dy*2
  ' Score Move If First on Square
    If bv(px,py) = 0 Then
      pP(p%) = pP(p%) + PTS_SQUARE
    End If
  ' Make New Square Visible - Pause if interesting
    bv(px,py) = 1
    IO_SquareAndWallsDisplay px,py
  ' Move Player   
    pCx(p%) = px
    pCy(p%) = py
  ' Move Treasure if Carried!
    If pT(p%) > 0 Then
      m% = pT(p%)
      mTx(m%) = px
      mTy(m%) = py
    End If
    IO_SquareDisplay ox,oy,1
    IO_SquareAndWallsDisplay px, py
  ' Landed on a Monster? - If attacked (only once) were done!
    For m = 1 to gm
      If mCx(m) = px And mCy(m) = py Then
        Player_SquareLight p%
        Monster_Attacks p%,m
        Board_Show ' FIX!!!
        Exit Function
      End If
    Next
  ' Check New Space
    c = bm(px, py)
  ' Found Treasure?
    If gap And TreasureAt(px,py) Then 
      Player_Player_PickupTreasure p%, px, py
  ' Home With Treasure?
    Else If c=ih And pT(p%) >0 Then
    ' Score
      pP(p%) = pP(p%) + PTS_HTREASURE
    ' Update at some point with multiple wins (# treasures should be odd - 2 player)
      Inc pP(p%)
    ' Once less Level Treasure
      lt = lt - 1
    ' Another Found!
      Inc gf ' FIX is this used anywhere?
      m = pT(p%)
      IO_Event ACT_VICTORY,p%,m
    ' Remove Monster - Poof! (Only if ghost!)
      If mD(m) = 0 Then
        mA(m) = -1 ' Monster Off Board!
      ' FIX Animate Ghost Disappears
        IO_AttackAnimate p%,m ' Will This work?
        IO_SquareAndWallsDisplay mCx(m),mCy(m) ' Redraw Monster Square!
        mCx(m) = -1 : mCy(m) = -1
      End If
    ' Remove Treasure From Player
      pT(p%) = 0
      mTp(m) = 0    
    ' Remove Treasure From Board
      mTx(m) = 0 : mTy(m) = 0
      Level_OverCheck
    Else
      Player_Move = 1
    End If   
    Player_SquareLight p%
    IO_SquareAndWallsDisplay px,py
  End If
End Function


Function Player_Input(p%) as Integer
  Local integer px, py, pf, c
  Game_InputBegin(p%)
  Player_Input = 0
  Do
    Do
      c = Game_InputScan(p%)
      IO_PlayerAnimate p%
    Loop Until c <> KEY_NOTHING
    IO_PlayerShow p%
    Select Case c
    ' Special
      Case KEY_PICKUP: Player_Pickup p% : c = KEY_NOTHING
      Case KEY_QUIT: lc = 1 : gc = 1 : quit = 1
    ' Options
      Case KEY_SOUND: c = KEY_NOTHING: Game_SoundToggle
      Case KEY_TALK: c = KEY_NOTHING: Game_TalkToggle
    ' Debug
      Case KEY_DEBUG_TREASURE: c = KEY_NOTHING: If dt Then dt = 0 Else dt = 1
      Case KEY_DEBUG_MONSTERS: c = KEY_NOTHING: If dm Then dm = 0 Else dm = 1
      Case KEY_DEBUG_SHOW: c = KEY_NOTHING: lm=1:Board_Show
      Case KEY_DEBUG_LIGHT: c = KEY_NOTHING: If pL(p%) Then pL(p%) = 0 Else pL(p%) = 1
    ' Error
      Case KEY_BAD: IO_Event ACT_BAD,p%,0 : Debug "Bad Key " + str$(c) : c = 0
    ' Otherwise Ok!
      Case Else:
    End Select
  ' Pause Action if not a motion!
    If c=KEY_NOTHING Then Pause 500
  Loop Until c <> KEY_NOTHING
  Player_Input = c
End Function


Function Game_Input(p%) as Integer
  Local Integer c
  Game_Input = KEY_NOTHING
  Game_InputBegin p%
  Do
    c = Game_InputScan(p%)
  Loop Until c <> KEY_NOTHING
  Game_Input = c
End Function

Sub Game_InputBegin p%
  Do
  Loop Until IO_InputKbd(p%)=KEY_NOTHING And IO_AtariInput(p%)=KEY_NOTHING And IO_ClassicInput(p%)=KEY_NOTHING
End Sub

Function Game_InputScan(p%) as Integer
  Local Integer c
  c = IO_InputKbd(p%)
  If c=KEY_NOTHING Then c=IO_AtariInput(p%)
  If c=KEY_NOTHING Then c=IO_ClassicInput(p%)
  Game_InputScan = c
End Function


Sub Player_Pickup p%
  Local Integer x%, y%, c%, m%
  x% = pCx(p%) : y% = pCy(p%)
  c% = bm(x%,y%)
  Select Case c%
    Case IL: Player_PickupTorch p%, x%, y%
    Case IB: Player_PickupMap p%, x%, y%
    Case IP: Player_PickupPotion p%, x%, y% 
    Case Else:
      If TreasureAt(x%,y%) > 0 Then Player_PickupTreasure p%, x%, y%
  End Select
End Sub


Sub Player_PickupTorch p%, x%, y%
' Score
  pP(p%) = pP(p%) + PTS_LIGHT
' Alert
  IO_Event ACT_LIGHT,p%,0
' Remove Torch
  bm(x%,y%) = 0
' Give Player Torch
  pL(p%) = 1
' Give Torch Fuel
  pF(p%) = bdx * bdy / 2
' Light the Square
  Player_SquareLight p%
' Redraw Square!
  IO_SquareAndWallsDisplay x%, y%
' Update Player
  IO_PlayerUpdate p%
End Sub

Sub Player_PickupPotion p%, x%, y%
' Score
  pP(p%) = pP(p%) + PTS_POTION
' Alert
  IO_Event ACT_POTION,p%,0
' Remove Potion
  bm(x%,y%) = 0
' Give Player Potion
  pH(p%) = 3 
' Redraw Square!
  IO_SquareAndWallsDisplay x%, y%
' Update Player
  IO_PlayerUpdate p%
End Sub


Sub Player_PickupMap p%, x%, y%
' Score
  pP(p%) = pP(p%) + PTS_MAP
' Alert
  IO_Event ACT_Map,p%,0
' Remove Map
  bm(x%,y%) = 0
' Have Map
  lm = 1
' Show Map!
  Board_Show
' Update Player
  IO_PlayerUpdate p%
End Sub


Sub Player_PickupTreasure p%, x%, y%
  Local Integer m%
' Can only carry 1 treasure!
  If pT(p%) > 0 Then
  ' Only complain if manual pickup!
    If gap = 0 Then
      IO_Event ACT_BAD, p%, 0
    End If
    Return
  End If
' Score
  pP(p%) = pP(p%) + PTS_PTREASURE
' Pick up Treasure
  bm(x%,y%) = 0
' Treasure is heavy! Reduce Remaining moves!
  If pH(p%)>1 And pM(p%)>1 Then pM(p%) = pM(p%) / 2
' Which Treasure is it?
  m% = WhoseTreasure(x%,y%)
' Alert!
  IO_Event ACT_TREASURE,p%,m%
' Warrior has Monster Treasure
  pT(p%) = m%
' Monster Treasure is with Warrior
  mTp(m%) = p%
' Redraw Square!Show Pickup
  IO_SquareDisplay x%, y%, 1
' Update Player
  IO_PlayerUpdate p%
End Sub


Sub Player_SquareLight p%
  Local Integer x,y
  If pL(p%) or lm Then 'gmf
    x = pCx(p%) : y = pCy(p%)
  ' Square (shouldn't be needed)
    bv(x,y) = 1
  ' Walls
    bv(x-1,y) = 1
    bv(x+1,y) = 1
    bv(x,y-1) = 1
    bv(x,y+1) = 1
  ' Posts
    bv(x-1,y-1) = 1
    bv(x+1,y-1) = 1
    bv(x-1,y+1) = 1
    bv(x+1,y+1) = 1
  End If
End Sub


Sub Board_Show
  IO_BoardDisplay
End Sub


' ++++++++++++++++
' Monster Routines
' ++++++++++++++++


Sub Monster_Turns
  Local Integer m
  For m = 1 to gm
    If lc <> 0 OR quit <> 0 Then Return
    If mA(m) > -1 Then
      Monster_Turn m
    End If
  Next
End Sub


Sub Monster_Turn m%
  Local Integer dx,dy,p%,tp%,d%,l%,ox%,oy%,na%
  Local Float pd, pm
  Debug "Monster " +str$(m%) + ":"+ str$(mD(m%)) + " Turn"
' Setup
  ox% = mCx(m%) : oy% = mCy(m%)

' Monster asleep/returning but Warriors Close?
  If mA(m%) = 0 or mA(m%) = 2 Then
    na% = 0
  ' Ghost - Calc Distance
    If mD(m%) = 0 Then
      For p% = 1 To gp
        If sqr( (pCx(p%)-mCx(m%))^2 + (pCy(p%)-mCy(m%))^2 ) < 7 Then 
          na% = 1
          Exit For
        End If
      Next
    End If
  ' Guard/Wander - Calc Moves
    If mD(m%) > 0 Then
      If Board_Search%(mCx(m%),mCy(m%),3,0,0,0)> 0 Then
        na% = 1
      End If
    End If
  ' Update
    If na% > 0 Then
      If mA(m%) = 0 Then
        IO_Event ACT_AWAKE,0,m%
      Else
        IO_Event ACT_SPOTTED,0,m%
      End If
      mA(m%) = na%   
    End If
  End If

' Monster Asleep? Nothing to do
  If ma(m%) < 1 Then
  ' Sanity Check
    If ox% <> mCx(m%) OR oy% <> mCy(m%) Then Debug "INSANE MOVE 1"
    Return
  End If

' Time to move!
  IO_Event ACT_FLY,0,m%

' Get Player with Treasure! (If any...)
  tp% = mTp(m%)

' Ghost Attacking?
  If mD(m%) = 0 and mA(m%) = 1 Then
    Debug "Ghost Attacking"
    ' Get Closest Player not in Safe Space
      If tp% = 0 Then
        pm = 1000
        For p% = 1 to gp
          If pH(p%)=0 Or (pCx(p%)=pSx(p%) And pCy(p%)=pSy(p%)) Then
            Debug "Skip Player " + str$(p%) + " as Safe!"
          Else
            pd = sqr( (pCx(p%)-mCx(m%))^2 + (pCy(p%)-mCy(m%))^2 ) 
            If pd < pm Then
              pm = pd
              tp% = p%
              Debug "Track Player " + str$(p%) + "."
            End If
          End If
        Next
      End If

    ' Move Towards Player
      If tp% > 0 Then
      ' Now Have Player tp% to Move Towards
        Debug "Ghost moving towards player."
        dx = sgn(pCx(tp%)-mCx(m%))*2
        dy = sgn(pCy(tp%)-mCy(m%))*2
        IO_Event ACT_FLY,tp%,m%
      Else
      ' Change Activity to Return
        mA(m%) = 2
      End If
    End If

  End If

' Ghost Returning
  If mD(m%) = 0 And mA(m%) = 2 Then
    Debug "Ghost Returning"
    dx = sgn(mTx(m%)-mCx(m%))*2
    dy = sgn(MTy(m%)-MCy(m%))*2
    IO_Event ACT_FLY_HOME,tp%,m%
  End If

' Monster Attacking?
  If mD(m%) > 0 and mA(m%) = 1 Then
    Debug "Monster Attacking"
  ' Follow 5 moves unless has treasure then unlimited!
    l% = 5
    If tp% > 0 Then
      d% = Board_Search%(mCx(m%),mCy(m%),100,2,pCx(tp%),pCy(tp%))
    Else
      d% = Board_Search%(mCx(m%),mCy(m%),l%,0,0,0)
    End If
  ' Debug_SearchShow
  ' Debug_WallsShow
    Debug "Attack->d:" + str$(d%)
    Select Case d%
      Case 0: mA(m%) = 2 ' Mark as returning...
      Case 1: dx = dx + 2
      Case 2: dx = dx - 2
      Case 3: dy = dy + 2
      Case 4: dy = dy - 2
    End Select
  End If

' Monster Returning?
  If mD(m%) > 0 And mA(m%) = 2 Then
    dx = 0 : dy = 0
    Debug "Monster Returning"
    d% = Board_Search%(mCx(m%),mCy(m%),100,2,mTx(m%),mTy(m%))
    Debug "Return->d:" + str$(d%)
    Select Case d%
      Case 0: mD(m%) = 2 : mA(m%) = 1 ' Change to wanderer! (This shouldn't happen)
      Case 1: dx = dx + 2
      Case 2: dx = dx - 2
      Case 3: dy = dy + 2
      Case 4: dy = dy - 2
    End Select
  End If

' Monster Wandering?
  If mD(m%) = 2 And mA(m%) = 1 And dx = 0 And dy = 0 Then
    Debug "Monster Wandering"
    dx = 0 : dy = 0
  ' Falls Asleep?
    d% = Rnd1N(10)
    If d% = 10 Then
    ' Sleep
      mA(m%) = 0
      Debug "Monster fell asleep."
    Else
      d% = Rnd1N(4)
      Debug "Wander->d:" + str$(d%)
      Select Case d%
        Case 1: If bm(ox-1,oy) = 0 Then dx = -2
        Case 2: If bm(ox+1,oy) = 0 Then dx = 2
        Case 3: If bm(ox,oy-1) = 0 Then dy = -2
        Case 4: If bm(ox,oy+1) = 0 Then dy = 2
      End Select
    End If
  End If

' Calc XY
  Debug "dx,dy = " + str$(dx) + "," + str$(dy)
  dx = mCx(m%) + dx
  dy = mCy(m%) + dy

' If Occupied Safe Space Don't go in!
  If bm(dx,dy)=IH Then
  ' Is Warrior at home?
    Debug "Moving to Player Home!"
    For p = 1 to gp
      If pSx(p)=dx And pSy(p)=dy And pCx(p)=dx And pCy(p)=dy Then
        IO_Event ACT_RAGE,p%,m%
        Debug "Can't go in!"
        Return
      End If
    Next
  End If

' Move XY
' Sanity Check
  If ox% <> mCx(m%) OR oy% <> mCy(m%) Then Debug "INSANE MOVE 2"
  mCx(m%) = dx
  mCy(m%) = dy

' If Returning Deactivate if reached home
  If mA(m%) = 2 And mCx(m%)=mTx(m%) And mCy(m%) = mTy(m%) Then
    mA(m%) = 0
  End If

' Show 'To-Do Replace this!!!
  IO_SquareDisplay ox%,oy%,1
  IO_SquareDisplay dx,dy,1

' Found Player?
' Loop Through Players
  For p% = 1 to gp
    If pCx(p%) = mCx(m%) And pCy(p%) = mCy(m%) Then 
      Monster_Attacks p%, m%
      Return
    End If
  Next

' Back at Treasure And Treasure Still There? - Sleep
  If mTp(m%) = 0 And mCx(m%) = mTx(m%) And mCy(m%) = mTy(m%) Then
    IO_Event ACT_SLEEP,0,m%
    mA(m%) = 0
  End If

End Sub


' +++++++++++++++
' Search Routines
' +++++++++++++++


Function Board_Search%(x%,y%,nm%,st%,x2%,y2%) as Integer ' Dungeon Search
' ml% Max Level (Find in nm% moves)
' st% Search Type. 0 = Player, 1 = Monster, 2 = XY
' Returns 0 if not found, otherwise direction (opposite direction!)
  Local Integer r, c, e%, e1%, e2%, l%, b%, d%, f%, ll%, lx, ly ' f% = Found Flag
  Board_Search% = 0 ' Default not found
' Clear Search Grid
  For r = 1 to bsy
    For c = 1 to bsx
      bs(c,r) = 0
    Next
  Next
' Setup Search
  Debug "Board_search @("+str$(x%)+","+str$(y%)+") For "+str$(st%)+":("+str$(x2%)+","+str$(y2%)+") in "+str$(nm%)+" moves."
  lx% =x% : ly% = y%
  l% = 1
  ll% = nm%+l%+1 ' Start at 1 so +2 is last level
  bs(x%,y%) = l%
' Initial Edge List is Starting Location
  e1% = 1
  ex1(1) = lx% 
  ey1(1) = ly%
  e2% = 0
' Search
  f% = 0
  Do
  ' Search Level
  ' Takes edges from e1, place edges in e2
    l% = l% + 1
  ' Debug "Search level " + str$(l%)
  ' Debug_EdgesShow e1%
    For e% = 1 to e1%
    ' Get Edge
      lx% = ex1(e%) : ly% = ey1(e%)
    ' Found ?
      Select Case st%
        Case 0: f% = PlayerUnsafeAt(lx%,ly%)
        Case 1: f% = MonsterAt(lx%,ly%) 
        Case 2: f% = lx% = x2% And ly% = y2%
      End Select
      If f% > 0 Then
        l% = l% -1 'Found a previous level
        Exit For
      End If
    ' If Last Level Not going further!
      If l% = ll% Then Continue For
    ' Left -2,0
      If bm(lx%-1,ly%) = 0 Then
        If bs(lx%-2,ly%) = 0 Then
          bs(lx%-2,ly%) = l% : Inc e2% : ex2(e2%) = lx%-2 : ey2(e2%) = ly%
        End If
      End If
    ' Right +2,0
      If bm(lx%+1,ly%) = 0 Then
        If bs(lx%+2,ly%) = 0 Then
          bs(lx%+2,ly%) = l% : Inc e2% : ex2(e2%) = lx%+2 : ey2(e2%) = ly%
        End If
      End If
    ' Up 0,-2
      If bm(lx%,ly%-1) = 0 Then
        If bs(lx%,ly%-2) = 0 Then
          bs(lx%,ly%-2) = l% : Inc e2% : ex2(e2%) = lx% : ey2(e2%) = ly%-2
        End If
      End If
    ' Down 0,+2
      If bm(lx%,ly%+1) = 0 Then
        If bs(lx%,ly%+2) = 0 Then
          bs(lx%,ly%+2) = l% : Inc e2% : ex2(e2%) = lx% : ey2(e2%) = ly%+2
        End If
      End If
    Next
  ' Found ?
    If f% > 0 Then Exit Do
  ' Copy e2 to e1
    For e% = 1 to e2%
      ex1(e%) = ex2(e%) : ey1(e%) = ey2(e%)
    Next
    e1% = e2%
    e2% = 0
  Loop Until l% = ll% Or e1% = 0
' Not Found ? in ml% Moves? -> Give up!
  If f% = 0 Then
    Debug "Search failed. Giving up."
    Exit Function
  End If
' Debug_SearchShow
  Debug "Found at " + str$(x%) + "," + str$(y%) + " : " + str$(l%)
' Okay - Now to walk it back... Found a x%, y%, l%
  For b% = l% -1 to 1 Step -1
  ' Debug "Backtrack " + str$(x%) + " " + str$(y%) + " Find " + str$(b%)
  ' Remember Move
    d% = 0
  ' Find Previous Move - Check Walls! (No need to check boundaries)
    If bm(lx%-1,ly%) = 0 Then
      If bs(lx%-2,ly%) = b% Then
        lx% = lx% - 2 : d% = 1
      End If
    End If
    If d% = 0 And bm(lx%+1,ly%) = 0 Then
      If bs(lx%+2,ly%) = b% Then
        lx% = lx% + 2 : d% = 2
      End If
    End If
    If d% = 0 And bm(lx%,ly%-1) = 0 Then
      If bs(lx%,ly%-2) = b% Then
        ly% = ly% - 2 : d% = 3
      End If
    End If
    If d% = 0 And bm(lx%,ly%+1) = 0 Then
      If bs(lx%,ly%+2) = b% Then
        ly% = ly% + 2 : d% = 4
      End If
    End If
  ' If no move we've screwed up
    If d% = 0 Then
      Debug "No move found - we've screwed up."
      Exit Function
    End If        
  Next
  Board_Search = d%
End Function


' +++++++++++++
' Attack/Battle
' +++++++++++++


Sub Monster_Attacks(p%, m%)
  Local Integer m2%
' Monster Attack!
  IO_Event ACT_ATTACK,p%,m%
  mA(m%) = 1
  IO_AttackAnimate p%,m%
' Wound Warrior
  pH(p%) = pH(p%) - 1
  IO_PlayerUpdate p%
' Move Warrior to Safety
  pCx(p%) = pSx(p%)
  pCy(p%) = pSy(p%)
' Redraw Square to Remove Warrior!
  IO_SquareDisplay mCx(m%), mCy(m%), 1
' If Wounds too great or carrying treasure he's dead
  If pT(p%) > 0 OR pH(p%) < 1 Then
    IO_Event ACT_DEFEAT,p%,m%
    pH(p%) = 0
  ' Drop Treasure!
    If pT(p%) > 0 Then
      m2% = pT(p%) ' Could be a different monster?
      pT(p%) = 0
      bm(mCx(m%),mCy(m%))=IT
    End If
    Level_OverCheck
    Return
  End If
' Return To Secret Room
  IO_Event ACT_RETURN,p%,m%
End Sub


' +++++++++++++++++
' Utility Functions
' +++++++++++++++++

Function Odd(n as Integer) As Integer
  Odd = n Mod 2
End Function

Function Rnd1N(n%) as Integer ' 1...N
  Rnd1N = Fix(Rnd()*n%+1)
End Function

Function Rnd0N(n%) as Integer ' 0...N
  Rnd0N = Fix(Rnd()*(n%+1))
End Function

Function DnXRnd() as Integer ' 2...2*bdx
  DnXRnd = Rnd1N(bdx)*2
End Function

Function DnYRnd() as Integer ' 2...2*bdy
  DnYRnd = Rnd1N(bdy)*2
End Function

Function DnSxInterior() as Integer
  DnSxInterior = Fix(rnd() * (bsx-2) + 2)
End Function

Function DnSyInterior() as Integer
  DnSyInterior = Fix(rnd() * (bsy-2) + 2)
End Function

Function DnOccupied(x%,y%) as Integer
  DnOccupied = bm(x%,y%)
End Function

Function DnEmpty(x%,y%) as Integer
  DnEmpty = 1
  If DnOccupied(x%,y%) Then dnEmpty = 0
End Function

Function DnDistance(x%,y%,x2%,y2%) as Integer
  DnDistance = sqr( (x%-x2%)^2 + (y%-y2%)^2 )
End Function

Function InRange(x%,y%,x2%,y2%) as Integer
  InRange = 0
  If DnDistance(x%,y%,x2%,y2%) < 7 Then InRange = 1
End Function

Function WhoseTreasure(x%,y%) as Integer
  WhoseTreasure = 0
  Local Integer m%
  For m%=1 to gm
    If mTx(m%) = x% And mTy(m%) = y% Then
      WhoseTreasure = m%
      Exit Function
    End If 
  Next
End Function

Function BoardTest(x%,y%,v%) as Integer
  BoardTest = 0
  If x% > 0 And x% < bsx And y% > 0 And y% < bsy Then
    If bm(x%,y%)=v% Then BoardTest = 1
  End If
End Function


Sub CheckPosts x%,y%
  Local Integer ox%,oy%
  If Odd(x%) Then
    CheckPost x%,y%-1
    CheckPost x%,y%+1
  Else
    CheckPost x%-1,y%
    CheckPost x%+1,y%
  End If
End Sub

Sub CheckPost x%,y%
  If x% = 1 or x% = bsx or y% = 1 or y% = bsy Then
    Return
  End If
  If bv(x%-1,y%) And bv(x%+1,y%) And bv(x%,y%-1) And bv(x%,y%+1) Then
    bv(x%,y%) = 1
  End If
End Sub


Function PlayerUnsafeAt(x%,y%) as Integer
  Local p%
  p% = PlayerAt(x%,y%)
  If p% > 0 Then
    If pSx(p%) = x% And pSy(p%) = y% Then p% = 0
  End If
  PlayerUnsafeAt = p%
End Function

Function PlayerAt(x%,y%) as Integer
  Local p%
  PlayerAt = 0
  Do
    Inc p%
    If pH(p%) > 0 And pCx(p%) = x% And pCy(p%) = y% Then
      PlayerAt = p%
      Exit Function
    End If
  Loop Until p% = gp
End Function

Function PlayerNUnsafeAt(x%,y%,id%) as Integer
  Local p%
' Debug "PNUnsafe " + str$(x%) + "," + str$(y%) + " " + str$(id%)
  p% = PlayerNAt(x%,y%,id%)
  If p% > 0 Then
    If pSx(p%) = x% And pSy(p%) = y% Then
      Debug "Player " +str$(p%) + " is safe!" : p% = 0
    End If
  End If
  If p% > 0 Then
     Debug "Player " + str$(p%) + " found unsafe at " +str$(x%) + "," + str$(y%)
  End If
  PlayerNUnsafeAt = p%
End Function

Function PlayerNAt(x%,y%,id%) as Integer
  Local p%
  PlayerNAt = 0
  If id% > 0 Then p% = id% - 1' : Debug "PlayerNAt id:"+str$(id%)
  Do
    Inc p%
    If pH(p%)>0 And pCx(p%) = x% And pCy(p%) = y% Then
      PlayerNAt = p%
    ' Debug "Player " + str$(p%) + " found at " +str$(x%) + "," + str$(y%)
      Exit Function
    End If
  Loop Until p% = gp Or id% > 0
End Function

Function TreasureAt(x%,y%) as Integer
  Local m%
  TreasureAt = 0
  Do
    Inc m%
    If mTx(m%) = x% And mTy(m%) = y% Then
      TreasureAt = m%
      Exit Function
    End If
  Loop Until m% = gm
End Function

Function MonsterAt(x%,y%) as Integer
  Local m%
  MonsterAt = 0
  Do
    Inc m%
    If mA(m%) > -1 And mCx(m%) = x% And mCy(m%) = y% Then
      MonsterAt = m%
      Exit Function
    End If
  Loop Until m% = gm
End Function


Function MonsterNAt(x%,y%,id%) as Integer
  Local m%
  MonsterNAt = 0
  If id% > 0 Then m% = id% - 1
  Do
    Inc m%
    If mA(m%) > -1 And mCx(m%) = x% And mCy(m%) = y% Then
      MonsterNAt = m%
      Exit Function
    End If
  Loop Until m% = gm
End Function


Function Location(d%) as Integer
  Location = (d% \ 2) * 8 + ((d% - 1) \ 2) * 32
End Function


Sub IO_PlayerLoad s% 
  LoadSpritePNG s%, "hero" + str$(Rnd1N(WI))
End Sub

Sub IO_MonsterLoad s%
  LoadSpritePNG s%, "monster" + str$(Rnd1N(MI))
End Sub

Sub IO_GhostLoad s%
  LoadSpritePNG s%, "ghost" + str$(Rnd1N(GI))
End Sub

Sub LoadSpritePNG s%, filename$
  Print filename$
  Sprite LoadPNG s%, "img/" + filename$ + ".png"
End Sub


' ++++++++++++++
' Debug Routines
' ++++++++++++++

Sub Debug_EdgesShow em%
  Local e%,m$
  m$ = "Edges: "
  For e% = 1 to em%
    m$ = m$ + "("+str$(ex1(e%)/2)+","+str$(ey1(e%)/2)+") "
  Next
  Debug m$
End Sub


Sub Debug_SearchShow
  Local Integer x,y
  Local String a
  Debug "Search"
  For y = 2 to sy - 1 step 2
    a = ""
    For x = 2 to sx - 1 step 2
      a = a + " " + str$(bs(x,y))
    Next
    Debug a
  Next      
End Sub

Sub Debug_WallsShow
  Local Integer x,y,ox,oy
  Local String a
  Debug "Walls"
  For y = 1 to sy
    a = ""
    For x = 1 to sx
      ox = Odd(x) : oy = Odd(y)
      If ox And oy Then 
        a = a + " "
      Else If ox Then
        a = a + str$(bm(x,y))
      Else If oy Then
        a = a + str$(bm(x,y))
      Else
        a = a + " "
      End If     
    Next
    Debug a
  Next      
End Sub


' ++++++++++++++++++++++++++
' I/O Display/Sound Routines
' ++++++++++++++++++++++++++


' +++++++++++++++++++++++
' IO - Initialization Routines
' +++++++++++++++++++++++


Sub IO_AtariInitialize
  If CON_ATARI_ON=0 Then Return
' Configure Atari GPIO
  SetPin CON_ATARI_UP, DIN, PULLUP  
  SetPin CON_ATARI_DOWN, DIN, PULLUP  
  SetPin CON_ATARI_LEFT, DIN, PULLUP  
  SetPin CON_ATARI_RIGHT, DIN, PULLUP  
  SetPin CON_ATARI_FIRE, DIN, PULLUP    
End Sub

Sub IO_ClassicInitialize
  If CON_CLASS_ON= 0 Then Return
' P1
  If CON_CLASS_P1>0 Then
    On Error Skip
    Wii Classic Open CON_CLASS_P1
    If MM.ERRNO <> 0 Then
      ' ? "Classic controller ",CON_CLASS_P1, " not found."      
      Pause 2000
    End If
  End If
' P2
  If CON_CLASS_P2>0 Then
    On Error Skip
    Wii Classic Open CON_CLASS_P2
    If MM.ERRNO <> 0 Then
      ' ? "Classic controller ",CON_CLASS_P2, " not found."      
      Pause 2000
    End If
  End If
End Sub


Sub IO_ClassicDeInitialize
  If CON_CLASS_ON= 0 Then Return
' P1
  If CON_CLASS_P1>0 Then
    On Error Skip
    Wii Classic Close CON_CLASS_P1
  End If
' P2
  If CON_CLASS_P2>0 Then
    On Error Skip
    Wii Classic Close CON_CLASS_P2
  End If
End Sub


' +++++++++++++++++++++++
' Display Main_Initialize
' +++++++++++++++++++++++

Sub IO_DisplayInitialize
  Local Integer rx, ry, tx, ty,r
' Setup Board & Screen
' Dungeon Dimensions and Map Size
' Screen & Font Size
  sx = mm.hres : sy = mm.vres
  Font 1
  sFw = mm.info(fontwidth) : sFh = mm.info(fontheight)
  Font 2
  sF2w = mm.info(fontwidth) : sF2h = mm.info(fontheight)
  Font 1
' Reserve Debug space
  If df > 0 Then sx = sx - Int(sx / 2)
' Calc Board Size
' - Min (32+6) For Player Sides
' - Min (sF2w+6) For Banner and Status (so far - may go to f1)
  r = sFw*6 + 2 '32 + 6
  If r < 38 Then r = 38
  tx = sx - 2*(r) - 8 ' 8 For Starting Wall.
  ty = sy - 2*(sF2h+6) - 8 ' 8 For Starting Wall.
  bdx = Int(tx / 40) ' 40 per column
  bdy = Int(ty / 40) ' 40 per column
  bsx = bdx*2+1
  bsy = bdy*2+1
' Calc Remainder - Split among sides and center board
' rx = sx - (bdx*40 + 8) - 2*(32+6)
  rx = sx - (bdx*40 + 8) - 2*(r)
  ry = sy - (bdy*40 + 8) - 2*(sF2h+6)
' Block Off Players
  sPx(1) = 0 : sPy(1) = 0
  sPw(1) = r + rx/2 : sPh(1) = sy
  sPx(2) = sx - (r + rx/2) : sPy(2) = 0 
  sPw(2) = r + rx/2 : sPh(2) = sy
' Block Off Banner
  sBx = sPx(1) + sPw(1)
  sBy = 0
  sBw = sx - sPw(1) - sPw(2)
  sBh = sF2h + 6 + ry/2
' Block Off Status
  sSx = sBx
  sSy = sy - sF2h - 6 - ry/2
  sSw = sBw
  sSh = sBh
' Block Off Board
  bx = sBx : by = sBy + sBh + 1
End Sub


' +++++++++++++++++
' Display - Mode
' +++++++++++++++++

Sub IO_ScreenDetermine
  Local String l1, l2
' Defaults
  sm = 8 : df = 0
' Read Screen File
  On Error Skip
  Open ePath + "screen.txt" for Input as #1
  If MM.ERRNO = 0 Then
    If Not Eof(1) Then
      Input #1, sm, df
    End If
    Close #1
  End If
' Query Screen?
  If oq>0 Then
    IO_ScreenQuery
  End If
' Write Screen File
  On Error Skip
  Open ePath + "screen.txt" for Output as #1
  Print #1, sm;","; df
  Close #1
End Sub


Sub IO_ScreenQuery
' Return
  Local Integer sx, sy, sFw, sF2w, sFh, sF2h
  Mode 2 '8
  Cls
  sx = mm.hres : sy = mm.vres
  Font 1
  sFw = mm.info(fontwidth) : sFh = mm.info(fontheight)
  Font 2
  sF2w = mm.info(fontwidth) : sF2h = mm.info(fontheight)
  Font 1
  Colour RGB(White), RGB(Black)
  Local Integer cw, cl ' char width and length
  Local Integer dx, dy, lh ' line height
  Local Integer x, y, xn, yn, xv, yv, wv, s, c, t, t1, t2 ' Section
  Local Integer md(18), lm
  Local String m

' Mode List
  md(1) = 5 : md(2) = 6 : md(3) = 3 : md(4) = 7 : md(5) = 17
  md(6) = 13 : md(7) = 4 : md(8) = 2 : md(9) = 8 : md(10) = 1
  md(11) = 10 : md(12) = 12 : md(13) = 14 : md(14) = 9 : md(15) = 11
  md(16) = 15 : md(17) = 16

' Convert Screen Mode to Local Mode
  For lm = 1 to 17
    If md(lm)=sm Then Exit For
  Next

' Calculations
  cw = 28 ' 1 section
  dx = (sx - cw*sFw)/2
  cl = 1 + 1 + 1 + 3 + 17 ' 1 Header, 1 Title, 1 Instruction, 3 Seperators, 17 options
  lh = sFh+2 ' Two extra pixels on each line (Fox Box)
  dy = (sy - cl*lh)/2
  dc = 610

' Header
  m = "Screen"
  Print @((sx-Len(m)*sFw)/2,dy) m;
  y = dy + lh*2
' Titles
  Print @(dx,y) "Mode DimX x DimY Notes";
  y = y + lh*2
  Print @(dx,y) "   5  240 x  216 (Too Small)";
  y = y + lh  
  Print @(dx,y) "   6  256 x  240 (Too Small)";
  y = y + lh  
  Print @(dx,y) "   3  320 x  200 (Too Small)";
  y = y + lh  
  Print @(dx,y) "   7  320 x  240";
  y = y + lh  
  Print @(dx,y) "  17  348 x  240";
  y = y + lh
  Print @(dx,y) "  13  400 x  300";
  y = y + lh  
  Print @(dx,y) "   4  480 x  432";
  y = y + lh  
  Print @(dx,y) "   2  640 x  400";
  y = y + lh  
  Print @(dx,y) "   8  640 x  480 (Default)";
  y = y + lh  
  Print @(dx,y) "   1  800 x  600";
  y = y + lh  
  Print @(dx,y) "  10  848 x  480 ";
  y = y + lh  
  Print @(dx,y) "  12  960 x  540 ";
  y = y + lh  
  Print @(dx,y) "  14  960 x  540 ";
  y = y + lh  
  Print @(dx,y) "   9 1024 x  768 ";
  y = y + lh  
  Print @(dx,y) "  11 1280 x  720 ";
  y = y + lh  
  Print @(dx,y) "  15 1280 x 1024 ";
  y = y + lh  
  Print @(dx,y) "  16 1920 x 1080 (Enormous!)";
  y = y + lh*2  
  Print sm, lm, md(lm), df;

' Instructions
  m = "(Arrows to Select, Enter to Proceed)"
  Print @((sx-Len(m)*sFw)/2,y) m;
' Boxes
  dc = 620
' Section
  y = dy + lh*2
  wv = cw*sFw
' Section Mode
  Box dx-1, y-1, wv+2, lh+1,,RGB(BLUE)
' Values
  y = dy + lh*4
' Players
  yv = y + (lm-1)*lh
  Box dx-1, yv-1, wv+2, lh+1,,RGB(GREEN)

' Get Input
  dc = 630
  c = 0
  Do
    c = Game_Input(1)
    Select Case c
      Case KEY_UP:
        t1 = lm: t2 = t1 - 1: lm = t2 : If t2<1 Then t2 = 17 : lm = t2
      ' Remove Box
        y = dy + lh*4 + (t1-1)*lh
        Box dx-1, y-1, wv+2, lh+1,,RGB(BLACK)
      ' Draw Box
        y = dy + lh*4 + (t2-1)*lh
        Box dx-1, y-1, wv+2, lh+1,,RGB(GREEN)    
      Case KEY_DOWN:
        t1 = lm: t2 = t1 + 1: lm = t2 : If t2>17 Then t2 = 1 : lm = t2
      ' Remove Box
        y = dy + lh*4 + (t1-1)*lh
        Box dx-1, y-1, wv+2, lh+1,,RGB(BLACK)
      ' Draw Box
        y = dy + lh*4 + (t2-1)*lh
        Box dx-1, y-1, wv+2, lh+1,,RGB(GREEN)    
      Case KEY_DONE:
        c = 0
      Case KEY_PICKUP:
        c = 0
    End Select
  Loop Until c = 0

' Get Screen Mode From Local Mode
  sm = md(lm)  
  Cls
End Sub


' +++++++++++++++++
' Display - Game
' +++++++++++++++++

Sub IO_GameDetermine
' Change Screen Mode
  Local Integer sx, sy, sFw, sF2w, sFh, sF2h
  Mode 8
  sx = mm.hres : sy = mm.vres
  Font 1
  sFw = mm.info(fontwidth) : sFh = mm.info(fontheight)
  Font 2
  sF2w = mm.info(fontwidth) : sF2h = mm.info(fontheight)
  Font 1
  Cls
  Local Integer cw, cl ' char width and length
  Local Integer dx(3), dy, lh ' line height
  Local Integer x, y, xn, yn, xv, yv, wv, s, c, t, t1, t2 ' Section
  Local String m
' Read Game File
' Defaults
  quit = 0
  gp = 1 : gt = 2 : gd = 3
' Read Game File
  On Error Skip
  Open ePath + "game.txt" for Input as #1
  If MM.ERRNO = 0 Then
    If Not Eof(1) Then
      Input #1, gp, gt, gd
    End If
    Close #1
  End If
' Calculations
  cw = 2*2 + 6 + 8 + 10 ' 2 seperators, 3 sections
  cw = 2*2 + 3*10 ' 2 seperators, 3 sections (All 10 wide!)
  dx(1) = (sx - cw*sFw)/2
  dx(2) = dx(1) + (2 + 6)*sFw
  dx(2) = dx(1) + (2 + 10)*sFw
  dx(3) = dx(2) + (2 + 8)*sFw
  dx(3) = dx(2) + (2 + 10)*sFw
  cl = 1 + 1 + 1 + 3 + 5 ' 1 Header, 1 Title, 1 Instruction, 3 Seperators, 5 options
  lh = sFh+2 ' Two extra pixels on each line (Fox Box)
  dy = (sy - cl*lh)/2
  dc = 610
' Header
  m = "Options"
  Print @((sx-Len(m)*sFw)/2,dy) m;
  y = dy + lh*2
' Titles
  Print @(dx(1),y) "Players";
  Print @(dx(2),y) "Game";
  Print @(dx(3),y) "Difficulty";
  y = y + lh*2
' Row 1
  Print @(dx(1),y) "One";
  Print @(dx(2),y) "Surprise";
  Print @(dx(3),y) "Beginner";
  y = y + lh  
' Row 2
  Print @(dx(1),y) "Two";
  Print @(dx(2),y) "Explore";
  Print @(dx(3),y) "Easy";
  y = y + lh  
' Row 3
  Print @(dx(2),y) "Excavate";
  Print @(dx(3),y) "Normal";
  y = y + lh  
' Row 4
  Print @(dx(3),y) "Hard";
  y = y + lh  
' Row 5
  Print @(dx(3),y) "Fiendish";
  y = y + lh*2
' Instructions
  m = "(Arrows to Select, Enter to Proceed, Esc to Quit)"
  Print @((sx-Len(m)*sFw)/2,y) m;
' Boxes
' Section
  s = 1
  y = dy + lh*2
  wv = 10*sFw
' Section Players
  Box dx(1)-1, y-1, wv+2, lh+1,,RGB(BLUE)
' Values
  y = dy + lh*4
' Players
  yv = y + (gp-1)*lh
  Box dx(1)-1, yv-1, wv+2, lh+1,,RGB(GREEN)
' Game
  yv = y + (gt-1)*lh
  Box dx(2)-1, yv-1, wv+2, lh+1,,RGB(GREEN)
' Difficulty
  yv = y + (gd-1)*lh
  Box dx(3)-1, yv-1, wv+2, lh+1,,RGB(GREEN)
' Get Input
  c = 0
  Do
    c = Game_Input(1)
    Select Case c
      Case KEY_RIGHT:
        y = dy + lh*2
      ' Remove Box
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLACK)
        s = s + 1
        If s > 3 Then s=1
      ' Draw Box
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLUE)
      Case KEY_LEFT:
        y = dy + lh*2
      ' Remove Box
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLACK)
        s = s - 1
        If s < 1 Then s=3
      ' Draw Box
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLUE)
      Case KEY_UP:
        Select Case s
          Case 1: t1 = gp: t2 = t1 - 1: gp = t2 : If t2<1 Then t2 = 2 : gp = t2
          Case 2: t1 = gt: t2 = t1 - 1: gt = t2 : If t2<1 Then t2 = 3 : gt = t2
          Case 3: t1 = gd: t2 = t1 - 1: gd = t2 : If t2<1 Then t2 = 5 : gd = t2
        End Select
      ' Remove Box
        y = dy + lh*4 + (t1-1)*lh
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLACK)
      ' Draw Box
        y = dy + lh*4 + (t2-1)*lh
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(GREEN)    
      Case KEY_DOWN:
        Select Case s
          Case 1: t1 = gp: t2 = t1 + 1: gp = t2 : If t2>2 Then t2 = 1 : gp = t2
          Case 2: t1 = gt: t2 = t1 + 1: gt = t2 : If t2>3 Then t2 = 1 : gt = t2
          Case 3: t1 = gd: t2 = t1 + 1: gd = t2 : If t2>5 Then t2 = 1 : gd = t2
        End Select
      ' Remove Box
        y = dy + lh*4 + (t1-1)*lh
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(BLACK)
      ' Draw Box
        y = dy + lh*4 + (t2-1)*lh
        Box dx(s)-1, y-1, wv+2, lh+1,,RGB(GREEN)    
      Case KEY_DONE:
        c = 0
      Case KEY_PICKUP:
        c = 0
      Case KEY_QUIT:
        quit = 1 : c = 0
    End Select
  Loop Until c = 0
' Save Game File - For next game!
  On Error Skip
  Open ePath + "game.txt" for Output as #1
  Print #1, gp;",";gt;",";gd
  Close #1
' Prepare
  Cls
  gm = 2 ' What are these?
  gap = 0
End Sub


Sub IO_BaseGraphicsLoad
  Local Integer i
' Load Background Art on Page 1
  Page Write 1
  Load BMP "img\background"
  Page Write 0
' 16 Sprites
' Load Hit Sprites
  LoadSpritePNG S_HIT1, "hit1a"
  LoadSpritePNG S_HIT2, "hit1b"
  LoadSpritePNG S_HIT3, "hit1c"
  LoadSpritePNG S_HIT4, "hit1d"
' Load Map Sprite
  LoadSpritePNG S_MAP, "mapbook"
' Load Treasure Sprite
  LoadSpritePNG S_TREA, "chest"
' Load Light/Torch Sprite
  LoadSpritePNG S_TORCH, "torch"
' Load Potion
  LoadSpritePNG S_POTION, "potion"
' Home
  LoadSpritePNG S_BASE, "home"
' Loading Now -> But WILL be overridded for each game!
' Just to get it defaulted/debugged
' Ghosts
  IO_GhostLoad S_GHOST1
  IO_GhostLoad S_GHOST2
' Monsters
  IO_MonsterLoad S_MON1
  IO_MonsterLoad S_MON2
  IO_MonsterLoad S_MON3
'  IO_MonsterLoad S_MON4
' Players
  IO_PlayerLoad S_WAR1
  IO_PlayerLoad S_WAR2
End Sub

Sub IO_BaseGraphicsPreload
  Mode sm
  sx = mm.hres : sy = mm.vres
  Font 1
  sFw = mm.info(fontwidth) : sFh = mm.info(fontheight)
  Font 2
  sF2w = mm.info(fontwidth) : sF2h = mm.info(fontheight)
  Font 1
End Sub

Sub IO_BaseGraphicsReload
  Mode sm
  Page Write 1
  Load BMP "img\background"
  Page Write 0
End Sub

Sub IO_GameSpritesLoad
' Unload
  Sprite Close S_GHOST1
  Sprite Close S_GHOST2
  Sprite Close S_MON1
  Sprite Close S_MON2
  Sprite Close S_MON3
  Sprite Close S_WAR1
  Sprite Close S_WAR2
' Ghosts
  IO_GhostLoad S_GHOST1
  IO_GhostLoad S_GHOST2
' Monsters
  IO_MonsterLoad S_MON1
  IO_MonsterLoad S_MON2
  IO_MonsterLoad S_MON3
' Players
  IO_PlayerLoad S_WAR1
  IO_PlayerLoad S_WAR2
End Sub


' ++++++++++++++++++++++++
' Low Level Input Routines
' ++++++++++++++++++++++++


Function IO_AtariInput(p%) as Integer
  IO_AtariInput = KEY_NOTHING
  If CON_ATARI_ON=0 Or p%<>1 Then Exit Function
  Local Integer c
  If Pin(CON_ATARI_UP)=0 Then c=KEY_UP
  If Pin(CON_ATARI_DOWN)=0 Then c=KEY_DOWN
  If Pin(CON_ATARI_LEFT)=0 Then c=KEY_LEFT
  If Pin(CON_ATARI_RIGHT)=0 Then c=KEY_RIGHT
  If Pin(CON_ATARI_FIRE)=0 Then c=KEY_PICKUP
  IO_AtariInput=c
End Function

Function IO_ClassicInput(p%) as Integer
  IO_ClassicInput = KEY_NOTHING
  If CON_CLASS_ON=0 Then Exit Function
  Local Integer c,n
  n=CON_CLASS_P1
  If p%<>1 Then n=CON_CLASS_P2
  If n=0 Then Exit Function
  c = 0
  On Error Skip
  c = Classic(B,n)
  If MM.ERRNO<>0 Then
    Debug MM.ERRMSG$
  End If
  Select Case c
    Case 2048 : c = KEY_DONE
    Case  256 : c = KEY_LEFT
    Case  128 : c = KEY_UP
    Case   64 : c = KEY_RIGHT
    Case   32 : c = KEY_DOWN
    Case    4 : c = KEY_QUIT
    Case    1 : c = KEY_PICKUP
    Case    0 : c = KEY_NOTHING
    Case  Else: c = KEY_BAD
  End Select
  IO_ClassicInput = c
End Function

Function IO_InputKbd(p%) as Integer
  IO_InputKbd = KEY_NOTHING
  Local String a
  Local Integer c,d
' Key Pressed?
  a = Inkey$
  If a="" Then Exit Function
' Key Pressed!
  d = Asc(a)
' Save Screen
  If d=157 Then
    a = "screen."+Left$(Date$,2)+Mid$(Date$,4,2)+Right$(Date$,2)+"."+Left$(Time$,2)+Mid$(Time$,4,2)+Right$(Time$,2)+".bmp"
    save image a
    exit function
  End If
  c = KEY_BAD
  d = Asc(a)
' All Lowercase
  If d>96 And d<123 Then d=d-32

' All Players
  Select Case d ' Need new keys!!!
    Case  27: c = KEY_QUIT
  ' Functions
    Case 145: c = KEY_SOUND
    Case 146: c = KEY_TALK
  ' Debug
    Case 153: c = KEY_DEBUG_TREASURE
    Case 154: c = KEY_DEBUG_MONSTERS
    Case 155: c = KEY_DEBUG_SHOW
    Case 156: c = KEY_DEBUG_LIGHT
  End Select
  IO_InputKbd = c
  If c <> KEY_BAD Then Exit Function
  
' Player 1
  If p% = 1 Then
    Select Case d
      Case 128, 85, 56 'U 8
        c = KEY_UP
      Case 130, 72, 52 'H 4
        c = KEY_LEFT
      Case 129, 77, 50 'M 2
        c = KEY_DOWN
      Case 131, 75, 54 'K 6
        c = KEY_RIGHT
      Case 80, 74      'P J
        c = KEY_PICKUP
      Case  13, 89     'Enter Y
        c = KEY_DONE
    End Select
  End If

' Player 2
  If p% = 2 Then
    Select Case d
      Case 87 'W
        c = KEY_UP
      Case 65 'A
        c = KEY_LEFT
      Case 88 'X 
        c = KEY_DOWN
      Case 68 'D
        c = KEY_RIGHT
      Case 83 'S
        c = KEY_PICKUP
      Case 81 'Q
        c = KEY_DONE
    End Select
  End If

' All Done  
  IO_InputKbd = c
End Function


' ++++++++++++++++++++
' Display - Debug Setup
' ++++++++++++++++++++

Sub IO_DebugSetup
  If df=0 Then Return
  Local Integer tx
  tx = sPx(2)+sPw(2)+1
' Create/Recreate Windows
  if ds = 0 Then wn.setup 1
' Output Window - 0
  wn.create 0, tx, 0, mm.hres-tx, mm.vres/2, 1, rgb(green), rgb(black), "", rgb(white)
' Debug Window - 1
  wn.create 1, tx, mm.vres/2, mm.hres-tx, mm.vres/2, 1, rgb(green), rgb(black), "", rgb(white)
  ds = 1
End Sub

' ++++++++++++++++++++++++++
' Display - Screen/Board
' ++++++++++++++++++++++++++

Sub IO_ScreenDraw
  Local String m
  IO_PlayerDraw 1
  IO_PlayerDraw 2
' Banner
  Select Case gt
    Case 1: m = "Surprise"
    Case 2: m = "Explore"
    Case 3: m = "Excavate"
    Case Else: m = "???"
  End Select
  If sx > 500 Then m = "Dungeon " + m
  IO_Sprint2 sBx+4, sBy+4, sBw, m '"Dungeon Monsters"
' Level
  IO_Sprint1L sBx+4+10, sBy+4, "Level"
  IO_Sprint1LN sBx+4+sFw+10, sBy+4+sFh, gl, 3
' Sound
  IO_Sprint1L sBx+4+10+6*sFw, sBy+4, "Sound"
  IO_SoundDraw
' Game
  Select Case gd
    Case 1: m = "Begin"
    Case 2: m = "Easy"
    Case 3: m = "Norm"
    Case 4: m = "Hard"
    Case 5: m = "Fiend"
    Case Else: m = "???"
  End Select
  IO_Sprint1R sBx+sBw-4-10, sBy+4, "Game"
  IO_Sprint1R sBx+sBw-4-10, sBy+4+sFh, m
' Talk
  IO_Sprint1R sBx+sBw-4-10-6*sFw, sBy+4, "Talk"
  IO_TalkDraw
' Banner Border
  Blit 0,0,sBx,sBy,8,sBh+1,1
  Blit 0,0,sBx+sBw-8,sBy,8,sBh+1,1
' Status
  IO_Sprint2 sSx+4,sSy+4, sSw, "" '"Status Line"
' Status Border
  Blit 0,0,sSx,sSy,8,sSh,1
  Blit 0,0,sSx+sSw-8,sSy,8,sSh,1
End Sub

Sub IO_TalkDraw
  Local String m
  m = "Off"
  If ot>0 Then m = "On "
  IO_Sprint1R sBx+sBw-4-10-6*sFw, sBy+4+sFh, m
End Sub

Sub IO_SoundDraw
  Local String m
  m = "Off"
  If os>0 Then m = "On "  
  IO_Sprint1L sBx+4+10+6*sFw, sBy+4+sFh, m
End Sub

Sub IO_PlayerDraw(p as Integer)
  Local Integer x, y, w, s, s2, g, g2,c
  If gp < p Then Return
  x = sPx(p)
  y = sPy(p)
  w = sPw(p)
  g = (w - 38) / 2
  g = (w - 32) / 2
  g2 = (w - sFw*6)/2
  s = 8 : s2 = 4
' Banner
  y = y + 4
  IO_Sprint2 x, y, w, "P" + str$(p)
  y = y + sF2h  
' Icon
  Sprite Write pS(p), x+g, y' x+g, y 'x+g  
  y = y + 32 + s2 ' + s ' + s
' Moves
  IO_Sprint1 x, y, w, "Moves"
  y = y + sFh
  IO_Sprint1N x, y, w, pM(p), 1 
  y = y + sFh + s  
  Blit 0,0,x,y-s+2,w,4,1
' Points
  IO_Sprint1 x, y, w, "Score"
  y = y + sFh
  IO_Sprint1N x, y, w, pP(p), 5
  y = y + sFh + s
  Blit 0,0,x,y-s+2,w,4,1
' Health
  IO_Sprint1 x, y, w, "Health"
  y = y + sFh
  c = RGB(GREEN)
  If pH(p%) < 1 Then c = RGB(GRAY)
  Box x+g2, y, sFw*2, sFh,,c, c
  If pH(p%) < 2 Then c = RGB(GRAY)
  Box x+g2+sFw*2, y, sFw*2, sFh,,c, c
  If pH(p%) < 3 Then c = RGB(GRAY)
  Box x+g2+sFw*4, y, sFw*2, sFh,,c, c
  y = y + sFh + s
  Blit 0,0,x,y-s+2,w,4,1
' Fuel
  IO_Sprint1 x, y, w, "Torch" '"Fuel"
  y = y + sFh
  c = RGB(YELLOW)
  If pF(p%) < 1 Then c = RGB(GRAY)
  Box x+g2, y, sFw, sFh,,c, c
  If pF(p%) < 3 Then c = RGB(GRAY)
  Box x+g2+sFw, y, sFw, sFh,,c, c
  If pF(p%) < 5 Then c = RGB(GRAY)
  Box x+g2+sFw*2, y, sFw, sFh,,c, c
  If pF(p%) < 10 Then c = RGB(GRAY)
  Box x+g2+sFw*3, y, sFw, sFh,,c, c
  If pF(p%) < 20 Then c = RGB(GRAY)
  Box x+g2+sFw*4, y, sFw, sFh,,c, c
  If pF(p%) < 40 Then c = RGB(GRAY)
  Box x+g2+sFw*5, y, sFw, sFh,,c, c
  y = y + sFh + s
  Blit 0,0,x,y-s+2,w,4,1
' Treasure
  IO_Sprint1 x, y, w, "Carry"
  y = y + sFh
  If pT(p) > 0 Then
    Sprite Write S_TREA, x+g, y  
  Else
    Box x+g, y, 32, 32,,RGB(BLACK),1
  End If
  y = y + 32 + s
  Blit 0,0,x,y-s+2,w,4,1
End Sub

Sub IO_PlayerHighlight p as Integer, o as Integer
  If o>0 Then
    Box sPx(p), sPy(p), sPw(p), sF2h+sFh+sFh+32+9,,RGB(ORANGE)
  Else
    Box sPx(p), sPy(p), sPw(p), sF2h+sFh+sFh+32+9,,RGB(BLACK)
  End If
End Sub

Sub IO_PlayerUpdate p as integer
  Local Integer x, y, w, s, s2, g, g2, c
  If gp < p Then Return
  x = sPx(p)
  y = sPy(p)
  w = sPw(p)
  g = (w - 38) / 2
  g = (w - 32) / 2
  g2 = (w - sFw*6)/2
  s = 8 : s2 = 4
' Banner
  y = y + 4
  y = y + sF2h  
' Icon
  y = y + 32 + s2 ' + s ' + s
' Moves
  y = y + sFh
  IO_Sprint1N x, y, w, pM(p), 1 
  y = y + sFh + s  
' Points
  y = y + sFh
  IO_Sprint1N x, y, w, pP(p), 5
  y = y + sFh + s
' Health
  y = y + sFh
  c = RGB(GREEN)
  If pH(p%) < 1 Then c = RGB(GRAY)
  Box x+g2, y, sFw*2, sFh,,c, c
  If pH(p%) < 2 Then c = RGB(GRAY)
  Box x+g2+sFw*2, y, sFw*2, sFh,,c, c
  If pH(p%) < 3 Then c = RGB(GRAY)
  Box x+g2+sFw*4, y, sFw*2, sFh,,c, c
  y = y + sFh + s
' Fuel
  y = y + sFh
  c = RGB(YELLOW)
  If pF(p%) < 1 Then c = RGB(GRAY)
  Box x+g2, y, sFw, sFh,,c, c
  If pF(p%) < 3 Then c = RGB(GRAY)
  Box x+g2+sFw, y, sFw, sFh,,c, c
  If pF(p%) < 5 Then c = RGB(GRAY)
  Box x+g2+sFw*2, y, sFw, sFh,,c, c
  If pF(p%) < 10 Then c = RGB(GRAY)
  Box x+g2+sFw*3, y, sFw, sFh,,c, c
  If pF(p%) < 20 Then c = RGB(GRAY)
  Box x+g2+sFw*4, y, sFw, sFh,,c, c
  If pF(p%) < 40 Then c = RGB(GRAY)
  Box x+g2+sFw*5, y, sFw, sFh,,c, c
  y = y + sFh + s
' Treasure
  y = y + sFh
  If pT(p) > 0 Then
    Sprite Write S_TREA, x+g, y  
  Else
    Box x+g, y, 32, 32,,RGB(BLACK),1
  End If
  y = y + 32 + s
End Sub

Sub IO_PlayerAnimate p%
  Static Integer goTime
  Static Integer hidden
  If (timer > goTime) Then
    If hidden Then
      IO_PlayerShow p%
      IO_PlayerHighlight p%, 1
      goTime = Timer + 400
      hidden = 0
    Else
      IO_PlayerHide p%
      IO_PlayerHighlight p%, 0
      goTime = Timer + 200
      hidden = 1
    End If
  End If
End Sub

Sub IO_PlayerHide(p%)
  IO_SquareDisplay pCx(p%), pCy(p%),0
End Sub

Sub IO_PlayerShow(p%)
  IO_SquareDisplay pCx(p%), pCy(p%),1
End Sub


Sub IO_AttackAnimate(p%,m%)
  Local Integer x,y,i,j
' Get Monster Position
  x = mCx(m%) : y = mCy(m%)
' Convert to Screen w Offset (Hits are 40x40)
  x = Location(x) - 4 + bx : y = Location(y) - 4 + by
  For i = 1 to 4
    For j = 0 to 3
      Sprite Show S_HIT1+j, x, y, 0
      Pause 200
      Sprite Hide S_HIT1+j
    Next
  Next
End Sub


Sub IO_BoardDisplay
  Local Integer gx,gy,x,y,s,c,v,t,p,m
  Debug "IO_BoardDisplay"
  gx = bx : gy = by
  For y=1 to bsy
    For x = 1 to bsx
      c = bm(x,y)
      v = bv(x,y) Or lm 'gmf 'Or showAll
    ' Post or Wall
      If Odd(x) Or Odd(y) Then
        IO_WallDisplay x, y
    ' Character - 32,32
      Else
        IO_SquareDisplay x, y, 1
        gx = gx + 32
      End If
    Next
    gx = bx
    gy = gy + 8
    If Odd(y) = 0 Then gy = gy + 24
  Next
End Sub


Sub IO_WallDisplay x%, y%
' Temp Fix
  If x% < 1 Or x% > bsx Or y% < 1 Or y% > bsy Then
    Debug "IO_WallDisplay Fail! " + str$(x%) + " " + str$(y%)
    Return
  End If
  Local Integer gx%,gy%,c,v
  gx = Location(x%)+bx : gy = Location(y%)+by
  c = bm(x%,y%)
  v = bv(x%,y%)
' Post
  If Odd(x%) and Odd(y%) Then
    If v or lm Then 'gmf
      If c Then
        Blit 0,0,gx,gy,8,8,1
      Else If v Then
        Blit 8,8,gx,gy,8,8,1
      End If
    Else
      Box gx,gy,8,8,,0,0
    End If
' Vertical Wall - 8,32
  Else If Odd(x%) Then
    If c And (v or lm) Then 'gmf
      Blit 0,8,gx,gy,8,32,1
    Else If v Then
      Blit 8,16,gx,gy,8,32,1
    Else
      Box gx,gy,8,32,,0,0
    End If
' Horizontal Wall - 32,8
  Else If Odd(y%) Then
    If c and (v or lm) Then 'gmf
      Blit 8,0,gx,gy,32,8,1
    Else If v Then
      Blit 16,8,gx,gy,32,8,1
    Else
      Box gx,gy,32,8,,0,0
    End If
  End If
End Sub


Sub IO_SquareAndWallsDisplay x%, y%
  IO_WallDisplays x%, y%
  IO_PostsDisplay x%, y%
  IO_SquareDisplay x%, y%, 1
End Sub

Sub IO_WallDisplays x%, y%
' Draw Walls
  IO_WallDisplay x%-1,y%
  IO_WallDisplay x%,y%-1
  IO_WallDisplay x%+1,y%
  IO_WallDisplay x%,y%+1
End Sub

Sub IO_PostsDisplay x%,y%
' Draw Posts
  IO_WallDisplay x%-1,y%-1
  IO_WallDisplay x%-1,y%+1
  IO_WallDisplay x%+1,y%-1
  IO_WallDisplay x%+1,y%+1
End Sub


Sub IO_SquareDisplay x%, y%, pOn%
  Local Integer gx, gy, c, v, p, m
  gx = Location(x%)+bx : gy = Location(y%)+by
  c = bm(x%,y%)
  v = bv(x%,y%)
' Draw Background
  If v = 0 Then
  ' Black
    Box gx,gy,32,32,,0,0
  Else
  ' Background
    Blit 16,16,gx,gy,32,32,1
  End If
' Draw Icons
  If v > 0 OR dt Then
    If v > 0 And c = IH Then
      Sprite Write S_BASE,gx,gy
  ' Book ?
    Else If c = IB Then
      Sprite Write S_MAP,gx,gy
  ' Treasure ? -> Change to Moving Sprite!
    Else If c = IL Then
      Sprite Write S_TORCH,gx,gy
    Else If c = IP Then
      Sprite Write S_POTION,gx,gy
    End If
  End If

' Draw Treasures (Unless carried and blinking!)
  For m= 1 to gm
  ' Draw Treasure
    If (v > 0 Or dt > 0) And mD(m) <> 2 And mTx(m) = x% And mTy(m) = y% And (mTp(m) = 0 Or pOn%) Then
      Sprite Write S_TREA,gx,gy
    End If
  Next

' Draw Players (If Alive and not blinking)
  For p= 1 to gp
    If pOn% And pH(p)>0 And pCx(p) = x% And pCy(p) = y% Then
      Sprite Write pS(p),gx,gy
    End If
  Next
' Draw Monsters (If Active)
  For m= 1 to gm
  ' Draw Monster
    If mA(m) > 0 Or dm > 0 Then
      If mCx(m) = x% And mCy(m) = y% Then
        Sprite Write mS(m),gx,gy
      End If
    End If
  Next
End Sub

Sub IO_WelcomeDisplay
' Initially Mode 1
' Return
  Local Integer sx, sy, sFw, sF2w, sFh, sF2h
  Mode 1
  sx = mm.hres : sy = mm.vres
  Font 1
  sFw = mm.info(fontwidth) : sFh = mm.info(fontheight)
  Font 2
  sF2w = mm.info(fontwidth) : sF2h = mm.info(fontheight)
  Colour RGB(Green), RGB(Black)
  Cls
  Local String lfn, l, m
  Local Integer k, c, x
  oq = 0 ' Query Off
' Open Welcome Text
  lfn = ePath + "txt/welcome.txt"
  On Error Skip
  Open lfn for Input as #1
  If MM.ERRNO <> 0 Then
    Print "Welcome text not found."
    Pause 5000
    End
  End If
' Draw Text
  Do While not Eof(1)
    Line Input #1, l
    If Mid$(l,1,1)="@" Then
      m = Mid$(l,2,1)
      If m$ = "D" Then
        Font 1,2
        Color Rgb(White), Rgb(Black)
        Print tab(4);Mid$(l,3)
        Color Rgb(Green), Rgb(Black)
        Font 1,1
      End If
    Else
      Print tab(7);l
    End If
  Loop
  Close #1
' Draw Border
  c = RGB(RED)
  For x = 1 to 33
    Line x,35-x,x,sy-x,1,c
    Line sx-x,35-x,sx-x,sy-x,1,c
    Select Case x
      Case 9
        c = Rgb(Green)
      Case 17
        c = Rgb(Blue)
      Case 25
        c = Rgb(Yellow)
    End Select
  Next
' Wait For Continue
  Do
    k = Game_Input(1)
    If k = KEY_SOUND Then
      oq = 1 ' Query On
      Exit Do
    End If
    If k = KEY_DONE Then Exit Do
  Loop
End Sub


' +++++++++++++++++++++++++
' Display - Status Routines
' +++++++++++++++++++++++++


Sub IO_Status m$ ' Make This Internal FIX!!
  Box sSx+9,sSy+1,sSw-20,sSh-2,,RGB(BLACK),1
  IO_Sprint2 sSx+4,sSy+4,sSw-8, m$
End Sub


Sub IO_StatusEnter m$
  Static Integer goTime
  Static Integer hidden
  Local Integer c
  Game_InputBegin(1)
' Wait for Enter  
  Do
    If (timer > goTime) Then
      If hidden Then
        IO_Status m$
        goTime = Timer + 800
        hidden = 0
      Else
        IO_Status "(Press Enter)"
        goTime = Timer + 400
        hidden = 1
      End If
    End If
    c = Game_InputScan(1)
  Loop Until c=KEY_DONE
End Sub


Sub Debug m$
  If df=0 Then Return
  wn.print 1, m$, 1
End Sub


' ++++++++++++++++++++++++
' Display - Event Routines
' ++++++++++++++++++++++++

Sub IO_Event s%,p%,m%
  Debug "IO:"+str$(s%)+" p="+str$(p%)+" m="+str$(m%)
  Local t$,sw$,sm$,sf$,e%,w%,c%,mt%
  t$ = "": sw$ = "": sm$ = "" : sf$="" : e% = 0 : c% = 0
  Play Stop
  w%=500 ' Default
  mt% = md(m%)
  Select Case s%
    case ACT_BLANK
      c% = 1:w% = 0
    case ACT_PLAY
      If gp>1 Then
        t$ = "Player " + str$(p%) + " Turn": sw$="SND_PLAYER"
    ' Else
      ' c% = 1
      End If
    case ACT_BAD
      t$ = "Illegal Action!": sm$="SND_BAD":w%=1000 
    case ACT_AWAKE
      If mt%>0 Then
        t$ = "Monster Awakes!":sw$ ="SND_AWAKE_MONSTER"
      Else
        t$ ="Ghost Rises!":sw$="SND_AWAKE_GHOST"
      End If
    case ACT_FLY
      If mt%>0 Then
        t$ = "Monster Lurches":sw$="SND_MOVE_MONSTER"
      Else 
        t$="Ghost Flys":sm$="SND_MOVE_GHOST"
      End If
    case ACT_ATTACK
      If mt%>0 Then
        t$ = "Monster Attacks!":sw$="SND_ATTACK_MONSTER"
      Else
        t$="Ghost Attacks!":sw$="SND_ATTACK_GHOST"
      End If
      w%=1000
    case ACT_DEFEAT
      t$ = "Player Defeated!"
      sf$="SND_LOSE"
    case ACT_VICTORY
      t$ = "Treasure Won!"
      sw$="SND_TREASURE"
      w%=1000
    case ACT_MOVE      
      sw$="SND_MOVE"
      w%=0
    case ACT_TREASURE
      t$ = "Treasure picked up!"
      sw$="SND_TREASURE_PICKED_UP"
    case ACT_WALL
      t$ = "Player hits wall!"
      sm$="SND_WALL"
      w%=1000
    case ACT_SLEEP
      If mt%>0 Then
        t$ = "Monster sleeps.":sw$="SND_SLEEP_MONSTER"
      Else
        t$="Ghost rests.":sw$="SND_SLEEP_GHOST"
      End If
      w%=1000
    case ACT_FLY_HOME
      t$ = "Ghost flys home."
      sm$="SND_MOVE_GHOST"
    case ACT_RAGE
      If mt%>0 Then t$ = "Monster enraged!" Else t$="Ghost enraged!"
      sw$="SND_ENRAGED_MONSTER"
      w%=1000
    case ACT_RETURN
      t$ = "Player escapes." ' 2 too large! 24=>22.
      w%=1000
    case ACT_GAME_OVER
      t$ = "Game Over!"
    case ACT_NO_FUEL
      t$ = "Torch quits"
    case ACT_LIGHT
      t$ = "Torch starts"
    case ACT_MAP
      t$ = "Map Read!"
    case ACT_SPOTTED
      If mt%>0 Then t$ = "Monster sees warrior!" Else t$="Ghost senses player!"
      sw$="SND_SEE_GHOST"
      w%=1000
    case ACT_LEVEL_OVER
      t$ = "Level Complete!"
      sw$="SND_LEVEL_OVER"
      e%=1
      w%=1000
    case ACT_POTION
      t$ = "Healing Potion!"
      sf$="SND_POTION"
      w%=1000
    case ACT_WON
      t$ = "You Won!" : e%=1
      sw$="SND_WON"
    case ACT_LOST
      t$ = "You Lost..." : e%=1
      sf$="SND_LOSE"
    case ACT_SCORE
      t$ = "You Scored "+Str$(pP(1))+"." : e%=1
    case ACT_TIED:
      t$ = "You Tied!" : e%=1
    case ACT_PLAYERWIN
      If pP(1)>pP(2) Then t$ = "Player 1 wins!" Else t$="Player 2 wins!"
      e%=1
  End Select
' Text Normal
  If df>0 And LEN(t$) > 0 Then
    If p% > 0 Then t$ = "W-" + str$(p%) + " " + t$
    If m% > 0 Then t$ = "M-" + str$(m%) + "/" + str$(mD(m%)) + " " + t$
  End If
  If Len(t$)>0 Then
     pE = 1 ' Status updated
     IO_Status t$ ' Text and EnterText Displayed (In case talking)
  End If
' Clear Text
  If c%> 0 Then IO_Status " "
' Sound
  If os>0 Then
    Debug "sw$="+sw$+". sm$="+sm$+". sf$="+sf$+"."
  ' WAV
    If sw$ <> "" Then
      Play Wav "snd/"+sw$
  ' MP3
    Else If sm$ <> "" Then
      Play Mp3 "snd/"+sm$
  ' Flac
    Else If sf$ <> "" Then
      Play Flac "snd/"+sf$
  ' Talk
    Else If ot>0 And t$ <> "" Then
      Play Tts t$
    End If
  End If
' Talk
  If os=0 And ot>0 And t$ <> "" Then
    Play Tts t$
  End If
' Text Wait
  If Len(t$)>0 And e%>0 Then
      IO_StatusEnter t$ ' Enter Text Redisplayed
  End If
' Wait
  If w% > 0 Then
    Pause w%
  End If
End Sub


Sub IO_Sprint1 x%,y%,w%,m$
  Local d%
  Font 1
  d% = (w% - Len(m$)*sFw) / 2
  Print @(x%+d%,y%) m$;   
End Sub

Sub IO_Sprint2 x%,y%,w%,m$
  Local d%
  Font 2
  d% = (w% - Len(m$)*sF2w) / 2
  Print @(x%+d%,y%) m$;   
  Font 1
End Sub

Sub IO_Sprint1L x%,y%,m$
  Font 1
  Print @(x%,y%) m$;   
End Sub

Sub IO_Sprint1R x%,y%,m$
  Local Integer w
  w = Len(m$)*sFw
  Font 1
  Print @(x%-w,y%) m$;   
End Sub


Sub IO_Sprint1LN x%,y%,n%,d%
  Local m$
  Font 1
  m$ = str$(n%)
  If Len(m$)<d% Then m$ = String$(d%-Len(m$),"0") + m$
  Print @(x%,y%) m$;   
End Sub

Sub IO_Sprint1N x%,y%,w%,n%,d%
  Local g%,m$
  Font 1
  m$ = str$(n%)
  If Len(m$)<d% Then m$ = String$(d%-Len(m$),"0") + m$
  g% = (w% - Len(m$)*sFw) / 2
  Print @(x%+g%,y%) m$;   
End Sub





