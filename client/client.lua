-- Client script utama untuk Disnaker
local QBCore = nil
local ESX = nil
local ItemPrices = {}
local isMenuOpen = false

-- Deteksi framework yang digunakan (QBCore atau ESX)
Citizen.CreateThread(function()
    if GetResourceState('qb-core') == 'started' then
        QBCore = exports['qb-core']:GetCoreObject()
        print('[DISNAKER] QBCore framework terdeteksi')
    elseif GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        print('[DISNAKER] ESX framework terdeteksi')
    else
        print('[DISNAKER] PERINGATAN: Tidak ada framework yang terdeteksi, menggunakan mode standalone')
    end
    
    -- Minta data harga dari server
    Citizen.Wait(2000) -- Tunggu sebentar untuk memastikan server siap
    TriggerServerEvent('disnaker:requestPrices')
end)

-- Event untuk menerima pembaruan harga dari server
RegisterNetEvent('disnaker:updatePrices')
AddEventHandler('disnaker:updatePrices', function(items)
    ItemPrices = items
    print('[DISNAKER] Harga barang diperbarui dari server')
    
    -- Perbarui UI jika menu terbuka
    if isMenuOpen then
        RefreshPriceMenu()
    end
end)

-- Fungsi untuk mendapatkan harga saat ini untuk item tertentu
function GetCurrentItemPrice(itemName)
    for _, item in ipairs(ItemPrices) do
        if item.name == itemName then
            return item.currentPrice
        end
    end
    return 0
end

-- Fungsi untuk mendapatkan item berdasarkan kategori
function GetItemsByCategory(category)
    local items = {}
    for _, item in ipairs(ItemPrices) do
        if item.category == category then
            table.insert(items, item)
        end
    end
    return items
end

-- Fungsi untuk membuka menu harga barang
function OpenPriceMenu()
    if isMenuOpen then return end
    isMenuOpen = true
    
    -- Minta data harga terbaru dari server
    TriggerServerEvent('disnaker:requestPrices')
    
    -- Tampilkan menu harga (menggunakan NUI)
    SendNUIMessage({
        action = 'open',
        items = ItemPrices,
        categories = Config.Categories
    })
    SetNuiFocus(true, true)
end

-- Fungsi untuk memperbarui menu harga
function RefreshPriceMenu()
    if not isMenuOpen then return end
    
    -- Perbarui data di UI
    SendNUIMessage({
        action = 'refresh',
        items = ItemPrices,
        categories = Config.Categories
    })
end

-- Fungsi untuk menutup menu harga
function ClosePriceMenu()
    if not isMenuOpen then return end
    isMenuOpen = false
    
    -- Tutup UI
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
end

-- Event dari NUI ketika menu ditutup
RegisterNUICallback('closeMenu', function(data, cb)
    ClosePriceMenu()
    cb('ok')
end)

-- Command untuk membuka menu harga
RegisterCommand('hargabarang', function()
    OpenPriceMenu()
end, false)

-- Keybind untuk membuka menu harga (default: F9)
RegisterKeyMapping('hargabarang', 'Buka menu harga barang', 'keyboard', 'F9')

-- Ekspor fungsi untuk digunakan oleh script lain
exports('GetCurrentItemPrice', GetCurrentItemPrice)
exports('GetItemsByCategory', GetItemsByCategory)
exports('OpenPriceMenu', OpenPriceMenu)

-- Notifikasi untuk pemain
function ShowNotification(message)
    if QBCore then
        QBCore.Functions.Notify(message, 'primary', 5000)
    elseif ESX then
        ESX.ShowNotification(message)
    else
        -- Fallback ke notifikasi GTA V native
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

-- Fungsi callback untuk framework
function TriggerServerCallback(name, cb, ...)
    if QBCore then
        QBCore.Functions.TriggerCallback(name, function(...)
            cb(...)
        end, ...)
    elseif ESX then
        ESX.TriggerServerCallback(name, function(...)
            cb(...)
        end, ...)
    else
        -- Implementasi fallback untuk standalone
        local eventName = name .. ':cb'
        
        -- Register event handler jika belum ada
        if not RegisteredCallbacks[name] then
            RegisterNetEvent(eventName)
            AddEventHandler(eventName, function(...)
                if CallbacksInProgress[name] then
                    CallbacksInProgress[name](...)
                    CallbacksInProgress[name] = nil
                end
            end)
            RegisteredCallbacks[name] = true
        end
        
        -- Simpan callback
        CallbacksInProgress[name] = cb
        
        -- Trigger event ke server
        TriggerServerEvent(name, ...)
    end
end

-- Inisialisasi variabel untuk callback
RegisteredCallbacks = {}
CallbacksInProgress = {}
