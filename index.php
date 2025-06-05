<?php
session_start();
include 'includes/config.php';

// Check if user is already logged in
if (isset($_SESSION['user_id'])) {
    // Redirect based on user role
    if ($_SESSION['role'] == 'librarian') {
        header('Location: librarian/dashboard.php');
    } else {
        header('Location: student/dashboard.php');
    }
    exit();
}

// Process login form
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = trim($_POST['email']);
    $password = $_POST['password'];
    
    // Validate input
    if (empty($email) || empty($password)) {
        $error = "Please enter both email and password";
    } else {
        // Prepare SQL statement
        $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows == 1) {
            $user = $result->fetch_assoc();
            if (password_verify($password, $user['password'])) {
                // Set session variables
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['name'] = $user['name'];
                $_SESSION['email'] = $user['email'];
                $_SESSION['role'] = $user['role'];
                
                // Redirect based on role
                if ($user['role'] == 'librarian') {
                    header('Location: librarian/dashboard.php');
                } else {
                    header('Location: student/dashboard.php');
                }
                exit();
            } else {
                $error = "Invalid password";
            }
        } else {
            $error = "User not found";
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Library Management System - Login</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="login-page">
    <div class="login-container">
        <div class="login-header">
            <h1><i class="fas fa-book-reader"></i> Library Management System</h1>
            <p>Access your library dashboard</p>
        </div>
        
        <div class="login-form">
            <?php if (isset($error)): ?>
                <div class="alert alert-danger"><?php echo $error; ?></div>
            <?php endif; ?>
            
            <form method="POST" action="">
                <div class="form-group">
                    <label for="email"><i class="fas fa-envelope"></i> Email</label>
                    <input type="email" id="email" name="email" required>
                </div>
                
                <div class="form-group">
                    <label for="password"><i class="fas fa-lock"></i> Password</label>
                    <input type="password" id="password" name="password" required>
                </div>
                
                <button type="submit" class="btn btn-primary btn-block">
                    <i class="fas fa-sign-in-alt"></i> Login
                </button>
            </form>
            
            <div class="login-footer">
                <p>&copy; 2025 Library Management System</p>
            </div>
        </div>
    </div>
    
    <script src="js/main.js"></script>
</body>
</html>