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
include(CMakeDependentOption)

####################################################################################################
##  _stoiridh_project_initialise_options()                                                        ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Initialises the CMake common options used by the Stòiridh Project.                            ##
##                                                                                                ##
####################################################################################################
function(_STOIRIDH_PROJECT_INITIALISE_OPTIONS)
    # documentation and examples options
    option(STOIRIDH_PROJECT_DOCUMENTATION_ENABLE "Build the documentation projects." ON)
    option(STOIRIDH_PROJECT_EXAMPLES_ENABLE "Build the examples projects." ON)

    # testing options
    option(STOIRIDH_PROJECT_TESTING_ENABLE "Build the unit testing projects" ON)
    cmake_dependent_option(STOIRIDH_PROJECT_TESTING_ENABLE_INTERNAL
        "Build the internal unit testing projects." ON
        "STOIRIDH_PROJECT_TESTING_ENABLE" OFF)
    cmake_dependent_option(STOIRIDH_PROJECT_TESTING_ENABLE_AUTOTESTS
        "Build the autotests projects." ON
        "STOIRIDH_PROJECT_TESTING_ENABLE" OFF)
endfunction()

####################################################################################################
##  _stoiridh_project_initialise_cache()                                                          ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Initialise CMake - advanced - variables used by the Stòiridh Project to the CMake cache.      ##
##                                                                                                ##
####################################################################################################
function(_STOIRIDH_PROJECT_INITIALISE_CACHE)
    set(STOIRIDH_INSTALL_ROOT_DIR "install-root" CACHE STRING "Install root directory")
    set(STOIRIDH_INSTALL_ROOT "${CMAKE_BINARY_DIR}/${STOIRIDH_INSTALL_ROOT_DIR}" CACHE PATH
        "The install root path where binaries, libraries, and other files will be copied.")

    # project name
    if(NOT STOIRIDH_PROJECT_NAME)
        set(STOIRIDH_PROJECT_NAME "${PROJECT_NAME}" CACHE STRING "Project name")
    else()
        set(STOIRIDH_PROJECT_NAME "${STOIRIDH_PROJECT_NAME}"
            CACHE STRING "Project name (User defined)")
    endif()

    # install directories hierarchy
    set(STOIRIDH_INSTALL_BINARY_DIR "bin" CACHE STRING "Binary directory")
    set(STOIRIDH_INSTALL_LIBRARY_DIR "lib" CACHE STRING "Library directory")
    set(STOIRIDH_INSTALL_INCLUDE_DIR "include" CACHE STRING "Include directory")
    set(STOIRIDH_INSTALL_PLUGINS_DIR
        "${STOIRIDH_INSTALL_LIBRARY_DIR}/${STOIRIDH_PROJECT_NAME}/plugins"
        CACHE STRING "Plugins directory")
    set(STOIRIDH_INSTALL_QML_DIR "${STOIRIDH_INSTALL_LIBRARY_DIR}/${STOIRIDH_PROJECT_NAME}/qml"
        CACHE STRING "QML directory")
    set(STOIRIDH_INSTALL_SHARE_DIR "share" CACHE STRING "Share directory")
    set(STOIRIDH_INSTALL_DOC_DIR "${STOIRIDH_INSTALL_SHARE_DIR}/doc/${STOIRIDH_PROJECT_NAME}"
        CACHE STRING "Documentation directory")

    mark_as_advanced(STOIRIDH_INSTALL_ROOT_DIR    STOIRIDH_INSTALL_ROOT
                     STOIRIDH_INSTALL_BINARY_DIR  STOIRIDH_INSTALL_LIBRARY_DIR
                     STOIRIDH_INSTALL_INCLUDE_DIR STOIRIDH_INSTALL_PLUGINS_DIR
                     STOIRIDH_INSTALL_QML_DIR     STOIRIDH_INSTALL_SHARE_DIR
                     STOIRIDH_INSTALL_DOC_DIR)
endfunction()
