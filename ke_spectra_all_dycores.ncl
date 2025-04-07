;*************************************
; ke_spectra_all_dycores.ncl
;
; Example usage: 
;
; 200 hPa 30-day-mean kinetic energy spectra (day 540-569) 
; ncl 'pfmt="png"' ke_spectra_all_dycores.ncl
;
; 250 hPa 10-day-mean kinetic energy spectra from day 630 onwards, requires daily output of U250 and V250
; or interpolations of the 3D wind data to this pressure level
; ncl 'pfmt="png"' day=630 tavg=10 level=250 ke_spectra_all_dycores.ncl
;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;+++++++++++++++++++++++++++++++++++++++++++++++++++++
; Check command line arguments
;+++++++++++++++++++++++++++++++++++++++++++++++++++++
  if (isvar("day")) then          ; start day for the average, command line setting?
      pday = day                  ; command line
  else
      pday = 0                  ; start day for the time-day mean (30-day-mean is default)
  end if
 
  if (isvar("tavg")) then          ; averaging time period, command line setting?
      pavg = tavg                  ; command line
  else
      pavg = 30                   ; averaging time period (30-day-mean is default), can be 1 for a single snapshot
  end if

  if (isvar("level")) then        ; pressure level on command line?
      plev = level                ; command line
  else
      plev =  850.                ; default 200 [hPa]
  end if

  if (isvar("pfmt")) then         ; plot format specified on command line?
      type = pfmt                 ; command line 
  else
      type = "png"                ; default X11 window
  end if


;=====
; declare the CAM directories and files, minimum is one file
;=====
  PATH1 = "/glade/derecho/scratch/$USER/CAM_6_3_45_SEne60_diffusion/run/"
  PATH2 = "/glade/derecho/scratch/$USER/CAM_6_3_45_SEne60_diffusion/run/"
  PATH3 = "/glade/derecho/scratch/$USER/CAM_6_3_45_SEne60_diffusion/run/"

;  Example with 1 file: APE with time average
;  files = (/PATH1+"CAM_Jan22.FV19.L32.ape.peaked.cam6.cam.h1.0001-01-01-00000.nc"/)
;  label  = (/"FV19L32 CAM6 APE peaked"/)
;
;  Example with 1 file: APE with time average
;  files = (/ PATH2+"CAM_Jan22.SEne16.L30.ape.flat.cam5.cam.h1.0001-01-01-00000.nc"/)
;  label  = (/"SEne16L30 CAM5 flat"/)

;  Example with 2 files: APE with time average
;  files = (/PATH1+"CAM_Jan22.FV19.L32.ape.peaked.cam6.cam.h1.0001-01-01-00000.nc",\
;            PATH2+"CAM_Jan22.SEne16.L30.ape.flat.cam5.cam.h1.0001-01-01-00000.nc"/)
;  label  = (/"FV19L32 CAM6 APE peaked","SEne16L30 CAM5 flat"/)

; Example with 3 files: APE with time average
  files = (/PATH1+"CAM_6_3_45_SEne60_diffusion.cam.h0i.0001-01-02-00000.doubled.nc",\
            PATH2+"CAM_6_3_45_SEne60_diffusion2.cam.h0i.0001-01-02-00000.default.nc",\
            PATH3+"CAM_6_3_45_SEne60_diffusion3.cam.h0i.0001-01-02-00000.halved.nc"/)
  label  = (/"Doubled diffusion","Default diffusion","Halved diffusion"/)

;------------------------------------
; Define the plotname and the label
 plotname   = "KE_"+plev+"Rossby."+pavg+"_day_mean"             ; label in plot

