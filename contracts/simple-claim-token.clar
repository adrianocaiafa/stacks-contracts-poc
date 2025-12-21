;; title: simple-claim-token
;; version: 1.0.0
;; summary: Token fungivel com claim unico por usuario
;; description: Contrato de token onde usuarios podem reivindicar uma quantidade fixa de tokens uma vez

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;; Balanco de tokens de cada usuario
(define-map balances principal uint)

;; Indica se um usuario ja fez claim
(define-map has-claimed principal bool)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
