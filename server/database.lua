-- Database handler untuk menyimpan dan memuat data harga barang
local SavedPrices = {}

-- Fungsi untuk memuat data dari database
function LoadPricesFromDatabase()
    -- Dalam implementasi nyata, ini akan mengambil data dari database SQL
    -- Untuk contoh ini, kita akan menggunakan file JSON sebagai penyimpanan sederhana
    
    local filePath = GetResourcePath(GetCurrentResourceName()) .. '/data/prices.json'
    local fileExists = false
    
    -- Periksa apakah file ada
    local f = io.open(filePath, "r")
    if f then
        fileExists = true
        f:close()
    end
    
    if fileExists then
        local fileContent = LoadResourceFile(GetCurrentResourceName(), 'data/prices.json')
        if fileContent then
            local success, data = pcall(json.decode, fileContent)
            if success and data then
                print("[DISNAKER] Data harga berhasil dimuat dari database")
                return data
            else
                print("[DISNAKER] Gagal mengurai data harga dari database")
            end
        else
            print("[DISNAKER] Gagal membaca file database")
        end
    else
        print("[DISNAKER] File database tidak ditemukan, menggunakan harga default")
    end
    
    -- Jika gagal memuat, gunakan harga default dari config
    return nil
end

-- Fungsi untuk menyimpan data ke database
function SavePricesToDatabase(prices)
    -- Buat direktori data jika belum ada
    local dataDir = GetResourcePath(GetCurrentResourceName()) .. '/data'
    os.execute('mkdir "' .. dataDir .. '" 2>nul')
    
    -- Simpan data ke file JSON
    local success, encodedData = pcall(json.encode, prices)
    if success then
        local result = SaveResourceFile(GetCurrentResourceName(), 'data/prices.json', encodedData, -1)
        if result then
            print("[DISNAKER] Data harga berhasil disimpan ke database")
            return true
        else
            print("[DISNAKER] Gagal menyimpan data harga ke database")
        end
    else
        print("[DISNAKER] Gagal mengkodekan data harga")
    end
    
    return false
end

-- Fungsi untuk memperbarui harga di database
function UpdatePriceInDatabase(itemName, newPrice)
    -- Muat data saat ini
    local currentPrices = SavedPrices
    
    -- Perbarui harga item
    local updated = false
    for i, item in ipairs(currentPrices) do
        if item.name == itemName then
            currentPrices[i].currentPrice = newPrice
            currentPrices[i].lastUpdate = GetCurrentTime()
            updated = true
            break
        end
    end
    
    -- Jika item ditemukan dan diperbarui, simpan ke database
    if updated then
        SavePricesToDatabase(currentPrices)
        return true
    end
    
    return false
end

-- Fungsi untuk menyinkronkan harga dari config ke database
function SyncPricesToDatabase()
    SavedPrices = Config.Items
    return SavePricesToDatabase(Config.Items)
end

-- Fungsi untuk menyinkronkan harga dari database ke config
function SyncPricesFromDatabase()
    local prices = LoadPricesFromDatabase()
    if prices then
        -- Perbarui harga di config
        for i, dbItem in ipairs(prices) do
            for j, configItem in ipairs(Config.Items) do
                if dbItem.name == configItem.name then
                    Config.Items[j].currentPrice = dbItem.currentPrice
                    Config.Items[j].lastUpdate = dbItem.lastUpdate
                    break
                end
            end
        end
        
        SavedPrices = prices
        return true
    end
    
    -- Jika tidak ada data yang dimuat, simpan config saat ini ke database
    SavedPrices = Config.Items
    SavePricesToDatabase(Config.Items)
    return false
end

-- Inisialisasi database saat resource dimulai
Citizen.CreateThread(function()
    -- Tunggu sebentar untuk memastikan config dimuat
    Citizen.Wait(1000)
    
    -- Buat direktori data jika belum ada
    local dataDir = GetResourcePath(GetCurrentResourceName()) .. '/data'
    os.execute('mkdir "' .. dataDir .. '" 2>nul')
    
    -- Sinkronkan harga dari database ke config
    local success = SyncPricesFromDatabase()
    if success then
        print("[DISNAKER] Harga barang berhasil disinkronkan dari database")
    else
        print("[DISNAKER] Menggunakan harga default dan menyimpan ke database")
    end
end)

-- Ekspor fungsi untuk digunakan oleh script lain
exports('SyncPricesToDatabase', SyncPricesToDatabase)
exports('SyncPricesFromDatabase', SyncPricesFromDatabase)
exports('UpdatePriceInDatabase', UpdatePriceInDatabase)
