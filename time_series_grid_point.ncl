;*************************************
; Example usage: 

; surface pressure is default
; ncl 'field="ps"'  'pfmt="png"' time_series_grid_point.ncl
; ncl 'field="ps"' longitude=230 latitude=55 time_series_grid_point.ncl
;
; temperature (850 hPa level) with png output
; ncl 'field="t850"' 'pfmt="png"' time_series_grid_point.ncl
;
; sea level pressure 
; ncl 'field="psl"'  time_series_grid_point.ncl
;
; omega (850 hPa level)
; ncl 'field="omega850"'  time_series_grid_point.ncl
;***********************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  

;************************************************
begin

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("field")) then           ; command line setting?
      pvar = field                   ; command line, e.g. t850, omega850, ps
  else
      pvar = "ps"                  ; default ps
  end if

  if (isvar("latitude")) then           ; command line setting?
      plat = latitude                   ; command line
  else
;      plat = 50                         ; default 50N, position of the highs
      plat = 60                         ; default 60N,  position of the lows
  end if

  if (isvar("longitude")) then           ; command line setting?
      plon = longitude                   ; command line
  else
      plon = 210                         ; default 210E 
  end if

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "X11"                ; default X11 window
  end if

;===================================
; declare the CAM directory and file
;===================================
;
; adjust PATH, files and version
; possibly: adjust the predefined color ranges (see below)
;
  casename = "CAM_6_3_45_bw_dry_fv09L30_jw06"
  PATH = "/glade/derecho/scratch/$USER/"+casename+"/run/"
