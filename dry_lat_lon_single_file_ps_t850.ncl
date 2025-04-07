;*************************************
; dry_lat_lon_single_file.ncl
;
; Example usage: 
; ncl dry_lat_lon_single_file.ncl
; ncl level=700 day=10 'pfmt="png"' dry_lat_lon_single_file.ncl
; ncl level=500 day=9 'pfmt="png"' dry_lat_lon_single_file.ncl
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
;  plotname = "hs"   ; dycore and day will be appended to this name

;=====
; declare the CAM directory and file
;=====
  casename = "CAM_6_3_45_bw_dry_fv09L30_jw06"
  dir = "/glade/derecho/scratch/$USER/"+casename+"/run/"
  data = dir+casename+".cam.h0i.0001-01-02-00000.nc"

;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "FV09L30"               ; label in plot and filename
; dycore   = "FV3C48L30"               ; label in plot and filename
; dycore  = "EULT85L30"           ; label in plot, name your dycore
; dycore  = "FV3c96L30"            ; label in plot, name your dycore
; dycore  = "MPAS120L30"           ; label in plot, name your dycore
; dycore  = "SEne30L30"            ; label in plot, name your dycore
; dycore  = "all_dycores"          ; label in plot, name your dycore

;=====
; declare a label for the type of dissipation
;=====
; diff   = "dif4_1e15"           ; coefficient of the fouth-order hyper-diffusion is 1e15
; diff   = "no_dif4"             ; no explicit diffusion
; diff   = "dif4_1e16"           ; dif4 increased by a factor of 10
 diff   = "div4"         ; 4th-order divergence damping 

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
  plotname = plotname+"_"+dycore+"_"+diff+"_ps_T850_day_"+pday

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
  ps@long_name  = "Surface pressure"

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
; read temperature at 850 hPa or interpolate
;*************   
  if (plev.eq.850 .and. isfilevar(a, "T850")) then
      t850 = a->T850({pday},:,:)                             ; (lat,lon)
  else
      t    = a->T({pday},:,:,:)  
      T850 = vinth2p(t,hyam,hybm,(/plev/),ps,1,P0mb,1,True)       ; (1,lat,lon)
      t850 = T850(0,:,:)     ; eliminate the level dimension
  end if
 t850@long_name = plev+" hPa temperature"
;  t850@long_name = plev+" hPa T"
  t850@units     = "K"
  printMinMax(t850,True)

;************************************************
;plot resources [options]
;************************************************
  plot = new(2,graphic)

  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
  pres@txString    = dycore+", "+diff
;  pres@txString    = dycore+", "+diff+", "+plev+" hPa level"
;  pres@txString    = dycore+", "+plev+" hPa level"
;  pres@txString    = ""
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnFrame         = False
;  pres@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/) ; add strings to panel
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
  res@pmLabelBarWidthF = 0.43

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


  res@cnLevelSelectionMode = "ManualLevels"
  res@cnLevelSpacingF = 5.
  res@cnMinLevelValF  = 950.
  res@cnMaxLevelValF  = 1020.
;  res@cnLinesOn         = False
  plot(0) = gsn_csm_contour(wks,ps_mb,res)

  res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLevelSpacingF = 5 
;  res@cnLinesOn         = False
;;  res@cnMinLevelValF  = 281.2
;;  res@cnMaxLevelValF  = 282.0
  plot(1) = gsn_csm_contour(wks,t850,res)

  gsn_panel(wks,plot,(/1,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
