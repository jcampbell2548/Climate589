;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ================================================;
begin

  if (isvar("pfmt")) then            ; plot format specified on command line?
      pltType = pfmt                 ; command line
  else
;      pltType = "eps"                ; default, others: X11, pdf
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
  plotname = "ape.cam6_3d_comparison"
  dir  = "/glade/derecho/scratch/$USER/"


; File Paths and names ---------------------------------------------------
  if (MHS) then
;   Example with 6 MHS file names, 6 files is the maximum, fewer files also work, see below
;   MHS needs both the h0 and h1 files, aqua-planet only needs the h0 files
;   file1 = (/"/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc"/)
;   file2 = (/"/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
;             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc"/)
;
;   Example with 6 file names, specify the settings for each file
;   cases= (/"FV09L30 MHS BM, rh=80%, tau=12h", \
;            "FV09L30 MHS BM, rh=80%, tau=12h", \
;            "FV09L30 MHS BM, rh=80%, tau=12h", \
;            "FV09L30 MHS BM, rh=80%, tau=12h", \
;            "FV09L30 MHS BM, rh=80%, tau=12h", \
;            "FV09L30 MHS BM, rh=80%, tau=12h"/)

;   Example with 3 MHS file names, here all the same for test purposes
    file1 = (/"/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc",\
             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h0.0001-01-01-00000.nc"/)
    file2 = (/"/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc",\
             "/glade/derecho/scratch/cjablono/CAM_Jan22.FV09.L30.ftj16.bm/run/CAM_Jan22.FV09.L30.ftj16.bm.cam.h1.0001-01-01-00000.nc"/)

;   Example with 3 MHS file names, specify the settings for each file
    cases= (/"FV09L30 MHS BM, rh=80%, tau=12h", \
             "FV09L30 MHS BM, rh=80%, tau=12h", \
             "FV09L30 MHS BM, rh=80%, tau=12h"/)

  else
;   Example with 3 aqua-planet file names, up to 6 files can be specified
    file1 = (/dir+"CAM_6_3_45_AQP1/run/CAM_6_3_45_AQP1.cam.h0a.0001-01-31-00000.nc",\
              dir+"CAM_6_3_45_AQP2/run/CAM_6_3_45_AQP2.cam.h0a.0001-01-31-00000.nc",\
              dir+"CAM_6_3_45_AQPCONST/run/CAM_6_3_45_AQPCONST.cam.h0a.0001-01-31-00000.nc"/)

;   Example with 3 file names, up to 6 files can be specified, specify the settings for each file
    cases= (/"FV19L32, APE, CAM6, control SST", \
             "FV19L32, APE, CAM6, flat SST", \
             "FV19L32, APE, CAM6, constant SST"/)
  end if

; Input settings from shell script -----------------------------
  start_month = 9

  letter = (/"a","b","c","d","e","f","g","h","i",\
             "j","k","l","m","n","o","p","q","r",\
             "s","t","u","v","w","x","y","z","aa",\
             "bb","cc","dd","ee","ff","gg","hh","ii","jj","kk"/)

; Options ------------------------------------------------------
  if (MHS) then
    variables = (/"U","V","T","OMEGA","Q","RELHUM","QRS","PTTEND","PTEQ","VQ","OMEGAQ", \ 
                  "Eddy_VQ","Eddy_OMEGAQ","Eddy_KE","Eddy_VT","Eddy_UV","Eddy_TT","Eddy_QQ"/)

     scale     = (/     1.,     1.,     1.,      1.,   1.e3,     1.,  8.64e4, 8.64e4, 8.64e7, 1.e3,   1.e3,\
                      1.e3,   1.e3,     1.,      1.,     1.,     1.,   1.e6/)

     units     = (/"m/s","m/s","K","Pa/s","g/kg","%","K/day","K/day","g/kg/day","m/s g/kg","Pa/s g/kg",\
                   "m/s g/kg","Pa/s g/kg","m2/s2","mK/s","m2/s2","K2","g2/kg2"/)

     cn_min    = (/-10.,  -5., 180., -0.27,   0.,  10., -1.6, -3., -5.5, -120.,-4.75,\
                   -10.,-0.45,   0.,  -18., -60.,   0.,    0./)

     cn_max    = (/ 65.,   5., 300.,  0.03,  20.,  90.,  0.4, 12., 3.5, 120.,  0.25,\
                    10.,   0., 500.,   18.,  60.,  33.,   10./)

     cn_space =  (/  5.,   1.,  10.,  0.03,   2.,  10.,   0.2, 1., 0.5, 20.,  .25,\
                     1., 0.05,  50.,    3.,  10.,   3.,    1./)

     cn_lines = (/ "True", "True", "True", "True", "True", "True", "True", "False", "False", "True","False",\
                   "True", "True", "True", "True", "True", "True", "True"/)
 
  else

    variables = (/"U","V","T","OMEGA","Q","RELHUM","CLDICE","CLDLIQ","CLOUD"/)

    scale     = (/     1.,     1.,     1.,      1.,   1.e3,     1.,   1.e3,   1.e3, 100./)

    units     = (/"m/s","m/s","K","Pa/s","g/kg","%","g/kg","g/kg","%"/)

    cn_min    = (/-10.,  -6., 180., -0.27,   0.,  10., 0., 0., 5./)

    cn_max    = (/ 65.,   6., 300.,  0.06,  20.,  90.,  0.014,  0.14, 80./)

    cn_space =  (/  5.,   1.,  10.,  0.03,   2.,  10.,   0.001, 0.02, 5./)

    cn_lines = (/ "True", "True", "True", "True", "True", "True", "True","True", "True"/)

  end if

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

    if (MHS) then
      f2 = addfile(file2(file_step),"r")
    end if

    lat = f1->lat
    if (isfilevar(f1,"gw")) then
      gw  = f1->gw
    else
      gw = new((/dimsizes(lat)/),double)
      gw = cos(lat)
    end if
    hya = f1->hyai
    hyb = f1->hybi
    p0  = 100000. 
    ps  = f1->PS(start_month:end_month,:,:)
    dp  = dpres_hybrid_ccm(ps,p0,hya,hyb)

    res = True
    res@tmXBMode             = "Explicit"
    res@tmXBValues           = (/-90,-60,-30,0,30,60,90/)
    res@tmXBLabels           = (/" ","60S","30S","EQ","30N","60N"," "/)

    res@cnFillOn             = True
    res@trYReverse           = True
    res@gsnLeftString        = " "
    res@gsnRightString       = " "
    res@tiYAxisString        = "Pressure (hPa)"
    res@tiMainString         = cases(file_step)
    res@gsnContourZeroLineThicknessF = 2
    res@gsnContourNegLineDashPattern = 1

    res@cnLineLabelsOn       = False
    res@cnInfoLabelOn        = False
    res@lbLabelBarOn         = False
    res@cnLinesOn            = cn_lines(i)

    res@gsnYAxisIrregular2Linear = True
    res@vpWidthF             = 0.4
    res@vpHeightF            = 0.2
    res@gsnDraw              = False
    res@gsnFrame             = False


    if (i.le.8) then
      var_in  = f1->$variables(i)$(start_month:end_month,:,:,:)
    else if (i.eq.9 .or. i.eq.10) then
      var_in  = f2->$variables(i)$(start_month:end_month,:,:,:)
    else if (i.eq.11) then
      var1_in  = f1->V(start_month:end_month,:,:,:)
      var2_in  = f1->Q(start_month:end_month,:,:,:)
      var3_in  = f2->VQ(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var3_in - var1_in*var2_in
      delete([/var1_in,var2_in,var3_in/])
    else if (i.eq.12) then
      var1_in  = f1->OMEGA(start_month:end_month,:,:,:)
      var2_in  = f1->Q(start_month:end_month,:,:,:)
      var3_in  = f2->OMEGAQ(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var3_in - var1_in*var2_in
      delete([/var1_in,var2_in,var3_in/])
    else if (i.eq.13) then
      var1_in  = f1->U(start_month:end_month,:,:,:)
      var2_in  = f1->V(start_month:end_month,:,:,:)
      var3_in  = f2->UU(start_month:end_month,:,:,:)
      var4_in  = f2->VV(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = (var3_in - var1_in*var1_in + var4_in - var2_in*var2_in)*0.5
      delete([/var1_in,var2_in,var3_in,var4_in/])
    else if (i.eq.14) then
      var1_in  = f1->V(start_month:end_month,:,:,:)
      var2_in  = f1->T(start_month:end_month,:,:,:)
      var3_in  = f2->VT(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var3_in - var1_in*var2_in
      delete([/var1_in,var2_in,var3_in/])
    else if (i.eq.15) then
      var1_in  = f1->U(start_month:end_month,:,:,:)
      var2_in  = f1->V(start_month:end_month,:,:,:)
      var3_in  = f2->VU(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var3_in - var1_in*var2_in
      delete([/var1_in,var2_in,var3_in/])
    else if (i.eq.16) then
      var1_in  = f1->T(start_month:end_month,:,:,:)
      var2_in  = f2->TT(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var2_in - var1_in*var1_in
      delete([/var1_in,var2_in/])
    else if (i.eq.17) then
      var1_in  = f1->Q(start_month:end_month,:,:,:)
      var2_in  = f2->QQ(start_month:end_month,:,:,:)
      var_in   = var1_in
      var_in   = var2_in - var1_in*var1_in
      delete([/var1_in,var2_in/])
    end if
    end if
    end if
    end if 
    end if 
    end if 
    end if 
    end if 
    end if 

;   scale
    var_in              = var_in*scale(i)

;   Compute averages -------------------------------------
    glob                = wgt_volave_ccm(var_in,dp,gw,1.0,0) ; global mean
    glob_time_ave       = dim_avg_n_Wrap(glob,0)

;   Compute zonal mean -------------------------------------
    var_avg             = dim_avg_n_Wrap(var_in,0)
    var_zonal           = dim_avg_Wrap(var_avg)
    var_zonal@long_name = variables(i)
    var_zonal@units     = units(i)

    res@gsnCenterString = "Min: "+min(var_zonal)+", Max: "+max(var_zonal)+", Mean: "+glob_time_ave

    if (variables(i) .eq. "Q") then
      res@cnLevelSelectionMode = "ExplicitLevels" 
      res@cnLevels = (/0.2,0.4,0.6,0.8,1.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20./)
    else
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF       = cn_min(i)
      res@cnMaxLevelValF       = cn_max(i)
      res@cnLevelSpacingF      = cn_space(i)
    end if

    if (variables(i) .eq. "OMEGA" .or. variables(i).eq."OMEGAQ") then
      res@trXMinF = -30
      res@trXMaxF = 30
      res@tmXBMode = "Explicit"
      res@tmXBValues = (/-30,-20,-10,0,10,20,30/)
      res@tmXBLabels = (/" ","20S","10S","EQ","10N","20N"," "/)
    end if

;   PLOTS ------------------------------

    if (i.eq.9) then    ; QV only lower part is shown
      panels(file_step) = gsn_csm_contour(wks,var_zonal(18:29,:),res)
    else 
      panels(file_step) = gsn_csm_contour(wks,var_zonal,res) 
    end if

    delete([/var_in,var_avg,var_zonal,glob_time_ave,ps,dp,glob,res,lat,gw,f1,hya,hyb/])
    if (MHS) then
      delete (f2)
    end if

  end do     ; variables loop

  resP = True
  resP@txString                   = letter(i)+") "+variables(i)+" ("+units(i)+")"
  resP@gsnPanelYWhiteSpacePercent = 6
  resP@gsnPanelXWhiteSpacePercent = 3
  resP@gsnMaximize                = True
  resP@lbLabelFontHeightF         = 0.015
  resP@pmLabelBarWidthF           = 0.8
  ;resP@lbTitleString             = units(i)
  resP@lbTitlePosition            = "Right"
  resP@lbTitleFontHeightF         = 0.015
  resP@lbTitleDirection           = "Across"
  ;resP@pmLabelBarParallelPosF    = 0.08
  resP@gsnPanelLabelBar           = True

  gsn_panel(wks,panels,panelSize,resP)

; trim the white space
  if (pltType .ne. "X11" .and. pltType.ne."eps") then
    system("convert -trim "+plotname+"."+variables(i)+"."+pfmt+" "+plotname+"."+variables(i)+"."+pfmt)
  end if


  delete([/panels/])

end do

end

