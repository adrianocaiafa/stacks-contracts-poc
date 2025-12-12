;; title: simple-counter
;; version: 1.0.0
;; summary: Contador global minimalista com rastreamento de usuarios
;; description: Contrato que permite incrementar, decrementar e resetar um contador global

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Contador global
(define-data-var count uint u0)

;; data maps
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; public functions
;; @notice Incrementa o contador em 1
(define-public (increment)
    (begin
        (let ((sender tx-sender))
            (begin
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
                ;; Incrementa contador global
                (var-set count (+ (var-get count) u1))
                (ok true)
            )
        )
    )
)

;; @notice Decrementa o contador em 1 (requer count > 0)
(define-public (decrement)
    (begin
        (let ((sender tx-sender))
            (let ((current-count (var-get count)))
                (asserts! (> current-count u0) (err u1))
                ;; Registro generico de interacao
                (match (map-get? has-interacted sender) already-interacted
                    true
                    (begin
                        (map-set has-interacted sender true)
                        (var-set total-unique-users (+ (var-get total-unique-users) u1))
                    )
                )
                ;; Incrementa contador de interacoes
                (let ((interaction-count (match (map-get? interactions-count sender) count
                    count
                    u0
                )))
                    (map-set interactions-count sender (+ interaction-count u1))
                )
                ;; Decrementa contador global
                (var-set count (- current-count u1))
                (ok true)
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;

