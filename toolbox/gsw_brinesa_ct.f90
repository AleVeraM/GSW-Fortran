!==========================================================================
elemental function gsw_brinesa_ct (ct, p, saturation_fraction)
!==========================================================================
!
!  Calculates the Absolute Salinity of seawater at the freezing temperature.  
!  That is, the output is the Absolute Salinity of seawater, with 
!  Conservative Temperature CT, pressure p and the fraction 
!  saturation_fraction of dissolved air, that is in equilibrium 
!  with ice at the same in situ temperature and pressure.  If the input 
!  values are such that there is no positive value of Absolute Salinity for
!  which seawater is frozen, the output, brineSA_CT, is made a NaN.
!
!  CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
!  p   =  sea pressure                                             [ dbar ]
!         ( i.e. absolute pressure - 10.1325 dbar ) 
!  saturation_fraction  =  the saturation fraction of dissolved air in 
!                          seawater
!
!  brineSA_CT  =  Absolute Salinity of seawater when it freezes, for 
!                 given input values of its Conservative Temperature,
!                 pressure and air saturation fraction.            [ g/kg ]
!--------------------------------------------------------------------------

use gsw_mod_toolbox, only : gsw_ct_freezing_first_derivatives, gsw_sa_p_inrange
use gsw_mod_toolbox, only : gsw_ct_freezing_exact, gsw_brinesa_estimate

use gsw_mod_error_functions, only : gsw_error_code, gsw_error_limit

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: ct, p, saturation_fraction

real (r14) :: gsw_brinesa_ct

integer :: i_iter
real (r14) :: ct_freezing_zero_sa, f, ctfreezing_sa
real (r14) :: sa, sa_cut_off, sa_mean, sa_old

integer, parameter :: number_of_iterations = 3

character (*), parameter :: func_name = "gsw_brinesa_ct"

! Find CT > CT_freezing_zero_SA.  If this is the case, the input values
! represent seawater that is not frozen (for any positive SA). 
ct_freezing_zero_sa = gsw_ct_freezing_exact(0d0,p,saturation_fraction)
if (ct .gt. ct_freezing_zero_sa) then
    gsw_brinesa_ct = gsw_error_code(1,func_name)
    return
end if

! Form the first estimate of brineSA_CT from a polynomial in CT and p 
sa = gsw_brinesa_estimate(p,saturation_fraction,ct=ct)

! Find -SA_cut_off < SA < SA_cut_off, and replace the above estimate of SA  
! with one based on (CT_freezing_zero_SA - CT).
sa_cut_off = 2.5d0 ! this is the band of sa within +- 2.5d0 g/kg of sa = 0, 
                   ! which we treat differently in calculating the initial
                   ! values of SA. 
if (sa .lt. -sa_cut_off) then
    gsw_brinesa_ct = gsw_error_code(2,func_name)
    return
end if

!--------------------------------------------------------------------------
! Form the first estimate of CTfreezing_SA, the derivative of CT_freezing 
! with respect to SA at fixed p.  
!--------------------------------------------------------------------------
sa = max(sa,0d0)
call gsw_ct_freezing_first_derivatives(sa,p,saturation_fraction, &
                                       ctfreezing_sa=ctfreezing_sa)
if (abs(sa) .lt. sa_cut_off) sa = (ct - ct_freezing_zero_sa)/ctfreezing_sa

!--------------------------------------------------------------------------
! Begin the modified Newton-Raphson method to solve  
! f = (CT_freezing - CT) = 0 for SA. 
!--------------------------------------------------------------------------
do i_iter = 1, number_of_iterations
    sa_old = sa
    f = gsw_ct_freezing_exact(sa,p,saturation_fraction) - ct
    sa = sa_old - f/ctfreezing_sa
    sa_mean = 0.5d0*(sa + sa_old) 
    call gsw_ct_freezing_first_derivatives(sa_mean,p,saturation_fraction, &
                                           ctfreezing_sa=ctfreezing_sa)
    sa = sa_old - f/ctfreezing_sa
end do

if (gsw_sa_p_inrange(sa,p)) then
    gsw_brinesa_ct = sa
else
    gsw_brinesa_ct = gsw_error_code(3,func_name)
end if

return
end function

!--------------------------------------------------------------------------
