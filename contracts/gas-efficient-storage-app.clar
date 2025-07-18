(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-ALREADY-EXISTS (err u409))
(define-constant ERR-INVALID-INPUT (err u400))
(define-constant ERR-STORAGE-FULL (err u507))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u402))

(define-constant MAX-STORAGE-ENTRIES u10000)
(define-constant STORAGE-COST-PER-BYTE u10)
(define-constant BATCH-DISCOUNT-THRESHOLD u5)
(define-constant BATCH-DISCOUNT-RATE u20)

(define-data-var storage-counter uint u0)
(define-data-var total-storage-used uint u0)
(define-data-var contract-balance uint u0)

(define-map storage-entries
  { storage-id: uint }
  { 
    owner: principal,
    data-hash: (buff 32),
    size: uint,
    timestamp: uint,
    access-count: uint,
    is-compressed: bool
  }
)

(define-map user-storage-stats
  { user: principal }
  {
    total-entries: uint,
    total-size: uint,
    total-spent: uint,
    last-access: uint
  }
)

(define-map compressed-data
  { data-hash: (buff 32) }
  { compressed-size: uint, original-size: uint }
)

(define-map storage-index
  { owner: principal, index: uint }
  { storage-id: uint }
)

(define-map batch-operations
  { batch-id: uint }
  {
    owner: principal,
    operation-count: uint,
    total-cost: uint,
    timestamp: uint,
    status: (string-ascii 10)
  }
)

(define-data-var batch-counter uint u0)

(define-private (calculate-storage-cost (size uint) (is-compressed bool))
  (let ((base-cost (* size STORAGE-COST-PER-BYTE)))
    (if is-compressed
      (/ (* base-cost u80) u100)
      base-cost)))

(define-private (calculate-batch-discount (operation-count uint) (total-cost uint))
  (if (>= operation-count BATCH-DISCOUNT-THRESHOLD)
    (/ (* total-cost (- u100 BATCH-DISCOUNT-RATE)) u100)
    total-cost))

(define-private (update-user-stats (user principal) (size uint) (cost uint))
  (let ((current-stats (default-to 
                         { total-entries: u0, total-size: u0, total-spent: u0, last-access: u0 }
                         (map-get? user-storage-stats { user: user }))))
    (map-set user-storage-stats 
      { user: user }
      {
        total-entries: (+ (get total-entries current-stats) u1),
        total-size: (+ (get total-size current-stats) size),
        total-spent: (+ (get total-spent current-stats) cost),
        last-access: stacks-block-height
      })))

(define-private (compress-data (original-size uint))
  (let ((compression-ratio (if (> original-size u1000) u60 u80)))
    (/ (* original-size compression-ratio) u100)))

(define-public (store-data (data-hash (buff 32)) (size uint) (compress bool))
  (let ((storage-id (+ (var-get storage-counter) u1))
        (compressed-size (if compress (compress-data size) size))
        (storage-cost (calculate-storage-cost compressed-size compress)))
    (asserts! (< (var-get storage-counter) MAX-STORAGE-ENTRIES) ERR-STORAGE-FULL)
    (asserts! (> size u0) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? storage-entries { storage-id: storage-id })) ERR-ALREADY-EXISTS)
    
    (try! (stx-transfer? storage-cost tx-sender (as-contract tx-sender)))
    
    (map-set storage-entries 
      { storage-id: storage-id }
      {
        owner: tx-sender,
        data-hash: data-hash,
        size: compressed-size,
        timestamp: stacks-block-height,
        access-count: u0,
        is-compressed: compress
      })
    
    (begin
      (if compress
        (map-set compressed-data 
          { data-hash: data-hash }
          { compressed-size: compressed-size, original-size: size })
        true))
    
    (let ((user-entry-count (get-user-entry-count tx-sender)))
      (map-set storage-index 
        { owner: tx-sender, index: user-entry-count }
        { storage-id: storage-id }))
    
    (update-user-stats tx-sender compressed-size storage-cost)
    (var-set storage-counter storage-id)
    (var-set total-storage-used (+ (var-get total-storage-used) compressed-size))
    (var-set contract-balance (+ (var-get contract-balance) storage-cost))
    
    (ok storage-id)))

(define-public (batch-store-data (data-list (list 10 { data-hash: (buff 32), size: uint, compress: bool })))
  (let ((batch-id (+ (var-get batch-counter) u1))
        (operation-count (len data-list))
        (total-cost (fold + (map calculate-individual-cost data-list) u0))
        (discounted-cost (calculate-batch-discount operation-count total-cost)))
    
    (asserts! (> operation-count u0) ERR-INVALID-INPUT)
    
    (try! (stx-transfer? discounted-cost tx-sender (as-contract tx-sender)))
    
    (map-set batch-operations 
      { batch-id: batch-id }
      {
        owner: tx-sender,
        operation-count: operation-count,
        total-cost: discounted-cost,
        timestamp: stacks-block-height,
        status: "pending"
      })
    
    (let ((results (map store-single-data data-list)))
      (map-set batch-operations 
        { batch-id: batch-id }
        {
          owner: tx-sender,
          operation-count: operation-count,
          total-cost: discounted-cost,
          timestamp: stacks-block-height,
          status: "completed"
        })
      
      (var-set batch-counter batch-id)
      (ok batch-id))))

