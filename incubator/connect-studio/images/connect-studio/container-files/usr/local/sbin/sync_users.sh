#!/bin/sh

LOCK_DIR="sync_in_progress"

HELP="Usage: sync_users.sh [OPTION]...

    -b path, --home-base path
        Use path as the base path for home directories
    -e URL, --api-endpoint URL
        Use URL as the endpoint at which to contact the CI-Connect API
    -g group, --group-group group
        Use group as the group membership source group, the group from which to 
        collect subgroups to which users may belong. This can be different from
        the user source group (specified with -u), but should probably be an
        enclosing group of the user source group.
    -h, --help
        Show this help message
    -t token, --api-token token
        Use token when contacting the CI-Connect API
    -u group, --user-group group
        Use group as the user source group, the group from which users are 
        selected to be provisioned
    --wipe
        Remove all users and groups previously provisioned. This operation will
        permanently destroy any data in users' home directories which has not 
        been copied elsewhere. 
    --dry-run
        Report changes which would be made, without actually making any. 
    --clean-home
        When deleting users, delete their home directories as well. 
"

# Read command line arguments
# TODO: support --option=value style
while [ "$#" -gt 0 ]
do
	arg="$1"
	shift
	if [ "$arg" = "--help" -o "$arg" = "-h" ]; then
		echo "$HELP"
		exit 0
	elif [ "$arg" = "--api-token" -o "$arg" = "-t" ]; then
		if [ "$#" -lt 1 ]; then
			echo "Error: Missing value after $arg option" 1>&2
			exit 1
		fi
		API_TOKEN="$1"
		shift
	elif [ "$arg" = "--api-endpoint" -o "$arg" = "-e" ]; then
		if [ "$#" -lt 1 ]; then
			echo "Error: Missing value after $arg option" 1>&2
			exit 1
		fi
		API_ENDPOINT="$1"
		shift
	elif [ "$arg" = "--user-group" -o "$arg" = "-u" ]; then
		if [ "$#" -lt 1 ]; then
			echo "Error: Missing value after $arg option" 1>&2
			exit 1
		fi
		USER_SOURCE_GROUP="$1"
		shift
	elif [ "$arg" = "--group-group" -o "$arg" = "-g" ]; then
		if [ "$#" -lt 1 ]; then
			echo "Error: Missing value after $arg option" 1>&2
			exit 1
		fi
		GROUP_ROOT_GROUP="$1"
		shift
	elif [ "$arg" = "--home-base" -o "$arg" = "-b" ]; then
		if [ "$#" -lt 1 ]; then
			echo "Error: Missing value after $arg option" 1>&2
			exit 1
		fi
		HOME_DIR_ROOT="$1"
		shift
	elif [ "$arg" = "--wipe" ]; then
		DO_WIPE=1
	elif [ "$arg" = "--clean-home" ]; then
		ERASE_HOME=1
	elif [ "$arg" = "--dry-run" ]; then
		DRY_RUN=1
	else
		echo "Error: Unexpected argument: $arg" 1>&2
		exit 1
	fi
done

if [ "$DRY_RUN" ]; then
	echo "Dry run; no changes will be made"
fi

USERDEL=userdel
if [ "$ERASE_HOME" ]; then
	USERDEL="userdel -r"
	echo "Home directories of deleted users will be erased"
fi

if [ "$DO_WIPE" ]; then
	mkdir "$LOCK_DIR"
	if [ "$?" -ne 0 ]; then
		echo "Error: Failed to create new $LOCK_DIR lock directory; cowardly refusing to continue" 1>&2
		exit 1
	fi
	echo "Warning: Erasing all provisioned users and groups in 5 seconds"
	sleep 5
	# erase users
	if [ -f existing_users ]; then
		for DEFUNCT_USER in $(cat existing_users); do
			echo "Deleting user $DEFUNCT_USER"
			if [ ! "$DRY_RUN" ]; then
				$USERDEL "$DEFUNCT_USER"
				if [ "$?" -ne 0 ]; then
					echo "Failed to delete user" 1>&2
					exit 1
				fi
				sed '/^'"$DEFUNCT_USER"'$/d' existing_users > existing_users.new
				mv existing_users.new existing_users
			fi
		done
	fi
	# erase groups
	if [ -f existing_groups ]; then
		for DEFUNCT_GROUP in $(cat existing_groups); do
			echo "Deleting group $DEFUNCT_GROUP"
			if [ ! "$DRY_RUN" ]; then
				groupdel "$DEFUNCT_GROUP"
				if [ "$?" -ne 0 ]; then
					echo "Failed to delete group" 1>&2
					exit 1
				fi
				sed '/^'"$DEFUNCT_GROUP"'$/d' existing_groups > existing_groups.new
				mv existing_groups.new existing_groups
			fi
		done
	fi
	rmdir "$LOCK_DIR"
	exit
