;; title: simple-nft
;; version: 1.0.0
;; summary: NFT controlado com limite de mint por usuario
;; description: Contrato NFT onde o owner controla o supply e usuarios podem mintar no maximo 2 NFTs

;; traits
;;

;; token definitions
;;

;; constants
;; Limite de NFTs que um usuario pode mintar
(define-constant MAX_MINT_PER_USER u2)

;; data vars
;; Owner do contrato (quem pode definir supply)
(define-data-var contract-owner principal tx-sender)

;; Supply maximo de NFTs (definido pelo owner)
(define-data-var max-supply (optional uint) none)

;; Contador de tokens mintados (para gerar IDs)
(define-data-var token-counter uint u0)

;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)
;; Proprietario de cada NFT (token-id -> principal)
(define-map owners uint principal)

;; Contador de NFTs mintados por usuario
(define-map minted-count principal uint)

;; public functions
;; @notice Define o supply maximo de NFTs (apenas owner)
(define-public (set-supply (supply uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
        (asserts! (> supply u0) (err u2))
        ;; Verifica se ainda nao foi definido ou permite redefinir
        (var-set max-supply (some supply))
        (ok true)
    )
)

;; @notice Minta um NFT para o usuario atual (maximo 2 por usuario)
(define-public (mint)
    (let ((sender tx-sender))
        (begin
            ;; Registra interacao
            (match (map-get? has-interacted sender) already-interacted
                true
                (begin
                    (map-set has-interacted sender true)
                    (var-set total-unique-users (+ (var-get total-unique-users) u1))
                )
            )
            (let ((current-count (match (map-get? interactions-count sender) count count u0)))
                (map-set interactions-count sender (+ current-count u1))
            )
            ;; Verifica se supply foi definido
            (match (var-get max-supply) max-supply-value
                (begin
                    ;; Verifica se ainda ha supply disponivel
                    (let ((current-supply (var-get token-counter)))
                        (asserts! (< current-supply max-supply-value) (err u3))
                        ;; Verifica limite por usuario
                        (let ((user-minted (match (map-get? minted-count sender) count count u0)))
                            (begin
                                (asserts! (< user-minted MAX_MINT_PER_USER) (err u4))
                                ;; Minta o NFT
                                (let ((new-token-id (var-get token-counter)))
                                    (begin
                                        (map-set owners new-token-id sender)
                                        (map-set minted-count sender (+ user-minted u1))
                                        (var-set token-counter (+ new-token-id u1))
                                        (ok true)
                                    )
                                )
                            )
                        )
                    )
                )
                (err u5)
            )
        )
    )
)

;; @notice Transfere um NFT para outro usuario (sem limites)
(define-public (transfer (token-id uint) (to principal))
    (begin
        (let ((sender tx-sender))
            (begin
                ;; Registra interacao
                (match (map-get? has-interacted sender) already-interacted
                    true
                    (begin
                        (map-set has-interacted sender true)
                        (var-set total-unique-users (+ (var-get total-unique-users) u1))
                    )
                )
                (let ((current-count (match (map-get? interactions-count sender) count count u0)))
                    (map-set interactions-count sender (+ current-count u1))
                )
                ;; Verifica se o token existe e se o sender e o dono
                (match (map-get? owners token-id) owner
                    (begin
                        (asserts! (is-eq sender owner) (err u6))
                        ;; Transfere o NFT
                        (map-set owners token-id to)
                        (ok true)
                    )
                    (err u7)
                )
            )
        )
    )
)

;; read only functions
;; @notice Retorna o dono de um NFT
(define-read-only (get-owner (token-id uint))
    (ok (map-get? owners token-id))
)

;; @notice Retorna quantos NFTs um usuario mintou
(define-read-only (get-minted-count (user principal))
    (ok (match (map-get? minted-count user) count count u0))
)

;; @notice Retorna quantos NFTs o usuario atual mintou
(define-read-only (my-minted-count)
    (ok (match (map-get? minted-count tx-sender) count count u0))
)

;; @notice Retorna o supply maximo definido
(define-read-only (get-max-supply)
    (ok (var-get max-supply))
)

;; @notice Retorna o contador atual de tokens mintados
(define-read-only (get-token-counter)
    (ok (var-get token-counter))
)

;; @notice Retorna o owner do contrato
(define-read-only (get-contract-owner)
    (ok (var-get contract-owner))
)

;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
)

;; @notice Retorna se um usuario ja interagiu com o contrato
(define-read-only (has-user-interacted (user principal))
    (ok (match (map-get? has-interacted user) interacted interacted false))
)

;; @notice Retorna o contador de interacoes de um usuario especifico
(define-read-only (get-interactions-count (user principal))
    (ok (match (map-get? interactions-count user) count count u0))
)

;; private functions
;;
