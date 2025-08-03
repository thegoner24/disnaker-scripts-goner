// Script untuk Disnaker - Sistem Harga Barang
let items = [];
let categories = [];
let currentCategory = 'all';
let currentSort = 'name-asc';
let currentView = 'grid';
let currentPage = 1;
let itemsPerPage = 12;
let searchQuery = '';

// Inisialisasi aplikasi
document.addEventListener('DOMContentLoaded', function() {
    // Event listener untuk tombol tutup
    document.getElementById('closeBtn').addEventListener('click', closeMenu);
    
    // Event listener untuk tombol tampilan
    document.getElementById('gridViewBtn').addEventListener('click', () => setView('grid'));
    document.getElementById('listViewBtn').addEventListener('click', () => setView('list'));
    
    // Event listener untuk dropdown pengurutan
    document.getElementById('sortSelect').addEventListener('change', function() {
        currentSort = this.value;
        renderItems();
    });
    
    // Event listener untuk pencarian
    document.getElementById('searchInput').addEventListener('input', function() {
        searchQuery = this.value.toLowerCase();
        currentPage = 1;
        renderItems();
    });
    
    // Inisialisasi dengan data dummy (akan diganti dengan data dari game)
    initDummyData();
});

// Fungsi untuk menginisialisasi data dummy
function initDummyData() {
    // Data dummy akan diganti dengan data dari game
    items = [
        {name: "Batu", label: "Batu", basePrice: 50, category: "mining", currentPrice: 50, lastUpdate: Date.now() - 3600000},
        {name: "Besi", label: "Besi", basePrice: 150, category: "mining", currentPrice: 165, lastUpdate: Date.now() - 3600000},
        {name: "Emas", label: "Emas", basePrice: 500, category: "mining", currentPrice: 450, lastUpdate: Date.now() - 3600000},
        {name: "Berlian", label: "Berlian", basePrice: 1000, category: "mining", currentPrice: 1100, lastUpdate: Date.now() - 3600000},
        {name: "Gandum", label: "Gandum", basePrice: 30, category: "farming", currentPrice: 33, lastUpdate: Date.now() - 3600000},
        {name: "Jagung", label: "Jagung", basePrice: 40, category: "farming", currentPrice: 36, lastUpdate: Date.now() - 3600000},
        {name: "Tomat", label: "Tomat", basePrice: 35, category: "farming", currentPrice: 38, lastUpdate: Date.now() - 3600000},
        {name: "Anggur", label: "Anggur", basePrice: 45, category: "farming", currentPrice: 49, lastUpdate: Date.now() - 3600000},
        {name: "Ikan_Kecil", label: "Ikan Kecil", basePrice: 25, category: "fishing", currentPrice: 27, lastUpdate: Date.now() - 3600000},
        {name: "Ikan_Sedang", label: "Ikan Sedang", basePrice: 50, category: "fishing", currentPrice: 45, lastUpdate: Date.now() - 3600000},
        {name: "Ikan_Besar", label: "Ikan Besar", basePrice: 100, category: "fishing", currentPrice: 110, lastUpdate: Date.now() - 3600000},
        {name: "Ikan_Langka", label: "Ikan Langka", basePrice: 300, category: "fishing", currentPrice: 330, lastUpdate: Date.now() - 3600000},
        {name: "Kayu_Biasa", label: "Kayu Biasa", basePrice: 20, category: "lumber", currentPrice: 22, lastUpdate: Date.now() - 3600000},
        {name: "Kayu_Oak", label: "Kayu Oak", basePrice: 40, category: "lumber", currentPrice: 36, lastUpdate: Date.now() - 3600000},
        {name: "Kayu_Maple", label: "Kayu Maple", basePrice: 60, category: "lumber", currentPrice: 66, lastUpdate: Date.now() - 3600000},
        {name: "Kayu_Mahoni", label: "Kayu Mahoni", basePrice: 80, category: "lumber", currentPrice: 88, lastUpdate: Date.now() - 3600000}
    ];
    
    categories = [
        {id: "all", label: "Semua Kategori"},
        {id: "mining", label: "Pertambangan"},
        {id: "farming", label: "Pertanian"},
        {id: "fishing", label: "Perikanan"},
        {id: "lumber", label: "Kayu"}
    ];
    
    // Render kategori dan item
    renderCategories();
    renderItems();
    updateLastUpdateTime();
}

// Fungsi untuk merender daftar kategori
function renderCategories() {
    const categoryList = document.getElementById('categoryList');
    categoryList.innerHTML = '';
    
    categories.forEach(category => {
        const li = document.createElement('li');
        li.textContent = category.label;
        li.dataset.category = category.id;
        
        if (category.id === currentCategory) {
            li.classList.add('active');
        }
        
        li.addEventListener('click', function() {
            currentCategory = category.id;
            currentPage = 1;
            
            // Update tampilan kategori aktif
            document.querySelectorAll('#categoryList li').forEach(item => {
                item.classList.remove('active');
            });
            this.classList.add('active');
            
            renderItems();
        });
        
        categoryList.appendChild(li);
    });
}