fi

# Check that necessary variables are set
if [ -z "$API_TOKEN" ]; then
	echo "Error: API_TOKEN must be set in the environment or with the --api-token option" 1>&2
	exit 1
fi
# This is the Base URL for contacting the connect API
if [ -z "$API_ENDPOINT" ]; then
	API_ENDPOINT='http://www-dev.ci-connect.net:18080'
	echo "API_ENDPOINT not set, using default value $API_ENDPOINT"
fi
# This is the group from which to collect users
if [ -z "$USER_SOURCE_GROUP" ]; then
	echo "Error: USER_SOURCE_GROUP must be set in the environment or with the --user-group option" 1>&2
	exit 1
fi
# This is the group from which to collect subgroups to which users may belong.
# It can be different from USER_SOURCE_GROUP, but should probably be an enclosing group in that case.
if [ -z "$GROUP_ROOT_GROUP" ]; then
	echo "Error: GROUP_ROOT_GROUP must be set in the environment or with the --group-group option" 1>&2
	exit 1
fi
# This is the base path within which users' home directories are provisioned.
if [ -z "$HOME_DIR_ROOT" ]; then
	HOME_DIR_ROOT='/home'
	echo "HOME_DIR_ROOT not set, using default value $HOME_DIR_ROOT"
fi

# Ensure that necessary commands are available
ensure_available(){
	if ! which "$1" >/dev/null 2>&1; then
		echo "Error: Unable to find required command $1" 1>&2
		exit 1
	fi
}
ensure_available curl
ensure_available jq

if [ ! "$DRY_RUN" ]; then
	# Ensure that the existing user/group lists exist
	if [ ! -f existing_users ]; then
		touch existing_users
	fi
	if [ ! -f existing_groups ]; then
		touch existing_groups
	fi
fi

mkdir "$LOCK_DIR"
if [ "$?" -ne 0 ]; then
	echo "Error: Failed to create new $LOCK_DIR lock directory; cowardly refusing to continue" 1>&2
	exit 1
fi

# Get all members of the group
curl -sf ${API_ENDPOINT}/v1alpha1/groups/${USER_SOURCE_GROUP}/members?token=${API_TOKEN} > group_members.json
if [ "$?" -ne 0 ]; then
	echo "Error: Failed to download data from ${API_ENDPOINT}/v1alpha1/groups/${USER_SOURCE_GROUP}/members" 1>&2
	rmdir "$LOCK_DIR"
	exit 1
fi
ACTIVE_USERS=$(jq '.memberships | map(select(.state==("admin","active")) | .user_name)' group_members.json | sed -n 's|.*"\([^"]*\)".*|\1|p' | sort)
DISABLED_USERS=$(jq '.memberships | map(select(.state==("disabled")) | .user_name)' group_members.json | sed -n 's|.*"\([^"]*\)".*|\1|p' | sort)
N_ACTIVE=$(/usr/bin/env echo "$ACTIVE_USERS" | wc -l)
echo "$N_ACTIVE active group members"
rm group_members.json

# Fetch details about active group members
# Do this in blocks to avoid any single request being too large and potentially timing out
BLOCK_SIZE=1000
TO_FETCH=$N_ACTIVE
PROCESSED=0
cat /dev/null > user_data
while [ "$PROCESSED" -lt "$N_ACTIVE" ]; do
	TO_FETCH=$(expr $PROCESSED + $BLOCK_SIZE)
	if [ "$TO_FETCH" -gt "$N_ACTIVE" ]; then
		TO_FETCH=$N_ACTIVE
		BLOCK_SIZE=$(expr $N_ACTIVE - $PROCESSED)
	fi
	USER_BLOCK=$(/usr/bin/env echo "$ACTIVE_USERS" | head -n $TO_FETCH | tail -n $BLOCK_SIZE)
	REQUEST='{'
	SEP=""
	for uname in $USER_BLOCK; do
		REQUEST="${REQUEST}${SEP}"'"/v1alpha1/users/'"$uname?token=${API_TOKEN}"'":{"method":"GET"}'
		SEP=','
	done
	REQUEST="${REQUEST}"'}'
	/usr/bin/env echo "$REQUEST" > user_request
	curl -sf -X POST --data '@user_request' ${API_ENDPOINT}/v1alpha1/multiplex?token=${API_TOKEN} > raw_user_data
	if [ "$?" -ne 0 ]; then
		echo "Error: Failed to download data from ${API_ENDPOINT}/v1alpha1/multiplex" 1>&2
		rmdir "$LOCK_DIR"
		exit 1
	fi
	jq '.[] | .body | fromjson | .metadata' raw_user_data | sed -e '/"institution"/d' \
		-e '/"access_token"/d' \
		-e '/"phone"/d' \
		-e '/"join_date"/d' \
		-e '/"last_use_time"/d' \
		-e '/"superuser"/d' \
		-e '/"state_set_by"/d' \
		-e 's/\("state": "[^"]*"\),/\1/' >> user_data
	rm user_request raw_user_data
	PROCESSED=$(expr $PROCESSED + $BLOCK_SIZE)
	echo "Fetched $PROCESSED users"
