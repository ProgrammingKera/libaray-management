<?php
// Include header
include_once '../includes/header.php';

// Check if user is a student or faculty
if ($_SESSION['role'] != 'student' && $_SESSION['role'] != 'faculty') {
    header('Location: ../index.php');
    exit();
}

// Basic student dashboard with issued books
$userId = $_SESSION['user_id'];

// Get issued books
$issuedBooks = [];
$sql = "
    SELECT ib.*, b.title, b.author
    FROM issued_books ib
    JOIN books b ON ib.book_id = b.id
    WHERE ib.user_id = ? AND (ib.status = 'issued' OR ib.status = 'overdue')
    ORDER BY ib.return_date ASC
";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$result = $stmt->get_result();
if ($result) {
    while ($row = $result->fetch_assoc()) {
        $issuedBooks[] = $row;
    }
}
?>

<h1 class="page-title">Student Dashboard</h1>

<p class="text-center">This is a basic student dashboard. The project requirement is to focus on the librarian screens only.</p>

<div class="card">
    <div class="card-header">
        <h3>My Issued Books</h3>
    </div>
    <div class="card-body">
        <?php if (count($issuedBooks) > 0): ?>
            <div class="table-container">
                <table class="table table-striped">
                    <thead>
                        <tr>
                            <th>Book Title</th>
                            <th>Author</th>
                            <th>Issue Date</th>
                            <th>Due Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($issuedBooks as $book): ?>
                            <tr>
                                <td><?php echo htmlspecialchars($book['title']); ?></td>
                                <td><?php echo htmlspecialchars($book['author']); ?></td>
                                <td><?php echo date('M d, Y', strtotime($book['issue_date'])); ?></td>
                                <td><?php echo date('M d, Y', strtotime($book['return_date'])); ?></td>
                                <td>
                                    <?php 
                                    $today = new DateTime();
                                    $dueDate = new DateTime($book['return_date']);
                                    if ($today > $dueDate) {
                                        echo '<span class="badge badge-danger">Overdue</span>';
                                    } else {
                                        echo '<span class="badge badge-primary">Issued</span>';
                                    }
                                    ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php else: ?>
            <p class="text-center">You don't have any books issued currently.</p>
        <?php endif; ?>
    </div>
</div>

<?php
// Include footer
include_once '../includes/footer.php';
?>