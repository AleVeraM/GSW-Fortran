!==========================================================================
elemental function gsw_sound_speed_ice (t, p)
!==========================================================================
!
!  Calculates the compression speed of sound in ice. 
!  
!  t   =  in-situ temperature (ITS-90)                            [ deg C ]
!  p   =  sea pressure                                             [ dbar ]
!         ( i.e. absolute pressure - 10.1325 dbar )
!
!  sound_speed_ice  =  compression speed of sound in ice            [ m/s ]
!--------------------------------------------------------------------------

use gsw_mod_toolbox, only : gsw_gibbs_ice

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

real (r14), intent(in) :: t, p

real (r14) :: gsw_sound_speed_ice

real (r14) :: gi_tp, gi_tt

gi_tt = gsw_gibbs_ice(2,0,t,p) 
gi_tp = gsw_gibbs_ice(1,1,t,p)

gsw_sound_speed_ice = gsw_gibbs_ice(0,1,t,p) * &
               sqrt(gi_tt/(gi_tp*gi_tp - gi_tt*gsw_gibbs_ice(0,2,t,p)))

return
end function

!--------------------------------------------------------------------------
