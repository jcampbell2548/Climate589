;*************************************
; lat_lon_comparison.ncl
;
; Example usage: 
;
; surface pressure (at day 9, default), png file
; ncl 'field="ps"' 'pfmt="png"' lat_lon_comparison.ncl
;
; sea level pressure (at day 15, png file)
; ncl 'field="psl"' 'pfmt="png"' day=15 lat_lon_comparison.ncl
;
; temperature (850 hPa (default) level at day 11), png file
; ncl 'field="t"' 'pfmt="png"' day=11 lat_lon_comparison.ncl
;
; relative vorticity (850 hPa (default) level at day 9, default day)
; ncl 'field="vor"' 'pfmt="png"' lat_lon_comparison.ncl
;
; tmq (vertically integrated precipitable water at day 9), png file
; ncl 'field="tmq"' 'pfmt="png"' lat_lon_comparison.ncl
;
; precl (precipitation rate at day 9), png file
; ncl 'field="precl"' 'pfmt="png"' lat_lon_comparison.ncl
;
; omega (850 hPa level at day 9, default), png file
; ncl 'field="omega"' 'pfmt="png"' lat_lon_comparison.ncl
;
; 700 hPa temperature at day 10:
; needs manual adjustment of the min/max contour range
; ncl 'field="t"' day=10 'pfmt="png"' level=700 lat_lon_comparison.ncl
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
      pvar = field                   ; command line
  else
      pvar = "psl"                  ; default day 9
  end if

  if (isvar("day")) then           ; command line setting?
      pday = day                   ; command line
  else
      pday = 30                     ; default day 9
  end if

  if (isvar("level")) then            ; pressure level on command line?
      plev = level                    ; command line
  else
      plev =  850.                ; default  [hPa]
  end if

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "png"                ; default X11 window
  end if

;===================================
; declare the CAM directory and file
;===================================
;
; adjust PATH, files and version
; possibly; adjust the predefined color ranges
;           res@cnMinLevelValF  = XXX
;           res@cnMaxLevelValF  = YYY
;           res@cnLevelSpacingF = ZZZ
;
;
;  Example with 3 files, same directory
;
  casename = "CAM_6_3_45_SEne60_diffusion"
  PATH = "/glade/derecho/scratch/juliacam/"+casename+"/run/"
;
; 3 different files, more (up to 6 total) can be added, last entry needs /) at the end
;
  files = (/PATH+"CAM_6_3_45_SEne60_diffusion.cam.h0i.0001-01-02-00000.doubled.nc",\
            PATH+"CAM_6_3_45_SEne60_diffusion2.cam.h0i.0001-01-02-00000.default.nc",\
            PATH+"CAM_6_3_45_SEne60_diffusion3.cam.h0i.0001-01-02-00000.halved.nc"/)

; define the labels for the plot
  version = (/"doubled diffusion","default diffusion", "halved diffusion"/)

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

;************************************************
; plot resources [options]
;************************************************
  if (nfiles .eq. 3 .or. nfiles .eq.5) then
    plot = new(nfiles+1,graphic)
  else 
    plot = new(nfiles,graphic)
  end if

;=====
; declare the file name of the plot
;=====
  plotname = "dry_rossby_comparison_"+pvar   ; dycore and day will be appended to this name

;=====
; declare a label for the dycore (appears in the title and the file name)
;=====
 dycore   = "SEne60"               ; label in plot, name your dycore
; dycore   = "FV09L30_FV05L30"       ; label in plot, name your dycore

; dycore   = "EULT85L30"           ; label in plot, name your dycore
; dycore   = "FV3c96L30"            ; label in plot, name your dycore
; dycore   = "MPAS120L30"           ; label in plot, name your dycore
; dycore   = "SEne30L30"            ; label in plot, name your dycore
; dycore   = "all_dycores"          ; label in plot, name your dycore

;=====
; complete the plotname
;=====
  if (pvar .eq. "ps") then
    plotname = plotname+"_"+dycore+"_ps_day"+pday
  else if (pvar .eq. "psl") then
    plotname = plotname+"_"+dycore+"_psl_day"+pday
  else
    plotname = plotname+"_"+plev+"hPa_"+dycore+"_day"+pday
  end if
  end if

;=======
; open plot and define color table
;=======
  wks = gsn_open_wks(type,plotname)   
  gsn_define_colormap(wks,"WhBlGrYeRe")       ; select color table

;************************************************
;   format the panel plot 
;************************************************
  pres = True               ; panel
  pres@gsnMaximize = True   ; [e]ps, pdf  make  large 
  pres@gsnPanelYWhiteSpacePercent = 0
  pres@gsnPanelXWhiteSpacePercent = 3
  pres@gsnPanelLabelBar           = True
  pres@gsnPanelFigureStrings= (/"a)","b)","c)","d)","e)","f)"/) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.012
  pres@amJust           = "BottomLeft"
  pres@gsnFrame         = False   
  pres@pmLabelBarWidthF         = 0.88
  pres@pmLabelBarOrthogonalPosF = -0.01   ; negative moves down
  pres@lbTitleFontHeightF  = 0.05
  pres@lbLabelFontHeightF  = 0.014

