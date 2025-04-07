;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ================================================;
begin

  if (isvar("pfmt")) then            ; plot format specified on command line?
      pltType = pfmt                 ; command line
  else
;      pltType = "png"                ; default, others: X11, pdf
      pltType = "X11"                ; default, others: X11, pdf
  end if

;=================================================;
; open file and read in data
;=================================================;
; if moist Held-Suarez test, set this flag to True, if aqua-planet set this flag to False
;  MHS = True
  MHS = False 

; specify the name of the plot and scratch directory
  plotname = "ape.cam6_2d_comparison"
  dir  = "/glade/derecho/scratch/$USER/"

; File Paths and names ---------------------------------------------------
; Example with 6 file names, pick 6 different files MHS or APE
;  file1 = (/"/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;           "/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;            "/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;            "/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;            "/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;            "/glade/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc"/)

;  Example with 3 aqua-planet file names, up to 6 files can be specified
   file1 = (/dir+"CAM_6_3_45_AQP1/run/CAM_6_3_45_AQP1.cam.h0a.0001-01-31-00000.nc",\
             dir+"CAM_6_3_45_AQP2/run/CAM_6_3_45_AQP2.cam.h0a.0001-01-31-00000.nc",\
             dir+"CAM_6_3_45_AQPCONST/run/CAM_6_3_45_AQPCONST.cam.h0a.0001-01-31-00000.nc"/)

;   Example with 3 file names, up to 6 files can be specified, specify the settings for each file
    cases= (/"FV19L32, APE, CAM6, control SST", \
             "FV19L32, APE, CAM6, flat SST", \
             "FV19L32, APE, CAM6, constant SST"/)

; Input settings from shell script -----------------------------
  start_month = 9

; Example with 6 file names, specify the settings for each file
;  cases= (/"FV09L30 MHS BM, rh=80%, tau=12h", \
;           "FV09L30 MHS BM, rh=80%, tau=12h", \
;           "FV09L30 MHS BM, rh=80%, tau=12h", \
;           "FV09L30 MHS BM, rh=80%, tau=12h", \
;           "FV09L30 MHS BM, rh=80%, tau=12h", \
;           "FV09L30 MHS BM, rh=80%, tau=12h"/)

            
  letter = (/"a","b","c","d","e","f","g","h","i",\
             "j","k","l","m","n","o","p","q","r",\
             "s","t","u","v","w","x","y","z","aa",\
             "bb","cc","dd","ee","ff","gg","hh","ii","jj","kk"/)

; Options ------------------------------------------------------
; moist Held-Suarez
  if (MHS) then
    variables = (/"PRECT","PRECL"     ,"PRECC"       ,"SHFLX","LHFLX",\
                "TMQ"  ,"QFLX-PRECT","PS"/)
  else
;   aqua-planet
    variables = (/"PRECT","PRECL"     ,"PRECC"       ,"SHFLX","LHFLX",\
                  "TMQ"  ,"QFLX-PRECT","PS","FLUT","CLDTOT","SST"/)
  end if

  scale     = (/ 8.64e7, 8.64e7, 8.64e7, 1., 1., \
                     1., 8.64e7,   0.01,  1., 100., 1. /)

  units     = (/"mm/day","mm/day","mm/day","W/m2","W/m2",\
                "kg/m2", "mm/day", "hPa", "W/m2"  ,"%", "K"/)

  cn_min    = (/0.,   0.,   0., 0.,   0.,\
                0., -25.,   980., 150., 35., 270. /)

  cn_max    = (/28., 28., 20., 25., 200.,\
                70., 10., 1030., 290., 100., 302. /) 

  var_num = dimsizes(variables)

; Case specific settings ----------------------------------------
  nfiles = dimsizes(cases)             ; number of files
  panelSize = (/round(nfiles/2.,3),2/)    ; panel dimensions

  color = "WhBlGrYeRe"
;=================================================================
; Loop over all files --------------------------------------
;=================================================================
 do i = 0,var_num-1       ; variable loop

  wks  = gsn_open_wks(pltType,plotname+"."+variables(i))
  print("Variable "+variables(i))
  panels = new((round(nfiles/2.,3))*2,graphic)   ; allocate array for panel plot
  gsn_define_colormap(wks,color)

  do file_step = 0, nfiles-1

;   Input Files --------------------------------------------
    print(file1(file_step))
    f1 = addfile(file1(file_step),"r")

    end_month = dimsizes(f1->time)-1
    print (end_month)

    lat = f1->lat
    if (isfilevar(f1,"gw")) then
      gw  = f1->gw
    else
      gw = new((/dimsizes(lat)/),double)
      gw = cos(lat)
    end if

    if (variables(i).eq."QFLX-PRECT") then
      var1 = f1->QFLX(start_month:end_month,:,:)
      var2 = f1->PRECT(start_month:end_month,:,:)
      var1 = var1*1.e-3  ; divide by density of water
      var_in = var1 - var2
      delete([/var1,var2/])
    else
      var_in = f1->$variables(i)$(start_month:end_month,:,:)
    end if

; time average
    var_avg = dim_avg_n_Wrap(var_in,0)
;   scale
    var_avg             = var_avg*scale(i)
    var_zonal           = dim_avg_Wrap(var_avg)
    var_zonal@long_name = variables(i)
    var_zonal@units     = units(i)

;   Compute average -------------------------------------
    gmean   = wgt_areaave(var_avg, gw, 1.0, 1)

    res = True

    res@gsnLeftString        = " "
    res@gsnRightString       = " "
    res@tiYAxisString        = variables(i)+" ("+units(i)+")"
    res@tiMainString         = cases(file_step)

    res@trYMaxF              = cn_max(i)
    res@trYMinF              = cn_min(i)

    res@vpKeepAspect         = True
    res@vpWidthF             = 0.5
    res@vpHeightF            = 0.5
    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnCenterString = "Min: "+min(var_zonal)+", Max: "+max(var_zonal)+", Mean: "+gmean

;   PLOTS ------------------------------

    panels(file_step) = gsn_csm_xy (wks,lat,var_zonal,res) 

    delete([/var_in,var_zonal,var_avg,res,lat,gw,f1,gmean/])

  end do     ; variables loop

  resP = True
  resP@txString                   = letter(i)+") "+variables(i)+" ("+units(i)+")"
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 10 
  ;resP@gsnMaximize                = True
  resP@lbLabelFontHeightF         = 0.015
  resP@pmLabelBarWidthF           = 0.8
  ;resP@lbTitleString             = units(i)
  resP@lbTitlePosition            = "Right"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbTitleDirection           = "Across"

  gsn_panel(wks,panels,panelSize,resP)

; trim the white space
  if (pltType .ne. "X11" .and. pltType.ne."eps") then
;   system("convert -trim "+plotname+"."+variables(i)+"."+pfmt+" "+plotname+"."+variables(i)+"."+pfmt)
    system("convert -trim -border 20 -bordercolor white "+plotname+"."+variables(i)+"."+pfmt+" "+plotname+"."+variables(i)+"."+pfmt)
  end if

  delete([/panels/])

end do

end

