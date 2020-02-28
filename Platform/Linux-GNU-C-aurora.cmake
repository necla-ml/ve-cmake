show_cmake_stuff("After default C compiler detection as Linux-GNU ...")
message(STATUS "Linux-GNU-C-aurora patches HERE : ${CMAKE_CURRENT_LIST_FILE}")
message(STATUS "  CMAKE_C_COMPILER              : ${CMAKE_C_COMPILER}")
message(STATUS "  CMAKE_C_COMPILER_ID           : ${CMAKE_C_COMPILER_ID}")

#nc++:   does not support -fvisibility= or -fvisibility-inlines-hidden
unset(CMAKE_C_COMPILE_OPTIONS_VISIBILITY)
unset(CMAKE_C_COMPILE_OPTIONS_VISIBILITY_INLINES_HIDDEN)

set(CMAKE_C_FLAGS_RELEASE_INIT "${CMAKE_C_FLAGS_RELEASE_INIT} -mretain-list-vector")
set(CMAKE_C_FLAGS_DEBUG_INIT "${CMAKE_C_FLAGS_DEBUG_INIT} -g2 -mretain-list-vector -O0")
set(CMAKE_C_FLAGS_RELWITHDEBINFO_INIT "${CMAKE_C_FLAGS_RELWITHDEBINFO_INIT} -g2 -mretain-list-vector")
# -Os is not supported
set(CMAKE_C_FLAGS_MINSIZEREL_INIT CMAKE_C_FLAGS_RELEASE_INIT)

# UnixPaths.cmake adds these host-only locations:
# ... so we'll remove them and use some VE paths ...
list(INSERT CMAKE_SYSTEM_PREFIX_PATH 0 ${VE_OPT} ${NLC_HOME})
list(REMOVE_DUPLICATES CMAKE_SYSTEM_PREFIX_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_LIBRARY_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_INCLUDE_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_PROGRAM_PATH)
list(REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH /usr/local /usr /usr/X11R6 /usr/pkg /opt /)
list(REMOVE_ITEM CMAKE_SYSTEM_INCLUDE_PATH /usr/include/X11)
list(REMOVE_ITEM CMAKE_SYSTEM_LIBRARY_PATH /usr/lib/X11)

set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB32_PATHS FALSE)
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS FALSE)
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIBX32_PATHS FALSE)
# expose cross compiler system paths to cmake
# This is now run during ve.cmake (very early)
#DETERMINE_NCC_SYSTEM_INCLUDES_DIRS(${CMAKE_C_COMPILER} "-pthread" VE_C_SYSINC VE_C_PREINC)
message(STATUS "  C pre-inc dirs  : ${VE_C_PREINC}")
message(STATUS "  C sys-inc dirs  : ${VE_C_SYSINC}")
message(STATUS "  CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")
unset(CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES)
list(REMOVE_ITEM CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES /usr/include)
list(INSERT CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES 0 "${VE_C_PREINC}")
list(APPEND CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES ${VE_C_SYSINC})
list(REMOVE_ITEM CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES /usr/include)
list(REMOVE_DUPLICATES CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES)
#list(APPEND CMAKE_SYSTEM_PREFIX_PATH /usr/X11R6 /usr/pkg /opt )
#list(APPEND CMAKE_SYSTEM_INCLUDE_PATH /usr/include/X11 )
#list(APPEND CMAKE_SYSTEM_LIBRARY_PATH /usr/lib/X11 )       
message(STATUS "  CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES -> ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES}")

VE_PARANOID_RPATH() # main output is VE_LINK_RPATH cache string
# also tries to set CMAKE_INSTALL_RPATH, and other CMAKE.*RPATH variables

# the following **DO** influence executables and libraries
# remove -Wl,-origin for ncc ?
# added rpath-link to compiler/lib dir ?
#       (but this SHOULD be in the RUNPATH of libmkldnn.so already!)
# (cmake might still be missing some COMPILER library info)
#
#  Note: nld has messages about not respecting ORIGIN in rpath.
#  This might explain some of the ugly link paths here ...
set(CMAKE_C_LINK_FLAGS "-Dcmake_c_link_flags ${CMAKE_C_LINK_FLAGS} -v -Wl,-origin -Wl,-rpath,$ORIGIN/../lib")
# very ugly!
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} -Wl,-rpath-link,${VE_C_ROOTDIR}/lib")
set(CMAKE_C_LINK_FLAGS "${CMAKE_C_LINK_FLAGS} ${VE_LINK_RPATH}")

set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-Dcmake_shared_library_create_c_flags ${CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS} ${VE_LINK_RPATH}")

show_cmake_stuff("End of Platform/Linux-GNU-C-aurora.cmake")
# vim: et ts=4 sw=4 ai
