# Sistem Reservasi Restoran

## Deskripsi Project
### Latar Belakang
Dalam era digital saat ini, manajemen reservasi restoran yang efisien sangat penting untuk memastikan kepuasan pelanggan dan optimalisasi operasi bisnis. Proyek ini bertujuan untuk mengembangkan sebuah sistem basis data untuk manajemen reservasi restoran yang mencakup pelanggan, restoran, meja, reservasi, dan pembayaran.

### Tujuan Proyek
1. Mempermudah Manajemen Reservasi: Mengurangi beban kerja staf restoran dengan mengotomatisasi proses reservasi.
2. Mengoptimalkan Utilisasi Meja: Memastikan meja dikelola secara efisien untuk memaksimalkan kapasitas restoran.
3. Meningkatkan Pengalaman Pelanggan: Memberikan pengalaman reservasi yang mulus dan cepat untuk pelanggan.
4. Pencatatan Pembayaran yang Akurat: Memastikan semua pembayaran tercatat dengan benar untuk keperluan akuntansi dan audit.

### Lingkup Proyek
Sistem ini akan mencakup komponen-komponen berikut:
1. Manajemen Pelanggan: Penyimpanan data pelanggan termasuk nama, email, dan nomor telepon.
2. Manajemen Restoran: Penyimpanan data restoran termasuk nama, alamat, dan nomor telepon.
3. Manajemen Meja: Penyimpanan data meja termasuk nomor meja, kapasitas, dan asosiasi dengan restoran.
4. Manajemen Reservasi: Penyimpanan data reservasi termasuk tanggal, waktu, jumlah orang, dan total pembayaran.
5. Manajemen Pembayaran: Penyimpanan data pembayaran termasuk tanggal pembayaran, jumlah, dan metode pembayaran.

### Spesifikasi Teknis
1. Basis Data: MySQL
2. Bahasa Pemrograman: SQL untuk operasi basis data
3. Indexing: Digunakan untuk mempercepat query
4. View: Digunakan untuk menyederhanakan query yang kompleks
5. Trigger: Digunakan untuk otomatisasi perhitungan total pembayaran

## Entity Relationship Diagram
![ERD Diagram](entity_relationship_diagram.png)

## Relasi
1. customer ke reservation (one to many)
Satu pelanggan (customer) dapat membuat banyak reservasi (reservation), tetapi setiap reservasi hanya dapat dibuat oleh satu pelanggan. Ini diimplementasikan melalui customer_id sebagai foreign key di tabel reservation, menghubungkannya ke tabel customer.

2. restaurant ke restaurant_table (one to many)
Satu restoran (restaurant) dapat memiliki banyak meja (restaurant_table), tetapi setiap meja hanya dapat dimiliki oleh satu restoran. Ini diimplementasikan melalui restaurant_id sebagai foreign key di tabel restaurant_table, menghubungkannya ke tabel restaurant.

3. restaurant ke reservation (one to many)
Satu restoran (restaurant) dapat menerima banyak reservasi (reservation), tetapi setiap reservasi hanya dapat dilakukan di satu restoran. Ini diimplementasikan melalui restaurant_id sebagai foreign key di tabel reservation, menghubungkannya ke tabel restaurant.

4. restaurant_table ke reservation (one to many)
Satu meja di restoran (restaurant_table) dapat digunakan untuk banyak reservasi (reservation), tetapi setiap reservasi hanya dapat dilakukan untuk satu meja. Ini diimplementasikan melalui table_id sebagai foreign key di tabel reservation, menghubungkannya ke tabel restaurant_table.

5. reservation ke payment (one to many)
Satu reservasi (reservation) dapat memiliki banyak pembayaran (payment), tetapi setiap pembayaran hanya dapat terkait dengan satu reservasi. Ini diimplementasikan melalui reservation_id sebagai foreign key di tabel payment, menghubungkannya ke tabel reservation.

