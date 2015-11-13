// { dg-options "-std=gnu++1y" }

// Copyright (C) 2015 Free Software Foundation, Inc.
//
// This file is part of the GNU ISO C++ Library.  This library is free
// software; you can redistribute it and/or modify it under the
// terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3, or (at your option)
// any later version.

// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License along
// with this library; see the file COPYING3.  If not see
// <http://www.gnu.org/licenses/>.

// 8.2.1 Class template shared_ptr [memory.smartptr.shared]

#include <experimental/memory>
#include <testsuite_hooks.h>

struct A { };
struct B : A { };

// 8.2.1.1 shared_ptr constructors [memory.smartptr.shared.const]

// Construction from pointer
int
test01()
{
  bool test __attribute__((unused)) = true;

  A * const a = 0;
  std::experimental::shared_ptr<A> p(a);
  VERIFY( p.get() == 0 );
  VERIFY( p.use_count() == 1 );
  return 0;
}

int
test02()
{
  bool test __attribute__((unused)) = true;

  A * const a = new A[5];
  std::experimental::shared_ptr<A[5]> p(a);
  VERIFY( p.get() == a );
  VERIFY( p.use_count() == 1 );
  return 0;
}

int
test03()
{
  bool test __attribute__((unused)) = true;

  B * const b = new B[5];
  std::experimental::shared_ptr<A[5]> p(b);
  VERIFY( p.get() == b );
  VERIFY( p.use_count() == 1 );

  return 0;
}

int
main()
{
  test01();
  test02();
  test03();
  return 0;
}
