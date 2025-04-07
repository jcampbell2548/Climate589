;================================================;
;	Example ncl script to produce the set of
;       error time series for ML algorithms
; Created by Christiane Jablonowski & Garrett Limon
;	(University of Michigan)
;
;================================================;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"   
; ================================================;

begin
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "X11"                ; default X11 window
  end if

;************************************************
; Set Output Name, Directory & File Name
;************************************************
  dycore   = "fvL30.cam5.PI4xSOMx2"     
  plotname   = dycore+".mean_circulation"               ; output name

  dir  = "/glade/derecho/scratch/juliacam/archive/PI4xSOMx2/atm/hist/"
  fname = "PI4xSOMx2.cam.h0.ANN.concat.nc"     ; aqua-planet

  data     = dir+fname
  f        = addfile(data,"r")

;************************************************
; read variables, provided as monthly-means (time,lev,lat,lon) from 0 to end_time-1
;************************************************
  start_time = 0                   ; first 9 months are ignored (spin-up)
  end_time = dimsizes(f->time)-1   ; read all time from start_time onwards

  lat      = f->lat
  lon      = f->lon
  T        = f->T(start_time:end_time,:,:,:)
  Q        = f->Q(start_time:end_time,:,:,:)      ; Moist
  U        = f->U(start_time:end_time,:,:,:)
  V        = f->V(start_time:end_time,:,:,:)
  OMEGA    = f->OMEGA(start_time:end_time,:,:,:)
  RH       = f->RELHUM(start_time:end_time,:,:,:) ; Moist
  PL       = f->PRECL(start_time:end_time,:,:)    ; Moist
  PC       = f->PRECC(start_time:end_time,:,:)    ; Moist
;  PT       = f->PRECT(start_time:end_time,:,:)    ; Moist

;************************************************
; Modify Units 
;************************************************
  Qm       = Q*1.e3        ; kg/kg -> g/kg
;  PTm      = PT*8.64e7     ; m/s -> mm/day
  PLm      = PL*8.64e7     ; m/s -> mm/day
  PCm      = PC*8.64e7     ; m/s -> mm/day

  copy_VarMeta(Q,Qm)
  ; copy_VarMeta(PT,PTm)
  ; copy_VarMeta(PL,PLm)
  ; copy_VarMeta(PC,PCm)
  Qm@units = "g/kg"
;  PTm@units = "mm/day"
  PLm@units = "mm/day"
  PCm@units = "mm/day"

;************************************************
; time average
;************************************************
  T_tm     = dim_avg_n_Wrap(T,0)
  Q_tm     = dim_avg_n_Wrap(Qm,0)
  U_tm     = dim_avg_n_Wrap(U,0)
  V_tm     = dim_avg_n_Wrap(V,0)
  OMEGA_tm = dim_avg_n_Wrap(OMEGA,0)
  RH_tm    = dim_avg_n_Wrap(RH,0)
  PL_tm    = dim_avg_n_Wrap(PLm,0)
  PC_tm    = dim_avg_n_Wrap(PCm,0)
;  PT_tm    = dim_avg_n_Wrap(PTm,0)

;************************************************
; zonal average (average over the last index) 
;************************************************
  T_m      = dim_avg_Wrap(T_tm)
  Q_m      = dim_avg_Wrap(Q_tm)
  U_m      = dim_avg_Wrap(U_tm)
  V_m      = dim_avg_Wrap(V_tm)
  OMEGA_m  = dim_avg_Wrap(OMEGA_tm)
  RH_m     = dim_avg_Wrap(RH_tm)
  PL_m     = dim_avg_Wrap(PL_tm)
  PC_m     = dim_avg_Wrap(PC_tm)
;  PT_m     = dim_avg_Wrap(PT_tm)

 
;************************************************
; Initialize Plot
;************************************************
  panelSize = (/3,3/)      ; panel dimensions
  wks       = gsn_open_wks(type,plotname)
  gsn_define_colormap(wks,"WhViBlGrYeOrRe")
  plot = new(8,graphic)

