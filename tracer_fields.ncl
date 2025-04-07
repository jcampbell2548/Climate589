;*************************************
; tracer_fields.ncl
;
; Example usage: 
; ncl tracer_fields.ncl
; ncl level=700 day=10 'pfmt="png"' tracer_fields.ncl
; ncl level=200 day=9 'pfmt="png"' tracer_fields.ncl
;
; for MPAS, level closest to 5000 m is selected
;  ncl level=5000  day=10 'pfmt="png"' tracer_fields.ncl
;***********************************************


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("day")) then           ; command line setting?
      pday = day                   ; command line
  else
      pday = 1                     ; default day 9
  end if

  if (isvar("level")) then            ; pressure or MPAS height level level on command line?
      plev = level                    ; command line
  else
      plev =  500.                ; default  [hPa]
  end if

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line
  else
      type = "png"                ; default X11 window
  end if


;=====
; declare the file name of the plot
;=====
  plotname = "tracers"   ; dycore and day will be appended to this name

;=====
; declare the CAM directory and file
;=====
  PATH = "/glade/derecho/scratch/$USER/CAM_6_3_45_SEne16_diffusion2/run/"

;  PATH = "/glade/scratch/$USER/CAM_Jan22.SEne30.L30.fkessler.bw_topo/run/"
;  data = PATH+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.no_topo.nc"
;  data = PATH+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.ridge_topo.nc"
;  data = PATH+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.no_topo.nc"

  data = PATH+"CAM_6_3_45_SEne16_diffusion2.cam.h0i.0001-01-02-00000.nc"

;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "SEne16"               ; label in plot and filename
; dycore  = "EULT85L30"           ; label in plot, name your dycore
; dycore  = "FV3c96L30"            ; label in plot, name your dycore
; dycore  = "MPAS120L32"           ; label in plot, name your dycore
; dycore  = "MPAS60L32"           ; label in plot, name your dycore
; dycore  = "SEne30L30"            ; label in plot, name your dycore
; dycore  = "all_dycores"          ; label in plot, name your dycore

;=====
; declare a label for the type of dissipation
;=====
 diff   = "halved_diffusion"           ; coefficient of the fouth-order hyper-diffusion is 1e15
; diff   = "no_dif4"             ; no explicit diffusion
; diff   = "dif4_1e16"           ; dif4 increased by a factor of 10
; diff   = "div4"                 ; 4th-order divergence damping 
; diff   = "nu_top_0.01"                 ; small dif2 at the model top
; diff = "div4"

;=====
; complete the plotname
;=====
  plotname = plotname+"_"+dycore+"_"+diff+"_plev"+plev+"_day"+pday
;  plotname = plotname+"_"+dycore+"_plev"+plev+"_day"+pday

;************************************************
; open netCDF file
;************************************************
  a = addfile(data,"r")

;================================================
; List the tracer names and set parameters
;================================================
;
; needed settings are: either from the 
; linear_correlation (False or True)
; vnames list
; initialization of fcnt 
;
;-----------------
; no test of linear correlations
; set the flag linear_correlation to False
; and use the  fcnt = dimsizes(vnames) command
;-----------------
  linear_correlation = False     ; 
; 6 panels: Example for 6 tracers
  vnames  = (/"TT_SLOT1","TT_SLOT2","TT_SLOT3","TT_COSB","TT_CCOSB","TT_lCCOSB"/)
; 3 panels: Example for 3 tracers
;  vnames  = (/"TT_SLOT1","TT_SLOT2","TT_SLOT3"/)
;  vnames  = (/"TT_COSB","TT_CCOSB","TT_lCCOSB"/)
  fcnt = dimsizes(vnames)

;=======
;-----------------
; with a test of linear correlations
; set the flag linear_correlation to True
; and use the  fcnt = dimsizes(vnames)+1 command
;-----------------
; 4 panels: Example for 3 tracers plus the test of the linear correlation between SLOT1, SLOT2 and SLOT3
;  linear_correlation = True
;  vnames  = (/"TT_SLOT1","TT_SLOT2","TT_SLOT3"/)     ; linear correlation between 3 slot tracers
;  vnames  = (/"TT_COSB","TT_lCCOSB"/)                 ; linear correlation between TT_COSB and TT_lCCOSB
;  fcnt = dimsizes(vnames) + 1

;************************************************
; read variables
;************************************************
  lev  = a->lev
  lat  = a->lat
  klev  = dimsizes(lev) - 1              ; index counts from 0 ... klev (30 values)

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
;  print (zs_min)
;  print (zs_max)

;*************
; Resources
;*************
  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large
  pres@txString    = dycore+", "+diff+", "+plev+" hPa level"
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
  res@lbLabelAutoStride = True
  res@tiMainString      = ""
  res@vpWidthF          = 0.44
  res@vpHeightF         = 0.22
  res@gsnCenterString   = "Day "+pday
  res@pmLabelBarWidthF     = 0.4

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
  res@cnMinLevelValF  = 0.
  res@cnMaxLevelValF  = 1.
  res@cnLevelSpacingF = 0.1 
  res@cnLinesOn         = False

  npanel = fcnt
  if (fcnt.eq.1 .or. fcnt.eq.3 .or. fcnt.eq.5) then
    npanel = fcnt+1
  end if
  plot = new(npanel,graphic)
  do k=0,fcnt-1
    print("plot "+k)
    if (linear_correlation.and.(fcnt.eq.3.and.k.eq.2. .or. fcnt.eq.4 .and. k.eq.3)) then
      varp = varp_linear 
      varp@long_name = plev+" hPa correlation" 
      varp@units     = "kg/kg"
    else
      if (dycore.eq."MPAS120L32".or.dycore.eq."MPAS60L32".or.dycore.eq."MPAS240L32") then
         varp  = a->$vnames(k)$({pday},{plev},:,:)    ; Read data
         height = round(a->lev({plev}),3)
         varp@long_name = height+" m "+vnames(k)
         varp@units     = "kg/kg"
      else
        hyam = a->hyam
        hybm = a->hybm
        var  = a->$vnames(k)$({pday},:,:,:)    ; Read data
        var@units = "kg/kg"
;       interpolate to a pressure level
        tmp = vinth2p(var,hyam,hybm,(/plev/),ps,1,P0mb,1,True)       ; (1,lat,lon)
        varp = tmp(0,:,:)     ; eliminate the level dimension
        varp@long_name = plev+" hPa "+vnames(k)
        varp@units     = "kg/kg"
      end if
      if (linear_correlation) then
        if (k.eq.0) then
          varp_linear = varp
        else
          varp_linear = varp_linear + varp   ; compute the sum of the first 3 tracers
        end if
      end if
;      delete(var)
;      delete(tmp)
;      delete(varp)
    end if

;   overlay topography contours
    if (zs_max .gt. 1. .and. zs_min .ge. 0.) then
      plot1 = gsn_csm_contour(wks,varp,res)
      plot2 = gsn_csm_contour(wks,zs,res_overlay)
      overlay (plot1,plot2)
      plot(k) = plot1
    else
      plot(k) = gsn_csm_contour(wks,varp,res)
    end if

  end do

  gsn_panel(wks,plot,(/npanel/2,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "png") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
