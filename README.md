# ⚡ Gas-Efficient Storage App

A Clarity smart contract demonstrating gas optimization best practices for efficient data storage on the Stacks blockchain.

## 🚀 Features

- **💰 Cost-Optimized Storage**: Dynamic pricing based on data size and compression
- **🗜️ Data Compression**: Automatic compression reduces storage costs by up to 40%
- **📦 Batch Operations**: Bulk storage with up to 20% discount for multiple operations
- **📊 Usage Analytics**: Track storage statistics and access patterns
- **🔍 Efficient Indexing**: Fast data retrieval with optimized indexing system
- **💡 Smart Optimization**: Convert existing data to compressed format

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
(store-data data-hash size compress)
```
Store data with optional compression.
- **data-hash**: SHA256 hash of your data
- **size**: Size in bytes
- **compress**: Enable compression (recommended for size > 1KB)

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
- **data-items**: List of {size: uint, compress: bool} items

## 💻 Usage Examples

### Basic Storage
```clarity
;; Store 1KB of data with compression
(contract-call? .gas-efficient-storage-app store-data 
  0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef 
  u1024 
  true)
```

### Batch Storage
```clarity
;; Store multiple items with batch discount
(contract-call? .gas-efficient-storage-app batch-store-data 
  (list 
    {data-hash: 0x1111..., size: u500, compress: true}
    {data-hash: 0x2222..., size: u800, compress: true}
    {data-hash: 0x3333..., size: u1200, compress: true}
  ))
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