;************************************************
; Format Plot
;************************************************
  res1                      = True
  res1@gsnDraw              = False          		; panel plot 
  res1@gsnFrame             = False			; don't draw yet
  res1@cnFillOn             = True
  res1@cnLinesOn            = False
  res1@gsnSpreadColors      = True
  res1@lbLabelAutoStride    = True
  res1@vpWidthF             = 0.5                         ; set aspect ratio
  res1@vpHeightF            = 0.32                        ; set aspect ratio
  res1@cnInfoLabelOn        = False			; don't give each
  res1@cnLineLabelsOn       = False			; panel its own
  res1@lbLabelBarOn         = True			; label bar
  res1@gsnMaximize          = True  
  res1@trYReverse           = True      			; reverses y-axis, false
;  res1@tmXBMinorPerMajor    = 4                           ; no effect in the current setup
  res1@gsnYAxisIrregular2Linear = True   ; Convert Y axis to linear ( linear -> log ?)

  pres                      = True
  pres@gsnMaximize          = True  
  pres@gsnPanelLabelBar     = False			; Communal label bar
  pres@gsnPanelBottom       = 0.			 ; shrink panel plot by setting bottom edge of plot
  pres@gsnPanelTop          = 0.96			 ; shrink panel plot by setting top edge of plot
;  pres@gsnPanelLeft        = 0.1
;  pres@gsnPanelRight       = 0.9
  pres@pmLabelBarOrthogonalPosF = -0.01            ; negative moves down like -0.03
  pres@pmLabelBarWidthF     = 0.4
  pres@gsnFrame             = False
  pres@lbLabelStride        = 2
  pres@lbTitleFontHeightF   = 0.06
  pres@gsnPanelYWhiteSpacePercent = 3
  pres@gsnPanelXWhiteSpacePercent = 2
  pres@lbLabelFontHeightF   = 0.01
  pres@gsnPanelFigureStrings = (/"a)","b)","c)","d)","e)","f)","g)","h)"/) ; add strings to panel
  pres@gsnPanelFigureStringsFontHeightF = 0.01
  pres@amJust               = "TopLeft"
  pres@gsnAttachBorderOn    = "False"
  pres@gsnPanelMainFontHeightF = 0.015
  pres@txString                = plotname

  res1@cnLevelSelectionMode = "AutomaticLevels" 
;  res1@cnMaxLevelValF      =   8.0                 ; max contour color label
;  res1@cnMinLevelValF      =   -2.4                  ; min contour color label
;  res1@cnLevelSpacingF     = 0.75                         ; contour color spacing

;************************************************
; Plot latitude-pressure cross sections of the time-mean zonal-mean quantities
;************************************************
  res1@tiYAxisString        = "Pressure (hPa)"
  plot(0)                   = gsn_csm_contour(wks,T_m(:,:),res1)	; plot var
  plot(1)                   = gsn_csm_contour(wks,Q_m(:,:),res1)	; plot var
  plot(2)                   = gsn_csm_contour(wks,U_m(:,:),res1)	; plot var
  plot(3)                   = gsn_csm_contour(wks,V_m(:,:),res1)	; plot var
  plot(4)                   = gsn_csm_contour(wks,RH_m(:,:),res1)	; plot var
  plot(5)                   = gsn_csm_contour(wks,OMEGA_m(:,:),res1)	; plot var

;************************************************
; Switch to line plots for the time-mean zonal-mean precipitation rates
;************************************************
  res2 = True
  res2@gsnDraw              = False                     ; panel plot
  res2@gsnFrame             = False                     ; don't draw yet
  res2@vpWidthF             = 0.5                         ; set aspect ratio
  res2@vpHeightF            = 0.32                        ; set aspect ratio
  res2@gsnMaximize          = True  

;  res22gsnRightString       = ""

  res2@tiYAxisString        = "Large-scale precip rate (mm/day)"
  plot(6)                   = gsn_csm_xy(wks,lat,PL_m(:),res2)	; plot var

  res2@tiYAxisString        = "Convective precip rate (mm/day)"
  plot(7)                   = gsn_csm_xy(wks,lat,PC_m(:),res2)	; plot var

;  res2@tiYAxisString        = "Total precip rate (mm/day)"
;  plot(8)                   = gsn_csm_xy(wks,lat,PT_m(:),res2)	; plot var

  gsn_panel(wks,plot,panelSize,pres)			; panel plot
  frame(wks)

;  trim the white space
  if (type .ne. "X11" .and. type .ne. "eps") then
    system("convert -trim "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
  end if


end
