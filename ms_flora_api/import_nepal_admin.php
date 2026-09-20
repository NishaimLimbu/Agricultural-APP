<?php

require_once __DIR__ . "/config/database.php";

$csvFile = "C:/Users/Asus/OneDrive/Desktop/Programming/apps/data of district/nepal_admin_import.csv";

if (!file_exists($csvFile)) {
    die("CSV file not found: " . $csvFile);
}

$handle = fopen($csvFile, "r");

if ($handle === false) {
    die("Could not open CSV file.");
}

// Remove old imported records
$conn->query("TRUNCATE TABLE nepal_admin_import");

$insert = $conn->prepare("
    INSERT INTO nepal_admin_import
    (
        province,
        district,
        local_government,
        local_government_type,
        ward_count
    )
    VALUES (?, ?, ?, ?, ?)
");

if (!$insert) {
    die("Prepare failed: " . $conn->error);
}

$line = 0;
$inserted = 0;
$errors = [];

while (($row = fgetcsv($handle)) !== false) {

    $line++;

    // Skip header
    if ($line === 1) {
        continue;
    }

    // Ignore completely empty rows
    if (count($row) === 0 || trim(implode("", $row)) === "") {
        continue;
    }

    // We need at least 5 columns
    if (count($row) < 5) {
        $errors[] = "Line $line: only " . count($row) . " columns found.";
        continue;
    }

    $province = trim($row[0]);
    $district = trim($row[1]);
    $localGovernment = trim($row[2]);
    $type = trim($row[3]);
    $wardCount = (int) trim($row[4]);

    if (
        $province === "" ||
        $district === "" ||
        $localGovernment === "" ||
        $type === "" ||
        $wardCount <= 0
    ) {
        $errors[] = "Line $line: invalid data.";
        continue;
    }

    $insert->bind_param(
        "ssssi",
        $province,
        $district,
        $localGovernment,
        $type,
        $wardCount
    );

    if ($insert->execute()) {
        $inserted++;
    } else {
        $errors[] = "Line $line: " . $insert->error;
    }
}

fclose($handle);
$insert->close();

echo "<h2>Import Complete</h2>";
echo "<p>Total CSV lines: " . $line . "</p>";
echo "<p>Successfully inserted: <strong>" . $inserted . "</strong></p>";
echo "<p>Errors: <strong>" . count($errors) . "</strong></p>";

if (!empty($errors)) {
    echo "<h3>Errors</h3>";
    echo "<pre>";
    print_r($errors);
    echo "</pre>";
}

?>