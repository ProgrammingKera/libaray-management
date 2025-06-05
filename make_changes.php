<?php
// Make necessary directory structure
if (!file_exists('uploads')) {
    mkdir('uploads', 0777, true);
}
if (!file_exists('uploads/ebooks')) {
    mkdir('uploads/ebooks', 0777, true);
}
if (!file_exists('uploads/covers')) {
    mkdir('uploads/covers', 0777, true);
}

echo "Initial setup completed. The Library Management System is ready to use.\n";
echo "Please visit index.php to start using the system.\n";
echo "Default librarian login:\n";
echo "Email: admin@library.com\n";
echo "Password: password123\n";
?>