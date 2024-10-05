import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/** IP address of the OCR service */
const SERVER_URL = "";

const OCR_URL = "http://206.87.194.232:8000/ocr";

Future<Map<String, dynamic>> getProfileMacros(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.post(
      Uri.parse('$SERVER_URL/createprofile'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}


/// Sends an HTTP POST request for OCR processing to the server
///
/// @param imageBytes  The image data to be sent for OCR processing
/// @param additionalParams  Additional parameters to include in the request
///
/// @return response object with status code and message
///      200: OCR processing was successful.
///      400: The request was malformed or invalid.
///      500: Internal server error - an unexpected error occurred on the server
///      Throws error if the request cannot be sent
///
Future<Map<String, dynamic>> sendOcrData(List<int> imageBytes) async {
  try {
    // Create a multipart request to send the image data
    var request = http.MultipartRequest('POST', Uri.parse(OCR_URL));

    // Add the image bytes as a file to the request
    request.files.add(http.MultipartFile.fromBytes(
      'image', // The key expected by the API for the image
      imageBytes,
      filename: 'receipt.jpg', // Filename to send in the request
    ));

    // Send the request and wait for the response
    final response = await request.send();

    // Read the response body as a string
    final responseBody = await response.stream.bytesToString();

    // Check the response status code
    if (response.statusCode == 200) {
      log("Server response: $responseBody");
      return jsonDecode(responseBody); // Return the decoded JSON response
    } else {
      log("Error: ${response.statusCode} : $responseBody");
      throw Exception("Error ${response.statusCode}: $responseBody");
    }
  } catch (error) {
    log("Error while sending OCR request: $error");
    rethrow;
  }
}



Future<Map<String, dynamic>> getReceiptsFromAWS(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.post(
      Uri.parse('$SERVER_URL/receipt'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getPantryFromAWS(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.post(
      Uri.parse('$SERVER_URL/pantry'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}
