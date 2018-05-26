/*
   Copyright (C)  2000    Daniel A. Atkinson  <DanAtk@aol.com>
   Copyright (C)  2004    Ivano Primi  <ivprimi@libero.it>    

   This file is part of the HPA Library.

   The HPA Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The HPA Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the HPA Library; if not, write to the Free
   Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
   02110-1301 USA.
*/

#include"xpre.h"

const unsigned short xM_sgn = 0x8000;
const unsigned short xM_exp = 0x7fff;
const short xBias = 16383;

const short xD_bias = 15360;
const short xD_max = 2047;
const short xD_lex = 12;

const short xF_bias = 16256;
const short xF_max = 255;
const short xF_lex = 9;

const short xMax_p = 16 * XDIM;
const short xK_lin = -8 * XDIM;

const struct xpr xZero = { {0x0, 0x0} };
const struct xpr xOne = { {0x3fff, 0x8000} };
const struct xpr xTwo = { {0x4000, 0x8000} };
const struct xpr xTen = { {0x4002, 0xa000} };
const struct xpr xPinf = { {0x7fff, 0x0} };
const struct xpr xMinf = { {0xffff, 0x0} };
const struct xpr xVSV = { {0x3ff2, 0x8000} };
const struct xpr xVGV = { {0x4013, 0x8000} };
const struct xpr xEmax = { {0x400c, 0xb16c} };
const struct xpr xEmin = { {0xc00c, 0xb16c} };
const struct xpr xE2min = { {0xc00c, 0xfffb} };	/* -16382.75 */
const struct xpr xE2max = { {0x400c, 0xfffb} };	/* +16382.75 */

/* static struct xpr xpzero = { {0x0, 0x0} }; */
/* static struct xpr xnzero = { {0x0, 0x0} }; */

#include "const31.h"
