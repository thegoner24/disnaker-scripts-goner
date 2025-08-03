Config = {}

-- Pengaturan dasar
Config.MinPriceMultiplier = 0.5 -- Harga minimum (50% dari harga dasar)
Config.MaxPriceMultiplier = 2.0 -- Harga maksimum (200% dari harga dasar)
Config.PriceFluctuationInterval = 3 -- Interval perubahan harga dalam jam
Config.PriceChangePercent = 10 -- Persentase perubahan harga (naik/turun) setiap interval

-- Pengaturan pemerintah
Config.GovernmentControl = true -- Aktifkan kontrol harga oleh pemerintah
Config.TaxRate = 5 -- Persentase pajak yang dikenakan pada transaksi (dalam %)
Config.GovernmentBudget = 10000000 -- Anggaran pemerintah untuk subsidi harga

-- Lokasi target untuk membuka UI Disnaker
Config.TargetLocation = vector4(-1289.84, -572.42, 30.57, 307.95) -- Lokasi penjualan Disnaker utama

-- Daftar barang Disnaker dengan harga dasar
Config.Items = {
    -- Kategori Makanan
    {name = "paketayam", label = "Paket Ayam", basePrice = 75000, category = "food", currentPrice = 75000, governmentPrice = 75000, lastUpdate = 0, subsidized = false},
    {name = "meat", label = "Daging", basePrice = 40000, category = "food", currentPrice = 40000, governmentPrice = 40000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Pertambangan
    {name = "iron", label = "Besi", basePrice = 35000, category = "mining", currentPrice = 35000, governmentPrice = 35000, lastUpdate = 0, subsidized = false},
    {name = "copper", label = "Tembaga", basePrice = 30000, category = "mining", currentPrice = 30000, governmentPrice = 30000, lastUpdate = 0, subsidized = false},
    {name = "gold", label = "Emas", basePrice = 35000, category = "mining", currentPrice = 35000, governmentPrice = 35000, lastUpdate = 0, subsidized = false},
    {name = "diamond", label = "Berlian", basePrice = 70000, category = "mining", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Perikanan
    {name = "catfish", label = "Ikan Lele", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "largemouthbass", label = "Ikan Bass", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "redfish", label = "Ikan Merah", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "salmon", label = "Ikan Salmon", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "stingray", label = "Ikan Pari", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "stripedbass", label = "Ikan Bass Bergaris", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    {name = "whale", label = "Paus", basePrice = 70000, category = "fishing", currentPrice = 70000, governmentPrice = 70000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Pertanian
    {name = "tomat", label = "Tomat", basePrice = 30000, category = "farming", currentPrice = 30000, governmentPrice = 30000, lastUpdate = 0, subsidized = false},
    {name = "kentang", label = "Kentang", basePrice = 32500, category = "farming", currentPrice = 32500, governmentPrice = 32500, lastUpdate = 0, subsidized = false},
    {name = "wortel", label = "Wortel", basePrice = 35000, category = "farming", currentPrice = 35000, governmentPrice = 35000, lastUpdate = 0, subsidized = false},
    {name = "jagung", label = "Jagung", basePrice = 37500, category = "farming", currentPrice = 37500, governmentPrice = 37500, lastUpdate = 0, subsidized = false},
    
    -- Kategori Kayu
    {name = "packaged_plank", label = "Kayu Olahan", basePrice = 85000, category = "lumber", currentPrice = 85000, governmentPrice = 85000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Bahan Kimia
    {name = "essence", label = "Essence", basePrice = 100000, category = "chemical", currentPrice = 100000, governmentPrice = 100000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Tekstil
    {name = "clothe", label = "Kain", basePrice = 90000, category = "textile", currentPrice = 90000, governmentPrice = 90000, lastUpdate = 0, subsidized = false},
    {name = "leather", label = "Kulit", basePrice = 45000, category = "textile", currentPrice = 45000, governmentPrice = 45000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Sampah
    {name = "plastic", label = "Plastik", basePrice = 45000, category = "trash", currentPrice = 45000, governmentPrice = 45000, lastUpdate = 0, subsidized = false},
    {name = "metalscrap", label = "Potongan Logam", basePrice = 45000, category = "trash", currentPrice = 45000, governmentPrice = 45000, lastUpdate = 0, subsidized = false},
    {name = "alumunium", label = "Alumunium", basePrice = 45000, category = "trash", currentPrice = 45000, governmentPrice = 45000, lastUpdate = 0, subsidized = false},
    {name = "glass", label = "Kaca", basePrice = 45000, category = "trash", currentPrice = 45000, governmentPrice = 45000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Barang Haram (Hanya untuk admin)
    {name = "cocaine_bag", label = "Kokain", basePrice = 150000, category = "illegal", currentPrice = 150000, governmentPrice = 150000, lastUpdate = 0, subsidized = false},
    {name = "heroin_bag", label = "Heroin", basePrice = 140000, category = "illegal", currentPrice = 140000, governmentPrice = 140000, lastUpdate = 0, subsidized = false},
    {name = "weedbag", label = "Ganja", basePrice = 180000, category = "illegal", currentPrice = 180000, governmentPrice = 180000, lastUpdate = 0, subsidized = false},
    
    -- Kategori Daur Ulang sudah dipindahkan ke kategori Sampah
}

-- Kategori barang
Config.Categories = {
    {id = "food", label = "Makanan"},
    {id = "mining", label = "Pertambangan"},
    {id = "fishing", label = "Perikanan"},
    {id = "farming", label = "Pertanian"},
    {id = "lumber", label = "Kayu"},
    {id = "chemical", label = "Bahan Kimia"},
    {id = "textile", label = "Tekstil"},
    {id = "recycle", label = "Daur Ulang"}
}

return Config
