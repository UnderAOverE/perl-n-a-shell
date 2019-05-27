#!/usr/bin/ksh

#
# urbanpenguin="https://www.youtube.com/watch?v=fCw-xf31M_s"
# 05/27/2019
# print_users_info.sh
# v1.0.0
# pretty print /etc/passwd first 10 users.
# r2d2c3p0
# ${%}
#
#

# global variables.
first_line=1
end_line=10

# main. # awk program from ${urbanpenguin} tutorials.
awk -v Start="${first_line}" -v End="${end_line}" -F ":" '
	BEGIN {
		print ""
		print "  ==================================================================="
		printf "%3s %-4s %-10s %-6s %-6s %-18s %-12s\n","","No.","User","UID","GID","Home","Shell"
		print "  ==================================================================="
	}
	NR==Start,NR==End {
		printf "%3s %-4d %-10s %-6d %-6d %-18s %-12s\n","",NR,$1,$3,$4,$6,$7
	}
	END {
		print "  ==================================================================="
		print ""
	}
' /etc/passwd

#end_print_users_info.sh
