!==========================================================================
elemental function gsw_pot_enthalpy_from_pt_ice (pt0_ice)
!==========================================================================
!
!  Calculates the potential enthalpy of ice from potential temperature of
!  ice (whose reference sea pressure is zero dbar).  
!
!  pt0_ice  =  potential temperature of ice (ITS-90)              [ deg C ]
!
!  gsw_pot_enthalpy_ice  =  potential enthalpy of ice              [ J/kg ]
!--------------------------------------------------------------------------

use gsw_mod_teos10_constants, only : gsw_t0

use gsw_mod_gibbs_ice_coefficients

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: pt0_ice

real (r14) :: gsw_pot_enthalpy_from_pt_ice

real (r14) :: tau
complex (r14) :: h0_part, sqtau_t1, sqtau_t2

tau = (pt0_ice + gsw_t0)*rec_tt

sqtau_t1 = (tau/t1)**2
sqtau_t2 = (tau/t2)**2

h0_part = r1*t1*(log(1 - sqtau_t1) + sqtau_t1) &
          + r20*t2*(log(1 - sqtau_t2) + sqtau_t2)

gsw_pot_enthalpy_from_pt_ice = g00 + tt*real(h0_part) 
              
return
end function

!--------------------------------------------------------------------------
