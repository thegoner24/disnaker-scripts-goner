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
        InitializeQBTarget()
    elseif GetResourceState('es_extended') == 'started' then
        ESX = exports['es_extended']:getSharedObject()
        print('[DISNAKER] ESX framework terdeteksi')
        InitializeESXTarget()
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

-- Event untuk membuka menu harga (digunakan oleh qb-target)
RegisterNetEvent('disnaker:openMenu')
AddEventHandler('disnaker:openMenu', function()
    OpenPriceMenu()
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
-- Dinonaktifkan agar tidak terbuka otomatis dengan keybind
-- RegisterKeyMapping('hargabarang', 'Buka menu harga barang', 'keyboard', 'F9')

-- Fungsi untuk inisialisasi target QBCore
function InitializeQBTarget()
    if not QBCore then return end
    
    -- Periksa apakah qb-target tersedia
    if GetResourceState('qb-target') ~= 'started' then
        print('[DISNAKER] PERINGATAN: qb-target tidak terdeteksi, targeting tidak akan berfungsi')
        return
    end
    
    -- Tambahkan target untuk Disnaker
    exports['qb-target']:AddBoxZone("DisnakerId", vector3(Config.TargetLocation.x, Config.TargetLocation.y, Config.TargetLocation.z), 1.5, 1.5, {
        name = "DisnakerId",
        heading = Config.TargetLocation.w,
        debugPoly = false,
        minZ = Config.TargetLocation.z - 1.0,
        maxZ = Config.TargetLocation.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "disnaker:openMenu",
                icon = "fas fa-chart-line",
                label = "Lihat Harga Barang",
            },
        },
        distance = 3.0
    })
    
    print('[DISNAKER] Target QBCore berhasil diinisialisasi')
end

-- Fungsi untuk inisialisasi target ESX
function InitializeESXTarget()
    if not ESX then return end
    
    -- Periksa apakah ox_target tersedia
    if GetResourceState('ox_target') == 'started' then
        -- Tambahkan target untuk Disnaker menggunakan ox_target
        exports.ox_target:addBoxZone({
            coords = vector3(Config.TargetLocation.x, Config.TargetLocation.y, Config.TargetLocation.z),
            size = vector3(1.5, 1.5, 2.0),
            rotation = Config.TargetLocation.w,
            debug = false,
            options = {
                {
                    name = 'disnaker_open',
                    icon = 'fas fa-chart-line',
                    label = 'Lihat Harga Barang',
                    onSelect = function()
                        OpenPriceMenu()
                    end
                }
            }
        })
        print('[DISNAKER] Target ESX (ox_target) berhasil diinisialisasi')
    -- Periksa apakah qtarget tersedia
    elseif GetResourceState('qtarget') == 'started' then
        -- Tambahkan target untuk Disnaker menggunakan qtarget
        exports.qtarget:AddBoxZone("DisnakerId", vector3(Config.TargetLocation.x, Config.TargetLocation.y, Config.TargetLocation.z), 1.5, 1.5, {
            name = "DisnakerId",
            heading = Config.TargetLocation.w,
            debugPoly = false,
            minZ = Config.TargetLocation.z - 1.0,
            maxZ = Config.TargetLocation.z + 1.0,
        }, {
            options = {
                {
                    icon = "fas fa-chart-line",
                    label = "Lihat Harga Barang",
                    action = function()
                        OpenPriceMenu()
                    end
                },
            },
            distance = 3.0
        })
        print('[DISNAKER] Target ESX (qtarget) berhasil diinisialisasi')
    else
        print('[DISNAKER] PERINGATAN: Tidak ada sistem target yang terdeteksi untuk ESX, targeting tidak akan berfungsi')
    end
end

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
