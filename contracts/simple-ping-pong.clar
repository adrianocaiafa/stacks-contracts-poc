;; title: simple-ping-pong
;; version: 1.0.0
;; summary: Interacoes ping/pong on-chain com contadores
;; description: Contrato que permite registrar pings e pongs com rastreamento de metricas

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Total de pings registrados
(define-data-var total-pings uint u0)

;; Total de pongs registrados
(define-data-var total-pongs uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; public functions
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