;=====
; Loop over all filies
;=====
  do i = 0,nfiles-1       ; loop

     print("File "+files(i))
     a = addfile(files(i),"r")

;************************************************
;    read variables
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
;    read surface pressure
;*************   
     ps = a->PS({pday},:,:)
     ps@units      = "Pa"
     ps@long_name  = "p~B~s~N~"

;*************
;    read surface geopotential (first time index)
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

     if (pvar .eq. "ps") then
;*************   
;      read  surface pressure and convert ps to hPa
;*************   
       var = ps*0.01                     ; if JW06, use actual surface presure
       copy_VarMeta (ps,var)             ; copy attributes and coordinate information
       var@units = "hPa"
       var@_FillValue = -9999.0

     else if (pvar .eq. "psl") then
;*************   
;      read sea level pressure and convert psl to hPa
;*************   
       var = a->PSL({pday},:,:)/100.
       copy_VarMeta (ps,var)             ; copy attributes and coordinate information
       var@long_name = "sea level p"
       var@units = "hPa"
       var@_FillValue = -9999.0

     else if (pvar .eq. "precl") then
;*************   
;      read precipitation rate and convert to mm/day
;*************   
       var = a->PRECL({pday},:,:)*8.64e7
       copy_VarMeta (ps,var)             ; copy attributes and coordinate information
       var@long_name = "Precipitation rate"
       var@units = "mm/day"

     else if (pvar .eq. "tmq") then
;*************   
;      read sea level pressure and convert psl to hPa
;*************   
       var   = a->TMQ({pday},:,:)                             ; (lat,lon)
       var@long_name = "Precipitable water"

     else if (pvar .eq. "t") then
;*************   
;      read temperature at 850 hPa or interpolate
;*************   
       if (plev.eq.850 .and. isfilevar(a, "T850")) then
         var = a->T850({pday},:,:)                             ; (lat,lon)
       else
         tmp1 = a->T({pday},:,:,:)  
         tmp2 = vinth2p(tmp1,hyam,hybm,(/plev/),ps,1,P0mb,1,True)       ; (1,lat,lon)
         var   = tmp2(0,:,:)     ; eliminate the level dimension
         delete (tmp1)
         delete (tmp2)
       end if
       var@long_name = plev+" hPa T"
       var@units     = "K"

     else if (pvar .eq. "vor") then
;*************   
;      read u and v at 850 hPa or interpolate
;*************   
       if (plev .eq. 850 .and. isfilevar(a, "U850") .and. isfilevar(a, "V850")) then
         tmp1 = a->U850({pday},:,:)
         tmp2 = a->V850({pday},:,:)
       else
         tmp3    = a->U({pday},:,:,:)  
         tmp4    = a->V({pday},:,:,:)  
         tmp5 = vinth2p(tmp3,hyam,hybm,(/plev/),ps,1,P0mb,1,True)
         tmp6 = vinth2p(tmp4,hyam,hybm,(/plev/),ps,1,P0mb,1,True)
         tmp1 = tmp3(0,:,:)     ; eliminate the level dimension U850
         tmp2 = tmp4(0,:,:)     ; eliminate the level dimension V850

         delete (tmp3)
         delete (tmp4)
         delete (tmp5)
         delete (tmp6)
       end if

       tmp1@units = "m/s"
       tmp2@units = "m/s"
       tmp1@long_name = plev+" hPa U"
       tmp2@long_name = plev+" hPa V"
       if (abs(lat(0)) .gt. 89.95) then
         var = uv2vrF_Wrap (tmp1,tmp2)     ; vorticity via spherical harmonics on fixed grid
         print("Fixed grid with poles")
       else
         var = uv2vrG_Wrap (tmp1,tmp2)     ; vorticity via spherical harmonics on Gaussian grid
         print("Gaussian grid")
       end if

       var = var*1.e5                 ; scale for better looking plot
       var@units = "10~S~-5~N~ s~S~-1~N~"
       var@long_name = plev+" hPa ~F33~z"

       delete (tmp1)
       delete (tmp2)

     else
;*************   
;      read omega at 850 hPa or interpolate
;*************   
       if (plev .eq. 850 .and. isfilevar(a, "OMEGA850")) then
         var = a->OMEGA850({pday},:,:)               ; (lat,lon)
       else
         tmp1 = a->OMEGA({pday},:,:,:) 
         tmp2 = vinth2p(tmp1,hyam,hybm,(/plev/),ps,1,P0mb,1,True) ; (1,lat,lon)
         var = tmp2(0,:,:)     ; eliminate the level dimension
         delete (tmp1)
         delete (tmp2)
       end if
       var@units = "Pa/s"
       var@long_name = plev+" hPa ~F33~w"

     end if
     end if
     end if
     end if
     end if
     end if

