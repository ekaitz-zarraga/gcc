(define-module (guix)
  #:use-module (ice-9 popen)
  #:use-module (ice-9 rdelim)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (guix profiles)
  #:use-module (guix download)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages cross-base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages base)
  #:use-module (gnu packages flex))

(define-public flex-2.5
  (package
    (inherit flex)
    (version "2.5.39")
    (source (origin
              (method url-fetch)
              (uri (string-append
                     "https://github.com/westes/flex"
                     "/releases/download/v" version "/"
                     "flex-" version ".tar.gz"))
              (sha256
                (base32
                  "0j49664wfmm2bvsdxxcaf1835is8kq0hr0sc20km14wc2mc1ppbi"))))
    (arguments '(#:tests? #f))))

(define %source-dir (dirname (current-filename)))

(define %git-commit
  (read-line
    (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2 "  OPEN_READ)))

(define (discard-git path stat)
  (let* ((start (1+ (string-length %source-dir)) )
         (end   (+ 4 start)))
  (not (false-if-exception (equal? ".git" (substring path start end))))))

(define* (gcc-from-source #:optional
                          (target %host-type)
                          (build  %host-type)
                          (host   %host-type))
  (package
    (inherit gcc-4.7)
    (version (string-append "4.6.4-HEAD"))
    (source (local-file %source-dir
              #:recursive? #t
              #:select? discard-git))

    #;(propagated-inputs
      `(("libc-for-target"     ,(cross-libc     target))
        ("binutils-for-target" ,(cross-binutils target))))
    (inputs `(("flex" ,flex-2.5)
              ("ppl" ,ppl)
              ,@(package-inputs gcc-4.7)))

    (arguments
      (substitute-keyword-arguments (package-arguments gcc-4.7)
         ;; Make only gcc target to make sure this thing compiles
         ;; Later we must make this compile the g++ and stuff...
         ((#:phases phases)
          #~(modify-phases #$phases
              (replace 'build
                       (lambda _
                         (invoke "make" "all-gcc")
                         #t))
              (replace 'install
                       (lambda _
                         (invoke "make" "install-gcc")
                         #t))))

         ((#:configure-flags configure-flags)
          `(let ((out   (assoc-ref %outputs "out"))
                 (libc  (assoc-ref %build-inputs "libc")))

            (list (string-append "--prefix=" out)

                  ,(string-append "--build="  build)
                  ,(string-append "--host="   host)
                  ,(string-append "--target=" target)

                  (let ((libc (assoc-ref %build-inputs "libc")))
                     (if libc
                       (string-append "--with-native-system-header-dir=" libc
                                      "/include")
                       "--without-headers"))

                  "CPP=cpp"

                  "--disable-nls"
                  "--disable-coverage"
                  "--disable-decimal-float"
                  "--disable-libatomic"
                  "--disable-libcilkrts"
                  "--disable-libgomp"
                  "--disable-libitm"
                  "--disable-libmudflap"
                  "--disable-libquadmath"
                  "--disable-libsanitizer"
                  "--disable-libssp"
                  "--disable-libvtv"
                  "--disable-lto"
                  "--disable-lto-plugin"
                  "--disable-multilib"
                  "--disable-plugin"
                  "--disable-threads"
                  "--disable-libstdcxx-pch"
                  "--disable-build-with-cxx"
                  "--with-local-prefix=/no-gcc-local-prefix"
                  "--with-system-zlib"

                  "--enable-languages=c"
                  "--disable-bootstrap" ; This is a cross compiler, we may need to disable it

                  "--enable-static"
                  "--disable-shared"

                  "--enable-threads=single")))))))

(define-public gcc-riscv   (gcc-from-source "riscv64-unknown-linux-gnu"))
(define-public gcc-mips    (gcc-from-source "mips-unknown-linux-gnu"))
(define-public gcc-native  (gcc-from-source))

(define-public gcc-native-toolchain (make-gcc-toolchain gcc-native glibc))

gcc-riscv
