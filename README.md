# ⚡ Gas-Efficient Storage App

A Clarity smart contract demonstrating gas optimization best practices for efficient data storage on the Stacks blockchain.

## 🚀 Features

- **💰 Cost-Optimized Storage**: Dynamic pricing based on data size and compression
- **🗜️ Data Compression**: Automatic compression reduces storage costs by up to 40%
- **📦 Batch Operations**: Bulk storage with up to 20% discount for multiple operations
- **📊 Usage Analytics**: Track storage statistics and access patterns
- **🔍 Efficient Indexing**: Fast data retrieval with optimized indexing system
- **💡 Smart Optimization**: Convert existing data to compressed format
- **⏰ Storage Expiration**: Time-based data expiration prevents blockchain bloat
- **🧹 Cleanup Rewards**: Earn rewards for cleaning up expired storage
- **🔐 Access Control**: Granular permissions for private, public, and shared storage
- **👥 Multi-User Access**: Collaborative data sharing with permission management
- **🔄 Ownership Transfer**: Secure two-step transfer mechanism with audit trails
- **📜 Transfer History**: Complete ownership provenance tracking

## 🎯 Gas Optimization Techniques

This contract demonstrates several key optimization strategies:

1. **Efficient Data Structures**: Uses maps for O(1) lookups instead of lists
2. **Compression**: Reduces storage footprint by 20-40%
3. **Batch Processing**: Discounts for multiple operations reduce per-item costs
4. **Lazy Loading**: Data is only loaded when accessed
5. **Storage Indexing**: User-specific indexes for faster queries

## 🛠️ Contract Functions

### Storage Operations

#### `store-data`
```clarity
(store-data data-hash size compress expiration-blocks permission-type)
```
Store data with compression, expiration, and access control.
- **data-hash**: SHA256 hash of your data
- **size**: Size in bytes
- **compress**: Enable compression (recommended for size > 1KB)
- **expiration-blocks**: Number of blocks until expiration (0 = default)
- **permission-type**: Access level (0=private, 1=public, 2=shared)

Note: Storage entries can be transferred using the propose/accept transfer mechanism.

#### `batch-store-data`
```clarity
(batch-store-data data-list)
```
Store multiple data items with batch discount (5+ items get 20% off).

#### `retrieve-data`
```clarity
(retrieve-data storage-id)
```
Retrieve stored data by ID. Increments access counter.

#### `delete-data`
```clarity
(delete-data storage-id)
```
Delete stored data and reclaim storage space.

#### `optimize-storage`
```clarity
(optimize-storage storage-id)
```
Convert existing uncompressed data to compressed format.

#### `extend-expiration`
```clarity
(extend-expiration storage-id additional-blocks)
```
Extend storage expiration time for additional cost.

#### `cleanup-expired-storage`
```clarity
(cleanup-expired-storage storage-id)
```
Clean up expired storage and earn rewards (anyone can call).

#### `grant-storage-access`
```clarity
(grant-storage-access storage-id grantee)
```
Grant access to shared storage (owner only).

#### `revoke-storage-access`
```clarity
(revoke-storage-access storage-id grantee)
```
Revoke access from shared storage (owner only).

#### `update-storage-permissions`
```clarity
(update-storage-permissions storage-id new-permission-type)
```
Update storage access permissions (owner only).

#### `propose-storage-transfer`
```clarity
(propose-storage-transfer storage-id new-owner)
```
Propose ownership transfer to another principal (owner only).

#### `accept-storage-transfer`
```clarity
(accept-storage-transfer storage-id)
```
Accept proposed ownership transfer (recipient only).

#### `cancel-storage-transfer`
```clarity
(cancel-storage-transfer storage-id)
```
Cancel pending transfer proposal (owner only).

### 📈 Analytics Functions

#### `get-user-stats`
```clarity
(get-user-stats user)
```
Get user's storage statistics including total entries, size, and spending.

#### `get-contract-stats`
```clarity
(get-contract-stats)
```
Get overall contract statistics and capacity information.

#### `calculate-storage-quote`
```clarity
(calculate-storage-quote size compress)
```
Calculate storage cost before storing data.

#### `calculate-batch-quote`
```clarity
(calculate-batch-quote data-items)
```
Calculate batch operation costs with discount information.
- **data-items**: List of {size: uint, compress: bool, expiration-blocks: uint, permission-type: uint} items

