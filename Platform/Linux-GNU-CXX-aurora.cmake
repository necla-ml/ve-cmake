show_cmake_stuff("After default CXX compiler detection as Linux-GNU ...")
message(STATUS "Linux-GNU-CXX-aurora patches HERE : ${CMAKE_CURRENT_LIST_FILE}")
message(STATUS "  CMAKE_CXX_COMPILER              : ${CMAKE_CXX_COMPILER}")
message(STATUS "  CMAKE_CXX_COMPILER_ID           : ${CMAKE_CXX_COMPILER_ID}")


#nc++:   does not support -fvisibility= or -fvisibility-inlines-hidden
unset(CMAKE_CXX_COMPILE_OPTIONS_VISIBILITY)
unset(CMAKE_CXX_COMPILE_OPTIONS_VISIBILITY_INLINES_HIDDEN)

# -Os is not supported
set(CMAKE_CXX_FLAGS_RELEASE_INIT "${CMAKE_CXX_FLAGS_RELEASE_INIT} -mretain-list-vector")
set(CMAKE_CXX_FLAGS_DEBUG_INIT "${CMAKE_CXX_FLAGS_DEBUG_INIT} -g2 -mretain-list-vector -O0")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT "${CMAKE_CXX_FLAGS_RELWITHDEBINFO_INIT} -g2 -mretain-list-vector")
set(CMAKE_CXX_FLAGS_MINSIZEREL_INIT CMAKE_CXX_FLAGS_RELEASE_INIT)

# UnixPaths.cmake adds these host-only locations:
#  get_filename_component(_CMAKE_INSTALL_DIR ${_CMAKE_INSTALL_DIR} PATH )
#  list(APPEND CMAKE_SYSTEM_PREFIX_PATH /usr/local /usr / ${_CMAKE_INSTALL_DIR} )
#  if(NOT CMAKE_FIND_NO_INSTALL_PREFIX )
#  list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_INSTALL_PREFIX} )
#  if(CMAKE_STAGING_PREFIX )
#  list(APPEND CMAKE_SYSTEM_PREFIX_PATH /usr/X11R6 /usr/pkg /opt )
#  list(APPEND CMAKE_SYSTEM_INCLUDE_PATH /usr/include/X11 )
#  list(APPEND CMAKE_SYSTEM_LIBRARY_PATH /usr/lib/X11 )
#  list(APPEND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES /lib /lib32 /lib64 /usr/lib /usr/lib32 /usr/lib64 )
#  list(APPEND CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES /usr/include )
#  list(APPEND CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES /usr/include )
#  list(APPEND CMAKE_CUDA_IMPLICIT_INCLUDE_DIRECTORIES /usr/include )
# ... so we'll remove them and use some VE paths ...
list(INSERT CMAKE_SYSTEM_PREFIX_PATH 0 ${VE_OPT} ${NLC_HOME})
list(REMOVE_DUPLICATES CMAKE_SYSTEM_PREFIX_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_LIBRARY_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_INCLUDE_PATH)
list(REMOVE_DUPLICATES CMAKE_SYSTEM_PROGRAM_PATH)
list(REMOVE_ITEM CMAKE_SYSTEM_PREFIX_PATH /usr/local /usr /usr/X11R6 /usr/pkg /opt /)
list(REMOVE_ITEM CMAKE_SYSTEM_INCLUDE_PATH /usr/include/X11)
list(REMOVE_ITEM CMAKE_SYSTEM_LIBRARY_PATH /usr/lib/X11)
#
# ..IMPLICIT_LINK.. variables are used to *filter* out some paths that the system
#                   automatically includes.  This needs some tweaking for ncc/nc++
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB32_PATHS FALSE)
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS FALSE)
set_property(GLOBAL PROPERTY FIND_LIBRARY_USE_LIBX32_PATHS FALSE)
# expose cross compiler system paths to cmake
# This is now run during ve.cmake (very early)
#DETERMINE_NCC_SYSTEM_INCLUDES_DIRS(${CMAKE_CXX_COMPILER} "-pthread" VE_CXX_SYSINC VE_CXX_PREINC)
message(STATUS "  CXX pre-inc dirs  : ${VE_CXX_PREINC}")
message(STATUS "  CXX sys-inc dirs  : ${VE_CXX_SYSINC}")
message(STATUS "  CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")
unset(CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES) # /lib /lib32 /lib64 /usr/lib /usr/lib32 /usr/lib64
list(REMOVE_ITEM CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES /usr/include)
#list(REMOVE_ITEM CMAKE_CUDA_IMPLICIT_INCLUDE_DIRECTORIES /usr/include)
list(INSERT CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES 0 "${VE_CXX_PREINC}")
list(APPEND CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES "${VE_CXX_SYSINC}")
list(REMOVE_ITEM CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES "/usr/include")
list(REMOVE_DUPLICATES CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES)
message(STATUS "  CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES -> ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES}")

# help debug library linking and RPATH stuff {perhaps paranoid]
#set(CMAKE_CXX_LINK_FLAGS "-v -Wl,--verbose -Wl,-z,origin")
VE_PARANOID_RPATH()

#set(CMAKE_CXX_LINK_FLAGS "-Dcmake_cxx_link_flags ${CMAKE_CXX_LINK_FLAGS} -v -Wl,-origin -Wl,-rpath,$ORIGIN/../lib ${VE_LINK_RPATH}")
# the following **DO** influence executables and libraries
# remove -Wl,-origin for ncc ?
# added rpath-link to compiler/lib dir ?
#       (but this SHOULD be in the RUNPATH of libmkldnn.so already!)
# (cmake might still be missing some COMPILER library info)
#
#  Note: nld has messages about not respecting ORIGIN in rpath.
#  This might explain some of the ugly link paths here ...
set(CMAKE_CXX_LINK_FLAGS "-Dcmake_c_link_flags ${CMAKE_CXX_LINK_FLAGS} -v -Wl,-origin -Wl,-rpath,$ORIGIN/../lib")
# very ugly!
set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} -Wl,-rpath-link,${VE_CXX_ROOTDIR}/lib")
set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} ${VE_LINK_RPATH}")

set(CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS "-Dcmake_shared_library_create_cxx_flags ${CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS} ${VE_LINK_RPATH}")

show_cmake_stuff("End of Platform/Linux-GNU-CXX-aurora.cmake")
# vim: et ts=4 sw=4 ai
