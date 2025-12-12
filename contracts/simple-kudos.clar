;; title: simple-kudos
;; version: 1.0.0
;; summary: Envia kudos simples on-chain entre enderecos
;; description: Contrato que permite enviar kudos entre usuarios com rastreamento de metricas

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Total de kudos enviados
(define-data-var total-kudos uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; Total de kudos que um usuario recebeu
(define-map kudos-received principal uint)

;; Total de kudos que um usuario enviou
(define-map kudos-sent principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

