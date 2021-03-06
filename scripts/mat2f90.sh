#!/bin/sh
#
# Convert GSW .m (Matlab) file to .f90 (Fortran) version.
# Handles most of the laborious tasks, but resulting file still requires
# some editing by hand. Variable declaration statements are placed at the
# end of the file.
#
# Usage: ./mat2f90.sh file
#

outfile=`basename $1 m | tr '[:upper:]' '[:lower:]'`f90

tmpfile1=__temp1.$$
tmpfile2=__temp2.$$
tmpfile3=__temp3.$$

sed -n '
	s/%/!/
/^!/! {
	s/;//
	s/(:)//g
	s/\.\//\//g
	s/\.\*/\*/g
	s/\.+/+/g
	s/\.-/-/g
	s/\.'"'"'//g
	s/\([0-9][0-9]*\)e/\1d/g
	s/\([0-9]*\.[0-9][0-9]*\)\([ \n\r+*/)-]\)/\1d0\2/g
	s/ > / .gt. /g
	s/ < / .lt. /g
	s/ == / .eq. /g
	s/|/.or./g
	s/&/.and./g
	s/\.\.\./\&/g
	s/any\((.*)\)/\1 then/g
	y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
	s/gsw_enthalpy_ct_exact/gsw_enthalpy/
	s/gsw_ct_from_enthalpy_exact/gsw_ct_from_enthalpy/
	s/gsw_enthalpy_first_derivatives_ct_exact/gsw_enthalpy_first_derivatives/
}
/^ *for / {
	s/for /do /
	s/:/, /
}
/^ *\[.*\] *= *find/ { b the_end }
/^ *\[.*\] *= *size/ { b the_end }
/^ *\[.*\] *=/ {
	s/ *\[\(.*\)\] *\(=.*\)).*/\2,\1)/
	s/ *//g
	s/=/call /g
}
/^function *\[/ {
	s/function *\[\(.*\)\] *= *\(.*\)(\(.*\))/elemental subroutine \2(\3,\1)/
	s/, /,/g
	s/,/, /g
	s/(/ (/
}
/^function / {
	s/function *[a-z_]* *= *\(.*\)/elemental function \1/
	s/,/, /g
	s/(/ (/
}
/^ *[a-z0-9_]* *=/ {
	w '"$tmpfile1"'
	s/^ *\([a-z0-9_]*\) *=.*/\1/
	H
	d
}
$ {
	w '"$tmpfile1"'
	x
	p
	d
}
:the_end
	w '"$tmpfile1"'
' $1 >> $tmpfile2

# Source code is in $tmpfile1 and variables in $tmpfile2

# Add arguments from subroutine calls to variable list in $tmpfile2

sed -n '
/ *call / {
	s/.*(\(.*\)).*/\1/
	s/ //g
	p
}
' $tmpfile1 | awk -F, '
{
	for (i = 1; i <= NF; i++) print $i;
}
' >> $tmpfile2

cat $tmpfile2 | sort -u > $tmpfile3
/bin/rm $tmpfile2

# Extract function/subroutine arguments and add to variable list in $tmpfile3
# (this will allow us to remove these names from the list altogether using the
# -u option to the uniq command, because we want to put them in separate
# declaration statememts)

sed -n '
/^elemental / {
	s/.*(\(.*\)).*/\1/
	s/ //g
	p
}
' $tmpfile1 | awk -F, '
{
	for (i = 1; i <= NF; i++) print $i;
}
' >> $tmpfile3

# Extract GSW function names and construct declaration statements

sed -n '
/^ *[a-z0-9_]* =.*gsw_[a-z0-9_]*(.*/ {
	s/^ *[a-z0-9_]* *=.*\(gsw_[a-z0-9_]*\)(.*/\1/
	p
}
/^ *call *gsw_[a-z0-9_]*(.*/ {
	s/^ *call *\(gsw_[a-z0-9_]*\)(.*/\1/
	p
}
' $tmpfile1 | sort -u | awk '
BEGIN	{
	print "";
}
NF > 0	&& $0 !~ /transposed/ {
	if (length(list)+length > 75) {
		print list;
		list = "";
	}
	if (list == "")
		list = "use gsw_mod_toolbox, only : " $0;
	else
		list = list ", " $0;
}
END     { print list }
' >> $tmpfile1

# Add some static source code ...

cat << END >> $tmpfile1

implicit none
integer, parameter :: r14 = selected_real_kind(14,30)

END

# Extract function/subroutine arguments and construct declaration statements

sed -n '
	y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/
/^function / {
	h
	s/,/, /g
	s/.*(\(.*\))/real (r14), intent(in) :: \1/
	p
	g
}
/^function *\[/ {
	s/function *\[\(.*\)\] *= *\(.*\)(\(.*\))/real (r14), intent(out) :: \1/
	p
	b
}
/^function / {
	h
	s/.*//
	p
	g
	s/.*\(gsw_[a-z0-9_]*\).*/real (r14) :: \1/
	p
}
' $1 >> $tmpfile1

# Sort variables and construct declaration statements

sort $tmpfile3 | uniq -u | awk '
BEGIN	{ print "" }
NF > 0	&& $0 !~ /transposed/ {
	if (length(list)+length > 75) {
		print list;
		list = "";
	}
	if (list == "")
		list = "real (r14) :: " $0;
	else
		list = list ", " $0;
}
END     { print list }
' >> $tmpfile1

# One more pass to make 'END' either 'END IF' or 'END DO'

awk '
BEGIN	{ n = 0 }
	{ printed = 0 }
/^elemental / {
	print "!==========================================================================";
	type = $2;
}
/^ *if */ {
	n++;
	filo[n] = "if";
}
/^ *do */ {
	n++;
	filo[n] = "do";
}
/^ *end */ {
	if (n > 0) {
		print "end " filo[n];
	}
	else {
		print "return";
		print $0,type;
		print "";
		print "!--------------------------------------------------------------------------";
	}
	printed = 1;
	n--;
}
printed == 0 { print $0 }
' $tmpfile1 > $outfile

tr -d '\r' <$outfile >$tmpfile1

/bin/mv $tmpfile1 $outfile
/bin/rm $tmpfile3

