!==========================================================================
elemental function gsw_enthalpy_ice (t, p)
!==========================================================================
!
! Calculates the specific enthalpy of ice (h_Ih). 
!
!  t  =  in-situ temperature (ITS-90)                             [ deg C ]
!  p  =  sea pressure                                              [ dbar ]
!        ( i.e. absolute pressure - 10.1325 dbar ) 
!
!  gsw_enthalpy_ice  :  specific enthalpy of ice                   [ J/kg ]
!--------------------------------------------------------------------------

use gsw_mod_teos10_constants, only : gsw_t0, db2pa

use gsw_mod_gibbs_ice_coefficients

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: t, p

real (r14) :: gsw_enthalpy_ice

real (r14) :: tau, dzi, g0
complex (r14) :: r2, sqtau_t1, sqtau_t2, g

tau = (t + gsw_t0)*rec_tt

dzi = db2pa*p*rec_pt

g0 = g00 + dzi*(g01 + dzi*(g02 + dzi*(g03 + g04*dzi)))

r2 = r20 + dzi*(r21 + r22*dzi)

sqtau_t1 = (tau/t1)**2
sqtau_t2 = (tau/t2)**2

g = r1*t1*(log(1d0 - sqtau_t1) + sqtau_t1) &
    + r2*t2*(log(1d0 - sqtau_t2) + sqtau_t2)

gsw_enthalpy_ice = g0 + tt*real(g) 

return
end function

!--------------------------------------------------------------------------