done

# Figure out the last component of the base group name, e.g. root.foo -> foo
BASE_GROUP_NAME=$(/usr/bin/env echo "$GROUP_ROOT_GROUP" | sed 's/.*\.\([^.]*\)$/\1/')
# Figure out what, if anything, contains the base group, e.g. root.foo.bar -> root.foo
BASE_GROUP_CONTEXT=$(/usr/bin/env echo "$GROUP_ROOT_GROUP" | sed -n 's/^\(.*\)\.[^.]*$/\1/p')
if [ "$BASE_GROUP_CONTEXT" ]; then
	# demand an explicit dot after a non-empty base
	BASE_GROUP_CONTEXT="$BASE_GROUP_CONTEXT."
fi
# Get all subgroups
curl -sf ${API_ENDPOINT}/v1alpha1/groups/${GROUP_ROOT_GROUP}/subgroups?token=${API_TOKEN} > subgroups.json
if [ "$?" -ne 0 ]; then
	echo "Error: Failed to download data from ${API_ENDPOINT}/v1alpha1/groups/${GROUP_ROOT_GROUP}/subgroups" 1>&2
	rmdir "$LOCK_DIR"
	exit 1
fi
SUBGROUPS=$(jq '.groups | map(.name)' subgroups.json | sed -n 's|.*"'"$BASE_GROUP_CONTEXT"'\([^"]*\)".*|\1|p')

# Delete all existing users which should not exist
echo "$ACTIVE_USERS
$DISABLED_USERS" | sort > all_users
for DEFUNCT_USER in $(join -v1 existing_users all_users); do
	echo "Deleting user $DEFUNCT_USER"
	if [ ! "$DRY_RUN" ]; then
		$USERDEL "$DEFUNCT_USER"
		sed '/^'"$DEFUNCT_USER"'$/d' existing_users > existing_users.new
		mv existing_users.new existing_users
	fi
done
rm all_users

# Delete all existing groups which should not exist
# Do this after deleting users in case any of the groups we need to delete was 
# the primary group of a user which was deleted. 
for DEFUNCT_GROUP in $(printf "%s\n%s" "$BASE_GROUP_NAME" "$SUBGROUPS" | sort | join -v1 existing_groups -); do
	echo "Deleting group $DEFUNCT_GROUP"
	if [ ! "$DRY_RUN" ]; then
		groupdel "$DEFUNCT_GROUP"
		sed '/^'"$DEFUNCT_GROUP"'$/d' existing_groups > existing_groups.new
		mv existing_groups.new existing_groups
	fi
done

# Create groups which are needed and don't yet exist
if grep -q "^${BASE_GROUP_NAME}:" /etc/group; then
	echo "Group $BASE_GROUP_NAME already exists"
else
	GID=$(curl -sf "${API_ENDPOINT}/v1alpha1/groups/${GROUP_ROOT_GROUP}?token=${API_TOKEN}" | jq -r '.metadata.unix_id')
	if [ "$?" -ne 0 ]; then
		echo "Error: Failed to download data from ${API_ENDPOINT}/v1alpha1/groups/${GROUP_ROOT_GROUP}" 1>&2
		rmdir "$LOCK_DIR"
		exit 1
	fi
	echo "Creating group $BASE_GROUP_NAME with gid $GID"
	if [ ! "$DRY_RUN" ]; then
		groupadd "$BASE_GROUP_NAME" -g $GID
		if [ "$?" -ne 0 ]; then
			echo "Aborting due to group creation error" 1>&2
			rmdir "$LOCK_DIR"
			exit 1
		fi
	fi