## Skema Basis Data
```sql
-- Tabel
CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    NAME VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);

CREATE TABLE restaurant (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    NAME VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL
);

CREATE TABLE restaurant_table (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    table_number INT NOT NULL,
    capacity INT NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id)
);

CREATE TABLE reservation (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    restaurant_id INT,
    table_id INT,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    number_of_people INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id),
    FOREIGN KEY (table_id) REFERENCES restaurant_table(table_id)
);

CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    reservation_id INT,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id)
);

-- Index
CREATE INDEX idx_reservation_customer_id ON reservation(customer_id);
CREATE INDEX idx_restaurant_id ON restaurant(restaurant_id);
CREATE INDEX idx_table_id ON restaurant_table(table_id);
CREATE INDEX idx_reservation_date ON reservation(reservation_date);
CREATE INDEX idx_reservation_time ON reservation(reservation_time);
CREATE INDEX idx_payment_reservation_id ON payment(reservation_id);
CREATE INDEX idx_customer_name ON customer(NAME);
CREATE INDEX idx_customer_id ON customer(customer_id);

-- Trigger
DELIMITER //
CREATE TRIGGER update_table_capacity_after_reservation
AFTER INSERT ON reservation
FOR EACH ROW
BEGIN
    UPDATE restaurant_table
    SET capacity = capacity - NEW.number_of_people
    WHERE table_id = NEW.table_id;
END;
//
DELIMITER ;

-- Trigger 2
DELIMITER //
CREATE TRIGGER update_total_payments_after_insert
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10, 2);
    
    SELECT SUM(amount) INTO total
    FROM payment
    WHERE reservation_id = NEW.reservation_id;
    
    UPDATE reservation
    SET total_payment = total
    WHERE reservation_id = NEW.reservation_id;
END;
//
DELIMITER ;

-- View
CREATE VIEW reservation_details AS
SELECT
    r.reservation_id,
    c.name AS customer_name,
    c.email AS customer_email,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id;

-- View 2
CREATE VIEW reservation_payment_details AS
SELECT
    r.reservation_id,
    c.name AS customer_name,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people,
    p.total_payment
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id
LEFT JOIN
    (SELECT reservation_id, SUM(amount) AS total_payment
     FROM payment
     GROUP BY reservation_id) p ON r.reservation_id = p.reservation_id;

-- View 3
CREATE VIEW customers_with_multiple_reservations AS
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(r.reservation_id) AS total_reservations
FROM
    customer c
LEFT JOIN
    reservation r ON c.customer_id = r.customer_id
WHERE
    c.name LIKE '%John%'
GROUP BY
    c.customer_id, c.name
HAVING
    COUNT(r.reservation_id) > 1;
```
## INDEX
```sql
CREATE INDEX idx_reservation_customer_id ON reservation(customer_id);
CREATE INDEX idx_restaurant_id ON restaurant(restaurant_id);
CREATE INDEX idx_table_id ON restaurant_table(table_id);
CREATE INDEX idx_reservation_date ON reservation(reservation_date);
CREATE INDEX idx_reservation_time ON reservation(reservation_time);
CREATE INDEX idx_payment_reservation_id ON payment(reservation_id);
CREATE INDEX idx_customer_name ON customer(NAME);
CREATE INDEX idx_customer_id ON customer(customer_id);
```
Berikut ini adalah alasan kenapa indeks tersebut diperlukan:

1. idx_reservation_customer_id pada reservation(customer_id): Digunakan dalam operasi JOIN antara tabel reservation dan customer. Indeks ini akan mempercepat penggabungan data berdasarkan customer_id.

2. idx_restaurant_id pada restaurant(restaurant_id): Digunakan dalam operasi JOIN antara tabel reservation dan restaurant. Indeks ini akan mempercepat penggabungan data berdasarkan restaurant_id.

3. idx_table_id pada restaurant_table(table_id): Digunakan dalam operasi JOIN antara tabel reservation dan restaurant_table. Indeks ini akan mempercepat penggabungan data berdasarkan table_id.

4. idx_reservation_date pada reservation(reservation_date): Digunakan untuk melakukan pencarian atau pengurutan berdasarkan tanggal reservasi (reservation_date), indeks ini akan mempercepat kinerja query yang memanfaatkan kolom ini.

