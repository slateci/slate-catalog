# awk functions to make it easy to edit squid.conf
# Last modified by Dave Dykstra 2010/03/09
#
# Available functions:
#    setoption(optname, value)
#    setoptionparameter(optname, paramnum, value)
#    insertline(regexp, line)
#    commentout(regexp)
#    uncomment(regexp)
#    setserviceoption(optname, prefix, value, numservices, multiplier)
# See the comments before each function below for details.

# NOTE: optnames may contain blanks, which is handy for setting acls
#  for example, but for the function that excepts a parameter number,
#  parameters are always numbered by whitespace separation from the
#  beginning even when the name contains blanks.

# Set the option optname to value after the first occurrence of the option
#  -- in a TAG, a comment, or commented out -- and comment out the option
#  when it wasn't commented
function setoption(optname, value) {
    if (match($0 "\n", "^#  TAG: " optname "[ \t\n]") != 0) {
	$0 = $0 "\n" optname " " value
	matched[optname] = NR
	return
    }
    if (match($0 "\n", "^#? *" optname "[ \t\n]") == 0) return
    if (matched[optname] == "") {
	# not matched before, print commented out and then set to new value
	if (substr($0,1,1) == "#") print $0
	else print "#", $0
	$0 = optname " " value
	matched[optname] = NR
    }
    else if (substr($0,1,1) != "#") {
	# matched before and wasn't commented out, just comment it out
	$0 = "# " $0
    }
}

# Set the parameter number paramnum of option optname to value after the
#  first occurrence of the option, in a comment or not, and comment out the
#  option when it wasn't commented.  May be called more than once to
#  set different parameters on the same option.
function setoptionparameter(optname, paramnum, value) {
    if (match($0 "\n", "^#? *" optname "[ \t\n]") == 0) return
    if (matched[optname] == "") {
	# this option hasn't matched before; print the current line
	# commented out and continue
	if (substr($0,1,1) == "#") {
	    print
	    sub("^#[ \t]*","")
	}
	else print "#", $0
    }
    else if ((matched[optname] != NR) && (substr($0,1,1) != "#")) {
	# matched before and wasn't commented out, just comment it out
	$0 = "# " $0
    }
    if ((matched[optname] == "") || (matched[optname] == NR)) {
	$(paramnum+1) = value
	matched[optname] = NR
    }
}

# Print the line whenever the regular expression regexp matches.
# If you want it before the matched line(s), put it before the default "print"
#  statement and if you want it after the matched line(s), put it after "print".
function insertline(regexp, line) {
    if (match($0, regexp) > 0) print line
}

# Comment out all lines that match the regular expression regexp.
# Put this before the default "print" statement.
function commentout(regexp) {
    if (match($0, regexp) > 0) sub("^","# ")
}

# Uncomment all lines that match the regular expression regexp.
# Put this before the default "print" statement.
function uncomment(regexp) {
    if (match($0, "^# *" regexp) > 0) sub("^# *","")
}

# Set an option using if/else syntax for multiple services.
# For n=0 to numservices-1, use value+(n*multiplier) for service squid$n.
# Typically multiplier will be 1 or -1.
# value may be comma-separated list of numbers, the adjustment will
#  apply to all the numbers
function setserviceoption(optname, prefix, value, numservices, multiplier) {
    if (match($0 "\n", "^ *" optname "[ \t\n]") != 0) {
	# if the option is uncommented, comment it; we match only on TAG
	$0 = "# " $0
	matched[optname] = NR
	return
    }
    if (match($0 "\n", "^#  TAG: " optname "[ \t\n]") == 0) return
    lines = ""
    for (n = 0; n < numservices; n++ ) {
	if (n > 0)
	    lines = lines "\nelse"
	lines = lines "\nif ${service_name} = " n
	nvalues = split(value, avalues, ",")
	newvalues = ""
	for (i = 1; i <= nvalues; i++) {
	    if (i > 1)
		newvalues = newvalues ","
	    newvalues = newvalues (avalues[i] + n * multiplier)
	}
	lines = lines "\n" optname " " prefix newvalues
    }
    for (n = 0; n < numservices; n++ ) {
	lines = lines "\nendif"
    }
    $0 = $0 lines
}
