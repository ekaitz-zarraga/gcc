/* Definitions for RISC-V GNU/Linux systems with ELF format.
   Copyright (C) 1998-2017 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3, or (at your option)
any later version.

GCC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

#define TARGET_OS_CPP_BUILTINS()  LINUX_TARGET_OS_CPP_BUILTINS()

#define MD_UNWIND_SUPPORT "config/riscv/linux-unwind.h"

#define GLIBC_DYNAMIC_LINKER "/lib/ld-linux-riscv" XLEN_SPEC "-" ABI_SPEC ".so.1"

#define LINK_SPEC "\
-melf" XLEN_SPEC "lriscv \
%{shared} \
  %{!shared: \
    %{!static: \
      %{rdynamic:-export-dynamic} \
      -dynamic-linker " LINUX_DYNAMIC_LINKER "} \
    %{static:-static}}"