// Fungsi untuk merender daftar item
function renderItems() {
    const container = document.getElementById('itemsContainer');
    container.innerHTML = '';
    
    // Filter item berdasarkan kategori dan pencarian
    let filteredItems = items.filter(item => {
        const matchesCategory = currentCategory === 'all' || item.category === currentCategory;
        const matchesSearch = searchQuery === '' || 
                             item.label.toLowerCase().includes(searchQuery) || 
                             item.category.toLowerCase().includes(searchQuery);
        return matchesCategory && matchesSearch;
    });
    
    // Urutkan item
    filteredItems = sortItems(filteredItems, currentSort);
    
    // Hitung pagination
    const totalPages = Math.ceil(filteredItems.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const paginatedItems = filteredItems.slice(startIndex, startIndex + itemsPerPage);
    
    // Set kelas tampilan
    container.className = `items-container ${currentView}-view`;
    
    // Render item
    if (paginatedItems.length === 0) {
        const emptyMessage = document.createElement('div');
        emptyMessage.className = 'empty-message';
        emptyMessage.textContent = 'Tidak ada barang yang ditemukan';
        container.appendChild(emptyMessage);
    } else {
        paginatedItems.forEach(item => {
            if (currentView === 'grid') {
                container.appendChild(createGridItem(item));
            } else {
                container.appendChild(createListItem(item));
            }
        });
    }
    
    // Render pagination
    renderPagination(totalPages);
}

// Fungsi untuk membuat item dalam tampilan grid
function createGridItem(item) {
    const template = document.getElementById('gridItemTemplate');
    const clone = document.importNode(template.content, true);
    
    const priceChange = calculatePriceChange(item);
    const priceChangeClass = priceChange >= 0 ? 'increase' : 'decrease';
    const priceChangeIcon = priceChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down';
    
    clone.querySelector('.item-name').textContent = item.label;
    clone.querySelector('.price-value').textContent = '$' + formatNumber(item.currentPrice);
    
    const priceChangeElement = clone.querySelector('.price-change');
    priceChangeElement.className = `price-change ${priceChangeClass}`;
    priceChangeElement.innerHTML = `<i class="fas ${priceChangeIcon}"></i> ${Math.abs(priceChange)}%`;
    
    // Set ikon berdasarkan kategori
    const iconElement = clone.querySelector('.item-icon i');
    iconElement.className = getCategoryIcon(item.category);
    
    // Tambahkan informasi harga pemerintah dan status subsidi
    if (item.governmentPrice !== undefined) {
        clone.querySelector('.gov-price').textContent = 'Harga Pemerintah: $' + formatNumber(item.governmentPrice);
        
        // Tampilkan status subsidi
        const subsidyElement = clone.querySelector('.subsidy-status');
        if (item.subsidized) {
            subsidyElement.textContent = 'Status: Disubsidi';
            subsidyElement.classList.add('subsidy-active');
        } else {
            subsidyElement.textContent = 'Status: Tidak Disubsidi';
            subsidyElement.classList.add('subsidy-inactive');
        }
    }
    
    return clone;
}

// Fungsi untuk membuat item dalam tampilan list
function createListItem(item) {
    const template = document.getElementById('listItemTemplate');
    const clone = document.importNode(template.content, true);
    
    const priceChange = calculatePriceChange(item);
    const priceChangeClass = priceChange >= 0 ? 'increase' : 'decrease';
    const priceChangeIcon = priceChange >= 0 ? 'fa-arrow-up' : 'fa-arrow-down';
    
    clone.querySelector('.item-name').textContent = item.label;
    clone.querySelector('.item-category').textContent = getCategoryLabel(item.category);
    clone.querySelector('.price-value').textContent = '$' + formatNumber(item.currentPrice);
    
    const priceChangeElement = clone.querySelector('.price-change');
    priceChangeElement.className = `price-change ${priceChangeClass}`;
    priceChangeElement.innerHTML = `<i class="fas ${priceChangeIcon}"></i> ${Math.abs(priceChange)}%`;
    
    // Set ikon berdasarkan kategori
    const iconElement = clone.querySelector('.item-icon i');
    iconElement.className = getCategoryIcon(item.category);
    
    // Tambahkan informasi harga pemerintah dan status subsidi
    if (item.governmentPrice !== undefined) {
        clone.querySelector('.gov-price').textContent = 'Harga Pemerintah: $' + formatNumber(item.governmentPrice);
        
        // Tampilkan status subsidi
        const subsidyElement = clone.querySelector('.subsidy-status');
        if (item.subsidized) {
            subsidyElement.textContent = 'Status: Disubsidi';
            subsidyElement.classList.add('subsidy-active');
        } else {
            subsidyElement.textContent = 'Status: Tidak Disubsidi';
            subsidyElement.classList.add('subsidy-inactive');
        }
    }
    
    return clone;
}

// Fungsi untuk merender pagination
function renderPagination(totalPages) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';
    
    if (totalPages <= 1) return;
    
    // Tombol Previous
    if (currentPage > 1) {
        const prevButton = document.createElement('button');
        prevButton.innerHTML = '<i class="fas fa-chevron-left"></i>';
        prevButton.addEventListener('click', () => {
            currentPage--;
            renderItems();
        });
        pagination.appendChild(prevButton);
    }
    
    // Tombol halaman
    for (let i = 1; i <= totalPages; i++) {
        if (
            i === 1 || 
            i === totalPages || 
            (i >= currentPage - 1 && i <= currentPage + 1)
        ) {
            const pageButton = document.createElement('button');
            pageButton.textContent = i;
            
            if (i === currentPage) {
                pageButton.classList.add('active');
            }
            
            pageButton.addEventListener('click', () => {
                currentPage = i;
                renderItems();
            });
            
            pagination.appendChild(pageButton);
        } else if (
            (i === currentPage - 2 && currentPage > 3) || 
            (i === currentPage + 2 && currentPage < totalPages - 2)
        ) {
            const ellipsis = document.createElement('span');
            ellipsis.textContent = '...';
            ellipsis.className = 'ellipsis';
            pagination.appendChild(ellipsis);
        }
    }
    
    // Tombol Next
    if (currentPage < totalPages) {
        const nextButton = document.createElement('button');
        nextButton.innerHTML = '<i class="fas fa-chevron-right"></i>';
        nextButton.addEventListener('click', () => {
            currentPage++;
            renderItems();
        });
        pagination.appendChild(nextButton);
    }
}

