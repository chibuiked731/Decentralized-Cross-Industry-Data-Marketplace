;; Dataset Registration Contract
;; Records available information resources

(define-data-var admin principal tx-sender)

;; Map to store datasets
(define-map datasets uint
  {
    provider: principal,
    name: (string-utf8 100),
    description: (string-utf8 500),
    hash: (buff 32),
    price: uint,
    registered-at: uint,
    active: bool
  }
)

;; Counter for dataset IDs
(define-data-var dataset-counter uint u0)

;; Public function to register a dataset
(define-public (register-dataset
                (name (string-utf8 100))
                (description (string-utf8 500))
                (hash (buff 32))
                (price uint))
  (let ((dataset-id (+ (var-get dataset-counter) u1)))
    (begin
      (asserts! (contract-call? .data-provider-verification is-verified tx-sender) (err u200))
      (var-set dataset-counter dataset-id)
      (ok (map-set datasets dataset-id
        {
          provider: tx-sender,
          name: name,
          description: description,
          hash: hash,
          price: price,
          registered-at: block-height,
          active: true
        }))
    )
  )
)

;; Public function to deactivate a dataset
(define-public (deactivate-dataset (dataset-id uint))
  (let ((dataset (unwrap! (map-get? datasets dataset-id) (err u201))))
    (begin
      (asserts! (is-eq tx-sender (get provider dataset)) (err u202))
      (ok (map-set datasets dataset-id
        (merge dataset {active: false})))
    )
  )
)

;; Public function to update dataset price
(define-public (update-price (dataset-id uint) (new-price uint))
  (let ((dataset (unwrap! (map-get? datasets dataset-id) (err u203))))
    (begin
      (asserts! (is-eq tx-sender (get provider dataset)) (err u204))
      (ok (map-set datasets dataset-id
        (merge dataset {price: new-price})))
    )
  )
)

;; Read-only function to get dataset details
(define-read-only (get-dataset (dataset-id uint))
  (map-get? datasets dataset-id)
)

;; Read-only function to get current dataset count
(define-read-only (get-dataset-count)
  (var-get dataset-counter)
)

;; Read-only function to check if dataset is active
(define-read-only (is-active (dataset-id uint))
  (match (map-get? datasets dataset-id)
    dataset (get active dataset)
    false
  )
)
