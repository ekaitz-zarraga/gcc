(use-modules (ice-9 popen)
             (ice-9 rdelim)
             (guix packages)
             (guix utils)
             (guix gexp)
             (guix profiles)
             (guix download)
             (gnu packages gcc)
             (gnu packages linux)
             (gnu packages maths)
             (gnu packages commencement)
             (gnu packages cross-base)
             (gnu packages compression)
             (gnu packages multiprecision)
             (gnu packages base)
             (gnu packages flex))

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


(define-public gcc-mine
  (package
    (inherit gcc-4.7)
    (version (string-append "4.6.4-HEAD"))
    (source (local-file %source-dir
              #:recursive? #t
              #:select? discard-git))

    (inputs `(("flex" ,flex-2.5)
              ("ppl" ,ppl)
              ,@(package-inputs gcc-4.7)))

    (arguments
      (substitute-keyword-arguments (package-arguments gcc-4.7)
         ((#:configure-flags configure-flags)
          `(let ((out   (assoc-ref %outputs "out"))
                 (libc  (assoc-ref %build-inputs "libc")))

            (list (string-append "--prefix=" out)
                  "--disable-nls"
                  "--disable-coverage"
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
                  "--disable-bootstrap"

                  "--enable-static"
                  "--disable-shared"

                  "--enable-threads=single")))))))

gcc-mine
