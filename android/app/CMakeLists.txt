cmake_minimum_required(VERSION 3.10)
project(api LANGUAGES CXX C)

add_library(
            image_processing
            SHARED
            ../../src/image_processing.cpp
)
