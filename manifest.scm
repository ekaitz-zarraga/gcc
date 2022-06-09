(load "guix.scm")

(packages->manifest
  (let* ((binutils (cross-binutils triplet))
         (libc     (cross-libc     triplet)))
    (list gcc-mine
          binutils
          libc
          (list libc "static"))))
