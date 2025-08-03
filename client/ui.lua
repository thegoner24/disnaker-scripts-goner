-- UI handler untuk Disnaker
local isUILoaded = false

-- Fungsi untuk memuat UI
function LoadUI()
    if isUILoaded then return end
    
    -- Pastikan direktori html ada
    local htmlDir = GetResourcePath(GetCurrentResourceName()) .. '/html'
    os.execute('mkdir "' .. htmlDir .. '" 2>nul')
    
    -- Pastikan file UI ada
    local indexPath = htmlDir .. '/index.html'
    local cssPath = htmlDir .. '/style.css'
    local jsPath = htmlDir .. '/script.js'
    local imgDir = htmlDir .. '/img'
    
    -- Buat direktori img jika belum ada
    os.execute('mkdir "' .. imgDir .. '" 2>nul')
    
    isUILoaded = true
end

-- Inisialisasi UI saat resource dimulai
-- Kita hanya memuat UI tanpa membukanya secara otomatis
Citizen.CreateThread(function()
    Citizen.Wait(1000)
    LoadUI()
    -- Tidak lagi membuka UI secara otomatis
end)
