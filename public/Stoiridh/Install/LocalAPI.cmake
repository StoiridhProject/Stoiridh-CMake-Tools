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

####################################################################################################
##  stoiridh_install_local_api(HEADERS <header1> [<header2>...]                                   ##
##                             DESTINATION <relative path>                                        ##
##                             [FILE_SUFFIXES <suffix1> [<suffix2>...]]                           ##
##                             [PATH_SUFFIXES <suffix1> [<suffix2>...]]                           ##
##                             [PUBLIC <header1> [<header2>...]]                                  ##
##                             [INTERNAL <header1> [<header2>...]]                                ##
##                             [PRIVATE <header1> [<header2>...]]                                 ##
##                             [VERSION <version>])                                               ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Install a local copy of the API to the relative destination at the STOIRIDH_INSTALL_ROOT      ##
##  absolute path.                                                                                ##
##                                                                                                ##
##  The HEADERS argument corresponds to a list of header files. Those files will be at the root   ##
##  of the destination path. Any subdirectories containing in the - absolute path - of an header  ##
##  file will be kept.                                                                            ##
##                                                                                                ##
##  The FILE_SUFFIXES argument may be added to replace the default file suffixes. The default     ##
##  file suffixes are .h, .hpp, .hxx, .inl, and .tpp. Also note, the *.* before the file suffix   ##
##  is important.                                                                                 ##
##                                                                                                ##
##  The PATH_SUFFIXES argument corresponds to a list of relative paths where this function will   ##
##  concatenate with the CMAKE_CURRENT_LIST_DIR variable in order to avoid the keep those paths   ##
##  during copying of the header files.                                                           ##
##                                                                                                ##
##  The PUBLIC, INERNAL, and PRIVATE optional arguments correspond to a list of header files      ##
##  that will be copied at the root of the destination path following by an optional version      ##
##  directory and a public, internal, and private directory, respectively.                        ##
##                                                                                                ##
##  Note: Any subdirectories provided by any header files will be kept.                           ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_INSTALL_LOCAL_API)
    stoiridh_include("Stoiridh.Utility.Header" INTERNAL)

    set(OVK "DESTINATION" "VERSION")
    set(MVK "HEADERS" "PUBLIC" "INTERNAL" "PRIVATE" "FILE_SUFFIXES" "PATH_SUFFIXES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_DESTINATION "DESTINATION is not specified or is empty.")
    stoiridh_assert(STOIRIDH_COMMAND_HEADERS "HEADERS is not specified or is an empty list.")

    if(NOT STOIRIDH_COMMAND_FILE_SUFFIXES)
        set(HEADER_SUFFIXES ".h;.hpp;.hxx;.inl;.tpp")
    else()
        set(HEADER_SUFFIXES "${STOIRIDH_COMMAND_FILE_SUFFIXES}")
    endif()

    if(NOT STOIRIDH_INSTALL_ROOT)
        message(WARNING "stoiridh_install_local_api: No STOIRIDH_INSTALL_ROOT set within the cache.
            Either set manually the variable with CMake or call stoiridh_project_initialise()
            function at the top-level of your project.")
        return()
    endif()

    set(INCLUDE_ROOT_PATH
        "${STOIRIDH_INSTALL_ROOT}/${STOIRIDH_INSTALL_INCLUDE_DIR}/${STOIRIDH_COMMAND_DESTINATION}")

    # copy HEADERS into INCLUDE_ROOT_PATH
    stoiridh_utility_header(COPY
                            HEADERS ${STOIRIDH_COMMAND_HEADERS}
                            DESTINATION ${INCLUDE_ROOT_PATH}
                            PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES})

    # override the INCLUDE_ROOT_PATH variable in order to add both the VERSION and the DESTINATION
    # directories. This change allows to install the public, internal, and private API in there.
    set(INCLUDE_ROOT_PATH
        "${INCLUDE_ROOT_PATH}/${STOIRIDH_COMMAND_VERSION}/${STOIRIDH_COMMAND_DESTINATION}")

    # filter the following commands in order to retrieve only the header files
    if(STOIRIDH_COMMAND_PUBLIC)
        set(PUBLIC_INCLUDE_PATH "${INCLUDE_ROOT_PATH}/public")
        stoiridh_utility_header(FILTER_COPY
                                HEADERS ${STOIRIDH_COMMAND_PUBLIC}
                                HEADER_SUFFIXES ${HEADER_SUFFIXES}
                                PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES}
                                DESTINATION ${PUBLIC_INCLUDE_PATH})
    endif()

    if(STOIRIDH_COMMAND_INTERNAL)
        set(INTERNAL_INCLUDE_PATH "${INCLUDE_ROOT_PATH}/internal")
        stoiridh_utility_header(FILTER_COPY
                                HEADERS ${STOIRIDH_COMMAND_INTERNAL}
                                HEADER_SUFFIXES ${HEADER_SUFFIXES}
                                PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES}
                                DESTINATION ${INTERNAL_INCLUDE_PATH})
    endif()

    if(STOIRIDH_COMMAND_PRIVATE)
        set(PRIVATE_INCLUDE_PATH "${INCLUDE_ROOT_PATH}/private")
        stoiridh_utility_header(FILTER_COPY
                                HEADERS ${STOIRIDH_COMMAND_PRIVATE}
                                HEADER_SUFFIXES ${HEADER_SUFFIXES}
                                PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES}
                                DESTINATION ${PRIVATE_INCLUDE_PATH})
    endif()
endfunction()
