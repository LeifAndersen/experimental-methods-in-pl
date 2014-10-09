#lang scheme/base
(require "../decode.rkt"
         "../struct.rkt"
         "../basic.rkt"
         "../manual-struct.rkt"
         "manual-ex.rkt"
         "manual-style.rkt"
         "manual-scheme.rkt"
         (for-syntax scheme/base
                     syntax/parse)
         (for-label scheme/base))

(provide defmodule defmodule* 
         defmodulelang defmodulelang* 
         defmodulereader defmodulereader*
         defmodule*/no-declare defmodulelang*/no-declare defmodulereader*/no-declare
         declare-exporting)

;; ---------------------------------------------------------------------------------------------------
(provide deprecated)

(require (only-in scribble/core make-style make-background-color-property)
         (only-in scribble/base para nested))

;; @deprecated[Precontent]{Precontent ... }
;; produces a nested paragraph with a yellow NOTE label to warn readers of deprecated modules 
(define-syntax-rule
  (deprecated replacement-library additional-notes ...)
  ;; ==> 
  (nested #:style 'inset
          (para (yellow (bold "NOTE:"))
                " This library is deprecated. Use "
                replacement-library
                " instead. "
                additional-notes ...)))

(define (yellow . content)
  (make-element (make-style #f (list (make-background-color-property "yellow"))) content))
;; ---------------------------------------------------------------------------------------------------

(define spacer (hspace 1))

(begin-for-syntax
 (define-splicing-syntax-class link-target?-kw
   #:description "#:link-target? keyword"
   (pattern (~seq #:link-target? expr))
   (pattern (~seq)
            #:with expr #'#t)))

(define-syntax (defmodule stx)
  (syntax-parse stx
    [(_ (~or (~seq #:require-form req)
             (~seq))
        (~or (~seq #:multi (name2 ...))
             name)
        (~or (~optional (~seq #:link-target? link-target-expr)
                        #:defaults ([link-target-expr #'#t]))
             (~optional (~seq #:use-sources (pname ...)))
             (~optional (~seq #:module-paths (modpath ...)))
             (~optional (~and #:no-declare no-declare))
             (~optional (~or (~and #:lang language)
                             (~and #:reader readr))))
        ...
        . content)
     (with-syntax ([(name2 ...) (if (attribute name)
                                    #'(name)
                                    #'(name2 ...))]
                   [(pname ...) (if (attribute pname)
                                    #'(pname ...)
                                    #'())])
       (with-syntax ([(decl-exp ...)
                      (if (attribute no-declare)
                          #'()
                          (if (attribute modpath)
                              #'((declare-exporting modpath ... #:use-sources (pname ...)))
                              #'((declare-exporting name2 ... #:use-sources (pname ...)))))]
                     [kind (cond
                            [(attribute language) #'#t]
                            [(attribute readr) #''reader]
                            [else #'#f])]
                     [modpaths (if (attribute modpath)
                                   #'(list (racketmodname modpath) ...)
                                   #'#f)]
                     [req (if (attribute req)
                              #'req
                              #'(racket require))]
                     [(show-name ...)
                      (if (attribute modpath)
                          #'(name2 ...)
                          #'((racketmodname name2) ...))])
         #'(begin
             decl-exp ...
             (*defmodule (list show-name ...)
                         modpaths
                         link-target-expr
                         kind
                         (list . content)
                         req))))]))

;; ----------------------------------------
;; old forms for backward compatibility:

(define-syntax defmodule*/no-declare
  (syntax-rules ()
    [(_ #:require-form req (name ...) . content)
     (defmodule #:require-form req
       #:names (name ...)
       #:no-declare
       . content)]
    [(_ (name ...) . content)
     (defmodule #:multi (name ...)
       #:no-declare
       . content)]))

(define-syntax defmodule*
  (syntax-rules ()
    [(_ #:require-form req (name ...) . options+content)
     (defmodule #:require-form req #:multi (name ...)
       . options+content)]
    [(_ (name ...) . options+content)
     (defmodule #:multi (name ...) . options+content)]))

(define-syntax defmodulelang*/no-declare
  (syntax-rules ()
    [(_ (lang ...) . options+content)
     (defmodule #:multi (lang ...)
       #:lang
       #:no-declare
       . options+content)]))

(define-syntax defmodulelang*
  (syntax-rules ()
    [(_ (name ...) . options+content)
     (defmodule #:multi (name ...)
       #:lang
       . options+content)]))

(define-syntax defmodulelang
  (syntax-rules ()
    [(_ lang #:module-path modpath . options+content)
     (defmodule lang
       #:module-paths (modpath)
       #:lang
       . options+content)]
    [(_ lang . options+content)
     (defmodule lang
       #:lang
       . options+content)]))

(define-syntax-rule (defmodulereader*/no-declare (lang ...) . options+content)
  (defmodule #:multi (lang ...)
    #:reader
    #:no-declare
    . options+content))

(define-syntax defmodulereader*
  (syntax-rules ()
    [(_ (name ...) . options+content)
     (defmodule #:multi (name ...)
       #:reader
       . options+content)]))

(define-syntax-rule (defmodulereader lang . options+content)
  (defmodule lang
    #:reader
    . options+content))

;; ----------------------------------------

(define (*defmodule names modpaths link-target? lang content req)
  (let ([modpaths (or modpaths names)])
    (make-splice
     (cons
      (make-table
       "defmodule"
       (map
        (lambda (name modpath)
          (define modname (if link-target?
                              (make-defracketmodname name modpath)
                              name))
          (list
           (make-flow
            (list
             (make-omitable-paragraph
              (cons
               spacer
               (case lang
                 [(#f)
                  (list (racket (#,req #,modname)))]
                 [(#t)
                  (list (hash-lang) spacer modname)]
                 [(reader)
                  (list (racketmetafont "#reader") spacer modname)]
                 [(just-lang)
                  (list (hash-lang) spacer modname)]
                 [else (error 'defmodule "unknown mode: ~e" lang)])))))))
        names
        modpaths))
      (append (if link-target?
                  (map (lambda (modpath)
                         (make-part-tag-decl 
                          (intern-taglet
                           `(mod-path ,(datum-intern-literal
                                        (element->string modpath))))))
                       modpaths)
                  null)
              (flow-paragraphs (decode-flow content)))))))

(define the-module-path-index-desc (make-module-path-index-desc))

(define (make-defracketmodname mn mp)
  (let ([name-str (datum-intern-literal (element->string mn))]
        [path-str (datum-intern-literal (element->string mp))])
    (make-index-element #f
                        (list mn)
                        (intern-taglet `(mod-path ,path-str))
                        (list name-str)
                        (list mn)
                        the-module-path-index-desc)))

(define-syntax (declare-exporting stx)
  (syntax-case stx ()
    [(_ lib ... #:use-sources (plib ...))
     (let ([libs (syntax->list #'(lib ... plib ...))])
       (for ([l libs])
         (unless (module-path? (syntax->datum l))
           (raise-syntax-error #f "not a module path" stx l)))
       (when (null? libs)
         (raise-syntax-error #f "need at least one module path" stx))
       #'(*declare-exporting '(lib ...) '(plib ...)))]
    [(_ lib ...) #'(*declare-exporting '(lib ...) '())]))

(define (*declare-exporting libs source-libs)
  (make-splice
   (list
    (make-part-collect-decl
     (make-collect-element
      #f null
      (lambda (ri) (collect-put! ri '(exporting-libraries #f) libs))))
    (make-part-collect-decl
     (make-exporting-libraries #f null (and (pair? libs) libs) source-libs)))))
