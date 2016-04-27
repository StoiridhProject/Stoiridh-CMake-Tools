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
##  stoiridh_qt_qml_add_module(<target>                                                           ##
##                             URI <uri>                                                          ##
##                             SOURCES <source1> [<source2>...]                                   ##
##                             [OTHER_FILES <file1> [<file2>...]]                                 ##
##                             [PATH_SUFFIXES <suffix1> [<suffix2>...]])                          ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Add a QtQml module to the project using the specified sources.                                ##
##                                                                                                ##
##  The URI argument is an identifier (URI dotted notation) for the module, which must match the  ##
##  module's install path.                                                                        ##
##                                                                                                ##
##  The PATH_SUFFIXES argument corresponds to a list of relative paths where this function will   ##
##  concatenate with the CMAKE_CURRENT_LIST_DIR variable in order to avoid the keep those paths   ##
##  during copying of the header files.                                                           ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_QT_QML_ADD_MODULE target)
    set(OVK "URI")
    set(MVK "OTHER_FILES" "PATH_SUFFIXES" "SOURCES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_SOURCES "SOURCES is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_URI "URI is not specified or is empty.")

    string(REPLACE "." "/" MODULE_NAME ${STOIRIDH_COMMAND_URI})
    set(INSTALL_ROOT_DIR "${STOIRIDH_INSTALL_ROOT}/${STOIRIDH_INSTALL_QML_DIR}/${MODULE_NAME}")

    stoiridh_utility_local_install(FILES ${STOIRIDH_COMMAND_SOURCES}
                                   DESTINATION ${INSTALL_ROOT_DIR}
                                   PATH_SUFFIXES ${STOIRIDH_COMMAND_PATH_SUFFIXES})

    if(STOIRIDH_COMMAND_OTHER_FILES)
        add_custom_target("${target}_OTHER_FILES"
                          SOURCES ${STOIRIDH_COMMAND_SOURCES} ${STOIRIDH_COMMAND_OTHER_FILES})
    endif()
endfunction()
