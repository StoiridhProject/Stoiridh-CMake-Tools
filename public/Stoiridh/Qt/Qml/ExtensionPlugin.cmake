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
stoiridh_include("Stoiridh.Qt.Qml.Module")
stoiridh_include("Stoiridh.Assert" INTERNAL)
stoiridh_include("Stoiridh.Qt.Helper" INTERNAL)

####################################################################################################
##  stoiridh_qt_qml_add_module(<target> [ALIAS <alias>]                                           ##
##                             URI <uri>                                                          ##
##                             SOURCES <source1> [<source2>...]                                   ##
##                             QML_SOURCES <source1> [<source2>...]                               ##
##                             DEPENDS <dependency1> [<dependency2>...]                           ##
##                             [QML_PATH_SUFFIXES <suffix1> [<suffix2>...]])                      ##
##                             [OTHER_FILES <file1> [<file2>...]]                                 ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Add a QtQml extension plugin to the project using the specified sources and Qml sources.      ##
##                                                                                                ##
##  An <alias> can be set to the <target> in order to be linked with an elegant name in others    ##
##  projects.                                                                                     ##
##                                                                                                ##
##  The URI argument is an identifier (URI dotted notation) for the module, which must match the  ##
##  module's install path.                                                                        ##
##                                                                                                ##
##  The QML_PATH_SUFFIXES argument corresponds to a list of relative paths where this function    ##
##  will concatenate with the CMAKE_CURRENT_LIST_DIR variable in order to avoid the keep those    ##
##  paths during copying of the header files.                                                     ##
##                                                                                                ##
##  If the OTHER_FILES argument is specified, then the other files will be added to the target    ##
##  without to be compiled. This option is useful to append some extra files in the project view  ##
##  of an IDE, e.g., QtCreator.                                                                   ##
##                                                                                                ##
##  Note: This function is targeting a C++14 compiler and Qt5 API.                                ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_QT_QML_ADD_EXTENSION_PLUGIN target)
    set(OVK "ALIAS" "URI")
    set(MVK "DEPENDS" "QML_PATH_SUFFIXES" "QML_SOURCES" "SOURCES" "OTHER_FILES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_DEPENDS "DEPENDS is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_QML_SOURCES "QML_SOURCES is not specified or is an"
                                                 "empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_SOURCES "SOURCES is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_URI "URI is not specified or is empty.")

    # a QtQml extension plugin is inherently a QtQml module.
    stoiridh_qt_qml_add_module(${target}
                               URI ${STOIRIDH_COMMAND_URI}
                               SOURCES ${STOIRIDH_COMMAND_QML_SOURCES}
                               OTHER_FILES ${STOIRIDH_COMMAND_OTHER_FILES}
                               PATH_SUFFIXES ${STOIRIDH_COMMAND_QML_PATH_SUFFIXES})

    # create the shared library
    stoiridh_qt_helper(MODULE ${target}
                       SOURCES ${STOIRIDH_COMMAND_SOURCES}
                       DEPENDS ${STOIRIDH_COMMAND_DEPENDS})

    # remove the 'lib' prefix for QtQml plugin.
    set_target_properties(${target} PROPERTIES IMPORT_PREFIX "" PREFIX "")

    # move the plugin in the 'qml' directory of the project.
    string(REPLACE "." "/" MODULE_NAME ${STOIRIDH_COMMAND_URI})
    set(DESTINATION_DIR "${STOIRIDH_INSTALL_QML_DIR}/${MODULE_NAME}")

    set_target_properties(${target} PROPERTIES
                          LIBRARY_OUTPUT_DIRECTORY "${STOIRIDH_INSTALL_ROOT}/${DESTINATION_DIR}")

    # make an alias of the library for CMake use, e.g., <PROJECT_NAME>::<SUBPROJECT_NAME>.
    if(STOIRIDH_COMMAND_ALIAS)
        add_library(${STOIRIDH_COMMAND_ALIAS} ALIAS ${target})
    endif()

    # add the install rule.
    install(TARGETS ${target} LIBRARY DESTINATION "${DESTINATION_DIR}")
endfunction()
