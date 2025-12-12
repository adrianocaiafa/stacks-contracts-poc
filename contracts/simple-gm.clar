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
;; @notice Da um GM on-chain (no maximo 1 vez por dia por endereco)
(define-public (gm)
    (begin
        (let ((sender tx-sender))
            (let ((today (/ burn-block-height BLOCKS_PER_DAY)))
                (let ((last-day (match (map-get? last-gm-day sender) day
                    day
                    u0
                )))
                    ;; Verifica se ja deu GM hoje
                    (asserts! (not (= today last-day)) (err u1))
                    ;; Registro generico de interacao
                    (match (map-get? has-interacted sender) already-interacted
                        true
                        (begin
                            (map-set has-interacted sender true)
                            (var-set total-unique-users (+ (var-get total-unique-users) u1))
                        )
                    )
                    ;; Incrementa contador de interacoes
                    (let ((current-count (match (map-get? interactions-count sender) count
                        count
                        u0
                    )))
                        (map-set interactions-count sender (+ current-count u1))
                    )
                    ;; Atualiza contagem de GMs
                    (let ((current-gm-count (match (map-get? gm-count sender) count
                        count
                        u0
                    )))
                        (map-set gm-count sender (+ current-gm-count u1))
                    )
                    ;; Atualiza o dia do ultimo GM
                    (map-set last-gm-day sender today)
                    (ok true)
                )
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;

