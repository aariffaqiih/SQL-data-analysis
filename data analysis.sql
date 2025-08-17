-- 1. Hitung total pendapatan perusahaan (revenue) dari semua penjualan.
--    Pendapatan dihitung dari quantityOrdered * priceEach.
--    Tujuan bisnis: mengetahui total pemasukan kotor perusahaan.

		SELECT ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
		FROM orderdetails od
		JOIN orders o
			ON od.orderNumber = o.orderNumber
		WHERE o.`status` = 'Shipped';

-- 2. Tampilkan 5 customer dengan total pembayaran (payments.amount) terbesar.
--    Tujuan bisnis: mengidentifikasi "top customer" yang memberikan kontribusi terbesar ke perusahaan.

		SELECT
			c.customerNumber,
			c.customerName,
			SUM(p.amount) AS sum_amount
		FROM payments p
		JOIN customers c
			ON p.customerNumber = c.customerNumber
		GROUP BY c.customerNumber
		ORDER BY sum_amount DESC
		LIMIT 5;

-- 3. Hitung rata-rata jumlah stok (quantityInStock) per productLine.
--    Tujuan bisnis: melihat kategori produk mana yang menumpuk terlalu banyak di gudang dan rawan overstock.

		SELECT
			p.productLine,
			ROUND(AVG(p.quantityInStock)) AS avg_stock,
			SUM(p.quantityInStock) AS total_stock
		FROM products p
		GROUP BY p.productLine
		ORDER BY total_stock DESC;

-- 4. Hitung jumlah order yang sudah dikirim (status = 'Shipped') per bulan.
--    Tujuan bisnis: menganalisis tren volume order bulanan untuk forecasting penjualan.

		SELECT
			YEAR(o.shippedDate) AS order_year,
			MONTH(o.shippedDate) AS order_months,
			MONTHNAME(o.shippedDate) AS month_name,
			COUNT(o.orderNumber) AS count_order
		FROM orders o
		WHERE o.`status` = 'Shipped'
		GROUP BY order_year, order_months
		ORDER BY order_year, order_months;

-- 5. Cari rata-rata lama keterlambatan pengiriman (shippedDate - requiredDate) untuk semua order.
--    Tujuan bisnis: mengukur performa operasional (apakah sering telat kirim, seberapa besar keterlambatannya).

		SELECT ROUND(AVG(DATEDIFF(o.shippedDate, o.requiredDate))) AS avg_delay
		FROM orders o
		WHERE o.shippedDate > o.requiredDate;
