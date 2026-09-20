<?php

header("Content-Type: application/json; charset=UTF-8");

echo json_encode([
    "success" => true,
    "app" => "MS FLORA ERP API",
    "version" => "1.0.0"
]);