;
; 3 different files, more (up to 6 total) can be added, last entry needs /) at the end
;
  files = (/PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_1.nc",\
            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_10.nc",\
            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_100.nc"/)

; define the labels for the plot
  version = (/"radius = 5","radius = 10 (default)", "radius = 100"/)

;-------------------------------------------
; Example with 4 files
;  files = (/PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_1.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_5.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_10.nc",\
;            PATH+casename+".cam.h0i.0001-01-02-00000.u_radius_100.nc"/)
;
;  version = (/"radius = 1", "radius = 5","radius = 10 (default)", "radius = 100"/)
;  version = (/"FV09L30, radius = 10", "FV09L30, radius = 5","FV09L30, radius = 1", "FV09L30, radius = 100"/)

  colors = (/"red","green","black","orange"/)

  nfiles = dimsizes(files)             ; number of files

;=====
; declare a label for the dycore
;=====
 dycore   = "FV09L30"               ; label in plot, name your dycore

; dycore  = "EULT85L30"           ; label in plot, name your dycore
; dycore  = "FV3c96L30"            ; label in plot, name your dycore
; dycore  = "MPAS120L30"           ; label in plot, name your dycore
; dycore  = "SEne30L30"            ; label in plot, name your dycore
; dycore  = "all_dycores"          ; label in plot, name your dycore

;=====
; declare the file name of the plot
;=====
  plotname = "bw_dry_jw06_time_series_"+dycore+"_"+pvar+"_lon"+plon+"_lat"+plat   ; day will be appended to this name
  wks = gsn_open_wks(type,plotname)

;=====
; definitions
;=====
  P0   = 100000.      ; Pa
  P0mb = P0*0.01      ; hPa 
  plev = 850.

;************************************************
;    plot resources [options]
;************************************************
     res                  = True 
;    res@gsnMaximize      = True
     res@tiMainString     = "Longitude "+plon+", Latitude "+plat
     res@gsnPaperOrientation = "portrait"
     res@gsnDraw          = False
     res@gsnFrame         = False
     res@xyLineThicknessF = 3.0

;=====
; Loop over all filies
;=====
  do i = 0,nfiles-1       ; loop

     print("File "+files(i))
     a = addfile(files(i),"r")

;************************************************
;    read variables
;************************************************

     ntime  = getfilevardimsizes(a, "time" ) ; read number of time snapshots
     time_day = new((/ntime/),float)
     time_day = ispan(1,(ntime),1)      ; data start at day 1
;     time_day = ispan(0,(ntime-1),1)   ; data start at day 0
     time_day@units = "Day"
     time_day@long_name = "Day"
     printMinMax(time_day, True)

     hyam = a->hyam
     hybm = a->hybm

     if (pvar .eq. "ps") then
;*************   
;      read surface pressure
;*************   
       ps = a->PS(:,{plat},{plon})
;*************   
;      convert ps to hPa
;*************   
       var = ps*0.01
       copy_VarMeta (ps,var)                ; copy attributes and coordinate information
       var@units = "hPa"
       var@long_name = "p~B~s~N~ (hPa)"
       var@_FillValue = -9999.0

     else if (pvar .eq. "psl") then
;*************   
;      read sea level pressure
;*************   
       ps = a->PSL(:,{plat},{plon})
;*************   
;      convert ps to hPa
;*************   
       var = ps*0.01
       copy_VarMeta (ps,var)                ; copy attributes and coordinate information
       var@units = "hPa"
       var@long_name = "sea level pressure (hPa)"
       var@_FillValue = -9999.0

     else if (pvar .eq. "t850") then
;*************   
;      read temperature at 850 hPa or interpolate
;*************   
       if (isfilevar(a, "T850")) then
         var = a->T850(:,{plat},{plon}) 
       else
         t     = a->T(:,:,{plat},{plon})  
         T_850 = vinth2p(t,hyam,hybm,(/plev/),ps,1,P0mb,1,True)       ; (time,1)
         var   = T_850(:,0)     ; eliminate the level dimension
         delete (t)
         delete (T_850)
       end if
       var@long_name = "850 hPa T (K)"
       var@units     = "K"

     else
;*************   
;      read omega at 850 hPa or interpolate
;*************   
       if (isfilevar(a, "OMEGA850")) then
         var = a->OMEGA850(:,{plat},{plon})               ; (time)
       else
         omega= a->OMEGA(:,:,{plat},{plon}) 
         OMEGA850 = vinth2p(omega,hyam,hybm,(/plev/),ps,1,P0mb,1,True) ; (time,1)
         var = OMEGA850(:,0)     ; eliminate the level dimension
         delete (omega)
         delete (OMEGA850)
       end if
       var@units = "Pa/s"
       var@long_name = "850 hPa ~F33~w~F25~ (Pa/s)"
     end if
     end if
     end if

;************************************************
;    print the min and max
;************************************************
     printMinMax(var,True)
 
     if (i.eq.0) then    ; set min/max range based on the first file, might need to be revised
       res@trYMinF          = (min(var)-5)    ;
       res@trYMaxF          = (max(var)+5)    ; 
       if (pvar.eq."omega850") then
         res@trYMinF          = min(var)-0.25*abs(min(var))    ;
         res@trYMaxF          = max(var)+0.25*abs(max(var))    ; 
       end if
     end if

     res@xyLineColor      = colors(i)

     plot0 = gsn_csm_xy(wks,time_day,var,res)

     if (i .eq. 0) then
       plot = plot0
     else
       overlay(plot,plot0)
     end if

  end do
  
; Attach a legend

  lgres                    = True
  lgres@lgLineColors       = colors
  lgres@lgLineThicknessF = 3.0
  lgres@lgItemType         = "Lines"        ; show lines only (default)
  lgres@lgLabelFontHeightF = .12            ; legend label font thickness
  lgres@vpWidthF           = 0.25           ; width of legend (NDC)
  lgres@vpHeightF          = 0.15           ; height of legend (NDC)
  lgres@lgPerimThicknessF  = 2.0            ; thicken the box perimeter
  lgres@lgMonoDashIndex    = True
  lgres@lgDashIndex        = 0

  legend = gsn_create_legend (wks, nfiles, version, lgres)

;
; Use gsn_add_annotation to attach this legend to our existing plot.
; This way, if we resize the plot, the legend will stay with the
; plot and be resized automatically.
;
; Point (0,0) is the dead center of the plot. Point (0,.5) is center,
; flush bottom. Point (0.5,0.5) is flush bottom, flush right.
;
  amres                  = True
  amres@amJust           = "BottomLeft"    ; Use bottom left corner of box
                                            ; for determining its location.
  amres@amParallelPosF   = -0.5              ; Move legend to left
  amres@amOrthogonalPosF = 0.5              ; Move legend down 

  annoid = gsn_add_annotation(plot,legend,amres)  ; add legend to plot

  draw(plot)
  frame(wks)

;  trim the white space
 if (type .ne. "X11") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end

