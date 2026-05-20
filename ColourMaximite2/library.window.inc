' WINDOW.INC
' 
' Created: 2021-Sep-11
' Updated: 2021-Oct-05
' Craig S. Buchanan
'

OPTION EXPLICIT
OPTION DEFAULT NONE

' Prepare Storage
sub wn.setup maxwin%
  dim integer wn.wx(maxwin%), wn.wy(maxwin%), wn.ww(maxwin%), wn.wh(maxwin%)
  dim integer wn.tx(maxwin%), wn.ty(maxwin%), wn.tw(maxwin%), wn.th(maxwin%)
  dim integer wn.cx(maxwin%), wn.cy(maxwin%), wn.cw(maxwin%), wn.ch(maxwin%)
  dim integer wn.px(maxwin%), wn.py(maxwin%)
  dim integer wn.fw(maxwin%), wn.fh(maxwin%)
  dim integer wn.bk = rgb(black), wn.bg(maxwin%) = rgb(black)
end sub

' Create Window
sub wn.create w%, wx%, wy%, ww%, wh%, tfont%, brdcol%, bgcol%, lbl$, lblcol%
  local integer fw, fh
  local integer cw, ch
  local integer tx, ty, tw, th
  local integer lw, lh
  ' Get Font
  font tfont%
  fw = mm.info(fontwidth)
  fh = mm.info(fontheight)
  ' Record Window
  wn.wx(w%) = wx%
  wn.wy(w%) = wy%
  wn.ww(w%) = ww%
  wn.wh(w%) = wh%
  ' Record Font
  wn.fw(w%) = fw
  wn.fh(w%) = fh
  wn.bg(w%) = bgcol%
  ' Calculate Label Area
  lw = 0
  lh = 0
  if len(lbl$) then
    lw = len(lbl$) * fw + 4
    if lw < ww% then lh = fh + 1
  end if
  ' Calculate Char Area
  cw = int((ww% - 4) / fw)
  ch = int((wh% - 4 - lh) / fh)
  wn.cw(w%) = cw
  wn.ch(w%) = ch
  ' Calculate Text Area
  tw = cw * fw
  th = ch * fh
  tx = int((ww% - tw) / 2)
  ty = int((wh% - th - lh) / 2)
  wn.tx(w%) = wx% + tx
  wn.ty(w%) = wy% + lh + ty
  wn.tw(w%) = tw
  wn.th(w%) = th
  ' Starting Position
  wn.px(w%) = wn.tx(w%)
  wn.py(w%) = wn.ty(w%)
  wn.cx(w%) = 0
  wn.cy(w%) = 0
  ' Clear Entire Window
  box wx%, wy%+lh%, ww%, wh%-lh%,, bgcol%, bgcol%
  ' Draw Window Box
  box wx%, wy%+lh, ww%, wh%-lh,, brdcol% 
  ' Create Label
  if (lh) then
    ' Draw Label Box
    box wx%+fw%, wy%, lw%, lh%+1,, brdcol%, bgcol% 
    ' Remove Bottom Line
    line wx%+fw%+1, wy%+lh%, wx%+fw%+lw%-2, wy%+lh%,, bgcol% 
    ' Draw Label
    colour lblcol%, bgcol%
    text wx% + fw + 2, wy% + 1, lbl$ 
  end if
end sub


' Window Clear Screen
sub wn.cls w%
  ' Starting Position
  wn.px(w%) = wn.tx(w%)
  wn.py(w%) = wn.ty(w%)
  wn.cx(w%) = 0
  wn.cy(w%) = 0
  ' Clear Text Window
  box wn.tx(w%), wn.ty(w%), wn.tw(w%), wn.th(w%),, wn.bg(w%), wn.bg(w%)  
end sub


' Window Line Feed
sub wn.lf w%
  local cy%, py%

  ' Get Char and Pixel Coordinates
  cy% = wn.cy(w%)
  py% = wn.py(w%)

  ' Line Feed Line Advance
  if cy% + 1 < wn.ch(w%) then
    inc cy%
    inc py%, wn.fh(w%)        
  else
    blit wn.tx(w%), wn.ty(w%)+wn.fh(w%), wn.tx(w%), wn.ty(w%), wn.tw(w%), wn.th(w%)-wn.fh(w%)
    box  wn.tx(w%), py%, wn.tw(w%), wn.fh(w%),, wn.bg(w%), wn.bg(w%)
  end if

  ' Save Char and Pixel Coordinates
  wn.px(w%) = wn.tx(w%)
  wn.py(w%) = py%
  wn.cx(w%) = 0
  wn.cy(w%) = cy%
end sub


'Print to Window
sub wn.print w%, s$, lf%
  local i%, cx%, cy%, px%, py%, c$

  ' Get Char and Pixel Coordinates
  cx% = wn.cx(w%)
  cy% = wn.cy(w%)
  px% = wn.px(w%)
  py% = wn.py(w%)

  ' Print Each Character
  for i% = 1 to len(s$)
    c$ = mid$(s$,i%,1)
    ' Print Character
    text px%, py%, c$
    if cx% + 1 < wn.cw(w%) then 
      ' Character Advance
      inc cx%
      inc px%, wn.fw(w%)
    else
      ' Line Advance
      cx% = 0
      px% = wn.tx(w%)
      if cy% + 1 < wn.ch(w%) then
        inc cy%
        inc py%, wn.fh(w%)        
      else
        blit wn.tx(w%), wn.ty(w%)+wn.fh(w%), wn.tx(w%), wn.ty(w%), wn.tw(w%), wn.th(w%)-wn.fh(w%)
        box  wn.tx(w%), py%, wn.tw(w%), wn.fh(w%),, wn.bg(w%), wn.bg(w%)
      end if
    end if
  next

  ' Line Feed ?
  if lf%  then
    ' Line Feed Line Advance
    cx% = 0
    px% = wn.tx(w%)
    if cy% + 1 < wn.ch(w%) then
      inc cy%
      inc py%, wn.fh(w%)        
    else
      blit wn.tx(w%), wn.ty(w%)+wn.fh(w%), wn.tx(w%), wn.ty(w%), wn.tw(w%), wn.th(w%)-wn.fh(w%)
      box  wn.tx(w%), py%, wn.tw(w%), wn.fh(w%),, wn.bg(w%), wn.bg(w%)
    end if
  end if

  ' Save Char and Pixel Coordinates
  wn.px(w%) = px%
  wn.py(w%) = py%
  wn.cx(w%) = cx%
  wn.cy(w%) = cy%
end sub

' Test
'wn.create 0, 100, 100, 204, 220, 1, rgb(green), rgb(blue), "Morse", rgb(red)
'wn.create 0, 100, 100, 204, 220, 1, rgb(green), rgb(blue)
'wn.create 0, 100, 100, 204, 220, 1, rgb(green), rgb(blue), "123456789012345678901234567890", rgb(red)
'colour rgb(white), rgb(blue)
'pause 4000
'dim integer cnt = 0
'do
'  wn.print 0, "123 456 789 abcd "
'  inc cnt
'  if (cnt = 25) then wn.lf(0)
'  if (cnt = 50) then cnt = 0 : wn.cls(0)  
'  pause 100
'loop 





