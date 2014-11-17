!==========================================================================
function gsw_entropy_part(sa,t,p)
!==========================================================================

! entropy minus the terms that are a function of only SA
!
! sa     : Absolute Salinity                               [g/kg]
! t      : in-situ temperature                             [deg C]
! p      : sea pressure                                    [dbar]
! 
! gsw_entropy_part : entropy part

implicit none

integer, parameter :: r14 = selected_real_kind(14,30)

real (r14) :: sa, t, p, sfac, x2, x, y, z, g03, g08, gsw_entropy_part

sfac = 0.0248826675584615d0

x2 = sfac*sa
x = sqrt(x2)
y = t*0.025d0
z = p*1d-4

g03 = z*(-270.983805184062d0 + &
    z*(776.153611613101d0 + z*(-196.51255088122d0 + (28.9796526294175d0 - 2.13290083518327d0*z)*z))) + &
    y*(-24715.571866078d0 + z*(2910.0729080936d0 + &
    z*(-1513.116771538718d0 + z*(546.959324647056d0 + z*(-111.1208127634436d0 + 8.68841343834394d0*z)))) + &
    y*(2210.2236124548363d0 + z*(-2017.52334943521d0 + &
    z*(1498.081172457456d0 + z*(-718.6359919632359d0 + (146.4037555781616d0 - 4.9892131862671505d0*z)*z))) + &
    y*(-592.743745734632d0 + z*(1591.873781627888d0 + &
    z*(-1207.261522487504d0 + (608.785486935364d0 - 105.4993508931208d0*z)*z)) + &
    y*(290.12956292128547d0 + z*(-973.091553087975d0 + &
    z*(602.603274510125d0 + z*(-276.361526170076d0 + 32.40953340386105d0*z))) + &
    y*(-113.90630790850321d0 + y*(21.35571525415769d0 - 67.41756835751434d0*z) + &
    z*(381.06836198507096d0 + z*(-133.7383902842754d0 + 49.023632509086724d0*z)))))))

g08 = x2*(z*(729.116529735046d0 + &
    z*(-343.956902961561d0 + z*(124.687671116248d0 + z*(-31.656964386073d0 + 7.04658803315449d0*z)))) + &
    x*( x*(y*(-137.1145018408982d0 + y*(148.10030845687618d0 + y*(-68.5590309679152d0 + 12.4848504784754d0*y))) - &
    22.6683558512829d0*z) + z*(-175.292041186547d0 + (83.1923927801819d0 - 29.483064349429d0*z)*z) + &
    y*(-86.1329351956084d0 + z*(766.116132004952d0 + z*(-108.3834525034224d0 + 51.2796974779828d0*z)) + &
    y*(-30.0682112585625d0 - 1380.9597954037708d0*z + y*(3.50240264723578d0 + 938.26075044542d0*z)))) + &
    y*(1760.062705994408d0 + y*(-675.802947790203d0 + &
    y*(365.7041791005036d0 + y*(-108.30162043765552d0 + 12.78101825083098d0*y) + &
    z*(-1190.914967948748d0 + (298.904564555024d0 - 145.9491676006352d0*z)*z)) + &
    z*(2082.7344423998043d0 + z*(-614.668925894709d0 + (340.685093521782d0 - 33.3848202979239d0*z)*z))) + &
    z*(-1721.528607567954d0 + z*(674.819060538734d0 + &
    z*(-356.629112415276d0 + (88.4080716616d0 - 15.84003094423364d0*z)*z)))))

gsw_entropy_part = -(g03 + g08)*0.025d0

return
end function

!--------------------------------------------------------------------------
