(load "guix.scm")

(packages->manifest
  (let* ((triplet "riscv64-linux-gnu")
         (binutils (cross-binutils triplet))
         (libc     (cross-libc     triplet)))
    (list gcc-riscv
          binutils
          libc
          (list libc "static"))))
