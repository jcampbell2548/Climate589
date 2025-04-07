;*************************************
;dry_lat_lon_single_file_zoom.ncl
; Example usage: 
; ncl level=850 day=9 'pfmt="eps"' dry_lat_lon_single_file_zoom.ncl
; ncl level=850 day=9 'pfmt="png"' dry_lat_lon_single_file_zoom.ncl
;***********************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;=====
; declare the file name of the plot
;=====
  plotname = "bw_dry_jw06"   ; dycore and day will be appended to this name
;  plotname = "bw_dry_Rossby_topo"   ; dycore and day will be appended to this name

;=====
; declare the CAM directory and file
;=====
  casename = "CAM_6_3_45_bw_dry_fv09L30_jw06"
  dir = "/glade/derecho/scratch/$USER/"+casename+"/run/"
  data = dir+casename+".cam.h0i.0001-01-02-00000.nc"

;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "FV09L30"               ; label in plot, name your dycore

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
; define the region to plot, selected for day 9
; adjust the zoomed area if you pick a different day
;===================
 lon_start = 120
 lon_end   = 300
 lat_start = -0.5 
 lat_end = 90 

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("day")) then           ; command line setting?
      pday = day                   ; command line
  else
      pday = 9                     ; default day 9
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
  plotname = plotname+"_"+dycore+"_"+diff+"_plev"+plev+"_day"+pday+"_zoom"
;  plotname = plotname+"_"+dycore+"_plev"+plev+"_day"+pday+"_zoom"

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
  gravity = 9.80616         ; gravitational acceleration in m/s^2

;*************   
; read surface pressure and sea level pressure
;*************   
  ps = a->PS({pday},:,:)
  ps@units      = "Pa"
  ps@long_name  = "PS"
  psl = a->PSL({pday},:,:)/100.
  copy_VarMeta (ps,psl)             ; copy attributes and coordinate information
  psl@long_name = "sea level pressure"
  psl@units = "hPa"

;*************   
; convert ps to hPa
;*************   
  ps_mb = ps*0.01
  copy_VarMeta (ps,ps_mb)                ; copy attributes and coordinate information
  ps_mb@units = "hPa"
  ps_mb@long_name = "surface pressure"
  ps_mb@_FillValue = -9999.0
  printMinMax(ps_mb,True)

;*************   
; read surface geopotential (first time index)
;*************   
  phis    = a->PHIS(0,:,:)
  zs      = phis/gravity    ; surface elevation
  copy_VarCoords (phis,zs)
  zs@units = "m"
  zs@long_name = "surface height"
  zs_min = min(zs)
  zs_max = max(zs)
  print (zs_min)
  print (zs_max)

;*************   
; read temperature at 850 hPa or interpolate
;*************   
  if (plev.eq.850 .and. isfilevar(a, "T850")) then
      t850 = a->T850({pday},:,:)                             ; (lat,lon)
  else
      t    = a->T({pday},:,:,:)  
      T850 = vinth2p(t,hyam,hybm,(/plev/),ps,1,P0mb,1,True)       ; (1,lat,lon)
      t850 = T850(0,:,:)     ; eliminate the level dimension
  end if
; t850@long_name = plev+" hPa temperature"
  t850@long_name = plev+" hPa T"
  t850@units     = "K"
  printMinMax(t850,True)

;*************   
; read u and v at 850 hPa or interpolate
;*************  
  if (plev .eq. 850 .and. isfilevar(a, "U850") .and. isfilevar(a, "V850")) then
      u850 = a->U850({pday},:,:)
      v850 = a->V850({pday},:,:)
  else
      u    = a->U({pday},:,:,:)  
      v    = a->V({pday},:,:,:)  
      U850 = vinth2p(u,hyam,hybm,(/plev/),ps,1,P0mb,1,True)
      V850 = vinth2p(v,hyam,hybm,(/plev/),ps,1,P0mb,1,True)
      u850 = U850(0,:,:)     ; eliminate the level dimension
      v850 = V850(0,:,:)     ; eliminate the level dimension
  end if
  u850@units = "m/s"
  v850@units = "m/s"
  u850@long_name = plev+" hPa U"
  v850@long_name = plev+" hPa V"
  printMinMax(u850,True)
  printMinMax(v850,True)

  if (plev .eq. 850 .and. isfilevar(a, "OMEGA850")) then
      omega850 = a->OMEGA850({pday},:,:)               ; (lat,lon)
  else
      omega= a->OMEGA({pday},:,:,:) 
      OMEGA850 = vinth2p(omega,hyam,hybm,(/plev/),ps,1,P0mb,1,True) ; (1,lat,lon)
      omega850 = OMEGA850(0,:,:)     ; eliminate the level dimension
  end if
  omega850@units = "Pa/s"
  omega850@long_name = plev+" hPa omega"
  printMinMax(omega850,True)
  
  if (abs(lat(0)) .gt. 89.95) then
      vort850= uv2vrF_Wrap (u850,v850)     ; vorticity via spherical harmonics on fixed grid
      print("Fixed grid with poles")
  else
      vort850= uv2vrG_Wrap (u850,v850)     ; vorticity via spherical harmonics on Gaussian grid
      print("Gaussian grid")
  end if

  vort850= vort850*1.e5                 ; scale for better looking plot
  vort850@units = "10~S~-5~N~ s~S~-1~N~"
  vort850@long_name = plev+" hPa rel. vorticity"
  printMinMax(vort850,True)

