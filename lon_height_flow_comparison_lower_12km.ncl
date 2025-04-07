script_name = "lon_height_flow_comparison_lower_12km.ncl"

; Example usage: 
; omega at day 4 is default
; ncl 'field="u"' 'pfmt="png" day=1 lon_height_flow_comparison_lower_12km.ncl
; ncl 'field="v"' 'pfmt="png" day=2 lat=10 lon_height_flow_comparison_lower_12km.ncl

;***********************************************
; Example Usage:
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
      pday = 20                    ; default day 4
  end if

  if (isvar("lat")) then           ; command line setting?
      plat = lat                   ; command line
  else
      plat = 40                    ; default at the equator
  end if

  if (isvar("field")) then           ; command line setting?
      var = field                   ; command line
  else
      var = "TT_COSB"                    ;  default variable omega
  end if

;=====
; declare a label for the dycore (appears in the title and the file name)
;=====
;  dycore   = "FV05L30_FV09L30"             ; label in plot, name your dycore
  dycore   = "SE"             ; label in plot, name your dycore
;=====
; complete the plotname
;=====
  plotname = dycore+"_lon_height_day"+pday
  pltTitle = ""

;  Example with 3 files, same directory
;
;  casename = "CAM_cesm2_2_rel_09.bw_dry_fv3C96L30"
  casename = "CAM_6_3_45_SEne30_Rossby"
  PATH = "/glade/derecho/scratch/$USER/"+casename+"/run/"
