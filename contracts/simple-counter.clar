;; title: simple-counter
;; version: 1.0.0
;; summary: Contador global minimalista com rastreamento de usuarios
;; description: Contrato que permite incrementar, decrementar e resetar um contador global

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Contador global
(define-data-var count uint u0)

;; data maps
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; public functions
;; @notice Incrementa o contador em 1
(define-public (increment)
    (begin
        (var-set count (+ (var-get count) u1))
        (ok true)
    )
)

;; read only functions
;;

;; private functions
;;

