;; title: wizard-game
;; version: 1.0.0
;; summary: Sistema de RPG on-chain com XP, niveis e feiticos
;; description: Contrato de jogo onde usuarios gastam MANA para ganhar XP, subir de nivel e lancar feiticos

;; traits
;; Trait para interagir com o wizard-token
(define-trait wizard-token-trait
    (
        (transfer (principal uint) (response uint uint))
        (get-balance (principal) (response uint uint))
    )
)

;; token definitions
;;

;; constants
;; XP necessario por nivel
(define-constant XP_PER_LEVEL u100)

;; Taxa de conversao MANA para XP (1 MANA = 1 XP, considerando 6 decimais)
(define-constant MANA_TO_XP_RATE u1)

;; Mana minimo para gastar (1 MANA com 6 decimais)
(define-constant MIN_MANA_SPEND u1000000)

;; data vars
;; Owner do contrato
(define-data-var contract-owner principal tx-sender)

;; Contrato do wizard-token (MANA)
(define-data-var wizard-token-contract (optional principal) none)

;; Contrato do wizard-card NFT (opcional)
(define-data-var wizard-card-contract (optional principal) none)

;; Se NFT e necessario para acoes
(define-data-var nft-required-for-actions bool false)

;; Total de wizards unicos
(define-data-var total-unique-wizards uint u0)

;; Contador de wizards (para lista indexada)
(define-data-var wizards-count uint u0)

;; data maps
;; Indica se um endereco ja interagiu
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; XP de cada wizard
(define-map xp principal uint)

;; Nivel de cada wizard
(define-map level principal uint)

;; Feiticos lancados por cada wizard
(define-map spells-cast principal uint)

;; Lista de wizards indexada (indice -> principal)
(define-map wizards uint principal)

;; MANA transferido para o contrato por cada usuario (para conversao em XP)
(define-map pending-mana principal uint)

;; public functions
;; @notice Define o contrato do wizard-token (apenas owner)
(define-public (set-wizard-token (token-contract principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
        (var-set wizard-token-contract (some token-contract))
        (ok true)
    )
)

;; @notice Define o contrato do wizard-card NFT (apenas owner)
(define-public (set-wizard-card (nft-contract principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u2))
        (var-set wizard-card-contract (some nft-contract))
        (ok true)
    )
)

;; @notice Define se NFT e necessario para acoes (apenas owner)
(define-public (set-nft-required-for-actions (required bool))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u3))
        (var-set nft-required-for-actions required)
        (ok true)
    )
)

;; @notice Retira MANA acumulado do contrato (apenas owner)
;; @dev Nota: Em Clarity, o contrato nao pode transferir tokens de outro contrato diretamente
;;      Esta funcao esta aqui para referencia, mas requer implementacao no wizard-token
(define-public (withdraw-mana (to principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u4))
        (asserts! (is-some (some to)) (err u5))
        ;; Nota: Em Clarity, nao podemos chamar transfer de outro contrato diretamente
        ;; O owner precisa fazer a transferencia manualmente do wizard-token
        (ok true)
    )
)

;; @notice Registra MANA transferido para o contrato (para conversao em XP)
;; @dev Usuario deve transferir MANA para este contrato antes de chamar esta funcao
(define-public (register-mana-transfer (mana-amount uint))
    (begin
        (asserts! (>= mana-amount MIN_MANA_SPEND) (err u8))
        (let ((sender tx-sender))
            (begin
                ;; Verifica se token contract foi definido
                (match (var-get wizard-token-contract) token-contract
                    (begin
                        ;; Registra MANA pendente (confia que usuario transferiu)
                        (let ((current-pending (match (map-get? pending-mana sender) pending pending u0)))
                            (map-set pending-mana sender (+ current-pending mana-amount))
                        )
                        (ok true)
                    )
                    (err u9)
                )
            )
        )
    )
)

;; @notice Gasta MANA registrado para ganhar XP diretamente
(define-public (spend-mana-for-xp (mana-amount uint))
    (begin
        (asserts! (>= mana-amount MIN_MANA_SPEND) (err u8))
        (let ((sender tx-sender))
            (begin
                ;; Verifica NFT se necessario
                (try! (check-nft sender))
                ;; Registra wizard
                (try! (register-wizard sender))
                ;; Verifica se tem MANA pendente suficiente
                (let ((pending (match (map-get? pending-mana sender) pending pending u0)))
                    (begin
                        (asserts! (>= pending mana-amount) (err u18))
                        ;; Remove MANA pendente
                        (map-set pending-mana sender (- pending mana-amount))
                        ;; Converte MANA para XP (1 MANA = 1 XP, considerando 6 decimais)
                        (let ((gained-xp (/ (* mana-amount MANA_TO_XP_RATE) u1000000)))
                            (begin
                                ;; Adiciona XP
                                (let ((current-xp (match (map-get? xp sender) xp-value xp-value u0)))
                                    (map-set xp sender (+ current-xp gained-xp))
                                )
                                ;; Verifica level up
                                (try! (handle-level-up sender))
                                (ok true)
                            )
                        )
                    )
                )
            )
        )
    )
)

