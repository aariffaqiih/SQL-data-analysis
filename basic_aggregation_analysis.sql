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
		
-- 6. Hitung total keuntungan kotor (gross profit) per productLine.
--    Rumus: SUM(orderdetails.quantityOrdered * (orderdetails.priceEach - products.buyPrice)).
--    Tujuan bisnis: mengidentifikasi lini produk mana yang paling menguntungkan.

		SELECT
			p.productLine,
			ROUND(SUM(od.quantityOrdered * (od.priceEach - p.buyPrice))) AS gross_profit
		FROM orderdetails od
		JOIN products p
			ON od.productCode = p.productCode
		GROUP BY p.productLine
		ORDER BY gross_profit DESC;

-- 7. Tampilkan 5 negara dengan total revenue penjualan terbesar.
--    Revenue = SUM(orderdetails.quantityOrdered * orderdetails.priceEach).
--    Tujuan bisnis: menganalisis performa pasar berdasarkan wilayah negara.

		SELECT
			c.country,
			ROUND(SUM(od.quantityOrdered * od.priceEach), 2) AS revenue
		FROM orderdetails od
		JOIN orders o
			ON od.orderNumber = o.orderNumber
		JOIN customers c
			ON o.customerNumber = c.customerNumber
		GROUP BY c.country
		ORDER BY revenue DESC
		LIMIT 5;

-- 8. Hitung rata-rata nilai pembayaran (payments.amount) yang dilakukan oleh customer
--    berdasarkan jobTitle sales representative mereka.
--    Tujuan bisnis: mengukur efektivitas masing-masing posisi sales dalam menghasilkan pembayaran.

		SELECT
			e.jobTitle,
    		ROUND(AVG(p.amount), 2) AS avg_payment
		FROM payments p
		JOIN customers c
			ON p.customerNumber = c.customerNumber
		JOIN employees e
			ON c.salesRepEmployeeNumber = e.employeeNumber
		GROUP BY e.jobTitle
		ORDER BY avg_payment DESC;

-- 9. Hitung jumlah customer baru per tahun berdasarkan tahun pertama kali mereka melakukan pembayaran.
--    Tujuan bisnis: melihat tren pertumbuhan jumlah customer dari waktu ke waktu.
		
		WITH first_payment AS (
			SELECT
				c.customerNumber,
        		MIN(p.paymentDate) AS first_payment_date
    		FROM payments p
    		JOIN customers c
				ON p.customerNumber = c.customerNumber
			GROUP BY c.customerNumber
		)

		SELECT
			YEAR(first_payment_date) AS first_year,
			COUNT(*) AS new_customers
		FROM first_payment
		GROUP BY YEAR(first_payment_date)
		ORDER BY first_year;

-- 10. Cari produk dengan frekuensi penjualan terbanyak (paling sering muncul di orderdetails).
--     Tujuan bisnis: mengidentifikasi produk terlaris untuk strategi persediaan dan promosi.

		SELECT
			p.productLine,
			p.productName,
			SUM(od.quantityOrdered) AS total_quantity
		FROM orderdetails od
		JOIN products p
			ON od.productCode = p.productCode
		GROUP BY p.productLine, p.productName
		ORDER BY total_quantity DESC
		LIMIT 1;