#### `get-storage-permissions`
```clarity
(get-storage-permissions storage-id)
```
Get storage access permissions and settings.

#### `check-storage-access`
```clarity
(check-storage-access storage-id user)
```
Check if a user has access to specific storage.

#### `get-expiration-info`
```clarity
(get-expiration-info storage-id)
```
Get expiration details for stored data.

#### `get-cleanup-reward-estimate`
```clarity
(get-cleanup-reward-estimate storage-id)
```
Calculate potential cleanup reward for expired storage.

#### `get-transfer-proposal`
```clarity
(get-transfer-proposal storage-id)
```
Get pending transfer proposal details.

#### `get-ownership-history`
```clarity
(get-ownership-history storage-id transfer-index)
```
Get historical ownership transfer record.

#### `get-transfer-count`
```clarity
(get-transfer-count storage-id)
```
Get total number of ownership transfers.

## 💻 Usage Examples

### Basic Storage
```clarity
;; Store 1KB of private data with compression, expires in 1008 blocks (~1 week)
(contract-call? .gas-efficient-storage-app store-data 
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef 
  u1024 
  true
  u1008
  u0)  ;; private storage
```

### Batch Storage
```clarity
;; Store multiple items with batch discount
(contract-call? .gas-efficient-storage-app batch-store-data 
  (list 
    {data-hash: 0x1111..., size: u500, compress: true, expiration-blocks: u1008, permission-type: u0}
    {data-hash: 0x2222..., size: u800, compress: true, expiration-blocks: u2016, permission-type: u1}
    {data-hash: 0x3333..., size: u1200, compress: true, expiration-blocks: u504, permission-type: u2}
  ))
```

### Access Control Management
```clarity
;; Grant access to shared storage
(contract-call? .gas-efficient-storage-app grant-storage-access u123 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)

;; Check if user has access
(contract-call? .gas-efficient-storage-app check-storage-access u123 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)
```

### Ownership Transfer
```clarity
;; Propose transfer to new owner
(contract-call? .gas-efficient-storage-app propose-storage-transfer u123 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKQ9H6DPR)

;; Accept transfer (as recipient)
(contract-call? .gas-efficient-storage-app accept-storage-transfer u123)

;; View transfer history
(contract-call? .gas-efficient-storage-app get-ownership-history u123 u1)
```

### Cleanup Expired Storage
```clarity
;; Earn rewards by cleaning up expired storage
(contract-call? .gas-efficient-storage-app cleanup-expired-storage u123)
```

### Get Storage Quote
```clarity
;; Calculate cost before storing
(contract-call? .gas-efficient-storage-app calculate-storage-quote u1024 true)
```

## 🔧 Configuration

### Cost Structure
- **Base Cost**: 10 microSTX per byte
- **Compression Savings**: 20% cost reduction
- **Batch Discount**: 20% off for 5+ operations
- **Maximum Entries**: 10,000 storage slots
- **Default Expiration**: 1008 blocks (~1 week)
- **Cleanup Reward**: 50% of original storage cost

### Compression Ratios
- **Large files (>1KB)**: 40% compression
- **Small files (≤1KB)**: 20% compression

## 🧪 Testing

Run the test suite with Clarinet:

```bash
clarinet test
```

## 📊 Gas Efficiency Metrics

| Operation | Without Optimization | With Optimization | Savings |
|-----------|---------------------|-------------------|---------|
| Single Store | 1000 μSTX | 800 μSTX | 20% |
| Batch Store (5x) | 5000 μSTX | 4000 μSTX | 20% |
| Compressed Store | 1000 μSTX | 600 μSTX | 40% |
| Optimized Batch | 5000 μSTX | 3200 μSTX | 36% |

## 🌟 Best Practices Demonstrated

1. **🎯 Data Minimization**: Only store essential data
2. **🗜️ Compression**: Use compression for larger datasets
3. **📦 Batch Operations**: Group multiple operations for efficiency
4. **🔍 Smart Indexing**: Efficient data retrieval patterns
5. **💰 Cost Awareness**: Transparent pricing and quotes
6. **📊 Analytics**: Track usage for optimization insights

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License.
