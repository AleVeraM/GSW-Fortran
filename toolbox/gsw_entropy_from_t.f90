!==========================================================================
elemental function gsw_entropy_from_t (sa, t, p) 
!==========================================================================
!
! Calculates the specific entropy of seawater
!
! sa     : Absolute Salinity                               [g/kg]
! t      : in-situ temperature                             [deg C]
! p      : sea pressure                                    [dbar]
! 
! gsw_entropy_from_t : specific entropy                    [J/(kg K)]
!--------------------------------------------------------------------------

use gsw_mod_toolbox, only : gsw_gibbs

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: sa, t, p 

real (r14) :: gsw_entropy_from_t

integer, parameter :: n0=0, n1=1

gsw_entropy_from_t = -gsw_gibbs(n0,n1,n0,sa,t,p)

return
end function

!--------------------------------------------------------------------------
