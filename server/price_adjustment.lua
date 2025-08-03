-- Script untuk menaikkan dan menurunkan harga jual barang Disnaker
local lastGlobalUpdate = 0
local isUpdating = false

-- Fungsi untuk menyimpan data harga ke database (simulasi)
local function SavePricesToDatabase()
    -- Dalam implementasi nyata, ini akan menyimpan ke database
    -- Untuk contoh ini, kita hanya menampilkan log
    print("[DISNAKER] Harga barang telah diperbarui dan disimpan ke database")
end

-- Fungsi untuk memperbarui harga semua barang
function UpdateAllPrices()
    if isUpdating then return end
    isUpdating = true
    
    local currentTime = GetCurrentTime()
    if not ShouldUpdatePrices(lastGlobalUpdate, Config.PriceFluctuationInterval) then
        isUpdating = false
        return
    end
    
    print("[DISNAKER] Memulai pembaruan harga barang...")
    
    -- Perbarui harga untuk setiap barang
    for i, item in ipairs(Config.Items) do
        -- Hanya perbarui jika sudah waktunya
        if ShouldUpdatePrices(item.lastUpdate, Config.PriceFluctuationInterval) then
            -- Tentukan perubahan harga (naik atau turun)
            local priceChange = GeneratePriceChange(Config.PriceChangePercent)
            
            -- Hitung harga baru
            local newPrice = math.floor(item.currentPrice * (1 + priceChange))
            
            -- Pastikan harga dalam batas yang diizinkan
            local minPrice = math.floor(item.basePrice * Config.MinPriceMultiplier)
            local maxPrice = math.floor(item.basePrice * Config.MaxPriceMultiplier)
            newPrice = Clamp(newPrice, minPrice, maxPrice)
            
            -- Perbarui harga dan waktu terakhir diperbarui
            Config.Items[i].currentPrice = newPrice
            Config.Items[i].lastUpdate = currentTime
            
            -- Log perubahan harga
            local changeDirection = priceChange >= 0 and "naik" or "turun"
            local changePercent = math.abs(priceChange * 100)
            print(string.format("[DISNAKER] Harga %s %s %.1f%% menjadi $%s", 
                item.label, changeDirection, changePercent, FormatNumber(newPrice)))
        end
    end
    
    -- Simpan perubahan ke database
    SavePricesToDatabase()
    
    -- Perbarui waktu pembaruan global
    lastGlobalUpdate = currentTime
    
    -- Beritahu semua klien tentang perubahan harga
    TriggerClientEvent('disnaker:updatePrices', -1, Config.Items)
    
    print("[DISNAKER] Pembaruan harga selesai")
    isUpdating = false
end

-- Fungsi untuk mendapatkan harga saat ini untuk item tertentu
function GetCurrentItemPrice(itemName)
    for _, item in ipairs(Config.Items) do
        if item.name == itemName then
            return item.currentPrice
        end
    end
    return 0
end

-- Fungsi untuk memperbarui harga satu item secara manual
function ManuallyUpdateItemPrice(itemName, newPrice)
    for i, item in ipairs(Config.Items) do
        if item.name == itemName then
            -- Pastikan harga dalam batas yang diizinkan
            local minPrice = math.floor(item.basePrice * Config.MinPriceMultiplier)
            local maxPrice = math.floor(item.basePrice * Config.MaxPriceMultiplier)
            newPrice = Clamp(newPrice, minPrice, maxPrice)
            
            -- Perbarui harga dan waktu
            Config.Items[i].currentPrice = newPrice
            Config.Items[i].lastUpdate = GetCurrentTime()
            
            -- Beritahu semua klien tentang perubahan harga
            TriggerClientEvent('disnaker:updatePrices', -1, Config.Items)
            
            return true, newPrice
        end
    end
    return false, 0
end

-- Fungsi untuk memperbarui harga barang berdasarkan persentase perubahan
function PriceAdjustment.UpdateItemPrice(itemName, changePercent)
    for i, item in ipairs(Config.Items) do
        if item.name == itemName then
            local priceChange = (item.basePrice * changePercent) / 100
            item.currentPrice = math.floor(item.currentPrice + priceChange)
            
            -- Pastikan harga tidak melebihi batas minimum dan maksimum
            item.currentPrice = Utils.ClampValue(
                item.currentPrice,
                item.basePrice * Config.MinPriceMultiplier,
                item.basePrice * Config.MaxPriceMultiplier
            )
            
            item.lastUpdate = os.time()
            
            -- Simpan perubahan harga ke database
            Database.SaveItemPrice(itemName, item.currentPrice)
            
            -- Kirim pembaruan ke semua klien
            TriggerClientEvent('disnaker:updateItemPrice', -1, itemName, item.currentPrice)
            
            return true, item.currentPrice
        end
    end
    
    return false, 0
end

-- Fungsi untuk mengatur harga pembelian pemerintah
function PriceAdjustment.SetGovernmentPrice(itemName, newPrice, isSubsidized)
    for i, item in ipairs(Config.Items) do
        if item.name == itemName then
            item.governmentPrice = math.floor(newPrice)
            item.subsidized = isSubsidized
            
            -- Simpan perubahan harga pemerintah ke database
            Database.SaveGovernmentPrice(itemName, item.governmentPrice, item.subsidized)
            
            -- Kirim pembaruan ke semua klien
            TriggerClientEvent('disnaker:updateGovernmentPrice', -1, itemName, item.governmentPrice, item.subsidized)
            
            return true, item.governmentPrice
        end
    end
    
    return false, 0
end

-- Fungsi untuk mengatur persentase perubahan harga
function SetPriceChangePercent(newPercent)
    if newPercent >= 1 and newPercent <= 50 then
        Config.PriceChangePercent = newPercent
        return true
    end
    return false
end

-- Fungsi untuk mengatur interval fluktuasi harga
function SetPriceFluctuationInterval(newInterval)
    if newInterval >= 1 and newInterval <= 24 then
        Config.PriceFluctuationInterval = newInterval
        return true
    end
    return false
end

-- Ekspor fungsi untuk digunakan oleh script lain
exports('GetCurrentItemPrice', GetCurrentItemPrice)
exports('ManuallyUpdateItemPrice', ManuallyUpdateItemPrice)
exports('SetPriceChangePercent', SetPriceChangePercent)
exports('SetPriceFluctuationInterval', SetPriceFluctuationInterval)

-- Mulai timer untuk memperbarui harga secara berkala
Citizen.CreateThread(function()
    -- Tunggu sebentar setelah resource dimulai
    Citizen.Wait(10000)
    
    -- Perbarui harga setiap menit (periksa apakah sudah waktunya untuk pembaruan)
    while true do
        UpdateAllPrices()
        Citizen.Wait(60000) -- Tunggu 1 menit
    end
end)