5. idx_reservation_time pada reservation(reservation_time): Digunakan untuk melakukan pencarian atau pengurutan berdasarkan waktu reservasi (reservation_time), indeks ini akan mempercepat kinerja query yang memanfaatkan kolom ini.

6. idx_payment_reservation_id pada payment(reservation_id): Digunakan untuk menggabungkan data dari subquery yang menghitung total pembayaran (total_payment) berdasarkan reservation_id. Indeks ini akan mempercepat operasi penggabungan data antara reservation dan payment.

7. idx_customer_name pada customer(name): Digunakan dalam kondisi pencarian (WHERE c.name LIKE '%John%'). Indeks ini akan mempercepat pencarian data pelanggan berdasarkan nama.

8. idx_customer_id pada customer(customer_id): Digunakan dalam operasi JOIN antara tabel customer dan reservation. Indeks ini akan mempercepat penggabungan data berdasarkan customer_id.

## TRIGGER
### 1. TRIGGER: update_table_capacity_after_reservation
Trigger ini bertujuan untuk mengurangi kapasitas meja di restoran setiap kali ada reservasi baru yang dilakukan.

Detail Penjelasan:

1. Trigger Definition:
* Nama Trigger: update_table_capacity_after_reservation
* Event yang Memicu Trigger: AFTER INSERT (Setelah ada data baru yang dimasukkan ke dalam tabel reservation)
* Tabel yang Dipantau: reservation
* Kapan Trigger Dijalankan: Setelah setiap baris baru dimasukkan ke dalam tabel reservation (FOR EACH ROW)

2. Konteks Penggunaan:
* Situasi: Ketika sebuah reservasi baru dibuat dan disimpan ke dalam tabel reservation.
* Tujuan: Untuk memperbarui kapasitas dari meja restoran yang dipesan dalam reservasi tersebut dengan mengurangi jumlah orang dalam reservasi dari kapasitas awal meja.

3. Prosedur yang Dilakukan:
* Awal dan Akhir Blok Trigger:
```sql
BEGIN
...
END;
```
* SQL yang Dieksekusi:
```sql
UPDATE restaurant_table
SET capacity = capacity - NEW.number_of_people
WHERE table_id = NEW.table_id;
```
* Penjelasan Prosedur:
  
    * UPDATE restaurant_table: Perintah untuk memperbarui tabel restaurant_table.
    * SET capacity = capacity - NEW.number_of_people: Mengurangi nilai kapasitas meja dengan jumlah orang yang baru saja melakukan reservasi (NEW.number_of_people).
    * WHERE table_id = NEW.table_id: Memastikan bahwa hanya baris di tabel restaurant_table yang memiliki table_id yang sesuai dengan table_id dari reservasi baru yang di-update.

4. DELIMITER:
* Delimiter digunakan untuk mengubah karakter yang digunakan untuk mengakhiri pernyataan SQL. Ini diperlukan karena pernyataan trigger dapat mengandung beberapa pernyataan SQL.
* DELIMITER // mengubah karakter akhir menjadi //, memungkinkan kita untuk menulis blok kode trigger.
* DELIMITER ; mengembalikan karakter akhir kembali ke ; setelah definisi trigger selesai.

5. Kode Trigger
```sql
DELIMITER //
CREATE TRIGGER update_table_capacity_after_reservation
AFTER INSERT ON reservation
FOR EACH ROW
BEGIN
    UPDATE restaurant_table
    SET capacity = capacity - NEW.number_of_people
    WHERE table_id = NEW.table_id;
END;
//
DELIMITER ;
```
6. Ilustrasi
* Sebelum Reservasi:
    - Kapasitas meja di restaurant_table misalnya 10 orang.
    - Tidak ada reservasi yang dilakukan pada meja tersebut.

* Reservasi Baru:
    - Pelanggan membuat reservasi untuk 4 orang pada meja dengan table_id tertentu.
    - Data reservasi ini dimasukkan ke dalam tabel reservation.

