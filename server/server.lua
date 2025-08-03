-- Server script utama untuk Disnaker
local QBCore = nil
local ESX = nil

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
end)

-- Event ketika resource dimulai
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    print('[DISNAKER] Resource dimulai: ' .. resourceName)
    
    -- Muat data harga dari database (simulasi)
    -- Dalam implementasi nyata, ini akan memuat dari database
    print('[DISNAKER] Memuat data harga barang...')
end)

-- Event ketika resource dihentikan
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    print('[DISNAKER] Resource dihentikan: ' .. resourceName)
    
    -- Simpan data harga ke database (simulasi)
    print('[DISNAKER] Menyimpan data harga barang...')
end)

-- Callback untuk mendapatkan daftar barang dan harga
RegisterServerCallback('disnaker:getItems', function(source, cb)
    cb(Config.Items)
end)

-- Event untuk mendapatkan harga saat ini
RegisterNetEvent('disnaker:requestPrices')
AddEventHandler('disnaker:requestPrices', function()
    local src = source
    TriggerClientEvent('disnaker:updatePrices', src, Config.Items)
end)

-- Command untuk admin untuk memperbarui harga secara manual
RegisterCommand('updateprice', function(source, args, rawCommand)
    local src = source
    
    -- Periksa izin admin
    if IsPlayerAdmin(src) then
        if #args < 2 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Penggunaan: /updateprice [nama_barang] [harga_baru]"}
            })
            return
        end
        
        local itemName = args[1]
        local newPrice = tonumber(args[2])
        
        if not newPrice or newPrice <= 0 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Harga harus berupa angka positif"}
            })
            return
        end
        
        local success, finalPrice = ManuallyUpdateItemPrice(itemName, newPrice)
        
        if success then
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"[DISNAKER]", "Harga " .. itemName .. " diperbarui menjadi $" .. FormatNumber(finalPrice)}
            })
            
            -- Log ke console
            print(string.format("[DISNAKER] Admin %s memperbarui harga %s menjadi $%s", 
                GetPlayerName(src), itemName, FormatNumber(finalPrice)))
        else
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Barang tidak ditemukan: " .. itemName}
            })
        end
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DISNAKER]", "Anda tidak memiliki izin untuk menggunakan perintah ini"}
        })
    end
end, false)

-- Command untuk admin untuk mengatur persentase perubahan harga
RegisterCommand('setpricechange', function(source, args, rawCommand)
    local src = source
    
    -- Periksa izin admin
    if IsPlayerAdmin(src) then
        if #args < 1 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Penggunaan: /setpricechange [persentase]"}
            })
            return
        end
        
        local newPercent = tonumber(args[1])
        
        if not newPercent or newPercent < 1 or newPercent > 50 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Persentase harus antara 1 dan 50"}
            })
            return
        end
        
        local success = SetPriceChangePercent(newPercent)
        
        if success then
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"[DISNAKER]", "Persentase perubahan harga diatur menjadi " .. newPercent .. "%"}
            })
            
            -- Log ke console
            print(string.format("[DISNAKER] Admin %s mengatur persentase perubahan harga menjadi %d%%", 
                GetPlayerName(src), newPercent))
        end
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DISNAKER]", "Anda tidak memiliki izin untuk menggunakan perintah ini"}
        })
    end
end, false)

-- Command untuk admin untuk mengatur interval fluktuasi harga
RegisterCommand('setpriceinterval', function(source, args, rawCommand)
    local src = source
    
    -- Periksa izin admin
    if IsPlayerAdmin(src) then
        if #args < 1 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Penggunaan: /setpriceinterval [jam]"}
            })
            return
        end
        
        local newInterval = tonumber(args[1])
        
        if not newInterval or newInterval < 1 or newInterval > 24 then
            TriggerClientEvent('chat:addMessage', src, {
                color = {255, 0, 0},
                multiline = true,
                args = {"[DISNAKER]", "Interval harus antara 1 dan 24 jam"}
            })
            return
        end
        
        local success = SetPriceFluctuationInterval(newInterval)
        
        if success then
            TriggerClientEvent('chat:addMessage', src, {
                color = {0, 255, 0},
                multiline = true,
                args = {"[DISNAKER]", "Interval fluktuasi harga diatur menjadi " .. newInterval .. " jam"}
            })
            
            -- Log ke console
            print(string.format("[DISNAKER] Admin %s mengatur interval fluktuasi harga menjadi %d jam", 
                GetPlayerName(src), newInterval))
        end
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DISNAKER]", "Anda tidak memiliki izin untuk menggunakan perintah ini"}
        })
    end
end, false)

-- Command untuk memaksa pembaruan harga
RegisterCommand('forceupdateprices', function(source, args, rawCommand)
    local src = source
    
    -- Periksa izin admin
    if IsPlayerAdmin(src) then
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"[DISNAKER]", "Memaksa pembaruan harga barang..."}
        })
        
        -- Paksa pembaruan harga
        UpdateAllPrices()
        
        -- Log ke console
        print(string.format("[DISNAKER] Admin %s memaksa pembaruan harga barang", GetPlayerName(src)))
    else
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"[DISNAKER]", "Anda tidak memiliki izin untuk menggunakan perintah ini"}
        })
    end
end, false)

-- Fungsi untuk memeriksa apakah pemain adalah admin
function IsPlayerAdmin(source)
    -- Implementasi sesuai dengan framework yang digunakan
    if QBCore then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and Player.PlayerData.permission == "admin" or Player.PlayerData.permission == "god" then
            return true
        end
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer and xPlayer.getGroup() == "admin" or xPlayer.getGroup() == "superadmin" then
            return true
        end
    else
        -- Fallback ke izin ace
        return IsPlayerAceAllowed(source, "command.updateprice")
    end
    
    return false
end

-- Fungsi callback untuk framework
function RegisterServerCallback(name, cb)
    if QBCore then
        QBCore.Functions.CreateCallback(name, cb)
    elseif ESX then
        ESX.RegisterServerCallback(name, cb)
    else
        -- Implementasi fallback untuk standalone
        local eventName = name .. ':cb'
        RegisterNetEvent(name)
        AddEventHandler(name, function(...)
            local src = source
            local args = {...}
            
            -- Tambahkan callback sebagai argumen terakhir
            table.insert(args, function(...)
                TriggerClientEvent(eventName, src, ...)
            end)
            
            -- Panggil callback dengan argumen yang diperbarui
            cb(src, table.unpack(args))
        end)
    end
end
