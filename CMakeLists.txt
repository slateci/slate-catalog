cmake_minimum_required(VERSION 3.0)
project("slate-catalog" NONE)

set(catalog_url "https://jenkins.slateci.io/catalog" CACHE STRING "The base URL at which the catalog is published")
set(catalog_path "/usr/share/nginx/html/catalog" CACHE PATH "The base path from which the catalog is published")

set(helm_dir "${CMAKE_BINARY_DIR}/helm")

find_program(SHASUM_PROGRAM NAMES "sha512sum" "shasum")
if(SHASUM_PROGRAM STREQUAL "SHASUM_PROGRAM-NOTFOUND")
	message(FATAL_ERROR "Unable to find a SHA-512 program")
else()
	message(STATUS "Found SHA sum program: ${SHASUM_PROGRAM}")
endif()
# If using the generic shasum we must specify the algorithm
if(SHASUM_PROGRAM MATCHES "shasum$")
	set(SHASUM_OPTIONS "-a512" CACHE STRING "Options to pass to SHASUM_PROGRAM")
else()
	set(SHASUM_OPTIONS "" CACHE STRING "Options to pass to SHASUM_PROGRAM")
endif()
message(STATUS "+ SHA options: ${SHASUM_OPTIONS}")

add_custom_command(OUTPUT "${helm_dir}"
                   COMMAND helm init -c --home "${helm_dir}" --skip-refresh)

add_custom_target(publish COMMAND true)

# define a repository using all of the charts found in the corresponding directory
# Minor flaw: the resulting makefile will not automatically rerun cmake if the 
# set of charts changes. This can be worked around by always running 
# `make rebuild_cache`, although it might be possible to use techniques from
# https://stackoverflow.com/a/33771598 to automate this.
function(add_repository name)
	message(STATUS "Configuring repository: ${name}")
	file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/${name}")

	# attempt to download fingerprints of previously published chart versions
	set(existing_fingerprints "${CMAKE_BINARY_DIR}/${name}/existing_fingerprints")
	add_custom_target("${name}_existing_fingerprints"
	                   COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/scripts/fetch_fingerprints" "${catalog_url}/${name}/fingerprints" "${existing_fingerprints}")

	# Collect the charts which belong in this repository
	file(GLOB raw_manifest "${CMAKE_CURRENT_SOURCE_DIR}/${name}/*")
	foreach(chart ${raw_manifest}) # filter out any loose files
		if(IS_DIRECTORY "${chart}")
			list(APPEND manifest "${chart}")
		endif()
	endforeach()
	foreach(chart ${manifest})
		get_filename_component(chart_name "${chart}" NAME)
		message(STATUS "+ ${chart_name}")
		if(NOT EXISTS "${chart}/${chart_name}")
			message(FATAL_ERROR "${chart} does not contain a ${chart_name} subdirectory for chart sourcecs")
		endif()
		if(NOT EXISTS "${chart}/${chart_name}/Chart.yaml")
			message(FATAL_ERROR "${chart}/${chart_name} does not contain a Chart.yaml")
		endif()
		# If the chart file changes it will need to be reparsed to see if the version has changed
		# so inform cmake to rebuild in this case
		set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${chart}/${chart_name}/Chart.yaml")
		# Try to extract the chart version from the top level Chart.yaml
		# This is needed in order to know what output file this chart will become
		file(STRINGS "${chart}/${chart_name}/Chart.yaml" chart_lines)
		unset(chart_version)
		foreach(line ${chart_lines})
			if(line MATCHES "^version: \"?[0-9.]*\"?$")
				string(REGEX REPLACE "^version: \"?([0-9.]*)\"?$" "\\1" chart_version "${line}")
				break()
			endif()
		endforeach()
		if(chart_version)
			message(STATUS "  Chart version: ${chart_version}")
		else()
			message(FATAL_ERROR "Unable to determine chart version")
		endif()
		set(compiled_chart "${CMAKE_BINARY_DIR}/${name}/${chart_name}-${chart_version}.tgz")

		# Collect the names of all files in the chart to use as dependencies for rebuilding it
		file(GLOB_RECURSE chart_files "${chart}/${chart_name}/*")
		list(SORT chart_files)
		set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${chart_files})
		add_custom_command(OUTPUT "${compiled_chart}.hash"
		                   COMMAND cat ${chart_files} > "${compiled_chart}.hash_input"
                                   COMMAND cat ${chart_files} | ${SHASUM_PROGRAM} ${SHASUM_OPTIONS} | awk '{print $$1}' > "${compiled_chart}.hash"
		                   DEPENDS ${chart_files} "${name}_existing_fingerprints")
		list(APPEND repo_hashes "${compiled_chart}.hash")
		add_custom_command(OUTPUT "${compiled_chart}"
		                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/helm_lint_filter "${chart}/${chart_name}"
		                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/check_hash "${existing_fingerprints}" "${compiled_chart}.hash"
		                   COMMAND rm -f "${CMAKE_BINARY_DIR}/${name}/${chart_name}*.tgz"
		                   COMMAND helm package "${chart}/${chart_name}" -d "${CMAKE_BINARY_DIR}/${name}" --home "${helm_dir}"
		                   DEPENDS ${chart_files} ${helm_dir} "${compiled_chart}.hash")
		list(APPEND repo_charts "${compiled_chart}")
	endforeach()

	# Also generate the repository index file
	set(index_file "${CMAKE_BINARY_DIR}/${name}/index.yaml")
	add_custom_command(OUTPUT "${index_file}"
	                   COMMAND helm repo index "${CMAKE_BINARY_DIR}/${name}/" --home "${helm_dir}"
	                   DEPENDS ${repo_charts})
	set(fingerprint_file "${CMAKE_BINARY_DIR}/${name}/fingerprints")
	add_custom_command(OUTPUT "${fingerprint_file}"
	                   COMMAND rm -f "${fingerprint_file}"
	                   COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/compile_fingerprints "${fingerprint_file}" ${repo_hashes}
	                   DEPENDS ${repo_hashes})
	# Build the repository as part of the default target
	add_custom_target("${name}-repo" ALL DEPENDS ${repo_charts} "${index_file}" "${fingerprint_file}")
	# Define publishing the repository
	add_custom_target("publish_${name}" DEPENDS "${name}-repo"
	                  COMMAND mkdir -p "${catalog_path}/${name}"
	                  COMMAND cp "${CMAKE_BINARY_DIR}/${name}/*.tgz" "${catalog_path}/${name}/"
	                  COMMAND cp "${index_file}" "${fingerprint_file}" "${catalog_path}/${name}/")
	# Add publishing this repository as a dependency of the overall publish
	add_dependencies(publish "publish_${name}")
endfunction(add_repository)

list(APPEND repositories
	stable
	incubator
)
foreach(repository_dir ${repositories})
	get_filename_component(repository "${repository_dir}" NAME)
	add_repository("${repository}")
endforeach()
