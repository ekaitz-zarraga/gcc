(load "guix.scm")

(packages->manifest (list gcc-mine
                          binutils
                          glibc
                          (list glibc "static")))