fi
for GROUP in $SUBGROUPS; do
	GID=$(jq -r '.groups | map(select(.name==("'"${BASE_GROUP_CONTEXT}${GROUP}"'"))) | map(.unix_id)[0]' subgroups.json)
	if grep -q "^${GROUP}:" /etc/group; then
		echo "Group $GROUP already exists"
		ACTUAL_GROUP_ID=$(sed -n 's|^'"$GROUP"':[^:]*:\([0-9]*\):.*|\1|p' < /etc/group)
		if [ "$ACTUAL_GROUP_ID" != "$GID" ]; then
			echo "Warning: in-use gid for ${GROUP} (${ACTUAL_GROUP_ID}) does not match expected gid (${GID})"
		fi
	else
		echo "Creating group $GROUP with gid $GID"
		if [ ! "$DRY_RUN" ]; then
			groupadd "$GROUP" -g $GID
			if [ "$?" -ne 0 ]; then
				echo "Aborting due to group creation error" 1>&2
				rmdir "$LOCK_DIR"
				exit 1
			fi
		fi
	fi
done
if [ ! "$DRY_RUN" ]; then
	printf "%s\n%s" "$BASE_GROUP_NAME" "$SUBGROUPS" | cat existing_groups - | sort | uniq > existing_groups.new
	mv existing_groups.new existing_groups
fi

USERS_TO_CREATE=$(echo "$ACTIVE_USERS" | join -v2 existing_users -)
USERS_TO_UPDATE=$(echo "$ACTIVE_USERS" | join existing_users -)

set_ssh_authorized_keys(){
	USER="$1"
	USER_HOME_DIR="$2"
	USER_KEY_DATA="$3"
	if [ ! -d "$USER_HOME_DIR/.ssh" ]; then
		mkdir "$USER_HOME_DIR/.ssh"
	fi
	echo "$USER_KEY_DATA" > "$USER_HOME_DIR/.ssh/authorized_keys"
	chown -R "$USER" "$USER_HOME_DIR/.ssh"
	chmod 0600 "$USER_HOME_DIR/.ssh/authorized_keys"
}

set_default_project(){
	USER="$1"
	USER_HOME_DIR="$2"
	USER_PROJECT="$3"
	
	# Don't overwrite if the user already has a project file
	if [ -e "$USER_HOME_DIR/.ciconnect/defaultproject" ]; then
		return
	fi
	if [ ! -d "$USER_HOME_DIR/.ciconnect" ]; then
		mkdir "$USER_HOME_DIR/.ciconnect"
	fi
	echo "$USER_PROJECT" > "$USER_HOME_DIR/.ciconnect/defaultproject"
	chown -R "$USER" "$USER_HOME_DIR/.ciconnect"
}

# Ensure that all active users have accounts
cat /dev/null > new_users
for USER in $USERS_TO_CREATE; do
	if [ -f user_data -a ! -s user_data ]; then
		echo "user_data is empty!" 1>&2
		rmdir "$LOCK_DIR"
		exit 1
	fi
	USER_DATA=$(jq 'select(.unix_name==("'${USER}'"))' user_data)
	if [ "$(/usr/bin/env echo "$USER_DATA" | jq '.service_account')" = "true" ]; then
		echo "Skipping user $USER which is a service account"
		continue
	fi
	USER_ID=$(/usr/bin/env echo "$USER_DATA" | jq -r '.unix_id')
	USER_NAME=$(/usr/bin/env echo "$USER_DATA" | jq -r '.name')
	USER_EMAIL=$(/usr/bin/env echo "$USER_DATA" | jq -r '.email')
	RAW_USER_GROUPS=$(/usr/bin/env echo "$USER_DATA" | jq '.group_memberships | map(select(.state==("active","admin")) | .name)' | sed -n 's|.*"'"$BASE_GROUP_CONTEXT"'\([^"]*\)".*|\1|p' | sed -n '/^'"$BASE_GROUP_NAME"'/p')
	if [ "$?" -ne 0 ]; then
		echo "Failed to extract group_memberships for user $USER" 1>&2
		rmdir "$LOCK_DIR"
		exit 1
	fi
	USER_GROUPS=$(/usr/bin/env echo "$RAW_USER_GROUPS" | tr '\n' ',' | sed 's|,$||')
	echo "Creating user $USER with uid $USER_ID and groups $USER_GROUPS"
	if [ ! "$DRY_RUN" ]; then
		useradd -c "$USER_NAME" -u "$USER_ID" -m -b "${HOME_DIR_ROOT}" -N -g "$BASE_GROUP_NAME" -G "$USER_GROUPS" "$USER"
		if [ "$?" -ne 0 ]; then
			echo "Failed to create user $USER" 1>&2
			cat existing_users new_users | sort | uniq > existing_users.new
			mv existing_users.new existing_users
			if [ "$?" -ne 0 ]; then
				echo "Failed to replace existing_users file" 1>&2
				rmdir "$LOCK_DIR"
				exit 1
			fi
			rm new_users
			rmdir "$LOCK_DIR"
			exit 1
		fi
		set_ssh_authorized_keys "$USER" "${HOME_DIR_ROOT}/${USER}" "$(/usr/bin/env echo "$USER_DATA" | jq -r '.public_key')"
		# OSG specific: Try to pick out the first group to which the user belongs and set it as the default 'project'
		# However, we must not pick 'osg', or any of the login node groups, so we remove these from the list.
		FILTERED_USER_GROUPS=$(/usr/bin/env echo "$RAW_USER_GROUPS" | sed -e '/^'"$BASE_GROUP_NAME"'$/d' -e '/^'"$BASE_GROUP_NAME"'.login-nodes/d')
		DEFAULT_GROUP=$(/usr/bin/env echo "$FILTERED_USER_GROUPS" | head -n 1)
		set_default_project "$USER" "${HOME_DIR_ROOT}/${USER}" "$DEFAULT_GROUP"
		echo "$USER" >> new_users
	fi
