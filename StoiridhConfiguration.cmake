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
include("${STOIRIDH_CONFIGURATION_ROOT}/internal/configuration.cmake")

####################################################################################################
##  stoiridh_project_initialise()                                                                 ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Initialise the cache and the common options used by the Stòiridh Project.                     ##
##                                                                                                ##
##  Note: This function must be set at the top-level of the project.                              ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_PROJECT_INITIALISE)
    _stoiridh_project_initialise_options()
    _stoiridh_project_initialise_cache()

    # Operating System detection
    if(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(STOIRIDH_OS_WINDOWS YES CACHE INTERNAL "Operating system")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        set(STOIRIDH_OS_LINUX YES CACHE INTERNAL "Operating system")
    endif()
endfunction()
####################################################################################################
##  stoiridh_include(<module name> [INTERNAL])                                                    ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Load and run CMake code from the specified <module name> file.                                ##
##                                                                                                ##
##  A module is coumpound of the following form: <namespace>.<module_name>. The namespace         ##
##  corresponds to the path where the module is located with a dotted URI notation and the        ##
##  <module name> corresponds to the CMake file without the .cmake suffix.                        ##
##                                                                                                ##
##  If the INTERNAL option is specified, the module will be search in the internal path of the    ##
##  STOIRIDH_CONFIGURATION_ROOT variable, otherwise, in the public path.                          ##
##                                                                                                ##
##  Example:                                                                                      ##
##      stoiridh_include("Stoiridh.Qt.Application")                                               ##
##      is equivalent to                                                                          ##
##      include("${STOIRIDH_CONFIGURATION_ROOT}/public/Stoiridh/Qt/Application.cmake")            ##
##                                                                                                ##
##  Note: The STOIRIDH_CONFIGURATION_ROOT variable must be set - ideally at the top-level of the  ##
##        project - before using this function.                                                   ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_INCLUDE module_name)
    set(OPTIONS "INTERNAL")
    cmake_parse_arguments(STOIRIDH_COMMAND "${OPTIONS}" "" "" ${ARGN})

    # replace dots by CMake path separators.
    string(REPLACE "." "/" MODULE_NAME_NORMALISED ${module_name})

    if(NOT STOIRIDH_CONFIGURATION_ROOT)
        message(FATAL_ERROR "STOIRIDH_CONFIGURATION_ROOT is not set.")
    endif()

    set(MODULE "${STOIRIDH_CONFIGURATION_ROOT}")

    if(STOIRIDH_COMMAND_INTERNAL)
        set(MODULE "${MODULE}/internal")
    else()
        set(MODULE "${MODULE}/public")
    endif()

    set(MODULE "${MODULE}/${MODULE_NAME_NORMALISED}")

    if(NOT module_name MATCHES "[A-Za-z0-9_]+.cmake")
        set(MODULE "${MODULE}.cmake")
    endif()

    include(${MODULE})
    unset(MODULE)
endfunction()
