import 'dart:convert';
import 'dart:io';

void main() {
  print('🔍 Verifying OAuth Configuration...\n');
  
  // Read google-services.json
  final file = File('android/app/google-services.json');
  if (!file.existsSync()) {
    print('❌ google-services.json not found!');
    return;
  }
  
  final content = file.readAsStringSync();
  final json = jsonDecode(content);
  
  print('📱 Package Name: ${json['client'][0]['client_info']['android_client_info']['package_name']}');
  print('🔑 Project ID: ${json['project_info']['project_id']}');
  print('🔢 Project Number: ${json['project_info']['project_number']}\n');
  
  // Check OAuth clients
  final oauthClients = json['client'][0]['oauth_client'];
  print('🔐 OAuth Clients:');
  
  for (var client in oauthClients) {
    print('  - Client ID: ${client['client_id']}');
    print('    Type: ${client['client_type']}');
    
    if (client['android_info'] != null) {
      print('    Package: ${client['android_info']['package_name']}');
      print('    SHA-1: ${client['android_info']['certificate_hash']}');
    }
    print('');
  }
  
  // Check for both debug and release SHA-1
  final hashes = oauthClients
      .where((client) => client['android_info'] != null)
      .map((client) => client['android_info']['certificate_hash'])
      .toList();
  
  print('🔍 SHA-1 Fingerprints Found:');
  for (var hash in hashes) {
    print('  - $hash');
  }
  
  // Expected fingerprints
  const debugSha1 = '83aba5a0c1de4731470555c111ab5988144c546a';
  const releaseSha1 = 'fb094af817dd6862d7d7bf6ab208d3f7bc1fa8a9';
  
  print('\n✅ Expected SHA-1 Fingerprints:');
  print('  - Debug:  $debugSha1');
  print('  - Release: $releaseSha1');
  
  final hasDebug = hashes.contains(debugSha1);
  final hasRelease = hashes.contains(releaseSha1);
  
  print('\n📊 Status:');
  print('  - Debug SHA-1: ${hasDebug ? '✅ Found' : '❌ Missing'}');
  print('  - Release SHA-1: ${hasRelease ? '✅ Found' : '❌ Missing'}');
  
  if (!hasRelease) {
    print('\n🚨 ISSUE: Release SHA-1 fingerprint is missing!');
    print('   This is why OAuth fails in release builds.');
    print('   Please add the release SHA-1 to Firebase Console and download the updated google-services.json');
  } else {
    print('\n✅ Configuration looks good!');
  }
}
