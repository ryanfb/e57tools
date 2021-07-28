cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)
set(CMAKE_CXX_STANDARD 11)

project( E57Tools )

include( E57Support.cmake )

# Find Boost
set(Boost_USE_STATIC_LIBS   OFF)
set(Boost_USE_STATIC_RUNTIME OFF)
set(Boost_USE_MULTITHREADED ON)
find_package(Boost
    COMPONENTS
        program_options
        system
        thread
        filesystem
    QUIET
)
if (NOT Boost_FOUND)
    set(BOOST_ROOT CACHE PATH  "Location of the boost root directory" )
    message(FATAL_ERROR
"Unable to find boost library.
Please set the BOOST_ROOT to point to the boost distribution files."
)
endif(NOT Boost_FOUND)

add_executable( e57validate
  src/e57validate.cpp
)
target_link_libraries( e57validate
	${Boost_LIBRARIES}
	${CMAKE_THREAD_LIBS_INIT}
)
target_link_LIBE57FORMAT( e57validate )

add_executable( e57unpack
  src/e57unpack.cpp
)
target_link_libraries( e57unpack
	${Boost_LIBRARIES}
	${CMAKE_THREAD_LIBS_INIT}
)
target_link_LIBE57FORMAT( e57unpack )

install(
  TARGETS
    e57validate
    e57unpack
  RUNTIME DESTINATION bin
)
