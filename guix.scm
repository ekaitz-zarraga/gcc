(use-modules (ice-9 popen)
             (ice-9 rdelim)
             (srfi srfi-1)
             (guix packages)
             (guix utils)
             (guix gexp)
             (guix profiles)
             (guix download)
             (gnu packages flex)
             (gnu packages gcc))

(define %source-dir (dirname (current-filename)))

(define %git-commit
  (read-line
    (open-pipe "git show HEAD | head -1 | cut -d ' ' -f 2 "  OPEN_READ)))

(define (keep-file? file stat)
  ;; Return #t if FILE in this repository must be kept, #f otherwise. FILE is
  ;; an absolute file name and STAT is the result of 'lstat' applied to FILE.
  (not (or (any (lambda (str) (string-contains file str))
                '(".git" ".log"))
           (any (lambda (str) (string-suffix? str file))
                '("guix.scm")))))

(define-public gcc-mine
  (package
    (inherit gcc-4.7)
    (version (string-append "4.6.4-HEAD"))
    (source (local-file %source-dir
              #:recursive? #t
              #:select? keep-file?))

    (native-inputs
     (modify-inputs (package-native-inputs gcc-4.7)
       (prepend flex)))

    (arguments
     (substitute-keyword-arguments (package-arguments gcc-4.7)
       ((#:phases phases)
        `(modify-phases ,phases
           (add-after 'unpack 'patch-for-glibc-2.26
             ;; https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81712
             ;; TODO: Make this dependant on the glibc version in the build.
             (lambda _
               (for-each
                 (lambda (dir)
                   (substitute* (string-append "gcc/config/"
                                               dir "/linux-unwind.h")
                     (("struct ucontext") "ucontext_t")))
                 '("alpha" "bfin" "i386" "pa" "sh" "xtensa" "riscv"))))
           (add-after 'unpack 'ignore-bad-compare
             ;; From Makefile.in:57786:
             ;; Since the 'compare' process will fail (on debugging information) if any
             ;; directory names are different, we need to link the gcc directory for
             ;; the previous stage to a constant name ('prev-gcc'), and to make the name of
             ;; the build directories constant as well. For the latter, we use naked names
             ;; like 'gcc', because the scripts in that directory assume it.  We use
             ;; mv on platforms where symlinks to directories do not work or are not
             ;; reliable.
             ;; We ignore the bad compare until we can figure out how the debug
             ;; information made its way into the stage2 build on riscv64.
             (lambda _
               (substitute* "Makefile.in"
                 (("cat \\.bad_compare;")
                  "cat \\.bad_compare; echo \"Ignoring bad compare!\"; exit 0;"))))
           (add-after 'unpack 'setenv
             ;; This phase is modeled after the one in commencement for gcc-mesboot1.
             ;; We don't want gcc-11:lib in CPLUS_INCLUDE_PATH, it messes with
             ;; libstdc++ from gcc-4.6.
             (lambda _
               (setenv "CPLUS_INCLUDE_PATH" (getenv "C_INCLUDE_PATH"))))))))))

gcc-mine