* Setelah Trigger Dijalankan:
    - Trigger update_table_capacity_after_reservation secara otomatis dipicu.
    - Kapasitas meja di restaurant_table diperbarui menjadi 10 - 4 = 6 orang.
   
7. Kesimpulan
* Trigger update_table_capacity_after_reservation memastikan bahwa kapasitas meja di restoran selalu diperbarui setiap kali ada reservasi baru yang masuk, membantu mengelola jumlah orang yang dapat ditampung oleh masing-masing meja secara akurat.

### 2. TRIGGER: update_total_payments_after_insert
Trigger ini bertujuan untuk memperbarui total pembayaran untuk reservasi tertentu setiap kali ada pembayaran baru yang ditambahkan.

Detail Penjelasan:
1. Trigger Definition:
* Nama Trigger: update_total_payments_after_insert
* Event yang Memicu Trigger: AFTER INSERT (Setelah ada data baru yang dimasukkan ke dalam tabel payment)
* Tabel yang Dipantau: payment
* Kapan Trigger Dijalankan: Setelah setiap baris baru dimasukkan ke dalam tabel payment (FOR EACH ROW)

2. Konteks Penggunaan:
* Situasi: Ketika sebuah pembayaran baru ditambahkan ke tabel payment.
* Tujuan: Untuk menghitung ulang total pembayaran untuk reservasi tertentu dan memperbarui kolom total_payment di tabel reservation.

3. Prosedur yang Dilakukan:
* Awal dan Akhir Blok Trigger:
```sql
BEGIN
...
END;
```
* Deklarasi Variabel:
```sql
DECLARE total DECIMAL(10, 2);
```
Mendeklarasikan variabel total untuk menyimpan total pembayaran yang dihitung.

* Penghitungan Total Pembayaran:
```sql
SELECT SUM(amount) INTO total
FROM payment
WHERE reservation_id = NEW.reservation_id;
```
SELECT SUM(amount) INTO total: Menghitung jumlah semua pembayaran (SUM(amount)) untuk reservation_id yang sama dengan reservasi baru yang dimasukkan (NEW.reservation_id), dan menyimpannya dalam variabel total.

* Memperbarui Tabel Reservation:
```sql
UPDATE reservation
SET total_payment = total
WHERE reservation_id = NEW.reservation_id;
```
UPDATE reservation: Memperbarui tabel reservation.
SET total_payment = total: Menetapkan nilai total_payment ke hasil perhitungan total yang baru (total).
WHERE reservation_id = NEW.reservation_id: Memastikan bahwa hanya baris dengan reservation_id yang sesuai dengan reservasi baru yang di-update.

4. DELIMITER:
* Delimiter digunakan untuk mengubah karakter yang digunakan untuk mengakhiri pernyataan SQL. Ini diperlukan karena pernyataan trigger dapat mengandung beberapa pernyataan SQL.
* DELIMITER // mengubah karakter akhir menjadi //, memungkinkan kita untuk menulis blok kode trigger.
* DELIMITER ; mengembalikan karakter akhir kembali ke ; setelah definisi trigger selesai.

5. Kode Trigger:
```sql
DELIMITER //
CREATE TRIGGER update_total_payments_after_insert
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    DECLARE total DECIMAL(10, 2);
    
    SELECT SUM(amount) INTO total
    FROM payment
    WHERE reservation_id = NEW.reservation_id;
    
    UPDATE reservation
    SET total_payment = total
    WHERE reservation_id = NEW.reservation_id;
END;
//
DELIMITER ;
```
6. Ilustrasi
* Sebelum Pembayaran Baru:
    * total_payment untuk reservasi tertentu dalam tabel reservation adalah sejumlah tertentu.
    * Tidak ada pembayaran baru yang ditambahkan ke tabel payment.
* Pembayaran Baru:
    * Pembayaran baru dimasukkan ke tabel payment dengan amount tertentu dan reservation_id tertentu.
* Setelah Trigger Dijalankan:
    * Trigger update_total_payments_after_insert secara otomatis dipicu.
    * Sistem menghitung jumlah semua pembayaran untuk reservation_id yang terkait.
    * Kolom total_payment dalam tabel reservation diperbarui dengan nilai baru yang mencerminkan total semua pembayaran untuk reservasi tersebut.
  
