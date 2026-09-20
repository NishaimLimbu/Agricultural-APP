<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(file_get_contents("php://input"), true);

$username = trim($data["username"] ?? "");
$mobile   = trim($data["mobile_no"] ?? "");
$email    = trim($data["email"] ?? "");
$password = $data["password"] ?? "";

if ($username === "" || $email === "" || $password === "") {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Username, email and password are required"
    ]);

    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Invalid email address"
    ]);

    exit;
}

if (strlen($password) < 6) {
    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Password must contain at least 6 characters"
    ]);

    exit;
}

/* Check existing email */

$stmt = $conn->prepare(
    "SELECT id FROM users WHERE email = ? LIMIT 1"
);

$stmt->bind_param("s", $email);
$stmt->execute();

$result = $stmt->get_result();

if ($result->num_rows > 0) {

    http_response_code(409);

    echo json_encode([
        "success" => false,
        "message" => "Email already registered"
    ]);

    exit;
}

$stmt->close();

/* Hash password */

$passwordHash = password_hash(
    $password,
    PASSWORD_DEFAULT
);

/* Create user */

$stmt = $conn->prepare(
    "INSERT INTO users
    (username, mobile_no, email, password_hash)
    VALUES (?, ?, ?, ?)"
);

$stmt->bind_param(
    "ssss",
    $username,
    $mobile,
    $email,
    $passwordHash
);

if (!$stmt->execute()) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => "Failed to create account: " . $stmt->error
    ]);

    exit;
}

$userId = $conn->insert_id;

$stmt->close();

echo json_encode([
    "success" => true,
    "message" => "Account created successfully",
    "user_id" => (int)$userId,
    "username" => $username,
    "email" => $email
]);