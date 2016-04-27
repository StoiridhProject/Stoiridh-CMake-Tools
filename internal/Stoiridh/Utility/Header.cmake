####################################################################################################
##                                                                                                ##
##            Copyright (C) 2016 William McKIE                                                    ##
##                                                                                                ##
##            This program is free software: you can redistribute it and/or modify                ##
##            it under the terms of the GNU General Public License as published by                ##
##            the Free Software Foundation, either version 3 of the License, or                   ##
##            (at your option) any later version.                                                 ##
##                                                                                                ##
##            This program is distributed in the hope that it will be useful,                     ##
##            but WITHOUT ANY WARRANTY; without even the implied warranty of                      ##
##            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                       ##
##            GNU General Public License for more details.                                        ##
##                                                                                                ##
##            You should have received a copy of the GNU General Public License                   ##
##            along with this program.  If not, see <http://www.gnu.org/licenses/>.               ##
##                                                                                                ##
####################################################################################################
stoiridh_include("Stoiridh.Assert" INTERNAL)
stoiridh_include("Stoiridh.Utility.LocalInstall" INTERNAL)

####################################################################################################
##  stoiridh_utility_header(COPY                                                                  ##
##                          HEADERS <header1> [<header2>...]                                      ##
##                          DESTINATION <destination>                                             ##
##                          [PATH_SUFFIXES <suffix1> [<suffix2>...]])                             ##
##                                                                                                ##
##  stoiridh_utility_header(FILTER <output>                                                       ##
##                          HEADERS <header1> [<header2>...]                                      ##
##                          SUFFIXES <suffix1> [<suffix2>...])                                    ##
##                                                                                                ##
##  stoiridh_utility_header(FILTER_COPY                                                           ##
##                          HEADERS <header1> [<header2>...]                                      ##
##                          HEADER_SUFFIXES <suffix1> [<suffix2>...]                              ##
##                          DESTINATION <absolute path>                                           ##
##                          [PATH_SUFFIXES <suffix1> [<suffix2>...]])                             ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  The COPY command copies the header files from the HEADERS list to the DESTINATION path.       ##
##                                                                                                ##
##  The PATH_SUFFIXES argument corresponds to a list of relative paths where this function will   ##
##  concatenate with the CMAKE_CURRENT_LIST_DIR variable in order to avoid the keep those paths   ##
##  during copying of the header files.                                                           ##
##                                                                                                ##
##                                    ========================                                    ##
##                                                                                                ##
##  The FILTER command filters the given HEADERS with the given SUFFIXES and put the result of    ##
##  the filtering into the <output> variable.                                                     ##
##                                                                                                ##
##  The SUFFIXES argument corresponds to a list of file suffix of the HEADERS. If a suffix        ##
##  matches for a given header in the given HEADERS list, then the header will be append to the   ##
##  <output>.                                                                                     ##
##                                                                                                ##
##                                    ========================                                    ##
##                                                                                                ##
##  The FILTER_COPY command is a combination of both COPY and FILTER commands. See above, the     ##
##  COPY and FILTER descriptions, respectively.                                                   ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_UTILITY_HEADER command)
    set(COMMANDS "COPY" "FILTER" "FILTER_COPY")
    set(OVK "DESTINATION")
    set(MVK "HEADERS" "PATH_SUFFIXES" "SUFFIXES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    if(NOT command IN_LIST COMMANDS)
        message(FATAL_ERROR "stoiridh_utility_header(${command}): invalid command.")
    endif()

    if(command STREQUAL "COPY")
        stoiridh_utility_local_install(FILES ${STOIRIDH_COMMAND_HEADERS}
                                       DESTINATION ${STOIRIDH_COMMAND_DESTINATION}
                                       PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES})
    elseif(command STREQUAL "FILTER")
        _stoiridh_utility_header_filter(FILTER_OUTPUT
                                        HEADERS ${STOIRIDH_COMMAND_HEADERS}
                                        SUFFIXES ${STOIRIDH_COMMAND_SUFFIXES})
        set(${ARGV1} ${FILTER_OUTPUT} PARENT_SCOPE)
    elseif(command STREQUAL "FILTER_COPY")
        _stoiridh_utility_header_filter_copy(HEADERS ${STOIRIDH_COMMAND_HEADERS}
                                             HEADER_SUFFIXES ${STOIRIDH_COMMAND_SUFFIXES}
                                             PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES}
                                             DESTINATION ${STOIRIDH_COMMAND_DESTINATION})
    endif()
endfunction()
####################################################################################################
########################################  PRIVATE FUNCTIONS  #######################################
####################################################################################################
##  _stoiridh_utility_header_filter(<output>                                                      ##
##                                  HEADERS <header1> [<header2>...]                              ##
##                                  SUFFIXES <suffix1> [<suffix2>...])                            ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  This is a helper function for the stoiridh_utility_header() function.                         ##
##                                                                                                ##
####################################################################################################
function(_STOIRIDH_UTILITY_HEADER_FILTER output)
    set(MVK "HEADERS" "SUFFIXES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_HEADERS "HEADERS is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_SUFFIXES "SUFFIXES is not specified or is an empty list.")

    foreach(HEADER ${STOIRIDH_COMMAND_HEADERS})
        get_filename_component(HEADER_SUFFIX ${HEADER} EXT)
        if(HEADER_SUFFIX IN_LIST STOIRIDH_COMMAND_SUFFIXES)
            list(APPEND HEADERS_LIST ${HEADER})
        endif()
    endforeach()

    if(HEADERS_LIST)
        list(REMOVE_DUPLICATES HEADERS_LIST)
        set(${output} ${HEADERS_LIST} PARENT_SCOPE)
    endif()
endfunction()
####################################################################################################
##  _stoiridh_utility_header_filter_copy(HEADERS <header1> [<header2>...]                         ##
##                                       HEADER_SUFFIXES <suffix1> [<suffix2>...]                 ##
##                                       DESTINATION <absolute path>                              ##
##                                       [PATH_SUFFIXES <suffix1> [<suffix2>...]])                ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  This is a helper function for the stoiridh_utility_header() function. It combines both COPY   ##
##  and FILTER command.                                                                           ##
##                                                                                                ##
####################################################################################################
function(_STOIRIDH_UTILITY_HEADER_FILTER_COPY)
    set(OVK "DESTINATION")
    set(MVK "HEADERS" "HEADER_SUFFIXES" "PATH_SUFFIXES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_HEADERS "HEADERS is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_HEADER_SUFFIXES "HEADER_SUFFIXES is not specified or is an "
                                                     "empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_DESTINATION "DESTINATION is not specified or is empty.")

    stoiridh_utility_header(FILTER
                            HEADERS ${STOIRIDH_COMMAND_HEADERS}
                            SUFFIXES ${STOIRIDH_COMMAND_HEADER_SUFFIXES})
    stoiridh_utility_header(COPY
                            HEADERS ${HEADERS}
                            DESTINATION ${STOIRIDH_COMMAND_DESTINATION}
                            PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES})
endfunction()
