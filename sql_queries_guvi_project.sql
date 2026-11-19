USE library;

-- ==========================================
-- 1. TOP 10 MOST BORROWED BOOKS
-- ==========================================

SELECT
    b.id,
    b.title,
    COUNT(l.id) AS total_borrowings
FROM books b
JOIN copies c ON b.id = c.book_id
JOIN loans l ON c.id = l.copy_id
GROUP BY b.id, b.title
ORDER BY total_borrowings DESC
LIMIT 10;


-- ==========================================
-- 2. MOST POPULAR AUTHORS
-- Assumes a book_authors junction table
-- with book_id and author_id columns.
-- ==========================================

SELECT
    a.id,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name,
    COUNT(l.id) AS total_borrowings
FROM authors a
JOIN book_authors ba ON a.id = ba.author_id
JOIN books b ON ba.book_id = b.id
JOIN copies c ON b.id = c.book_id
JOIN loans l ON c.id = l.copy_id
GROUP BY a.id, a.first_name, a.last_name
ORDER BY total_borrowings DESC
LIMIT 10;


-- ==========================================
-- 3. CATEGORY-WISE BORROWING ANALYSIS
-- ==========================================

SELECT
    cat.name AS category,
    COUNT(l.id) AS total_borrowings
FROM categories cat
JOIN books b ON cat.id = b.category_id
JOIN copies c ON b.id = c.book_id
JOIN loans l ON c.id = l.copy_id
GROUP BY cat.id, cat.name
ORDER BY total_borrowings DESC;


-- ==========================================
-- 4. MEMBERS WHO RETURNED BOOKS LATE
-- ==========================================

SELECT
    u.first_name,
    u.last_name,
    b.title,
    l.loan_date,
    l.due_date,
    l.return_date,
    DATEDIFF(l.return_date, l.due_date) AS late_days
FROM loans l
JOIN memberships m ON l.membership_id = m.id
JOIN users u ON m.user_id = u.id
JOIN copies c ON l.copy_id = c.id
JOIN books b ON c.book_id = b.id
WHERE l.return_date > l.due_date
ORDER BY late_days DESC;


-- ==========================================
-- 5. TOTAL FINES, COLLECTED AND OUTSTANDING
-- ==========================================

SELECT
    SUM(amount) AS total_fines,
    SUM(paid_amount) AS total_collected,
    SUM(amount - paid_amount) AS outstanding_amount
FROM fines;


-- ==========================================
-- 6. MONTHLY BORROWING TREND
-- ==========================================

SELECT
    DATE_FORMAT(loan_date, '%Y-%m') AS borrowing_month,
    COUNT(*) AS total_borrowings
FROM loans
GROUP BY DATE_FORMAT(loan_date, '%Y-%m')
ORDER BY borrowing_month;


-- ==========================================
-- 7. BOOK COPY AVAILABILITY BY STATUS
-- ==========================================

SELECT
    status,
    COUNT(*) AS total_copies
FROM copies
GROUP BY status
ORDER BY total_copies DESC;


-- ==========================================
-- 8. TOP 10 MOST ACTIVE MEMBERS
-- ==========================================

SELECT
    u.id,
    CONCAT(u.first_name, ' ', u.last_name) AS member_name,
    COUNT(l.id) AS total_borrowings
FROM users u
JOIN memberships m ON u.id = m.user_id
JOIN loans l ON m.id = l.membership_id
GROUP BY u.id, u.first_name, u.last_name
ORDER BY total_borrowings DESC
LIMIT 10;


-- ==========================================
-- 9. PUBLISHER-WISE BOOK DISTRIBUTION
-- ==========================================

SELECT
    p.name AS publisher_name,
    COUNT(b.id) AS total_books
FROM publishers p
JOIN books b ON p.id = b.publisher_id
GROUP BY p.id, p.name
ORDER BY total_books DESC;


-- ==========================================
-- 10. AVERAGE BOOK BORROWING DURATION
-- ==========================================

SELECT
    AVG(DATEDIFF(return_date, loan_date)) AS average_days,
    MIN(DATEDIFF(return_date, loan_date)) AS minimum_days,
    MAX(DATEDIFF(return_date, loan_date)) AS maximum_days
FROM loans
WHERE return_date IS NOT NULL;


-- ==========================================
-- 11. AUTOMATIC FINE CALCULATION TRIGGER
-- ==========================================

DROP TRIGGER IF EXISTS calculate_fine;

DELIMITER //

CREATE TRIGGER calculate_fine
AFTER UPDATE ON loans
FOR EACH ROW
BEGIN

    DECLARE overdue_days INT;
    DECLARE fine_rate DECIMAL(14,2);
    DECLARE maximum_fine DECIMAL(14,2);
    DECLARE policy_id INT;

    IF OLD.return_date IS NULL
       AND NEW.return_date IS NOT NULL
       AND NEW.return_date > NEW.due_date THEN

        SELECT id, daily_rate, max_fine
        INTO policy_id, fine_rate, maximum_fine
        FROM fine_policies
        WHERE name = 'standard';

        SET overdue_days =
            DATEDIFF(NEW.return_date, NEW.due_date);

        INSERT INTO fines
        (
            amount,
            fine_policy_id,
            loan_id,
            paid_amount,
            status
        )
        VALUES
        (
            LEAST(overdue_days * fine_rate, maximum_fine),
            policy_id,
            NEW.id,
            0,
            'unpaid'
        );

    END IF;

END //

DELIMITER ;


-- ==========================================
-- 12. VERIFY TRIGGER
-- ==========================================

SHOW TRIGGERS;