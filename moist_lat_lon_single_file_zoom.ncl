;*************************************
;  moist_lat_lon_single_file_zoom.ncl 
; Example usage: 
; ncl level=850 day=6 'pfmt="eps"'  moist_lat_lon_single_file_zoom.ncl 
;***********************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;=====
; declare the file name of the plot
;=====
  plotname = "bw_moist_topo"   ; dycore and day will be appended to this name

;=====
; declare the CAM directory and file
;=====
  casename = "CAM_6_3_45_bw_dry_fv09L30_jw06"     ; change
  dir = "/glade/derecho/scratch/$USER/"+casename+"/run/"
  data = dir+casename+".cam.h0i.0001-01-02-00000.nc"

;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "FV05L30"               ; label in plot and filename
; dycore   = "FV09L30"               ; label in plot and filename

; dycore  = "EULT85L30"           ; label in plot, name your dycore
; dycore  = "FV3c96L30"            ; label in plot, name your dycore
; dycore  = "MPAS120L30"           ; label in plot, name your dycore
; dycore  = "SEne30L30"            ; label in plot, name your dycore
; dycore  = "all_dycores"          ; label in plot, name your dycore

;=====
; declare a label for the type of dissipation
;=====
;  diff   = "dif4_1e15"           ; coefficient of the fouth-order hyper-diffusion is 1e15
; diff   = "no_dif4"             ; no explicit diffusion
; diff   = "dif4_1e16"           ; dif4 increased by a factor of 10
 diff   = "div4"                 ; 4th-order divergence damping 

;===================
; define the region to plot
;===================
 lon_start = 45. 
 lon_end   = 225. 
 lat_start = -0.5 
 lat_end = 90 

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("day")) then           ; command line setting?
      pday = day                   ; command line
  else
      pday = 5                     ; default day 5
  end if

  if (isvar("level")) then            ; pressure level on command line?
      plev = level                    ; command line
  else
      plev =  850.                ; default  [hPa]
  end if

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "X11"                ; default X11 window
  end if

;=====
; complete the plotname
;=====
  plotname = plotname+"_"+dycore+"_"+diff+"_plev"+plev+"_day"+pday
;  plotname = plotname+"_"+dycore+"_plev"+plev+"_day"+pday


;************************************************
; open netCDF file
;************************************************
  a = addfile(data,"r")

;************************************************
; read variables
;************************************************
  lev  = a->lev
  lat  = a->lat
  klev  = dimsizes(lev) - 1              ; index counts from 0 ... klev (30 values)
  hyam = a->hyam
  hybm = a->hybm

  P0   = 100000.      ; Pa
  P0mb = P0*0.01      ; hPa

;*************   
; read mean sea level pressure and surface pressure
;*************   
  ps        = a->PSL({pday},:,:)   ; sea level pressure
  ps@units  = "Pa"
  ps_actual = a->PS({pday},:,:)    ; actual surface pressure

;*************   
; convert ps to hPa
;*************   
  ps_mb = ps*0.01
  copy_VarMeta (ps,ps_mb)                ; copy attributes and coordinate information
  ps_mb@units = "hPa"
  ps_mb@long_name = "sea level pressure"
  ps_mb@_FillValue = -9999.0
  printMinMax(ps_mb,True)

;*************   
; read surface geopotential (first time index)
;*************   
  phis    = a->PHIS(0,:,:)
  
  gravity = 9.80616         ; gravitational acceleration in m/s^2
  zs      = phis/gravity    ; surface elevation
  copy_VarCoords (phis,zs)
  zs@units = "m"
  zs@long_name = "surface height"

;*************   
; read temperature at 850 hPa or interpolate
;*************   

  if (plev.eq.850 .and. isfilevar(a, "T850")) then
      t850 = a->T850({pday},:,:)                             ; (lat,lon)
  else
      t    = a->T({pday},:,:,:)  
      T850 = vinth2p(t,hyam,hybm,(/plev/),ps_actual,1,P0mb,1,True)       ; (1,lat,lon)
      t850 = T850(0,:,:)     ; eliminate the level dimension
  end if
; t850@long_name = plev+" hPa temperature"
  t850@long_name = plev+" hPa T"
  t850@units     = "K"
  printMinMax(t850,True)

;*************   
; read precipitation rate
;*************   
  prec   = a->PRECL({pday},:,:)                             ; (lat,lon)
  precl  = prec*8.64e7
  copy_VarMeta (prec,precl)
  precl@long_name = "Precipitation rate"
  precl@units = "mm/day"
  printMinMax(precl,True)

;*************
; read vertically-integrated precipitable water
;*************
  tmq   = a->TMQ({pday},:,:)                             ; (lat,lon)
  tmq@long_name = "Precipitable water"
  printMinMax(tmq,True)

