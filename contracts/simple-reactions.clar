;; title: simple-reactions
;; version: 1.0.0
;; summary: Sistema de like/dislike para um item compartilhado
;; description: Contrato que permite reagir com like ou dislike a um item unico

;; traits
;;

;; token definitions
;;

;; constants
;; Valores de reacao: -1 = dislike, 0 = nenhuma, 1 = like
(define-constant REACTION_DISLIKE i128 -1)
(define-constant REACTION_NONE i128 0)
(define-constant REACTION_LIKE i128 1)

;; data vars
;; Total de likes
(define-data-var likes uint u0)

;; Total de dislikes
(define-data-var dislikes uint u0)

;; data maps
;; Reacao de cada endereco (-1 = dislike, 0 = nenhuma, 1 = like)
(define-map reactions principal int128)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

