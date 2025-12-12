;; title: simple-gm
;; version: 1.0.0
;; summary: Registro simples de GM on-chain com contagem de usuarios, GMs e streaks
;; description: Contrato que permite registrar GM (Good Morning) uma vez por dia e rastreia streaks

;; traits
;;

;; token definitions
;;

;; constants
;; Blocos por dia (aproximadamente 144 blocos por dia no Bitcoin)
(define-constant BLOCKS_PER_DAY u144)

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

