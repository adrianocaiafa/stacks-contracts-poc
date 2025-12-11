;; title: simple-level-up
;; version: 1.0.0
;; summary: Sistema de XP + Niveis + Leaderboard automatico
;; description: Contrato que permite ganhar XP, subir de nivel e manter um leaderboard dos top 5

;; traits
;;

;; token definitions
;;

;; constants
;; XP necessario para subir de nivel
(define-constant XP_PER_LEVEL u100)

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; XP de cada endereco
(define-map xp principal uint)

;; Nivel de cada endereco
(define-map level principal uint)

;; Leaderboard dos 5 maiores niveis (indice 0-4)
(define-map top-levels uint principal)
;; Contador para saber quantos usuarios estao no top 5
(define-data-var top-levels-count uint u0)
;; Marca se um endereco esta no top 5
(define-map is-in-top5 principal bool)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

