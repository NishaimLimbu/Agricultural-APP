<?php

header("Content-Type: application/json; charset=UTF-8");

require_once "../config/database.php";

$data = json_decode(
    file_get_contents("php://input"),
    true
);

$businessId = (int)($data["business_id"] ?? 0);

$information = trim(
    $data["information"] ?? ""
);

$oneWord = trim(
    $data["one_word"] ?? ""
);

$aboutUs = trim(
    $data["about_us"] ?? ""
);

$notes = trim(
    $data["notes"] ?? ""
);

if ($businessId <= 0) {

    http_response_code(400);

    echo json_encode([
        "success" => false,
        "message" => "Business ID required"
    ]);

    exit;
}

try {

    // Check business exists

    $checkBusiness = $conn->prepare("
        SELECT id
        FROM businesses
        WHERE id = ?
        LIMIT 1
    ");

    if (!$checkBusiness) {
        throw new Exception(
            "Database query failed: " . $conn->error
        );
    }

    $checkBusiness->bind_param(
        "i",
        $businessId
    );

    $checkBusiness->execute();

    $businessResult =
        $checkBusiness->get_result();

    if ($businessResult->num_rows === 0) {

        $checkBusiness->close();

        http_response_code(404);

        echo json_encode([
            "success" => false,
            "message" => "Business not found"
        ]);

        exit;
    }

    $checkBusiness->close();


    // Check if profile already exists

    $checkProfile = $conn->prepare("
        SELECT id
        FROM business_profiles
        WHERE business_id = ?
        LIMIT 1
    ");

    if (!$checkProfile) {
        throw new Exception(
            "Profile table/query error: " . $conn->error
        );
    }

    $checkProfile->bind_param(
        "i",
        $businessId
    );

    $checkProfile->execute();

    $profileResult =
        $checkProfile->get_result();

    $exists =
        $profileResult->num_rows > 0;

    $checkProfile->close();


    // Update existing profile

    if ($exists) {

        $stmt = $conn->prepare("
            UPDATE business_profiles
            SET
                information = ?,
                one_word = ?,
                about_us = ?,
                notes = ?,
                updated_at = CURRENT_TIMESTAMP
            WHERE business_id = ?
        ");

        if (!$stmt) {
            throw new Exception(
                "Update query failed: " . $conn->error
            );
        }

        $stmt->bind_param(
            "ssssi",
            $information,
            $oneWord,
            $aboutUs,
            $notes,
            $businessId
        );

    } else {

        // Create new profile

        $stmt = $conn->prepare("
            INSERT INTO business_profiles
            (
                business_id,
                information,
                one_word,
                about_us,
                notes
            )
            VALUES
            (
                ?,
                ?,
                ?,
                ?,
                ?
            )
        ");

        if (!$stmt) {
            throw new Exception(
                "Insert query failed: " . $conn->error
            );
        }

        $stmt->bind_param(
            "issss",
            $businessId,
            $information,
            $oneWord,
            $aboutUs,
            $notes
        );
    }


    // Save profile

    if (!$stmt->execute()) {

        throw new Exception(
            "Failed to save business profile: " .
            $stmt->error
        );
    }

    $stmt->close();


    echo json_encode([
        "success" => true,
        "message" => "Business profile saved successfully"
    ]);

} catch (Exception $e) {

    http_response_code(500);

    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}