done
if [ ! "$DRY_RUN" ]; then
	cat existing_users new_users | sort | uniq > existing_users.new
	mv existing_users.new existing_users
	if [ "$?" -ne 0 ]; then
		echo "Failed to replace existing_users file" 1>&2
		rmdir "$LOCK_DIR"
		exit 1
	fi
	rm new_users
fi

# Ensure that previously existing users have updated information
for USER in $USERS_TO_UPDATE; do
	USER_DATA=$(jq 'select(.unix_name==("'${USER}'"))' user_data)
	if [ $(/usr/bin/env echo "$USER_DATA" | jq '.service_account') = "true" ]; then
		echo "Skipping $USER which is a service account"
		continue
	fi
	EXPECTED_USER_ID=$(/usr/bin/env echo "$USER_DATA" | jq -r '.unix_id')
	USER_NAME=$(/usr/bin/env echo "$USER_DATA" | jq -r '.name')
	USER_EMAIL=$(/usr/bin/env echo "$USER_DATA" | jq -r '.email')
	RAW_USER_GROUPS=$(/usr/bin/env echo "$USER_DATA" | jq '.group_memberships | map(select(.state==("active","admin")) | .name)' | sed -n 's|.*"'"$BASE_GROUP_CONTEXT"'\([^"]*\)".*|\1|p' | sed -n '/^'"$BASE_GROUP_NAME"'/p')
	USER_GROUPS=$(/usr/bin/env echo "$RAW_USER_GROUPS" | tr '\n' ',' | sed 's|,$||')
	echo "Updating user $USER with groups $USER_GROUPS"
	if [ ! "$DRY_RUN" ]; then
		usermod -G "$USER_GROUPS" "$USER"
		set_ssh_authorized_keys "$USER" "${HOME_DIR_ROOT}/${USER}" "$(/usr/bin/env echo "$USER_DATA" | jq -r '.public_key')"
		# OSG specific: Try to pick out the first group to which the user belongs and set it as the default 'project'
		# However, we must not pick 'osg', or any of the login node groups, so we remove these from the list.
		FILTERED_USER_GROUPS=$(/usr/bin/env echo "$RAW_USER_GROUPS" | sed -e '/^'"$BASE_GROUP_NAME"'$/d' -e '/^'"$BASE_GROUP_NAME"'.login-nodes/d')
		DEFAULT_GROUP=$(/usr/bin/env echo "$FILTERED_USER_GROUPS" | head -n 1)
		set_default_project "$USER" "${HOME_DIR_ROOT}/${USER}" "$DEFAULT_GROUP"
	fi
	ACTUAL_USER_ID=$(id -u "$USER")
	if [ "$ACTUAL_USER_ID" != "$EXPECTED_USER_ID" ]; then
		echo "Warning: in-use uid for ${USER} (${ACTUAL_USER_ID}) does not match expected uid (${EXPECTED_USER_ID})"
	fi
done

# Ensure that all disabled users have their ssh keys removed
for USER in $DISABLED_USERS; do
	echo "Disabling user $USER"
	if [ ! "$DRY_RUN" ]; then
		if [ -f "${HOME_DIR_ROOT}/${USER}/.ssh/authorized_keys" ]; then
			cat /dev/null > "${HOME_DIR_ROOT}/${USER}/.ssh/authorized_keys"
		fi
	fi
done

rmdir "$LOCK_DIR"