(define-private (calculate-individual-cost (data-item { data-hash: (buff 32), size: uint, compress: bool }))
  (let ((size (get size data-item))
        (compress (get compress data-item)))
    (calculate-storage-cost (if compress (compress-data size) size) compress)))

(define-private (store-single-data (data-item { data-hash: (buff 32), size: uint, compress: bool }))
  (let ((storage-id (+ (var-get storage-counter) u1))
        (data-hash (get data-hash data-item))
        (size (get size data-item))
        (compress (get compress data-item))
        (compressed-size (if compress (compress-data size) size)))
    
    (map-set storage-entries 
      { storage-id: storage-id }
      {
        owner: tx-sender,
        data-hash: data-hash,
        size: compressed-size,
        timestamp: stacks-block-height,
        access-count: u0,
        is-compressed: compress
      })
    
    (begin
      (if compress
        (map-set compressed-data 
          { data-hash: data-hash }
          { compressed-size: compressed-size, original-size: size })
        true))
    
    (let ((user-entry-count (get-user-entry-count tx-sender)))
      (map-set storage-index 
        { owner: tx-sender, index: user-entry-count }
        { storage-id: storage-id }))
    
    (var-set storage-counter storage-id)
    (var-set total-storage-used (+ (var-get total-storage-used) compressed-size))
    
    storage-id))

(define-public (retrieve-data (storage-id uint))
  (let ((entry (unwrap! (map-get? storage-entries { storage-id: storage-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get owner entry) tx-sender) ERR-UNAUTHORIZED)
    
    (map-set storage-entries 
      { storage-id: storage-id }
      (merge entry { access-count: (+ (get access-count entry) u1) }))
    
    (ok entry)))

(define-public (delete-data (storage-id uint))
  (let ((entry (unwrap! (map-get? storage-entries { storage-id: storage-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get owner entry) tx-sender) ERR-UNAUTHORIZED)
    
    (map-delete storage-entries { storage-id: storage-id })
    (var-set total-storage-used (- (var-get total-storage-used) (get size entry)))
    
    (ok true)))

(define-public (optimize-storage (storage-id uint))
  (let ((entry (unwrap! (map-get? storage-entries { storage-id: storage-id }) ERR-NOT-FOUND)))
    (asserts! (is-eq (get owner entry) tx-sender) ERR-UNAUTHORIZED)
    (asserts! (not (get is-compressed entry)) ERR-INVALID-INPUT)
    
    (let ((original-size (get size entry))
          (compressed-size (compress-data original-size))
          (cost-savings (calculate-storage-cost (- original-size compressed-size) false)))
      
      (map-set storage-entries 
        { storage-id: storage-id }
        (merge entry { size: compressed-size, is-compressed: true }))
      
      (map-set compressed-data 
        { data-hash: (get data-hash entry) }
        { compressed-size: compressed-size, original-size: original-size })
      
      (var-set total-storage-used (- (var-get total-storage-used) (- original-size compressed-size)))
      
      (ok cost-savings))))

(define-read-only (get-storage-entry (storage-id uint))
  (map-get? storage-entries { storage-id: storage-id }))

(define-read-only (get-user-stats (user principal))
  (map-get? user-storage-stats { user: user }))

(define-read-only (get-user-entry-count (user principal))
  (match (map-get? user-storage-stats { user: user })
    stats (get total-entries stats)
    u0))

(define-read-only (get-user-storage-by-index (user principal) (index uint))
  (map-get? storage-index { owner: user, index: index }))

(define-read-only (get-compression-info (data-hash (buff 32)))
  (map-get? compressed-data { data-hash: data-hash }))

(define-read-only (get-batch-operation (batch-id uint))
  (map-get? batch-operations { batch-id: batch-id }))

(define-read-only (get-contract-stats)
  {
    total-entries: (var-get storage-counter),
    total-storage-used: (var-get total-storage-used),
    contract-balance: (var-get contract-balance),
    max-capacity: MAX-STORAGE-ENTRIES
  })

(define-read-only (calculate-storage-quote (size uint) (compress bool))
  (calculate-storage-cost (if compress (compress-data size) size) compress))

(define-read-only (calculate-batch-quote (data-items (list 10 { size: uint, compress: bool })))
  (let ((individual-costs (map calculate-quote-item data-items))
        (total-cost (fold + individual-costs u0))
        (operation-count (len data-items)))
    {
      individual-costs: individual-costs,
      total-cost: total-cost,
      discounted-cost: (calculate-batch-discount operation-count total-cost),
      savings: (- total-cost (calculate-batch-discount operation-count total-cost))
    }))

(define-private (calculate-quote-item (data-item { size: uint, compress: bool }))
  (let ((size (get size data-item))
        (compress (get compress data-item)))
    (calculate-storage-cost (if compress (compress-data size) size) compress)))

(define-public (withdraw-fees)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-UNAUTHORIZED)
    (let ((balance (var-get contract-balance)))
      (try! (as-contract (stx-transfer? balance tx-sender CONTRACT-OWNER)))
      (var-set contract-balance u0)
      (ok balance))))
