<?php
// Function to ensure the directory for the given IP address exists
function ensureDirectory($ipAddress) {
    $directory = 'ClientData/' . $ipAddress;
    if (!file_exists($directory)) {
        mkdir($directory, 0777, true);
    }
    return $directory;
}

// Function to generate a unique file name if a file with the same name already exists
function generateUniqueFileName($directory, $fileName) {
    $filePath = $directory . '/' . $fileName;
    $fileInfo = pathinfo($filePath);
    $baseName = $fileInfo['filename'];
    $extension = isset($fileInfo['extension']) ? '.' . $fileInfo['extension'] : '';
    
    $counter = 1;
    while (file_exists($filePath)) {
        $filePath = $directory . '/' . $baseName . '_' . $counter . $extension;
        $counter++;
    }
    
    return $filePath;
}

// Handle the file upload
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    $ipAddress = $_SERVER['REMOTE_ADDR'];
    $uploadDirectory = ensureDirectory($ipAddress);

    $fileName = basename($_FILES['file']['name']);
    $targetFilePath = generateUniqueFileName($uploadDirectory, $fileName);

    if (move_uploaded_file($_FILES['file']['tmp_name'], $targetFilePath)) {
        echo "$fileName successfully uploaded";
    } else {
        echo "There was an error uploading the file.";
    }
} else {
    echo "No file uploaded.";
}
?>
