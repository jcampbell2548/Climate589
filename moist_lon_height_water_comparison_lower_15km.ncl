script_name = "moist_lon_height_water_comparison_lower_15km.ncl"

;***********************************************
; examples
;
; ncl 'field="rain"' day=6 moist_lon_height_water_comparison_lower_15km.ncl
; ncl 'field="vapor"' day=2 lat=40 moist_lon_height_water_comparison_lower_15km.ncl
;***********************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
;************************************************
begin
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments: only  fnam is requited
;+++++++++++++++++++++++++++++++++++++++++++++++++++++

  if (isvar("pfmt")) then            ; plot format specified on command line?
      pltType = pfmt                 ; command line
  else
;      pltType = "eps"                ; default, others: X11, pdf
      pltType = "X11"                ; default, others: X11, pdf
  end if

  if (isvar("day")) then           ; command line setting?
      pday = day                   ; command line
  else
      pday = 12                     ; default day 5
  end if

  if (isvar("lat")) then            ; latitude on command line?
      plat = lat                    ; command line
  else
      plat =  45.                ; default 45N 
  end if

  if (isvar("field")) then           ; command line setting?
      var = field                   ; command line
  else
      var = "rain"                    ;  default variable CLDLIQ
  end if

;=====
; declare the CAM directory and file
;=====
;  Example with 3 files, same directory
;
;  casename = "CAM_cesm2_2_rel_09.bw_dry_fv3C96L30"
  casename = "CAM_6_3_45_FV05L30_moist_bw"
  PATH = "/glade/derecho/scratch/$USER/"+casename+"/run/"
  files = (/PATH+casename+".cam.h0i.0001-01-02-00000.1000m.nc",\
            PATH+casename+".cam.h0i.0001-01-02-00000.5000m.nc",\
            PATH+casename+".cam.h0i.0001-01-02-00000.9000m.nc"/)

; define the labels for the cases specified above (shown in plots)
  version = (/"peak = 1000m","peak = 5000m", "peak = 9000m"/)
;-----------------------------

  nfiles = dimsizes(files)             ; number of files
  gravity = 9.80616                    ; gravitational acceleration in m/s^2

;=====
; select a plotting region in longitude
;=====
  lon_start = 30
  lon_end   = 255

;=====
; declare a label for the dycore (appears in the title and the file name)
;=====
  dycore   = "FV05L30"             ; label in plot, name your dycore

;=====
; complete the plotname
;=====
  plotname = dycore+"_"+var+"_lon_height.lat_"+plat
  pltTitle = "CAM_6_3_45_FV05L30_moist_bw_AllPeaks_Day6"        ; Plot title if required

;************************************************
; define new height level with equidistant spacing
;************************************************
  zlev  = 175 
  ztop  = 15.15   ; ztop set to 15.15 km
  z_new = new((/zlev/),float)
  dz = ztop/zlev

  do kk=0,zlev-1
     z_new(kk) = (ztop-0.5*dz)-(kk)*dz  
  end do
  z_new@units = "km"
  z_new@long_name = "Height"
 
;************************************************
;  resources for topography profile
;************************************************
   res1 = True
   res1@gsnDraw  = False
   res1@gsnFrame = False
   res1@xyLineThicknessF   = 3.          ; line thickness
   res1@xyLineColors       = (/"black","white","blue","red","green"/)          ; line thickness
;  res1@gsnXYBelowFillColors = "black"     ; not a valid resource

;************************************************
;  define the panel 
;************************************************
   if (nfiles .eq. 3 .or. nfiles .eq.5) then
     plot = new(nfiles+1,graphic)
   else 
     plot = new(nfiles,graphic)
   end if

;************************************************
;  resources 
;************************************************
  res  = True                
  res@gsnDraw  = False
  res@gsnFrame = False
  res@cnFillOn          = True
;  res@cnLinesOn         = True
  res@cnLinesOn         = False
  res@gsnSpreadColors   = True
  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpKeepAspect      = True
  res@vpWidthF          = 0.48
  res@vpHeightF         = 0.25
  res@lbLabelBarOn      = False
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
; res@cnLevelSelectionMode = "AutomaticLevels"
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@sfYArray          = z_new  ; y axis array
  res@tiYAxisString     = "Height (km)"
;  res@tiXAxisString     = "Longitude"
  res@tiXAxisOffsetYF	   = 0.062
;  res@tiMainFontHeightF  = 0.1
  res@tmXBLabelFontHeightF = 0.015                 ; resize tick labels
  res@tmYLLabelFontHeightF = 0.015
  res@gsnStringFontHeightF = 0.013
  res@lbLabelFontHeightF = 0.015