;*************   
; read specific humidity at 850 hPa or interpolate
;*************   
  if (plev.eq.850 .and. isfilevar(a, "Q850")) then
      q850 = a->Q850({pday},:,:)                             ; (lat,lon)
  else
      q    = a->Q({pday},:,:,:)  
      Q850 = vinth2p(q,hyam,hybm,(/plev/),ps_actual,1,P0mb,1,True)       ; (1,lat,lon)
      q850 = Q850(0,:,:)     ; eliminate the level dimension
  end if
  q850 = q850*1000.
  q850@long_name = plev+" hPa q"
  q850@units     = "g/kg"
  printMinMax(q850,True)

;*************   
; read omega at 850 hPa or interpolate
;*************   
  if (plev.eq.850 .and. isfilevar(a, "OMEGA850")) then
      omega850 = a->OMEGA850({pday},:,:)                             ; (lat,lon)
  else
      omega = a->OMEGA({pday},:,:,:)  
      OMEGA850 = vinth2p(omega,hyam,hybm,(/plev/),ps_actual,1,P0mb,1,True)       ; (1,lat,lon)
      omega850 = OMEGA850(0,:,:)     ; eliminate the level dimension
  end if
  omega850@long_name = plev+" hPa ~F33~w"
  omega850@units     = "Pa/s"
  printMinMax(omega850,True)

;*************
; read rtically-integrated precipitable water
;*************
  tmq   = a->TMQ({pday},:,:)                             ; (lat,lon)
  tmq@long_name = "Precipitable water"

;************************************************
;plot resources [options]
;************************************************
  plot = new(6,graphic)

  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
;  pres@txString    = dycore+", "+diff+", "+plev+" hPa level"
  pres@txString    = dycore+", "+plev+" hPa level"
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnFrame         = False
  pres@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.012
  pres@amJust           = "BottomLeft"

  res = True  
  res@gsnDraw           = False              ; panel ... set to False
  res@gsnFrame          = False
  res@cnFillOn          = True
  res@gsnSpreadColors   = True
;  res@gsnSpreadColorStart = 4
  res@gsnSpreadColorEnd = 100          ; 
  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpWidthF          = 0.44
  res@vpHeightF         = 0.22
  res@cnLinesOn         = True
  res@gsnCenterString   = "Day "+pday
  res@cnLevelSelectionMode = "ManualLevels"

  res_overlay = True
  res_overlay@gsnDraw           = False              ; panel ... set to False
  res_overlay@gsnFrame          = False
  res_overlay@cnFillOn          = False
  res_overlay@lbLabelAutoStride = True
  res_overlay@tiMainString      = ""
  res_overlay@gsnLeftString     = ""
  res_overlay@gsnRightString    = ""
  res_overlay@vpWidthF          = 0.44
  res_overlay@vpHeightF         = 0.22
  res_overlay@cnLinesOn         = True
  res_overlay@cnLevelSelectionMode = "ManualLevels"
  res_overlay@cnMinLevelValF    = 0.                  ; set min contour level
;  res_overlay@cnMaxLevelValF    = 6000.               ; set max contour level
;  res_overlay@cnMaxLevelValF    = 2000.               ; set max contour level
  res_overlay@cnLevelSpacingF   = 400.                ; set contour spacing
;  res_overlay@cnLineColor        = "gray"
  res_overlay@cnLineLabelsOn    = False
  res_overlay@cnInfoLabelOn     = False

;=======
; open plot and define color table
;=======
  wks = gsn_open_wks(type,plotname)   
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table

  res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLinesOn         = True
;  res@cnLevelSpacingF = 5.
;  res@cnMinLevelValF  = 955.
;  res@cnMaxLevelValF  = 1025. 
  res@cnLinesOn         = False

  plot1 = gsn_csm_contour(wks,ps_mb({lat_start:lat_end},{lon_start:lon_end}),res)
  plot2 = gsn_csm_contour(wks,zs({lat_start:lat_end},{lon_start:lon_end}),res_overlay)
  overlay (plot1,plot2)
  plot(0) = plot1

;  res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLinesOn         = False
;  res@cnLevelSpacingF = 10 
;;  res@cnMinLevelValF  = 281.2
;;  res@cnMaxLevelValF  = 282.0
  plot(1) = gsn_csm_contour(wks,t850({lat_start:lat_end},{lon_start:lon_end}),res)

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ 0.10, 0.50, 1.00, 3, 5, 7.5, 10, 15, 20, 30, 40, 50, 75, 100 /) 
  plot(2) = gsn_csm_contour(wks,precl({lat_start:lat_end},{lon_start:lon_end}),res)

  res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLinesOn         = False
  plot(3) = gsn_csm_contour(wks,q850({lat_start:lat_end},{lon_start:lon_end}),res)

  res@cnLevelSelectionMode = "AutomaticLevels"
  plot(5) = gsn_csm_contour(wks,tmq({lat_start:lat_end},{lon_start:lon_end}),res)

  res@cnLevelSelectionMode = "AutomaticLevels"
;  res@cnLevelSpacingF = 0.005
  res@cnLinesOn         = False
  plot(4) = gsn_csm_contour(wks,omega850({lat_start:lat_end},{lon_start:lon_end}),res)

  gsn_panel(wks,plot,(/3,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
