;********************************************************************************
; Created by Christiane Jablonowski 1/17/2024
;********************************************************************************
; Default: X11 plot on the screen
; ncl ic_lat_p_stability.ncl
;
; Alternative: plot is stored as an eps file, use command line setting
; ncl 'pfmt="png"' ic_lat_p_stability.ncl
;********************************************************************************


;********************************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;********************************************************************************

begin

;=====
; declare the CAM directory, file and configuration
;=====
  casename = "CAM_6_3_45_bw_dry_fv09L30_jw06"
  dir = "/glade/derecho/scratch/$USER/"+casename+"/run/"
  data = dir+casename+".cam.h0i.0001-01-02-00000.nc"

  version  = "dry_jw06_default"   ; no white space, describe the version of the initial condition, is used in the plotname and title string       
;=====
; declare a label for the dycore that appears in the plot
;=====
 dycore   = "FV09L30"              ; label in plot and filename

; dycore  = "EULT85L30"            ; label in plot, name your dycore
; dycore  = "FV3c96L30"            ; label in plot, name your dycore
; dycore  = "MPAS120L30"           ; label in plot, name your dycore
; dycore  = "SEne30L30"            ; label in plot, name your dycore

;=====
; read command line settings
;=====

  if (isvar("pfmt")) then            ; plot format specified on command line?
      type = pfmt                    ; read plot type from command line
  else
      if (.not.ismissing(getenv("PFMT"))) then   ; environment variable set?
          type = getenv("PFMT")   ; use environment variable .. if present
      else
          type = "X11"            ; default is "X11", other choices can be "eps", "pdf", "png"
      end if
  end if

;=====
; declare the file name of the plot
;=====
  plotname = "bw_dry_jw06_ic_lat_p_stability_"+version+"_"+dycore    ; name of the plot  

;=====
; define parameters
;=====
  g = 9.80616
  Rd = 287.

;=====
; open NetCDF file
;=====
  a = addfile(data,"r")

;=====
;read in coordinates
;=====
  time = a->time
  lat  = a->lat
  lon  = a->lon
  lev  = a->lev

  nlon = dimsizes(lon)
  nlev = dimsizes(lev)

;=====
; evaluate the first time snapshot 0
;=====
  start_day = 0   ; initial state is index 0 

;=====
; read data 
;=====
  t  = a->T(start_day,:,:,[nlon/2])     ;  temperature at longitude near lon=180
  u  = a->U(start_day,:,:,[nlon/2])     ;  zonal wind at longitude near lon=180
  p  = t
  do k = 0, nlev-1
    p(k,:) = doubletofloat(lev(k)) * 100.              ; pressure in Pa
  end do
  p@units = "Pa"

;====
; compute the static stability indicators
;=====
  s1 = static_stability (p, t, 0, 1)  ; dim=0, opt=1 

  s = s1[0]          ; static stability parameter
  pt = s1[1]         ; potential temperature 

  printVarSummary (s)
  printVarSummary (pt)

  N2=t
  N2 = g*g*p/(t*t*Rd) * s
  copy_VarMeta (t,N2)                ; copy attributes and coordinate information
  N2@units = "s~S~-2~N~"
  N2@long_name = "N~S~2~N~"
  pt@long_name = "Potential temperature"

  printVarSummary (N2)
  
;=====
; set properties of the new array
;=====
;  var_diff@long_name = ""
;  var_diff@units = var@units
;  var_diff!0     = "lev"
;  var_diff&lev   = lev
;  var_diff!1     = "lat"
;  var_diff&lat   = lat  

;=====
; print some diagnostics
;=====
  printMinMax(s,True)
  printMinMax(pt,True)
  printMinMax(N2,True)