7. Kesimpulan
* Trigger update_total_payments_after_insert memastikan bahwa setiap kali pembayaran baru ditambahkan ke tabel payment, total pembayaran untuk reservasi terkait dihitung ulang dan diperbarui dalam tabel reservation. Ini membantu menjaga data total pembayaran tetap akurat dan terkini tanpa memerlukan intervensi manual.

## VIEW
### 1. VIEW: reservation_details
View ini bertujuan untuk menyajikan informasi lengkap tentang reservasi, termasuk detail pelanggan, restoran, dan meja yang dipesan.

Detail Penjelasan:

1. Nama View:
* reservation_details: Nama view yang mendeskripsikan bahwa view ini berisi detail terkait reservasi.

2. Tujuan View:
* Menggabungkan Data: Menggabungkan informasi dari beberapa tabel (reservation, customer, restaurant, dan restaurant_table) untuk menampilkan detail reservasi dalam satu tampilan.
* Menyederhanakan Query: Memberikan cara yang lebih sederhana untuk mengakses data yang tersebar di beberapa tabel tanpa harus melakukan join secara manual setiap kali membutuhkan informasi tersebut.

3. Tabel-tabel yang Digunakan:
* reservation (r): Tabel utama yang berisi informasi tentang reservasi.
* customer (c): Tabel yang berisi informasi tentang pelanggan yang melakukan reservasi.
* restaurant (rest): Tabel yang berisi informasi tentang restoran tempat reservasi dilakukan.
* restaurant_table (rt): Tabel yang berisi informasi tentang meja di restoran.

4. Kolom-kolom yang Dipilih:
* r.reservation_id: ID unik dari reservasi.
* c.name AS customer_name: Nama pelanggan yang melakukan reservasi.
* c.email AS customer_email: Email pelanggan yang melakukan reservasi.
* rest.name AS restaurant_name: Nama restoran tempat reservasi dilakukan.
* rt.table_number: Nomor meja yang dipesan.
* r.reservation_date: Tanggal reservasi.
* r.reservation_time: Waktu reservasi.
* r.number_of_people: Jumlah orang dalam reservasi.

5. Join Operation:
* JOIN customer (c) ON r.customer_id = c.customer_id:
    * Menggabungkan tabel reservation dengan customer berdasarkan customer_id.
* JOIN restaurant (rest) ON r.restaurant_id = rest.restaurant_id:
    * Menggabungkan tabel reservation dengan restaurant berdasarkan restaurant_id.
* JOIN restaurant_table (rt) ON r.table_id = rt.table_id:
    * Menggabungkan tabel reservation dengan restaurant_table berdasarkan table_id.

6. Kode View:
```sql
CREATE VIEW reservation_details AS
SELECT
    r.reservation_id,
    c.name AS customer_name,
    c.email AS customer_email,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id;
```

7. Ilustrasi Penggunaan
* Sebelum Menggunakan View:
```sql
SELECT
    r.reservation_id,
    c.name AS customer_name,
    c.email AS customer_email,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id;
```
* Setelah Menggunakan View:
```sql
SELECT * FROM reservation_details;
```

8. Kesimpulan
* View reservation_details menyederhanakan akses ke data reservasi dengan menggabungkan informasi yang relevan dari beberapa tabel ke dalam satu tampilan. Ini membuat query lebih sederhana, lebih mudah dibaca, dan mengurangi redundansi dalam menulis query yang kompleks. View ini sangat berguna dalam aplikasi yang sering membutuhkan informasi lengkap tentang reservasi.

### 2. VIEW: reservation_payment_details
View ini bertujuan untuk menyajikan informasi lengkap tentang reservasi, termasuk detail pelanggan, restoran, meja yang dipesan, serta total pembayaran yang telah dilakukan untuk setiap reservasi.

Detail Penjelasan:
1. Nama View:
* reservation_payment_details: Nama view yang mendeskripsikan bahwa view ini berisi detail terkait reservasi beserta informasi pembayaran.

