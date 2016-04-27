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
stoiridh_include("Stoiridh.Qt.Helper" INTERNAL)

####################################################################################################
##  stoiridh_qt_add_plugin(<target> [ALIAS <alias>]                                               ##
##                         SOURCES <source1> [<source2>...]                                       ##
##                         DEPENDS <dependency1> [<dependency2>...]                               ##
##                         [OTHER_FILES <file1> [<file2>...]]                                     ##
##                         [USE_QT_PRIVATE_API])                                                  ##
##                                                                                                ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Add a Qt plugin to the project.                                                               ##
##                                                                                                ##
##  An <alias> can be set to the <target> in order to be linked with an elegant name in others    ##
##  projects.                                                                                     ##
##                                                                                                ##
##  If the OTHER_FILES argument is given, then other files will be added to the target without    ##
##  to be compiled. This option is useful to append some extra files in the project view of an    ##
##  IDE, e.g., QtCreator.                                                                         ##
##                                                                                                ##
##  If the USE_QT_PRIVATE_API option is given, the header files from the Qt's private API will    ##
##  be added to <target>.                                                                         ##
##                                                                                                ##
##  Note: This function is targeting a C++14 compiler and Qt5 API.                                ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_QT_ADD_PLUGIN target)
    set(OPTIONS "USE_QT_PRIVATE_API")
    set(OVK "ALIAS")
    set(MVK "SOURCES" "DEPENDS" "OTHER_FILES")
    cmake_parse_arguments(STOIRIDH_COMMAND "${OPTIONS}" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_DEPENDS "DEPENDS is not specified or is an empty list.")
    stoiridh_assert(STOIRIDH_COMMAND_SOURCES "SOURCES is not specified or is an empty list.")

    set(USER_OPTIONS)

    if(STOIRIDH_COMMAND_USE_QT_PRIVATE_API)
        set(USER_OPTIONS "${USER_OPTIONS}" "USE_QT_PRIVATE_API")
    endif()

    # create the Qt plugin
    stoiridh_qt_helper(MODULE  ${target}
                       SOURCES ${STOIRIDH_COMMAND_SOURCES}
                       DEPENDS ${STOIRIDH_COMMAND_DEPENDS}
                       OTHER_FILES ${STOIRIDH_COMMAND_OTHER_FILES}
                       ${USER_OPTIONS})

    unset(USER_OPTIONS)

    # remove the 'lib' prefix for a Qt5 plugin.
    set_target_properties(${target} PROPERTIES IMPORT_PREFIX "" PREFIX "")

    # make an alias of the library for CMake use, e.g., <PROJECT_NAME>::<SUBPROJECT_NAME>.
    if(STOIRIDH_COMMAND_ALIAS)
        add_library(${STOIRIDH_COMMAND_ALIAS} ALIAS ${target})
    endif()

    # move the module either in the binary or plugins directory according to the Operating System.
    if(STOIRIDH_OS_WINDOWS)
        set(DESTINATION_DIR "${STOIRIDH_INSTALL_BINARY_DIR}")
    elseif(STOIRIDH_OS_LINUX)
        set(DESTINATION_DIR "${STOIRIDH_INSTALL_PLUGINS_DIR}")
    endif()

    set_target_properties(${target} PROPERTIES
                          LIBRARY_OUTPUT_DIRECTORY "${STOIRIDH_INSTALL_ROOT}/${DESTINATION_DIR}")

    # add the install rule.
    install(TARGETS ${target} LIBRARY DESTINATION "${DESTINATION_DIR}")
endfunction()