;  res@gsnCenterString = "at "+plat+"~S~o~N~N"
   res@gsnCenterString = "Day "+pday

  pres = True
  pres@gsnMaximize      = False
;  pres@txString         = pltTitle
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelLabelBar           = True 
;  pres@pmLabelBarOrthogonalPosF  = -0.05                  ; moves label bar (up[-], down[+]) default 0.02
  pres@pmLabelBarHeightF         = 0.08
  pres@pmLabelBarWidthF           = 0.8
  pres@gsnPanelFigureStrings = version 
  pres@gsnPanelFigureStringsFontHeightF = 0.0125
  pres@lbLabelFontHeightF = 0.013
  pres@amJust           = "TopLeft"
  pres@gsnFrame         = False   
;  pres@gsnDraw         = False   
  ;pres@gsnPanelBottom    = 0.05			 ; add some space at bottom
  ;pres@gsnPanelBottom    = 0.2			 ; shrink panel plot by setting bottom edge of plot
  ;pres@gsnPanelTop       = 0.9			 ; shrink panel plot by setting top edge of plot
  ;pres@gsnMaximize	   = True			;for PDF the plot will be expanded to fill
							; the biggest possible space on an 8 1/2" x 11" 
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks(pltType,plotname)   
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table
; gsn_define_colormap(wks,"amwg")       ; select color table
  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
; gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
; res@gsnSpreadColorStart = 5
  res@gsnSpreadColorEnd = -3          ; 

;=====
;  Loop over all filies
;=====
  do i = 0,nfiles-1       ; loop

     print("File "+files(i))
     a = addfile(files(i),"r")

;*************   
;    read surface geopotential
;*************   
     phis    = a->PHIS({pday},{plat},{lon_start:lon_end})
     zs      = phis/gravity/1000.    ; surface elevation
     copy_VarCoords (phis,zs)
     zs@units = "km"
     zs@long_name = "Surface height"
     lon  = a->lon({lon_start:lon_end})
     printMinMax(lon,True)

;************************************************
;    read variables 
;************************************************
     if (var.eq."cloud") then
       variable = a->CLDLIQ({pday},:,{plat},{lon_start:lon_end})*1000.   ; (lat,lon)
       variable@long_name = "Cloud liquid water at "+plat+"~S~o~N~N"
       res@cnLevels             = (/ 0.001, 0.01, 0.025,  0.05, 0.10, 0.15, 0.2, 0.25, 0.3, 0.4, 0.50, 0.6 /) 
     else if (var.eq."rain") then
       variable = a->RAINQM({pday},:,{plat},{lon_start:lon_end})*1000.   ; (lat,lon)
       variable@long_name = "Rain water at "+plat+"~S~o~N~N"
       res@cnLevels             = (/ 0.001, 0.01, 0.025,  0.05, 0.10, 0.15, 0.2, 0.25  /) 
     else
;      specific humidity
       variable = a->Q({pday},:,{plat},{lon_start:lon_end})*1000.   ; (lat,lon)
       variable@long_name = "Water vapor at "+plat+"~S~o~N~N"
       ;res@cnLevelSelectionMode = "ManualLevels"
       ;res@cnMinLevelValF    = 0.                  ; set min contour level
       ;res@cnMaxLevelValF    = 8.               ; set max contour level
       ;res@cnLevelSpacingF   = 0.5                ; set contour spacing
       res@cnLevels             = (/0, 0.5, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12  /) 
     end if
     end if
     variable@units = "g/kg"

     z3 = a->Z3({pday},:,{plat},{lon_start:lon_end})/1000.   ; in km
     printMinMax(variable,True)

;-------------------------------------
;    interpolate to equidistant height levels
;-------------------------------------
;    linlog  = 1  ; no extrapolation, linear interpolation
;;   var1_z = int2p_n_Wrap(z3,variable,z_new,linlog,0)

     var_z = linint1_n_Wrap(z3,variable,False,z_new,0,0)
     var_z!1   = "lon"
     var_z&lon = lon

     res@sfXArray          = lon    ; x axis array
     plot(i) = gsn_csm_contour(wks,var_z,res)   
     plot_topo = gsn_csm_xy (wks,lon,zs,res1) 
     delete (res@sfXArray) 

     overlay (plot(i),plot_topo)
     delete (variable)
     delete (var_z)
     delete (phis)
     delete (zs)
     delete (z3)
     delete (lon)

  end do

  nrows = (nfiles+1)/2
  gsn_panel(wks,plot,(/nrows,2/),pres)
  frame(wks)

;  trim the white space
  if (pltType .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end

