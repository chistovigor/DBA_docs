echo start `date`
echo
echo export const tables
echo
expdp router/loopexamspit parfile=exp_const.par
echo `date`
cat router_const.log | grep completed

echo
echo export annual tables
echo
expdp router/loopexamspit parfile=exp_annual.par
echo `date`
cat router_annual.log | grep completed

echo
echo import const tables
echo
impdp router/loopexamspit parfile=imp_const.par
echo `date`
cat imp_router_const.log | grep completed

echo
echo import annual tables
echo
impdp router/loopexamspit parfile=imp_annual.par
echo `date`
cat imp_router_annual.log | grep completed

exit