// Fungsi untuk mengatur tampilan (grid atau list)
function setView(view) {
    currentView = view;
    
    // Update tombol aktif
    document.getElementById('gridViewBtn').classList.toggle('active', view === 'grid');
    document.getElementById('listViewBtn').classList.toggle('active', view === 'list');
    
    renderItems();
}

// Fungsi untuk mengurutkan item
function sortItems(items, sortType) {
    const [property, direction] = sortType.split('-');
    
    return [...items].sort((a, b) => {
        let valueA, valueB;
        
        if (property === 'name') {
            valueA = a.label.toLowerCase();
            valueB = b.label.toLowerCase();
        } else if (property === 'price') {
            valueA = a.currentPrice;
            valueB = b.currentPrice;
        }
        
        if (direction === 'asc') {
            return valueA > valueB ? 1 : -1;
        } else {
            return valueA < valueB ? 1 : -1;
        }
    });
}

// Fungsi untuk menghitung persentase perubahan harga
function calculatePriceChange(item) {
    const diff = item.currentPrice - item.basePrice;
    const percent = (diff / item.basePrice) * 100;
    return Math.round(percent);
}

// Fungsi untuk mendapatkan label kategori
function getCategoryLabel(categoryId) {
    const category = categories.find(cat => cat.id === categoryId);
    return category ? category.label : categoryId;
}

// Fungsi untuk mendapatkan ikon kategori
function getCategoryIcon(categoryId) {
    switch (categoryId) {
        case 'mining':
            return 'fas fa-gem';
        case 'farming':
            return 'fas fa-seedling';
        case 'fishing':
            return 'fas fa-fish';
        case 'lumber':
            return 'fas fa-tree';
        default:
            return 'fas fa-box';
    }
}

// Fungsi untuk memformat angka dengan pemisah ribuan
function formatNumber(number) {
    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

// Fungsi untuk memperbarui waktu terakhir update
function updateLastUpdateTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('lastUpdateTime').textContent = `${hours}:${minutes}`;
}

// Fungsi untuk menutup menu
function closeMenu() {
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    }).then(resp => resp.json()).then(resp => {});
}

// Event listener untuk pesan dari game
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        document.getElementById('app').style.display = 'flex';
        
        if (data.items) {
            items = data.items;
        }
        
        if (data.categories) {
            // Tambahkan kategori "Semua" di awal
            categories = [
                {id: "all", label: "Semua Kategori"},
                ...data.categories
            ];
        }
        
        // Perbarui pengaturan dari config
        if (data.config) {
            document.getElementById('updateInterval').textContent = data.config.PriceFluctuationInterval;
            document.getElementById('priceChangePercent').textContent = data.config.PriceChangePercent;
        }
        
        renderCategories();
        renderItems();
        updateLastUpdateTime();
    } else if (data.action === 'close') {
        document.getElementById('app').style.display = 'none';
    } else if (data.action === 'refresh') {
        if (data.items) {
            items = data.items;
            renderItems();
            updateLastUpdateTime();
        }
    }
});
