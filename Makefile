#! /usr/bin/make -f

##
# @file
# @brief Makefile for building README.md
# @copyright
#	2025, Mitsutoshi Nakano <ItSANgo@gmail.com>
# 	SPDX-License-Identifier: Apache-2.0

TARGETS=README.md

.PHONY: all clean

all: $(TARGETS)
README.md: cflow2puml.pl
	pod2markdown cflow2puml.pl >README.md
clean:
	$(RM) $(TARGETS)
