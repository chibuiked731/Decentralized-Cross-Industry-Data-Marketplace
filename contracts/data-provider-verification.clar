;; Data Provider Verification Contract
;; This contract validates legitimate information sources

(define-data-var admin principal tx-sender)

;; Map to store verified providers
(define-map verified-providers principal
  {
    name: (string-utf8 100),
    verified: bool,
    reputation-score: uint,
    verification-date: uint
  }
)

;; Public function to verify a provider
(define-public (verify-provider
                (provider principal)
                (provider-name (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u100))
    (ok (map-set verified-providers provider
      {
        name: provider-name,
        verified: true,
        reputation-score: u50,
        verification-date: block-height
      }))
  )
)

;; Public function to update a provider's reputation
(define-public (update-reputation
                (provider principal)
                (new-score uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u101))
    (asserts! (map-has? verified-providers provider) (err u102))
    (let ((current-data (unwrap! (map-get? verified-providers provider) (err u103))))
      (ok (map-set verified-providers provider
        (merge current-data {reputation-score: new-score})))
    )
  )
)

;; Read-only function to check if a provider is verified
(define-read-only (is-verified (provider principal))
  (match (map-get? verified-providers provider)
    provider-data (get verified provider-data)
    false
  )
)

;; Read-only function to get provider details
(define-read-only (get-provider-details (provider principal))
  (map-get? verified-providers provider)
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u104))
    (ok (var-set admin new-admin))
  )
)
