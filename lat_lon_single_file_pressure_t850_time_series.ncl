;*************************************
; lat_lon_single_file_pressure_t850_time_series.ncl
;Example usage with optional input parameters, default is start day 7 and X11 screen output 
;
; png output, days 7, 9 ,11
; ncl 'pfmt="png"' lat_lon_single_file_pressure_t850_time_series.ncl
;
; png output, day 9, 11, 13
; ncl day=9 'pfmt="png"' lat_lon_single_file_pressure_t850_time_series.ncl
;***********************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;=====
; declare the file name of the plot
;=====
  plotname = "dry_Rossby_topo"   ; dycore and day will be appended to this name
;  plotname = "dry_Rossby_topo"   ; dycore and day will be appended to this name
;  plotname = "moist_bw_topo"   ; dycore and day will be appended to this name

;=====
; declare the CAM directory and file
;=====
 casename = "CAM_6_3_45_SEne60_Rossby"
 dir = "/glade/derecho/scratch/juliacam/"+casename+"/run/"
 data = dir+casename+".cam.h0i.0001-01-02-00000.nc"

;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "SEne60"               ; label in plot and filename

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

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++

;======
; set the days
;======
  if (isvar("day")) then           ; command line setting?
      day1 = day                   ; command line
  else
      day1 = 10                     ; default start day 7
  end if
  day2 = day1 + 10                  ; second snapshot is 2 days later
  day3 = day1 + 20                  ; third snapshot is 4 days later

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "X11"                ; default X11 window
  end if

;=====
; complete the plotname
;=====
  plotname = plotname+"_"+dycore+"_"+diff+"_ps_t500_day_"+day1+"_"+day2+"_"+day3
  gravity = 9.80616         ; gravitational acceleration in m/s^2

;************************************************
; open netCDF files
;************************************************
  a = addfile(data,"r")

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
;  print (zs_min)
;  print (zs_max)

;*************   
; read surface pressure or sea level pressure
;*************   
  if (zs_max .gt. 1. .and. zs_min .ge. 0.) then 
    ps = a->PSL(:,:,:)   ; read all time snapshots
  else 
    ps = a->PS(:,:,:)   ; read all time snapshots
  end if

;*************   
; convert ps to hPa
;*************   
  ps_mb = ps*0.01
  copy_VarMeta (ps,ps_mb)                ; copy attributes and coordinate information
  ps_mb@units = "hPa"
  if (zs_max .gt. 1. .and. zs_min .ge. 0.) then 
    ps_mb@long_name = "sea level pressure"
  else
    ps_mb@long_name = "p~B~s~N~"
  end if
  ps_mb@_FillValue = -9999.0

;  printMinMax(ps_mb,True)

;*************   
; read 850hPa temperature
;*************   
  t500           = a->T500(:,:,:)       ; (time,lat,lon)
  t500@long_name = "500 hPa T"
  t500@units     = "K"

;************************************************
;plot resources [options]
;************************************************
  plot = new(6,graphic)

  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
  pres@txString    = dycore+" at days "+day1+", "+day2+" and "+day3
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
  res@gsnSpreadColorStart = 4
  res@gsnSpreadColorEnd = 100          ;
  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpWidthF          = 0.44
  res@vpHeightF         = 0.22
  res@cnLinesOn         = True

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

;  res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnLevelSpacingF = 10.
  res@cnMinLevelValF  = 930.
  res@cnMaxLevelValF  = 1050. 
  res@cnLinesOn         = False 
  res@gsnCenterString   = "Day "+day1
  plot0 = gsn_csm_contour(wks,ps_mb(day1-1,:,:),res)
  res@gsnCenterString   = "Day "+day2
  plot2 = gsn_csm_contour(wks,ps_mb(day2-1,:,:),res)
  res@gsnCenterString   = "Day "+day3
  plot4 = gsn_csm_contour(wks,ps_mb(day3-1,:,:),res)
  if (zs_max .gt. 1. .and. zs_min .ge. 0.) then
    plot1 = gsn_csm_contour(wks,zs,res_overlay)
    overlay (plot0,plot1)
    plot1 = gsn_csm_contour(wks,zs,res_overlay)
    overlay (plot2,plot1)
    plot1 = gsn_csm_contour(wks,zs,res_overlay)
    overlay (plot4,plot1)
  end if

  plot(0) = plot0
  plot(2) = plot2
  plot(4) = plot4

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnLevelSpacingF = 5 
;  res@cnLinesOn         = True 
  res@cnMinLevelValF  = 275.
  res@cnMaxLevelValF  = 325.
  res@gsnCenterString   = "Day "+day1
  plot(1) = gsn_csm_contour(wks,t500(day1-1,:,:),res)
  res@gsnCenterString   = "Day "+day2
  plot(3) = gsn_csm_contour(wks,t500(day2-1,:,:),res)
  res@gsnCenterString   = "Day "+day3
  plot(5) = gsn_csm_contour(wks,t500(day3-1,:,:),res)

  gsn_panel(wks,plot,(/3,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
