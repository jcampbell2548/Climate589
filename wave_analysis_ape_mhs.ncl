;************************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"
;************************************************
begin
  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "x11"                ; default X11 window
  end if

;-------------------------------------
; recommendation: use PRECT for both APE and MHS (more or less identical information)
;  variable     = "FLUT"  ; outgoing longwave radiation (OLR) at the top of the atmosphere 
  variable     = "PRECT" ; total precipitation rate 

;=====
; specify the filename and open the file
;=====
  dycore   = "FV19L32.ape.control.cam6"               ; label in plot and filename
;  dycore   = "FV09.L30.ftj16.bm"                     ; label in plot and filename

  dir  = "/glade/derecho/scratch/$USER/"
  fname = "CAM_6_3_45_AQP1/run/CAM_6_3_45_AQP1.cam.h0a.0001-01-31-00000.nc"     ; aqua-planet

  case     = "WK_APE"                                           ; aqua-planet
;   case     = "WK_MHS"                                            ; moist Held-Suarez

;-------------------------------------
;  open file
   print(dir+fname)
   f  = addfile (dir+fname, "r")                                   ; open file
;----------- set arguments ------------
; see also explanation on the web page:
; https://www.ncl.ucar.edu/Document/Functions/Diagnostics/wkSpaceTime.shtml

; our data sets contain daily values (24h instantaneous data for 720 days, ignore spin-up)
  start_time = 360                              ; display only a temporal subset of the data
  end_time   = 719                              ; e.g. 360 days (1 sample per day)

   diro     = "./"       ; output dir: location of plots

   latN     = 15                           ; latBound
   latS     = -latN                        ; symmetric about the equator

   nDayWin  = 90                        ; Wheeler-Kiladis [WK] temporal window length (days), standard setting
   nDaySkip = -60                        ; time (days) between temporal windows [segments], negative means overlap (here 65 days)

   spd      = 1                            ; samples per day (24 hour sampling rate)
   var = variable

   opt      = True
;  output format is encapsulated postscript (eps), allowed are "png", "ps", "eps", "x11", "ncgm"
   opt@pltType     = type 
;   opt@pltType     = "png"
;   opt@pltType     = "x11"
   opt@debug= False                        ; if =True, Multiple printVarSummary will be activated
   opt@cnLinesOn   = False                 ; turn off contour lines
   opt@pltColorMap = "nrl_sirkes"          ; wgne15 works okay or nrl_sirkes
;   opt@pltColorMap = "BlueDarkRed18"      ; alternative clor map

; Color bar ranges for the 3a and 3b plots (see Wheeler and Kiladis (1999) paper), adjust as needed, 15 intervals is the only setting that works
  opt@Fig_3a = fspan(0.25,  3.75,  15)
  opt@Fig_3b = fspan(0.3,  4.5,  15)
;   opt@Fig_1 = fspan(-20., -15., 15)

; Title for the plots, read variable

   if (variable .eq. "FLUT") then
     field  = f->FLUT({start_time:end_time}, {latS:latN}, :)                ;FLUT(time,lat,lon)
     opt@pltTitle    = dycore+", OLR at TOA, LOG (Power: "+latN+"S-"+latN+"N)"
   end if
   if (variable .eq. "PRECT") then
     field  = f->PRECT({start_time:end_time}, {latS:latN}, :)               ;PRECT(time,lat,lon)
     opt@pltTitle    = dycore+", total precipitation rate, LOG(Power: "+latN+"S-"+latN+"N)"
   end if

   field!0 = "time"
   field!1 = "lat"
   field!2 = "lon"
   field&time  = f->time({start_time:end_time})
   field&lat = f->lat({latS:latN})
   field&lon = f->lon(:)

   printVarSummary(field)

;  compute WK wavenumber-frequency spectrum and create plots

   wkSpaceTime(field, diro, case, var, latN, spd, nDayWin, nDaySkip, opt)

end