;------------------------------------
; Example with 3 files: baroclinic waves at 850 hPa, single snapshot at day 12 (no time average)
; call with
; ncl 'pfmt="png"' day=12 tavg=1 level=850 ke_spectra_all_dycores.ncl 
;
;  PATH1 = "/glade/scratch/cjablono/CAM_Jan22.SEne30.L30.fkessler.bw_topo/run/"
;  PATH2 = "/glade/scratch/cjablono/CAM_Jan22.SEne30.L30.fkessler.bw_topo/run/"
;  PATH3 = "/glade/scratch/cjablono/CAM_Jan22.SEne30.L30.fkessler.bw_topo/run/"
;  files = (/PATH1+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.Gauss_topo.nc",\
;            PATH2+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.ridge_topo.nc",\
;            PATH3+"CAM_Jan22.SEne30.L30.fkessler.bw_topo.cam.h0.0001-01-01-00000.nu_top_0.01.no_topo.nc"/)
;  label  = (/"Gaussian","Ridge","No mountain"/)
;  plotname   = "KE_"+plev+"hPa.SEne30L30.umjs14_bw.topo.day_"+pday                           ; label in plot

  wks = gsn_open_wks(type,plotname)

  nfiles = dimsizes(files)             ; number of files

  colors = (/"red","blue","green","orange","Cyan","black"/)

  start_time = pday
  end_time   = pday + pavg - 1       ; assumes 24h output, 30-day time period is default, adjust if 6-hr output is present

;=====
; declare and some constants
;=====
  interp    = 2      ; type of vertica; interpolation: 1 = linear, 2 = log, 3 = loglog
  extrap    = True   ; is vertical extrapolation desired if data is outside the range of PS
  P0mb      = 1000.  ; 1000 hPa reference level
  eps       = 1.e-3  ; for tests whether two numbers are more or less identical
  lthick    = 3.0    ; line thickness for plot
  variables = (/"U"+plev,"V"+plev/)

;================================
; declare some plotting resources
;================================
  res=True
  res@xyXStyle ="Log"
  res@xyYStyle ="Log"
  res@tmXBMinorPerMajor = 8   
  res@tmXTMinorPerMajor = 8   
  res@tmYRMinorPerMajor = 8   
  res@tmYLMinorPerMajor = 8   
  res@tmYLLabelFont = 21    ;  21 = helvetica
  res@tmXBLabelFont = 21    ;  22 = helvetica-bold 

; res@tiMainString           = plev+" hPa, "+pavg+"-day average" 
  res@tiMainString           = plotname 
  res@tiXAxisString          = "Spherical wavenumber (n)"
  res@tiYAxisString          = "Kinetic energy spectrum (m~S~2~N~/s~S~2~N~)"
  res@gsnFrame = False
  res@xyLineThicknessF = lthick

  res@trXMinF = 1       
  res@trXMaxF = 300       
  res@trYMinF = 1e-6      
  res@trYMaxF = 1e3   
  res@xyDashPattern = 0

; for k^-3 reference line
  xref = (/15.,200./)
  spc_ref = 10*(xref/15)^(-3) ; make it 10 @ k=15
  polyres                  = True
  polyres@gsLineThicknessF = lthick
  polyres@gsLineColor = "black"

;************************************************
; Loop over all files 
;************************************************
  do k = 0, nfiles-1
    print("File "+files(k))
    a = addfile(files(k),"r")

    hyam = a->hyam
    hybm = a->hybm
    lon  = a->lon
    lat  = a->lat
    nlat = dimsizes(lat)
    nlon = dimsizes(lon)

; find out whether the data are on a Gaussian grid (EUL)
    grid_gauss = False
    if (abs(lat(0)).lt.89.99) then      ; pole point is not included
      if ((abs(lat(2)-lat(1)) - (abs(lat(1)-lat(0)))) .gt. eps) then    ; latitudes are non-equidistant
        grid_gauss = True
      end if
    end if

;   read data and compute the relative vorticity and horizontal divergence

    if (isfilevar(a, variables(0)) .and. isfilevar(a, variables(1))) then
