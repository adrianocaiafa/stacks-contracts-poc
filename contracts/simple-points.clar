;; title: simple-points
;; version: 1.0.0
;; summary: Sistema simples de pontos on-chain + contagem de usuarios unicos
;; description: Contrato que permite ganhar e transferir pontos entre usuarios

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; Pontos de cada endereco
(define-map points principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