2. Tujuan View:
* Menggabungkan Data: Menggabungkan informasi dari beberapa tabel (reservation, customer, restaurant, restaurant_table, dan payment) untuk menampilkan detail reservasi dan total pembayaran dalam satu tampilan.
* Menyederhanakan Query: Memberikan cara yang lebih sederhana untuk mengakses data yang tersebar di beberapa tabel tanpa harus melakukan join dan agregasi secara manual setiap kali membutuhkan informasi tersebut.

3. Tabel-tabel yang Digunakan:
* reservation (r): Tabel utama yang berisi informasi tentang reservasi.
* customer (c): Tabel yang berisi informasi tentang pelanggan yang melakukan reservasi.
* restaurant (rest): Tabel yang berisi informasi tentang restoran tempat reservasi dilakukan.
* restaurant_table (rt): Tabel yang berisi informasi tentang meja di restoran.
* payment (p): Tabel yang berisi informasi tentang pembayaran yang dilakukan untuk reservasi.

4. Kolom-kolom yang Dipilih:
* r.reservation_id: ID unik dari reservasi.
* c.name AS customer_name: Nama pelanggan yang melakukan reservasi.
* rest.name AS restaurant_name: Nama restoran tempat reservasi dilakukan.
* rt.table_number: Nomor meja yang dipesan.
* r.reservation_date: Tanggal reservasi.
* r.reservation_time: Waktu reservasi.
* r.number_of_people: Jumlah orang dalam reservasi.
* p.total_payment: Total pembayaran yang telah dilakukan untuk reservasi tersebut.

5. Join Operation:
* JOIN customer (c) ON r.customer_id = c.customer_id:
    * Menggabungkan tabel reservation dengan customer berdasarkan customer_id.
* JOIN restaurant (rest) ON r.restaurant_id = rest.restaurant_id:
    * Menggabungkan tabel reservation dengan restaurant berdasarkan restaurant_id.
* JOIN restaurant_table (rt) ON r.table_id = rt.table_id:
    * Menggabungkan tabel reservation dengan restaurant_table berdasarkan table_id.
* LEFT JOIN Subquery p ON r.reservation_id = p.reservation_id:
    * Menggabungkan tabel reservation dengan subquery p yang menghitung total pembayaran berdasarkan reservation_id.

6. Subquery untuk Total Pembayaran:
* Subquery menghitung total pembayaran untuk setiap reservasi:
```sql
(SELECT reservation_id, SUM(amount) AS total_payment
 FROM payment
 GROUP BY reservation_id)
```
* SELECT reservation_id, SUM(amount) AS total_payment: Memilih reservation_id dan menghitung total pembayaran (SUM(amount)) untuk setiap reservasi.
* FROM payment: Dari tabel payment.
* GROUP BY reservation_id: Mengelompokkan berdasarkan reservation_id.

7. Kode View:
```sql
CREATE VIEW reservation_payment_details AS
SELECT
    r.reservation_id,
    c.name AS customer_name,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people,
    p.total_payment
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id
LEFT JOIN
    (SELECT reservation_id, SUM(amount) AS total_payment
     FROM payment
     GROUP BY reservation_id) p ON r.reservation_id = p.reservation_id;
```

8. Ilustrasi Penggunaan
* Sebelum Menggunakan View:
```sql
SELECT
    r.reservation_id,
    c.name AS customer_name,
    rest.name AS restaurant_name,
    rt.table_number,
    r.reservation_date,
    r.reservation_time,
    r.number_of_people,
    (SELECT SUM(amount) FROM payment WHERE reservation_id = r.reservation_id) AS total_payment
FROM
    reservation r
JOIN
    customer c ON r.customer_id = c.customer_id
JOIN
    restaurant rest ON r.restaurant_id = rest.restaurant_id
JOIN
    restaurant_table rt ON r.table_id = rt.table_id;
```
* Setelah Menggunakan View:
```sql
SELECT * FROM reservation_payment_details;
```