;      2D data along a pressure level
       u = a->$variables(0)$({start_time:end_time},:,:)
       v = a->$variables(1)$({start_time:end_time},:,:)
       if (grid_gauss) then                   ; computations on a Gaussian grid
          vr = uv2vrG_Wrap (u,v)
          dv = uv2dvG_Wrap (u,v)
       else                              ; computations on a fixed grid, can be non-equidistant
          vr = uv2vrF_Wrap (u,v)
          dv = uv2dvF_Wrap (u,v)
       end if
    else
;      3D data, need vertical interpolations
       u_3d  = a->U({start_time:end_time},:,:,:)
       v_3d  = a->V({start_time:end_time},:,:,:)
       ps    = a->PS({start_time:end_time},:,:)
       if (grid_gauss) then
          vr_3d = uv2vrG_Wrap (u_3d,v_3d)
          dv_3d = uv2dvG_Wrap (u_3d,v_3d)
       else
          vr_3d = uv2vrF_Wrap (u_3d,v_3d)
          dv_3d = uv2dvF_Wrap (u_3d,v_3d)
       end if
       vr_int = vinth2p(vr_3d,hyam,hybm,(/plev/),ps,interp,P0mb,1,extrap) ; (time,1,lat,lon)
       dv_int = vinth2p(dv_3d,hyam,hybm,(/plev/),ps,interp,P0mb,1,extrap) ; (time;1,lat,lon)
       vr     = vr_int(:,0,:,:)     ; eliminate the level dimension
       dv     = dv_int(:,0,:,:)     ; eliminate the level dimension
       delete ([/u_3d,v_3d,ps,vr_3d,dv_3d,vr_int,dv_int/])
    end if

    if (nlon.eq.nlat*2 .or. nlon+2 .eq. nlat*2) then    ; equidistant: FV3, SE, EUL with or without the pole points
      vor = vr
      div = dv
      grid_fv = False
      print (" equidistant grid")
    else                                                ; non-equidistant fixed grid: FV, interpolation
      grid_fv = True
      nlon = tointeger(nlon*1.25)                       ; compute the # longitudes for equidistant offset grid (no poles)
      nlat = nlon/2
      lon_data = lon
      lat_data = lat
      delete ([/lat, lon/])
      lat = new((/nlat/), "double", 1d-99)
      lon = new((/nlon/), "double", 1d-99)
      offset = 360./nlon * 0.5
      lon = fspan (offset, 360.-offset,nlon)
      lat = fspan (-90.+offset, 90.-offset,nlat)
;     interpolate
      vor = linint2_Wrap(lon_data,lat_data,vr,True,lon,lat,0)
      div = linint2_Wrap(lon_data,lat_data,dv,True,lon,lat,0)
      delete ([/lon_data,lat_data/])

    end if

    print ("vor min/max = "+min(vor(:,:,:))+", "+max(vor(:,:,:)) )
    print ("div min/max = "+min(div(:,:,:))+", "+max(div(:,:,:)) )
    print ("ntimes="+pavg+" nlat x nlon "+nlat+"x"+nlon)

;***************************************************************   
;   compute the scalar spherical harmonic transform: NCAR docu vorticity-divergence form
;***************************************************************   
    spc_time = new ( (/pavg,nlat/), "double", 1d-99 )
    x        = new ( (/nlat/), "double", 1d-99 )

    if (grid_gauss) then
       ab_vr = shagC (vor(:,:,:))
       ab_dv = shagC (div(:,:,:))
    else
       ab_vr = shaeC (vor(:,:,:))
       ab_dv = shaeC (div(:,:,:))
    end if

    print ("Transform done. ")

;   compute energy in vort and div components, no factor 1/2
;
    cr = ab_vr(0,:,:,:)                ; real coef  (time,nlat,nlat) vort
    ci = ab_vr(1,:,:,:)                ; imaginary  (time,nlat,nlat) vort
    pwr_vr = (cr^2 + ci^2)             ; (time,nlat,nlat)  array

    cr = ab_dv(0,:,:,:)                ; real coef  (time,nlat,nlat) div
    ci = ab_dv(1,:,:,:)                ; imaginary  (time,nlat,nlat) div
    pwr_dv = (cr^2 + ci^2)             ; (time,nlat,nlat)  array
  
                                ; for clarity use do loops
    do n1=0,nlat-1
      spc_time(:,n1) = pwr_vr(:,n1,0) + pwr_dv(:,n1,0)
      factor = 16. * n1*(n1+1)
