-- Fungsi untuk membatasi nilai dalam rentang tertentu
function Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

-- Fungsi untuk memformat angka dengan pemisah ribuan
function FormatNumber(number)
    local formatted = tostring(number)
    local k = 3
    while k < #formatted do
        formatted = string.sub(formatted, 1, #formatted - k) .. "." .. string.sub(formatted, #formatted - k + 1)
        k = k + 4
    end
    return formatted
end

-- Fungsi untuk mendapatkan waktu server saat ini dalam format timestamp
function GetCurrentTime()
    return os.time()
end

-- Fungsi untuk memeriksa apakah sudah waktunya untuk mengubah harga
function ShouldUpdatePrices(lastUpdate, interval)
    local currentTime = GetCurrentTime()
    local intervalSeconds = interval * 3600 -- Konversi jam ke detik
    return (currentTime - lastUpdate) >= intervalSeconds
end

-- Fungsi untuk menghasilkan persentase perubahan harga
function GeneratePriceChange(basePercent)
    -- Menghasilkan nilai acak antara -basePercent dan +basePercent
    local randomFactor = math.random(-basePercent, basePercent) / 100
    return randomFactor
end
