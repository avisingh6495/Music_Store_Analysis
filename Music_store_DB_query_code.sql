--Q1. who is the senior most empolee based on the job title?

SELECT*FROM employee
ORDER BY levels DESC
limit 1;

--Q2. Which countries have most invoices ? 

SELECT billing_country, COUNT(*) as most_invo 
FROM invoice
GROUP BY billing_country
ORDER BY most_invo DESC;

--Q3. What are the top three values of the total invoice?

SELECT total from invoice
ORDER BY total DESC
LIMIT 3;

--Q4.  Which city has the best customers? We would like to throw a promotional Music 
--     Festival in the city we made the most money. Write a query that returns one city that 
--     has the highest sum of invoice totals. Return both the city name & sum of all invoice 
--     totals

SELECT billing_city, SUM(total) AS invo_total FROM invoice
GROUP BY billing_city 
ORDER BY invo_total DESC;

--Q5. Who is the best customer? The customer who has spent the most money will be 
--    declared the best customer. Write a query that returns the person who has spent the 
--    most money

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer AS c
JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
limit 1;

--Q6. Write query to return the email, first name, last name, & Genre of all Rock Music 
--    listeners. Return your list ordered alphabetically by email starting with A

SELECT first_name, last_name, email
FROM customer
JOIN invoice 
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
      SELECT track_id FROM track
      JOIN genre 
      ON track.genre_id = genre.genre_id
      WHERE genre.name LIKE 'Rock')
ORDER BY email ASC;

--Q7. Let's invite the artists who have written the most rock music in our dataset. Write a 
--    query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.artist_id, artist.name, count(artist.artist_id) as total_track
FROM artist
JOIN album
ON artist.artist_id = album.artist_id
JOIN track
ON album.album_id = track.album_id
JOIN genre
ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY total_track DESC
LIMIT 10

--Q8. Return all the track names that have a song length longer than the average song length. 
--    Return the Name and Milliseconds for each track. Order by the song length with the 
--    longest songs listed first

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	  SELECT AVG(milliseconds) as av_length
	  FROM track)
ORDER BY milliseconds DESC

--Q9. Find how much amount spent by each customer on best artist? Write a query to return
--    customer name, artist name and total spent!

WITH best_selling_artist AS (
		SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
		SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
		FROM invoice_line
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN album ON album.album_id = track.album_id
		JOIN artist ON artist.artist_id = album.artist_id
		GROUP BY artist.artist_id
		ORDER BY total_sales DESC
		LIMIT 1)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album a ON a.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC

--Q10.  We want to find out the most popular music Genre for each country. We determine the 
--     most popular genre as the genre with the highest amount of purchases. Write a query 
--     that returns each country along with the top Genre. For countries where the maximum 
--     number of purchases is shared return all Genres

WITH popular_genre AS (
	SELECT COUNT (invoice_line.quantity) AS purchase, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER () OVER (PARTITION BY customer.country ORDER BY COUNT (invoice_line.quantity) DESC) AS RowNo
	FROM customer
	JOIN invoice ON customer.customer_id = invoice.customer_id
	JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC )
SELECT * FROM popular_genre WHERE RowNO <=1