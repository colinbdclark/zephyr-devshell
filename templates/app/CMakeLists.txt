cmake_minimum_required(VERSION 3.20.0)

set(NAME app)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(${NAME})

target_sources(${NAME} PRIVATE src/main.c)
