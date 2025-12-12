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

;; Dados especificos de GM
;; Quantos GMs esse endereco ja deu no total
(define-map gm-count principal uint)

;; "Dia" (em numero de blocos) do ultimo GM dado por esse endereco
(define-map last-gm-day principal uint)

;; Streak atual de dias seguidos dando GM
(define-map current-streak principal uint)

;; Melhor streak ja atingida
(define-map best-streak principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;