;     vectorize the loop
      if (n1.gt.0) then
        spc_time(:,n1) = spc_time(:,n1) + 2.*( dim_sum( pwr_vr(:,n1,1:n1)) + dim_sum( pwr_dv(:,n1,1:n1)) )
      end if
;     this vectorization replaces the typical loop
;     do m=1,n1
;        spc_time(:,n1) = spc_time(:,n1) + 2.*(pwr_vr(:,n1,m) + pwr_dv(:,n1,m))
;     end do
      if (n1 .ne. 0) then
        spc_time(:,n1) = (6371229.^2) / factor * spc_time(:,n1)  ; scaling from NCAR/TN-388+STR
      end if
      x(n1) = n1
    end do
 
    spc = dim_avg_n(spc_time,0)     ; time average

;---------------------------------------------
;  determine how many wave numbers should be plotted
;---------------------------------------------
    nlat_end = (nlat - 6)              ; FV3, avoid the highest wavenumbers, interpolation issues sneek in
    test_se = nlon/1.4222222222222     ; test whether this is the SE grid
    if (abs(test_se-180.).lt.eps .or. abs(test_se-360.).lt.eps .or. abs(test_se-720.).lt.eps) then
      nlat_end = round(test_se/2-10,3) ;  SE has finer grid than necessary by a factor of 1.42, avoid high wavenumbers
    end if
    if (grid_gauss) then
      nlat_end = (nlat - 2)            ; EUL
    else if (grid_fv) then
      nlat_end = (nlat - 10)           ; FV is interpolated from non-equidistant grid, cut more than FV3
    end if
    end if

;---------------------------------------------
;   plot the KE spectrum
;---------------------------------------------
    res@xyLineColors = colors(k)
    plot  = gsn_xy (wks,x(0:nlat_end),spc(0:nlat_end),res)     ; 

;*****************************************************   
;   Manually create and attach legend, automatic legend had issues, up to 6 entries are supported
;***************************************************** 
    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.015                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineDashPattern = 0.                    ; solid line
    res_lines@gsLineThicknessF  = 5.                    ; line thicker

    xx = (/1.5,2.5/)
    zz = 0.4
    dz = 0.033
    if (k.eq.0) then
      y = 0.001
      gsn_polyline(wks,plot,xref,spc_ref,polyres)       ; add k^-3 reference line
      res@tiMainString           = "" 
      res@tiXAxisString          = ""
      res@tiYAxisString          = ""
    else if (k.eq.1) then
      y = 0.0003 
    else if (k.eq.2) then
      y = 0.0001
    else if (k.eq.3) then
      y = 0.00003
    else if (k.eq.4) then
      y = 0.00001
    else if (k.eq.5) then
      y = 0.000003
    end if
    end if
    end if
    end if
    end if
    end if
    yy =  (/y,y/)

    res_lines@gsLineColor       = colors(k)             ; line color
    gsn_polyline(wks,plot,xx,yy,res_lines)              ; add polyline
    gsn_text_ndc(wks,label(k),0.315,zz-k*dz,res_text); add text

    delete ([/vr,dv,u,v,lon,lat,hyam,hybm,vor,div,spc_time,spc,x,ab_vr,ab_dv,pwr_vr,pwr_dv,cr,ci/])

  end do
  frame(wks)                                     ; now advance

;  trim the white space
;  if (type .ne. "png" .or,. type.ne."eps") then
;    system("convert -trim "+plotname+"."+pfmt+" "+plotname+"."+pfmt)
;  end if
  
end