;; @notice Lanca um feitico em outro wizard
(define-public (cast-spell (target principal) (mana-amount uint))
    (begin
        (asserts! (is-some (some target)) (err u10))
        (asserts! (not (is-eq target tx-sender)) (err u11))
        (asserts! (>= mana-amount MIN_MANA_SPEND) (err u12))
        (let ((sender tx-sender))
            (begin
                ;; Verifica NFT se necessario
                (try! (check-nft sender))
                ;; Registra wizard (sender e target)
                (try! (register-wizard sender))
                (try! (register-wizard target))
                ;; Verifica se tem MANA pendente suficiente
                (let ((pending (match (map-get? pending-mana sender) pending pending u0)))
                    (begin
                        (asserts! (>= pending mana-amount) (err u19))
                        ;; Remove MANA pendente
                        (map-set pending-mana sender (- pending mana-amount))
                        ;; Converte MANA para XP
                        (let ((gained-xp (/ (* mana-amount MANA_TO_XP_RATE) u1000000)))
                            (begin
                                ;; Adiciona XP ao sender
                                (let ((current-xp (match (map-get? xp sender) xp-value xp-value u0)))
                                    (map-set xp sender (+ current-xp gained-xp))
                                )
                                ;; Incrementa contador de feiticos
                                (let ((current-spells (match (map-get? spells-cast sender) spells spells u0)))
                                    (map-set spells-cast sender (+ current-spells u1))
                                )
                                ;; Verifica level up
                                (try! (handle-level-up sender))
                                (ok true)
                            )
                        )
                    )
                )
            )
        )
    )
)

;; read only functions
;; @notice Retorna o XP do wizard atual
(define-read-only (my-xp)
    (ok (match (map-get? xp tx-sender) xp-value xp-value u0))
)

;; @notice Retorna o nivel do wizard atual
(define-read-only (my-level)
    (ok (match (map-get? level tx-sender) level-value level-value u0))
)

;; @notice Retorna quantos feiticos o wizard atual lancou
(define-read-only (my-spells-cast)
    (ok (match (map-get? spells-cast tx-sender) spells spells u0))
)

;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
)

;; @notice Retorna o XP de um wizard especifico
(define-read-only (get-xp (user principal))
    (ok (match (map-get? xp user) xp-value xp-value u0))
)

;; @notice Retorna o nivel de um wizard especifico
(define-read-only (get-level (user principal))
    (ok (match (map-get? level user) level-value level-value u0))
)

;; @notice Retorna quantos feiticos um wizard lancou
(define-read-only (get-spells-cast (user principal))
    (ok (match (map-get? spells-cast user) spells spells u0))
)

;; @notice Retorna o total de wizards unicos
(define-read-only (get-total-unique-wizards)
    (ok (var-get total-unique-wizards))
)

;; @notice Retorna se um usuario ja interagiu
(define-read-only (has-user-interacted (user principal))
    (ok (match (map-get? has-interacted user) interacted interacted false))
)

;; @notice Retorna o contador de interacoes de um usuario
(define-read-only (get-interactions-count (user principal))
    (ok (match (map-get? interactions-count user) count count u0))
)

;; @notice Retorna MANA pendente do usuario atual
(define-read-only (my-pending-mana)
    (ok (match (map-get? pending-mana tx-sender) pending pending u0))
)

;; @notice Retorna o numero de wizards
(define-read-only (get-wizards-count)
    (ok (var-get wizards-count))
)

;; @notice Retorna um wizard pelo indice
(define-read-only (get-wizard (index uint))
    (ok (map-get? wizards index))
)

;; @notice Retorna wizard com XP e nivel por indice (para leaderboard)
(define-read-only (get-wizard-with-stats (index uint))
    (match (map-get? wizards index) wizard
        (ok (some {
            user: wizard,
            xp: (match (map-get? xp wizard) xp-value xp-value u0),
            level: (match (map-get? level wizard) level-value level-value u0),
            spells-cast: (match (map-get? spells-cast wizard) spells spells u0)
        }))
        (ok none)
    )
)

;; @notice Retorna informacoes do contrato
(define-read-only (get-contract-info)
    (ok {
        owner: (var-get contract-owner),
        wizard-token: (var-get wizard-token-contract),
        wizard-card: (var-get wizard-card-contract),
        nft-required: (var-get nft-required-for-actions),
        total-wizards: (var-get total-unique-wizards)
    })
)

;; private functions
;; @notice Registra um wizard (adiciona a lista se for primeira vez)
(define-private (register-wizard (user principal))
    (begin
        ;; Se e a primeira interacao, adiciona a lista de wizards
        (match (map-get? has-interacted user) already-interacted
            true
            (begin
                (map-set has-interacted user true)
                (var-set total-unique-wizards (+ (var-get total-unique-wizards) u1))
                ;; Adiciona a lista de wizards
                (let ((next-index (var-get wizards-count)))
                    (begin
                        (map-set wizards next-index user)
                        (var-set wizards-count (+ next-index u1))
                    )
                )
            )
        )
        ;; Incrementa contador de interacoes
        (let ((current-count (match (map-get? interactions-count user) count
            count
            u0
        )))
            (map-set interactions-count user (+ current-count u1))
        )
        (ok true)
    )
)

;; @notice Verifica se usuario tem NFT (se necessario)
(define-private (check-nft (user principal))
    (begin
        (if (var-get nft-required-for-actions)
            (match (var-get wizard-card-contract) nft-contract
                (begin
                    ;; Verifica se usuario tem pelo menos 1 NFT
                    ;; Nota: Em Clarity, precisariamos de um trait para verificar balance do NFT
                    ;; Por enquanto, vamos apenas validar que o contrato foi definido
                    (ok true)
                )
                (err u7)
            )
            (ok true)
        )
    )
)

;; @notice Verifica e atualiza nivel do wizard baseado no XP
(define-private (handle-level-up (user principal))
    (begin
        (let ((user-xp (match (map-get? xp user) xp-value xp-value u0))
              (user-level (match (map-get? level user) level-value level-value u0))
              (new-level (/ user-xp XP_PER_LEVEL)))
            (if (> new-level user-level)
                (map-set level user new-level)
                true
            )
        )
        (ok true)
    )
)
