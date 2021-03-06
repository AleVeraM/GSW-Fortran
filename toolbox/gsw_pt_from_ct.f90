!==========================================================================
elemental function gsw_pt_from_ct (sa, ct) 
!==========================================================================
!
! potential temperature of seawater from conservative temperature
!
! sa     : Absolute Salinity                               [g/kg]
! ct     : Conservative Temperature                        [deg C]
! p      : sea pressure                                    [dbar]
!
! gsw_pt_from_ct : potential temperature with              [deg C]
!                  reference pressure of  0 dbar
!--------------------------------------------------------------------------

use gsw_mod_toolbox, only : gsw_ct_from_pt, gsw_gibbs_pt0_pt0

use gsw_mod_teos10_constants, only : gsw_cp0, gsw_ups, gsw_t0

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: sa, ct 

real (r14) :: gsw_pt_from_ct

real (r14) :: a5ct, b3ct, ct_factor, pt_num, pt_den, ct_diff
real (r14) :: ct0, pt, pt_old, ptm, dct, dct_dpt, s1

real (r14), parameter :: a0 = -1.446013646344788d-2
real (r14), parameter :: a1 = -3.305308995852924d-3
real (r14), parameter :: a2 =  1.062415929128982d-4
real (r14), parameter :: a3 =  9.477566673794488d-1
real (r14), parameter :: a4 =  2.166591947736613d-3
real (r14), parameter :: a5 =  3.828842955039902d-3

real (r14), parameter :: b0 =  1.000000000000000d0
real (r14), parameter :: b1 =  6.506097115635800d-4
real (r14), parameter :: b2 =  3.830289486850898d-3
real (r14), parameter :: b3 =  1.247811760368034d-6

s1 = sa/gsw_ups

a5ct = a5*ct
b3ct = b3*ct

ct_factor = (a3 + a4*s1 + a5ct)
pt_num = a0 + s1*(a1 + a2*s1) + ct*ct_factor
pt_den = b0 + b1*s1 + ct*(b2 + b3ct)
pt = (pt_num)/(pt_den)

dct_dpt = (pt_den)/(ct_factor + a5ct - (b2 + b3ct + b3ct)*pt)

! Start the 1.5 iterations through the modified Newton-Rapshon iterative,
! method, which is also known as the Newton-McDougall method. 

ct_diff = gsw_ct_from_pt(sa,pt) - ct
pt_old = pt
pt = pt_old - (ct_diff)/dct_dpt
ptm = 0.5d0*(pt + pt_old)

dct_dpt = -(ptm + gsw_t0)*gsw_gibbs_pt0_pt0(sa,ptm)/gsw_cp0

pt = pt_old - (ct_diff)/dct_dpt
ct_diff = gsw_ct_from_pt(sa,pt) - ct
pt_old = pt
gsw_pt_from_ct = pt_old - (ct_diff)/dct_dpt

return 
end function

!--------------------------------------------------------------------------
