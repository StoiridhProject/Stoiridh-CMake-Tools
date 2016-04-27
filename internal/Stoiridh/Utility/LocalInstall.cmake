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
##  stoiridh_utility_local_install(FILES <file1> [<file2>...]                                     ##
##                                 DESTINATION <absolute path>                                    ##
##                                 [PATH_SUFFIXES <suffix1> [<suffix2>...]])                      ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Install a local copy of the files in the destination path.                                    ##
##                                                                                                ##
##  The PATH_SUFFIXES argument corresponds to a list of relative paths where this function will   ##
##  concatenate with the CMAKE_CURRENT_LIST_DIR variable in order to avoid the keep those paths   ##
##  during copying of the header files.                                                           ##
##                                                                                                ##
####################################################################################################
function(STOIRIDH_UTILITY_LOCAL_INSTALL)
    set(OVK "DESTINATION")
    set(MVK "FILES" "PATH_SUFFIXES")
    cmake_parse_arguments(STOIRIDH_COMMAND "" "${OVK}" "${MVK}" ${ARGN})

    # preconditions
    stoiridh_assert(STOIRIDH_COMMAND_DESTINATION "DESTINATION is not specified or is empty.")
    stoiridh_assert(STOIRIDH_COMMAND_FILES "FILES is not specified or is an empty list.")

    foreach(FILE ${STOIRIDH_COMMAND_FILES})
        get_filename_component(FILE_PATH ${FILE} DIRECTORY)

        if(STOIRIDH_COMMAND_PATH_SUFFIXES)
            foreach(PATH_SUFFIX ${STOIRIDH_COMMAND_PATH_SUFFIXES})
                set(PATH "${CMAKE_CURRENT_LIST_DIR}/${PATH_SUFFIX}")
                string(FIND ${FILE_PATH} ${PATH} RESULT)
                if(RESULT EQUAL 0 OR RESULT GREATER 0)
                    __get_relative_path(RELATIVE_FILE_PATH ${PATH} ${FILE} PATH_ONLY)
                    set(OUTPUT_PATH "${STOIRIDH_COMMAND_DESTINATION}/${RELATIVE_FILE_PATH}")
                    file(COPY ${FILE} DESTINATION ${OUTPUT_PATH})
                    set(FOUND TRUE)
                    break()
                endif()
            endforeach()
        endif()

        if(NOT FOUND)
            set(PATH "${CMAKE_CURRENT_LIST_DIR}")
            __get_relative_path(RELATIVE_FILE_PATH ${PATH} ${FILE} PATH_ONLY)
            set(OUTPUT_PATH "${STOIRIDH_COMMAND_DESTINATION}/${RELATIVE_FILE_PATH}")
            file(COPY ${FILE} DESTINATION ${OUTPUT_PATH})
        endif()
        unset(FOUND)
    endforeach()
endfunction()
####################################################################################################
########################################  PRIVATE FUNCTIONS  #######################################
####################################################################################################
##  __get_relative_path(<output> <base_dir> <file> [PATH_ONLY])                                   ##
##------------------------------------------------------------------------------------------------##
##                                                                                                ##
##  Retrieve the relative path of a <file> from a <base_dir> - an absolute path - and set the     ##
##  result into the <output> variable.                                                            ##
##                                                                                                ##
##  If the PATH_ONLY option is specified the relative path without the filename will be returned  ##
##  into the <output> variable.                                                                   ##
##                                                                                                ##
####################################################################################################
function(__GET_RELATIVE_PATH output base_dir file)
    set(OPTIONS "PATH_ONLY")
    cmake_parse_arguments(STOIRIDH_COMMAND "${OPTIONS}" "" "" ${ARGN})

    file(RELATIVE_PATH RELATIVE_FILE ${base_dir} ${file})

    if(STOIRIDH_COMMAND_PATH_ONLY)
        file(TO_CMAKE_PATH ${RELATIVE_FILE} RELATIVE_FILE)
        get_filename_component(RELATIVE_PATH ${RELATIVE_FILE} DIRECTORY)
        set(${output} ${RELATIVE_PATH} PARENT_SCOPE)
    else()
        set(${output} ${RELATIVE_FILE} PARENT_SCOPE)
    endif()
endfunction()
