!==========================================================================
elemental function gsw_melting_seaice_sa_ct_ratio (sa, ct, p, &
                                  saturation_fraction, sa_seaice, t_seaice)
!==========================================================================
!
! Calculates the ratio of SA to CT changes when sea ice melts into seawater.
! It is assumed that a small mass of sea ice melts into an infinite mass of
! seawater.  Because of the infinite mass of seawater, the sea ice will 
! always melt.   
!
! Ice formed at the sea surface (sea ice) typically contains between 2 g/kg
! and 12 g/kg of salt (defined as the mass of salt divided by the mass of 
! ice Ih plus brine) and this programme returns NaN's if the input 
! SA_seaice is greater than 15 g/kg.  If the SA_seaice input is not zero, 
! usually this would imply that the pressure p should be zero, as sea ice 
! only occurs near the sea surface.  The code does not impose that p = 0 if 
! SA_seaice is non-zero.  Rather, this is left to the user.  
!
! The Absolute Salinity, SA_brine, of the brine trapped in little pockets 
! in the sea ice, is in thermodynamic equilibrium with the ice Ih that
! surrounds these pockets.  As the seaice temperature, t_seaice, may be 
! less than the freezing temperature, SA_brine is usually greater than the
! Absolute Salinity of the seawater at the time and place when and where 
! the sea ice was formed.  So usually SA_brine will be larger than SA.  
!
! The output, melting_seaice_SA_CT_ratio, is dSA/dCT rather than dCT/dSA. 
! This is done so that when (SA - seaice_SA) = 0, the output, dSA/dCT is 
! zero whereas dCT/dSA would be infinite. 
!
!  SA  =  Absolute Salinity of seawater                            [ g/kg ]
!  CT  =  Conservative Temperature of seawater (ITS-90)           [ deg C ]
!  p   =  sea pressure at which the melting occurs                 [ dbar ]
!         ( i.e. absolute pressure - 10.1325 dbar ) 
!  saturation_fraction = the saturation fraction of dissolved air in 
!               seawater.  The saturation_fraction must be between 0 and 1.
!  SA_seaice  =  Absolute Salinity of sea ice, that is, the mass fraction 
!                of salt in sea ice expressed in g of salt per kg of 
!                sea ice                                           [ g/kg ]
!  t_seaice = the in-situ temperature of the sea ice (ITS-90)     [ deg C ]
!
!  melting_seaice_SA_CT_ratio = the ratio dSA/dCT of SA to CT changes when
!                sea ice melts into a large mass of seawater   [ g/(kg K) ]
!--------------------------------------------------------------------------

use gsw_mod_toolbox, only : gsw_ct_freezing, gsw_enthalpy, gsw_t_freezing
use gsw_mod_toolbox, only : gsw_brinesa_t, gsw_enthalpy_ice
use gsw_mod_toolbox, only : gsw_enthalpy_t_exact
use gsw_mod_toolbox, only : gsw_enthalpy_first_derivatives

use gsw_mod_error_functions, only : gsw_error_code, gsw_error_limit

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: sa, ct, p, saturation_fraction, sa_seaice
real (r14), intent(in) :: t_seaice

real (r14) :: gsw_melting_seaice_sa_ct_ratio

real (r14) :: ctf, delsa, denominator, h, h_brine, h_ih, sa_brine
real (r14) :: tf_sa_seaice, h_hat_sa, h_hat_ct

character (*), parameter :: func_name = "gsw_melting_seaice_sa_ct_ratio"

if (sa_seaice .lt. 0d0 .or. sa_seaice .gt. 15d0) then
    gsw_melting_seaice_sa_ct_ratio = gsw_error_code(1,func_name)
    return
end if

ctf = gsw_ct_freezing(sa,p,saturation_fraction)
if (ct .lt. ctf) then    ! the seawater ct input is below the freezing temp
    gsw_melting_seaice_sa_ct_ratio = gsw_error_code(2,func_name)
    return
end if

!--------------------------------------------------------------------------
tf_sa_seaice = gsw_t_freezing(sa_seaice,p,saturation_fraction) - 1d-6
if (t_seaice .gt. tf_sa_seaice) then   ! t_seaice exceeds the freezing sa
    gsw_melting_seaice_sa_ct_ratio = gsw_error_code(3,func_name)
    return
end if
!
! The 1e-6 C buffer in the allowable t_seaice is to ensure that there is
! some ice Ih in the sea ice.  Without this buffer, that is if t_seaice
! is allowed to be exactly equal to tf_sa_seaice, the sea ice is actually
! 100% brine at Absolute Salinity of SA_seaice.
!--------------------------------------------------------------------------

h = gsw_enthalpy(sa,ct,p)
h_ih = gsw_enthalpy_ice(t_seaice,p)
call gsw_enthalpy_first_derivatives(sa,ct,p,h_hat_sa,h_hat_ct)
! Note that h_hat_CT is equal to cp0*(273.15 + t)./(273.15 + pt0)

sa_brine = gsw_brinesa_t(t_seaice,p,saturation_fraction)
if (sa_brine .gt. gsw_error_limit) then
    gsw_melting_seaice_sa_ct_ratio = gsw_error_code(4,func_name,sa_brine)
    return
end if
h_brine = gsw_enthalpy_t_exact(sa_brine,t_seaice,p)
delsa = sa - sa_seaice

denominator = h - h_ih - delsa*h_hat_sa - sa_seaice*(h_brine - h_ih)/sa_brine
gsw_melting_seaice_sa_ct_ratio = h_hat_ct*delsa/denominator

return
end function