;
; select 2, 3, 4, 5 or 6 different files, more (up to 6 total) can be added, last entry needs /) at the end
;
;  files = (/PATH+casename+".cam.h0.0001-01-01-00000.regrid.1x1.jw.hord_10.nc",\
;            PATH+casename+".cam.h0.0001-01-01-00000.regrid.1x1.jw.hord_6.nc"/)
; define the labels for the plot
;  version = (/"hord = 10","hord = 6"/)

  files = (/"CAM_6_3_45_SEne16_Rossby.cam.h0i.0001-01-02-00000.nc",\
            CAM_6_3_45_SEne30_Rossby.cam.h0i.0001-01-02-00000.nc",\
            "CAM_6_3_45_SEne60_Rossby.cam.h0i.0001-01-02-00000.nc"/)

; define the labels for the cases specified above (shown in plots)
  version = (/"2-degree","1-degree", "0.5-degree"/)


;-------------------------------------------
; Example with 4 files
;  files = (/PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_1.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_5.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_10.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_100.nc"/)
;
;  version = (/"radius = 1", "radius = 5","radius = 10 (default)", "radius = 100"/)
;
;------
; Example for 3 model configurations, they can be in different directories
; specify the selected case names and define the PATH variables for the various simulations
;
;  casename1 = "CAM_6_3_45_bw_dry_fv09L30_jw06"
;  PATH1 = "/glade/derecho/scratch/$USER/"+casename1+"/run/"
;  casename2 = "CAM_6_3_45_bw_dry_fv09L30_jw06"
;  PATH2 = "/glade/derecho/scratch/$USER/"+casename2+"/run/"
;  casename3 = "CAM_6_3_45_bw_dry_fv09L30_jw06"
;  PATH3 = "/glade/derecho/scratch/$USER/"+casename3+"/run/"
;
;  files = (/PATH1+casename1+".cam.h0i.0001-01-02-00000.u_radius_1.nc",\
;            PATH2+casename2+".cam.h0i.0001-01-02-00000.u_radius_10.nc",\
;            PATH3+casename3+".cam.h0i.0001-01-02-00000.u_radius_100.nc"/)

;  specify the labels for the plots, examples are
;  version = (/"radius = 5","radius = 10 (default)", "radius = 100"/)
;
;;  version = (/"FV09 Rossby topo","FV09 bw topo", "FV05 bw topo"/)
;;  version = (/"FV09 bw topo r=7","FV09 bw top r=8", "FV05 bw topo"/)


  nfiles = dimsizes(files)             ; number of files
  gravity = 9.80616                    ; gravitational acceleration in m/s^2

;************************************************
; define new height level with equidistant spacing
;************************************************
  zlev  = 202 
  ztop  = 11.75   ; ztop set to 11.75 km
  z_new = new((/zlev/),float)
  dz = ztop/zlev

  do kk=0,zlev-1
      z_new(kk) = (ztop-0.5*dz)-(kk)*dz  
  end do
  z_new@units = "km"
  z_new@long_name = "Height"

;************************************************
; define the panel plot 
;************************************************
  if (nfiles .eq. 3 .or. nfiles .eq.5) then
    plot = new(nfiles+1,graphic)
  else 
    plot = new(nfiles,graphic)
  end if

;************************************************
; Plot Resources
;************************************************
  res  = True                
  res@gsnDraw  = False
  res@gsnFrame = False
  res@cnFillOn          = True
; res@cnLinesOn         = True
  res@cnLinesOn         = False
  res@gsnSpreadColors   = True
  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpKeepAspect      = True
  res@vpWidthF          = 0.48
  res@vpHeightF         = 0.29
  res@lbLabelBarOn      = True
  res@cnLineLabelsOn    = False
  res@cnInfoLabelOn     = False
  res@cnLevelSelectionMode = "AutomaticLevels"
  res@sfYArray          = z_new  ; y axis array
  res@tiYAxisString     = "Height (km)"
; res@tiXAxisString     = "Longitude"
  res@tiXAxisOffsetYF	   = 0.062
; res@tiMainFontHeightF  = 0.1
  res@tmXBLabelFontHeightF = 0.015                 ; resize tick labels
  res@tmYLLabelFontHeightF = 0.015
  res@gsnStringFontHeightF = 0.015
  res@lbLabelFontHeightF = 0.015

  pres = True
  pres@gsnMaximize      = False
  pres@txString         = pltTitle+dycore
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelLabelBar           = False 
; pres@pmLabelBarOrthogonalPosF  = -0.05                  ; moves label bar (up[-], down[+]) default 0.02
  pres@pmLabelBarHeightF         = 0.08
  pres@pmLabelBarWidthF           = 0.8
  pres@gsnPanelFigureStrings= version ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.0125
  pres@lbLabelFontHeightF = 0.015
  pres@amJust           = "TopLeft"
  pres@gsnFrame         = False   
; pres@gsnDraw         = False   
  pres@amJust           = "TopRight"
 ;pres@gsnPanelBottom    = 0.05			 ; add some space at bottom
 ;pres@gsnPanelBottom    = 0.2			 ; shrink panel plot by setting bottom edge of plot
 ;pres@gsnPanelTop       = 0.9			 ; shrink panel plot by setting top edge of plot
 ;pres@gsnMaximize	   = True			;for PDF the plot will be expanded to fill
							; the biggest possible space on an 8 1/2" x 11" 

;************************************************
;  create default plot
;************************************************
  wks = gsn_open_wks(pltType,plotname)   
;  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table
;  gsn_define_colormap(wks,"BlueRed")       ; select color table
;  gsn_define_colormap(wks,"amwg_blueyellowred")       ; select color table
  gsn_define_colormap(wks,"temp_19lev")
;  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")
;  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
;  res@gsnSpreadColorStart = 3
;  res@gsnSpreadColorEnd = -3          ; 

;  res@gsnCenterString = "at "+plat+"~S~o~N~N"
   res@gsnCenterString = "Day "+pday

;  res@cnLevelSelectionMode = "ManualLevels"
;  res@cnMinLevelValF    = -1.                  ; set min contour level
;  res@cnMaxLevelValF    = 1.               ; set max contour level
;  res@cnLevelSpacingF   = 0.1                ; set contour spacing

;  res@cnLevelSelectionMode = "ExplicitLevels"
;  res@cnLevels             = (/ 0.001, 0.01, 0.025,  0.05, 0.10, 0.15, 0.2, 0.25, 0.3, 0.4, 0.50, 0.6 /) 

;************************************************
;   Resources for the topography
;************************************************
   res1 = True
   res1@gsnDraw  = False
   res1@gsnFrame = False
   res1@xyLineThicknessF   = 3.          ; line thickness
   res1@xyLineColors       = (/"black","white","blue","red","green"/)          ; line thickness
;  res1@gsnXYBelowFillColors = "black"     ; not a valid resource

;=====
;  Loop over all filies
;=====
   do i = 0,nfiles-1       ; loop

     print("File "+files(i))
     a = addfile(files(i),"r")

;************************************************
;    read longitudes
;************************************************
     lon  = a->lon
     printMinMax(lon,True)
  ;  printVarSummary(lon)

;*************   
;    read surface geopotential
;*************   
     phis    = a->PHIS(0,{plat},:)
     zs      = phis/gravity/1000.    ; surface elevation in km
     copy_VarCoords (phis,zs)
     zs@units = "km"
     zs@long_name = "Surface height"

;*************   
;    read variable and geopotential height Z3
;*************   
     if (var.eq."omega") then
       variable = a->OMEGA({pday},:,{plat},:)                       ; (lat,lon)
       variable@long_name = "~F33~w ~F25~at "+plat+"~S~o~N~N"
       variable@units = "Pa/s"
     else if (var.eq."u") then
       variable = a->U({pday},:,{plat},:)                           ; (lat,lon)
       variable@long_name = "U at "+plat+"~S~o~N~N"
     else
       variable = a->V({pday},:,{plat},:) 
       variable@long_name = "V at "+plat+"~S~o~N~N"
     end if
     end if

     z3 = a->Z3({pday},:,{plat},:)/1000.   ; in km
     printMinMax(variable,True)

;-------------------------------------
;    interpolate the variable to equidistant height levels
;-------------------------------------
;     linlog  = 1  ; no extrapolation, linear interpolation
;     var_z = int2p_n_Wrap(z3,variable,z_new,linlog,0)

     var_z     = linint1_n_Wrap(z3,variable,False,z_new,0,0)
     var_z!1   = "lon"
     var_z&lon = lon

;     minimum = abs(min(var_z))
;     maximum = abs(max(var_z))
;     limit   = minimum                ; centers the zero contour 
;     if (limit.lt.maximum) then
;       limit  = maximum                ; centers the zero contour 
;     end if
;     res@cnMinLevelValF    = -limit                 ; set min contour level
;     res@cnMaxLevelValF    = limit                  ; set max contour level
     res@sfXArray          = lon    ; x axis array
;    res1@sfXArray         = lon    ; x axis array
     plot(i) = gsn_csm_contour(wks,var_z(:,:),res)   
     plot_topo = gsn_csm_xy (wks,lon(:),zs(:),res1) 
     delete (res@sfXArray) 
;    delete (res1@sfXArray) 

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
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end