;************************************************
;    print the min and max
;************************************************
     printMinMax(var,True)
 
;************************************************
;    format the plots 
;************************************************
     res = True  
     res@gsnDraw           = False              ; panel ... set to False
     res@gsnFrame          = False
     res@cnFillOn          = True
     res@cnLineColors      = "black"
     res@gsnSpreadColors   = True
     res@gsnSpreadColorStart = 4
     res@gsnSpreadColorEnd = 100          ; 
     res@lbLabelAutoStride = True
     res@tiMainString      = ""
     res@vpKeepAspect      = True
     res@vpWidthF          = 0.44
     res@vpHeightF         = 0.22
     res@lbLabelBarOn      = False
     res@cnLineLabelsOn    = False
     res@cnInfoLabelOn     = False
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
;    res_overlay@cnMaxLevelValF    = 6000.               ; set max contour level
;    res_overlay@cnMaxLevelValF    = 2000.               ; set max contour level
     res_overlay@cnLevelSpacingF   = 400.                ; set contour spacing
;    res_overlay@cnLineColor        = "gray"
     res_overlay@cnLineLabelsOn    = False
     res_overlay@cnInfoLabelOn     = False


     res@cnLinesOn       =  False 
     if (pvar .eq. "ps" .or. pvar.eq."psl") then
       if (pvar .eq. "ps") then
          pres@txString       = dycore+", surface pressure at day "+pday
       else
         pres@txString       = dycore+", sea level pressure at day "+pday
       end if
       res@cnLevelSpacingF = 10. 
       if (pday .le. 8) then
         res@cnMinLevelValF  = 970.
         res@cnMaxLevelValF  = 1010. 
         res@cnLevelSpacingF = 5. 
       else if (pday .le. 10) then
         res@cnMinLevelValF  = 940.
         res@cnMaxLevelValF  = 1020. 
       else if (pday .le. 13) then
         res@cnMinLevelValF  = 920.
         res@cnMaxLevelValF  = 1030. 
       else if (pday .gt. 13) then
         res@cnMinLevelValF  = 900.
         res@cnMaxLevelValF  = 1030. 
       end if
       end if
       end if
       end if
     else if (pvar .eq. "precl") then
       pres@txString       = dycore+", precipitation rate at day "+pday
       res@cnLevelSelectionMode = "ExplicitLevels"
       res@gsnSpreadColorStart = 0
       res@cnLevels             = (/ 0.10, 0.50, 1.00, 3, 5, 7.5, 10, 15, 20, 30, 40, 50, 75, 100 /) 
     else if (pvar .eq. "tmq") then
       pres@txString       = dycore+", precipitable water at day "+pday
       res@cnMinLevelValF  = 5.
       res@cnMaxLevelValF  = 55. 
       res@cnLevelSpacingF = 5. 
     else if (pvar .eq. "t") then
       pres@txString       = dycore+", "+plev+" hPa temperature at day "+pday
       res@cnLinesOn       = True
       res@cnMinLevelValF  = 230.
       res@cnMaxLevelValF  = 300. 
       res@cnLevelSpacingF = 10. 
     else if (pvar .eq. "vor") then
       pres@txString       = dycore+", "+plev+" hPa relative vorticity at day "+pday
       res@cnMinLevelValF  = -7.5
       res@cnMaxLevelValF  = 25. 
       res@cnLevelSpacingF = 2.5 
     else
       pres@txString       = dycore+", "+plev+" hPa vertical pressure velocity at day "+pday
       res@cnMinLevelValF  = -0.9
       res@cnMaxLevelValF  = 0.3 
       res@cnLevelSpacingF = 0.1 
     end if
     end if
     end if
     end if
     end if

     res@gsnCenterString   = version(i) 
     if (zs_max .gt. 1. .and. zs_min .ge. 0.) then
       plot1 = gsn_csm_contour(wks,var(:,:),res)
       plot2 = gsn_csm_contour(wks,zs(:,:),res_overlay)
       overlay (plot1,plot2)
       plot(i) = plot1
     else
       plot(i) = gsn_csm_contour(wks,var(:,:),res)
     end if

     delete (var)
     delete (lat)
     delete (lev)
     delete (hyam)
     delete (hybm)
     delete (ps)
     delete (phis)
     delete (zs)

  end do

  nrows = (nfiles+1)/2
  gsn_panel(wks,plot,(/nrows,2/),pres)
  frame(wks)

;  trim the white space
  if (type .ne. "png") then
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if

end
