;; title: simple-bookmarks
;; version: 1.0.0
;; summary: Bookmark on-chain por usuario (URL ou referencia)
;; description: Contrato que permite salvar e limpar um bookmark on-chain

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Bookmark de cada usuario (string de ate 500 caracteres)
(define-map bookmark principal (string-ascii 500))

;; public functions
;;

;; read only functions
;;

;; private functions
;;