9. Kesimpulan
* View reservation_payment_details menyederhanakan akses ke data reservasi dan pembayaran dengan menggabungkan informasi yang relevan dari beberapa tabel dan subquery ke dalam satu tampilan. Ini membuat query lebih sederhana, lebih mudah dibaca, dan mengurangi redundansi dalam menulis query yang kompleks. View ini sangat berguna dalam aplikasi yang sering membutuhkan informasi lengkap tentang reservasi dan total pembayaran.

### 3. VIEW: customers_with_multiple_reservations
View ini bertujuan untuk menyajikan informasi tentang pelanggan yang memiliki lebih dari satu reservasi, khususnya pelanggan yang namanya mengandung kata "John".

Detail Penjelasan:
1. Nama View:
* customers_with_multiple_reservations: Nama view yang mendeskripsikan bahwa view ini berisi informasi tentang pelanggan dengan lebih dari satu reservasi.

2. Tujuan View:
* Mengidentifikasi Pelanggan Aktif: Memberikan informasi tentang pelanggan yang sering melakukan reservasi, yang dapat berguna untuk analisis dan pemasaran.
* Filter Berdasarkan Nama: Fokus pada pelanggan yang namanya mengandung kata "John".
* Menyederhanakan Query: Menyediakan cara yang lebih sederhana untuk mendapatkan daftar pelanggan yang memenuhi kriteria tersebut tanpa harus menulis query kompleks berulang kali.

3. Tabel-tabel yang Digunakan:
* customer (c): Tabel yang berisi informasi tentang pelanggan.
* reservation (r): Tabel yang berisi informasi tentang reservasi yang dilakukan oleh pelanggan.

4. Kolom-kolom yang Dipilih:
* c.customer_id: ID unik dari pelanggan.
* c.name AS customer_name: Nama pelanggan.
* COUNT(r.reservation_id) AS total_reservations: Total jumlah reservasi yang dilakukan oleh pelanggan.

5. Join Operation:
* LEFT JOIN reservation (r) ON c.customer_id = r.customer_id
    * Menggabungkan tabel customer dengan reservation berdasarkan customer_id, menggunakan LEFT JOIN untuk memastikan semua pelanggan tercakup, termasuk yang tidak memiliki reservasi.

6. Filtering dan Grouping:
* WHERE c.name LIKE '%John%'
    * Menyaring pelanggan yang namanya mengandung kata "John".
* GROUP BY c.customer_id, c.name
    * Mengelompokkan hasil berdasarkan customer_id dan name untuk menghitung jumlah reservasi per pelanggan.
* HAVING COUNT(r.reservation_id) > 1
    * Memfilter hasil untuk hanya menyertakan pelanggan yang memiliki lebih dari satu reservasi.

7. Kode View:
```sql
CREATE VIEW customers_with_multiple_reservations AS
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(r.reservation_id) AS total_reservations
FROM
    customer c
LEFT JOIN
    reservation r ON c.customer_id = r.customer_id
WHERE
    c.name LIKE '%John%'
GROUP BY
    c.customer_id, c.name
HAVING
    COUNT(r.reservation_id) > 1;
```

8. Ilustrasi Penggunaan
* Sebelum Menggunakan View:
```sql
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(r.reservation_id) AS total_reservations
FROM
    customer c
LEFT JOIN
    reservation r ON c.customer_id = r.customer_id
WHERE
    c.name LIKE '%John%'
GROUP BY
    c.customer_id, c.name
HAVING
    COUNT(r.reservation_id) > 1;
```
* Setelah Menggunakan View:
```sql
SELECT * FROM customers_with_multiple_reservations;
```

9. Kesimpulan
* View customers_with_multiple_reservations menyederhanakan akses ke data pelanggan yang memiliki lebih dari satu reservasi dan namanya mengandung "John". Ini membuat query lebih sederhana, lebih mudah dibaca, dan mengurangi redundansi dalam menulis query yang kompleks. View ini sangat berguna dalam analisis data pelanggan dan dapat digunakan untuk mengidentifikasi pelanggan aktif untuk tujuan pemasaran dan layanan pelanggan.

