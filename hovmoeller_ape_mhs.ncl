; ===========================================
; hovmoeller.ncl
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; ===========================================
begin
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "X11"                ; default X11 window
  end if

  if (isvar("field")) then        ; variable specified on command line?
     choice  = field              ; variable from command line
  else
     choice = "FLUT"             ; default is the total preciptation rate PRECT
                                  ;  other choices are U200, V200, FLUT (for aqua-planet)
  end if

;=====
; specify the filename and open the file
;=====
;  dycore   = "MPAS120.L32.ape.control.cam5.inic"               ; label in plot and filename
;  dycore   = "SEne30.L32.ape.control.cam5.inic"               ; label in plot and filename
  dycore   = "FV19L32.ape.control.cam6"               ; label in plot and filename

;  dycore   = "FV09.L30.ftj16.bm"                     ; label in plot and filename

;  dir  = "/glade/derecho/scratch/$USER/CAM_6_3_45."+dycore+"/run/"
 dir  = "/glade/derecho/scratch/$USER/"
;  filename = "CAM_6_3_45."+dycore+".cam.h1i.0001-01-02-00000.regrid.1x1.nc"     ; aqua-planet
;  filename = "CAM_6_3_45."+dycore+".cam.h1i.0001-01-02-00000.nc"     ; aqua-planet
  filename = "CAM_6_3_45_AQP1/run/CAM_6_3_45_AQP1.cam.h0a.0001-01-31-00000.nc"     ; aqua-planet

;  filename = "CAM_6_3_45."+dycore+".cam.h2.0001-01-01-00000.nc"      ; moist Held-Suarez

  f = addfile (dir+filename,"r")

;=====
; declare the file name of the plot
;=====
  plotname = dycore+"."+choice+".hov"    ; name of the plot  

; our data sets contain daily values (24h instantaneous data for 720 days, ignore spin-up)
  start_time = 360                              ; display only a temporal subset of the data
  end_time   = 450                              ; e.g. 91 days (1 sample per day)
; end_time   = 540                              ; e.g. 181 days (1 sample per day)

  lat_cutoff = 5                                ; read variable in the latitudinal range -lat_cutoff:+lat_cutoff

  res = True                                    ; plot mods desired
; read variable, all time steps, all longitudes
  if (choice.eq."FLUT") then
     var   = f->FLUT({start_time:end_time},{-lat_cutoff:lat_cutoff},:)      ; read variable near the equator
     var@long_name = "OLR anomaly at the top of the atmosphere"
     res@tiMainString = choice+" anomaly ("+lat_cutoff+"S-"+lat_cutoff+"N)"   ; plot title
     res@cnFillPalette        = "WhBlReWh"
     res@cnFillPalette        = "WhiteBlueGreenYellowRed"
  end if
  if (choice.eq."U200") then
     var   = f->U200({start_time:end_time},{-lat_cutoff:lat_cutoff},:)      ; read variable near the equator
     var@long_name = "U anomaly at 200 hPa"
     res@tiMainString = choice+" anomaly ("+lat_cutoff+"S-"+lat_cutoff+"N)"   ; plot title
     res@cnFillPalette        = "WhiteBlueGreenYellowRed"
  end if
  if (choice.eq."V200") then
     var   = f->V200({start_time:end_time},{-lat_cutoff:lat_cutoff},:)      ; read variable near the equator
     var@long_name = "V anomaly at 200 hPa"
     res@tiMainString = choice+" anomaly ("+lat_cutoff+"S-"+lat_cutoff+"N)"   ; plot title
     res@cnFillPalette   = "BlWhRe"           ; set color map
  end if
  if (choice.eq."PRECT") then
     var   = f->PRECT({start_time:end_time},{-lat_cutoff:lat_cutoff},:)      ; read variable near the equator
     var   = var*8.64e7
     var@long_name = "Precipitation rate"
     var@units = "mm/day"
     res@tiMainString = choice+" ("+lat_cutoff+"S-"+lat_cutoff+"N)"   ; plot title
;     res@cnFillPalette        = "perc2_9lev"
;     res@cnFillPalette        = "precip3_16lev"
     res@cnFillPalette        = "prcp_1"
;     res@cnFillPalette        = "WhBlReWh"
;     res@cnFillPalette        = "WhiteBlueGreenYellowRed"
  end if
;  res@gsnSpreadColors = True

; compute latutidinal weights
  pih   = 2.*atan(1.)                           ; pi/2
  lat   = f->lat({-lat_cutoff:lat_cutoff})      ; read latitudes
  lat   = lat*pih/180                           ; convert to radians
  gw    = cos(lat)*abs(lat(1)-lat(0))           ; area weights for the latitudinal average

; weighted average in the latitudinal direction
  var_ave  = dim_avg_wgt_n_Wrap(var,gw,0,1)

; compute the horizontal average to derive anomaly
  hor_ave = wgt_areaave_Wrap(var,gw,1.0,0) 
; compute the time-mean of the horizontal mean
  mean =  dim_avg(hor_ave)
  print (mean)

  if (choice .eq. "PRECT") then
    var_ave  = var_ave                           ; no anomaly
  else 
    var_ave  = var_ave - mean                    ; compute anomaly
  end if

;==============================================
; create color plot
;=============================================
  wks  = gsn_open_wks (type, plotname ) 

  res                      = True               ; plot mods desired
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False               ; turn on color fill

  res@cnLevelSelectionMode = "AutomaticLevels"     ; manual contour levels
;  res@cnLevelSelectionMode = "ManualLevels"     ; manual contour levels
;  res@cnMinLevelValF       = -9.	        ; min level
;  res@cnMaxLevelValF       =  9               ; max level
;  res@cnLevelSpacingF      = 1.                 ; contour level spacing
  
  plot = gsn_csm_hov(wks, var_ave, res) 

;  trim the white space
  if (type .ne. "X11" .and. type.ne."eps") then
    system("convert -trim "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if
  
end


