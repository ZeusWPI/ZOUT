(use-modules (guix channels)
             (guix inferior)
             (guix profiles)
             (guix ui)
             (srfi srfi-11)
             (srfi srfi-26))

(define (pkgs channels specs)
  (let* ((inferior (inferior-for-channels channels))
         (lookup (cut lookup-inferior-packages inferior <> <>)))
    (map (lambda (spec)
           (let-values (((name version output)
                         (package-specification->name+version+output spec)))
             (list (car (lookup name version))
                   output)))
         specs)))

(packages->manifest
 (pkgs (list (channel
               (inherit %default-guix-channel)
               (commit "71ffb948b32b361d02ec0781e25f1e8f8f5aea75")))
       (list "bash"
             "coreutils" "findutils" "sed" "grep"
             "elixir@1.19" "erlang@27" "inotify-tools"
             "pgcli"
             "node@22"
             "nss-certs")))