;**********************************************************************************
; Plot the panel
;**********************************************************************************

  plot = new(4,graphic)

  res                 = True
  res@cnFillOn        = True           ; filled contours
  res@cnLinesOn       = True           ; contour lines are selected
  res@cnLineColors    = "black"        ; contour line color is black
  res@gsnSpreadColors = True           ; uses the full spectrum of the color table
  res@gsnContourNegLineDashPattern = 1 ; sets negative contours to dash pattern 1
  res@gsnContourZeroLineThicknessF = 2 ; thickness of the zero contour line is enhanced
  res@lbLabelAutoStride = True         ; automatic labels
  res@cnInfoLabelOn   = False          ; turn off contour info label
;  res@cnLineLabelsOn  = True 
  res@cnLineLabelsOn  = False          ; turn off contour line labels 
  res@vpWidthF        = 0.5            ; relative width
  res@vpHeightF       = 0.32           ; relative height
  res@lbLabelBarOn    = True           ; plot labelbar
  res@cnLevelSelectionMode  = "AutomaticLevels"  ; default, automatic contour levels
  res@trYReverse      = True             ; higher pressure values along y-axis are at the bottom
  res@tiYAxisString   = "Pressure (hPa)" ; y axis label

; Logarithmic scale 
;    res@gsnYAxisIrregular2Log = True       ; Convert Y axis to log axis, emphasizes upper levels
;   Set some axis labels, otherwise all we'll get is "10^3".
;    res@tmYLMode              = "Explicit"
;    res@tmYLValues            = (/4.,6.,10.,20.,50.,100.,200.,500.,900./)
;    res@tmYLLabels            = "" + res@tmYLValues

; Linear scale
  res@gsnYAxisIrregular2Linear = True   ; Convert Y axis to linear

; settings that determine the font size of the labels
  res@tmEqualizeXYSizes     = True
  res@tmXBLabelFontHeightF  = 0.018
  res@gsnStringFontHeightF  = 0.02
  res@lbLabelFontHeightF    = 0.018
  res@txFontHeightF         = 0.02
  res@tiXAxisFontHeightF    = 0.02
  res@tiYAxisFontHeightF    = 0.02
  res@pmLabelBarWidthF      = 0.5

; for panel plot:
  res@gsnDraw         = False      ; default=True
  res@gsnFrame        = False      ; default=True

; open the plot and select color table  
  wks = gsn_open_wks(type,plotname)           ; open the plot
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table
  res@gsnSpreadColorStart = 4
  res@gsnSpreadColorEnd = 100          ; 

; resources for the panel plot:
  pres = True                          ; panel plots desired
;  pres@gsnPanelLabelBar = True        ; common label bar
;  pres@gsnMaximize = True             ; make ps, eps, pdf large
  pres@txString    = ""                ; text string for panel plot
  pres@gsnPanelYWhiteSpacePercent = 3  ; spacing increased
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)","g)","h)"/) ; add strings to panel
  pres@amJust           = "TopLeft"    ; position of strings (see above)
  pres@gsnFrame         = False
  pres@gsnPanelFigureStringsFontHeightF = 0.012
  pres@txString       = dycore+": Initial state and stability parameters with "+version

;  manual settings of contour spacing if desired
;  res@cnLevelSelectionMode = "ManualLevels"  ; if set, contour levels are set manually
;  res@cnMaxLevelValF  =  45 
;  res@cnMinLevelValF  =  0.
;  res@cnLevelSpacingF =  5.
;  res@tiYAxisString   = ""

  res@gsnCenterString   = ""

  res@cnLevelSpacingF =  10.
  plot(0) = gsn_csm_contour(wks,t,res)
  res@cnLevelSpacingF =  0.00005
  plot(2) = gsn_csm_contour(wks,N2,res)
  res@cnLevelSpacingF =  5.
  plot(3) = gsn_csm_contour(wks,u,res)

  res@cnLevelSelectionMode = "ExplicitLevels"  ; if set, contour levels are set manually
  res@cnLevels = (/230., 250., 270., 290., 300., 310., 320., 330., 340., 350., 400., 500., 600. /)
  plot(1) = gsn_csm_contour(wks,pt,res)

  gsn_panel(wks,plot,(/2,2/),pres)  ; plot the panel

  frame(wks)	; now frame the plot and we're done
;  trim the white space
  if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end