;************************************************
; if present read geopotential height
;************************************************
  geopot  =  False
  if (isfilevar(a, "Z3")) then
    geopot = True
    if (plev .eq. 700 .and. isfilevar(a, "Z700")) then
       geo = a->Z700({pday},:,:)               ; (lat,lon)
    else if (plev .eq. 500 .and. isfilevar(a, "Z500")) then
       geo = a->Z500({pday},:,:)               ; (lat,lon)
    else if (plev .eq. 300 .and. isfilevar(a, "Z300")) then
       geo = a->Z300({pday},:,:)               ; (lat,lon)
    else
       z3 = a->Z3({pday},:,:,:)
       z3_int = vinth2p(z3,hyam,hybm,(/plev/),ps,1,P0mb,1,True) ; (1,lat,lon)
       geo = z3_int(0,:,:)     ; eliminate the level dimension
    end if
    end if
    end if
    geo@long_name = plev+" hPa height"
  end if

;************************************************
;plot resources [options]
;************************************************
  plot = new(6,graphic)

  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
  pres@txString    = dycore+", "+diff
;  pres@txString    = dycore+", "+diff+", "+plev+" hPa level"
;  pres@txString    = dycore+", "+plev+" hPa level"
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnFrame         = False     ; requires  frame(wks)  at the end
  pres@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.012
  pres@amJust           = "BottomLeft"

  res = True  
  res@gsnDraw           = False              ; panel ... set to False
  res@gsnFrame          = False
  res@cnFillOn          = True
  res@gsnSpreadColors   = True
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
; res_overlay@cnMaxLevelValF    = 6000.               ; set max contour level
; res_overlay@cnMaxLevelValF    = 2000.               ; set max contour level
  res_overlay@cnLevelSpacingF   = 400.                ; set contour spacing
; res_overlay@cnLineColor        = "gray"
  res_overlay@cnLineLabelsOn    = False
  res_overlay@cnInfoLabelOn     = False

;=======
; open plot and define color table
;=======
  wks = gsn_open_wks(type,plotname)   
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table
 
  res@cnLevelSelectionMode = "AutomaticLevels"
;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnLevelSpacingF = 2.
;  res@cnMinLevelValF  = 0.
;  res@cnMaxLevelValF  = 24.
  res@cnLinesOn      = False
  if (geopot) then
    if (zs_max .gt. 1. .and. zs_min .ge. 0.) then
      plot1 = gsn_csm_contour(wks,geo({lat_start:lat_end},{lon_start:lon_end}),res)
      plot2 = gsn_csm_contour(wks,zs({lat_start:lat_end},{lon_start:lon_end}),res_overlay)
      overlay (plot1,plot2)
      plot(2) = plot1
    else
      plot(2) = gsn_csm_contour(wks,geo({lat_start:lat_end},{lon_start:lon_end}),res)
    end if
  else
;   res@cnLevelSpacingF = 0.005
    plot(2) = gsn_csm_contour(wks,u850({lat_start:lat_end},{lon_start:lon_end}),res)     ; create a default plot
  end if

;  res@cnLevelSpacingF = 2.
;  res@cnMinLevelValF  = -14.
;  res@cnMaxLevelValF  = 14.
  plot(3) = gsn_csm_contour(wks,v850({lat_start:lat_end},{lon_start:lon_end}),res)

;  res@cnLevelSpacingF = 5.
;  res@cnMinLevelValF  = 955.
;  res@cnMaxLevelValF  = 1025. 
  res@cnLinesOn         = False
  if (zs_max .gt. 1. .and. zs_min .ge. 0.) then
    plot1 = gsn_csm_contour(wks,psl({lat_start:lat_end},{lon_start:lon_end}),res)
    plot2 = gsn_csm_contour(wks,zs({lat_start:lat_end},{lon_start:lon_end}),res_overlay)
    overlay (plot1,plot2)
    plot(0) = plot1
  else
    plot(0) = gsn_csm_contour(wks,ps_mb({lat_start:lat_end},{lon_start:lon_end}),res)
  end if

;  res@cnLevelSelectionMode = "AutomaticLevels"
;  res@cnLevelSpacingF = 10 
  res@cnLinesOn         = False
;;  res@cnMinLevelValF  = 281.2
;;  res@cnMaxLevelValF  = 282.0
  plot(1) = gsn_csm_contour(wks,t850({lat_start:lat_end},{lon_start:lon_end}),res)

;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnLevelSpacingF = 0.5
;  res@cnMinLevelValF  = -2.5
;  res@cnMaxLevelValF  = 2.5
  plot(5) = gsn_csm_contour(wks,omega850({lat_start:lat_end},{lon_start:lon_end}),res)

  res@cnLevelSelectionMode = "AutomaticLevels"
; res@cnLevelSpacingF = 0.005
  res@cnLinesOn         = False
  plot(4) = gsn_csm_contour(wks,vort850({lat_start:lat_end},{lon_start:lon_end}),res)

  gsn_panel(wks,plot,(/3,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
